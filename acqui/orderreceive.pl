#!/usr/bin/perl

#script to recieve orders
#written by chris@katipo.co.nz 24/2/2000

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

orderreceive.pl

=head1 DESCRIPTION
This script shows all order already receive and all pendings orders.
It permit to write a new order as 'received'.

=head1 CGI PARAMETERS

=over 4

=item supplierid
to know on what supplier this script has to display receive order.

=item receive

=item invoice
the number of this invoice.

=item freight

=item biblio
The biblionumber of this order.

=item datereceived

=item catview

=item gst

=back

=cut

use strict;

#use warnings; FIXME - Bug 2505
use CGI;
use C4::Context;
use C4::Koha;    # GetKohaAuthorisedValues GetItemTypes
use C4::Acquisition;
use C4::Auth;
use C4::Output;
use C4::Dates qw/format_date/;
use C4::Bookseller;
use C4::Members;
use C4::Branch;    # GetBranches
use C4::Items;
use C4::Biblio;
use C4::Suggestions;

my $input = new CGI;

my $dbh          = C4::Context->dbh;
my $supplierid   = $input->param('supplierid');
my $ordernumber  = $input->param('ordernumber');
my $search       = $input->param('receive');
my $invoice      = $input->param('invoice');
my $freight      = $input->param('freight');
my $datereceived = $input->param('datereceived');

$datereceived = $datereceived ? C4::Dates->new( $datereceived, 'iso' ) : C4::Dates->new();

my $bookseller = GetBookSellerFromId($supplierid);
my $results    = SearchOrder( $ordernumber, $search );

my $count = scalar @$results;
my $order = GetOrder($ordernumber);
my $gstrate = $order->{gstrate} || $bookseller->{gstrate} || C4::Context->preference("gist") || 0;

my $date = $order->{'entrydate'};

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "acqui/orderreceive.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_receive' },
        debug           => 1,
    }
);

# prepare the form for receiving
if ( $count == 1 ) {
    my $order = $order;
    if ( C4::Context->preference('AcqCreateItem') eq 'receiving' ) {

        # prepare empty item form
        my $cell = PrepareItemrecordDisplay( '', '', '', 'ACQ' );
        unless ($cell) {
            $cell = PrepareItemrecordDisplay( '', '', '', '' );
            $template->param( 'NoACQframework' => 1 );
        }
        my @itemloop;
        push @itemloop, $cell;

        $template->param( items => \@itemloop );
    }

    $order->{quantityreceived} = '' if $order->{quantityreceived} == 0;
    $order->{unitprice} = '' if $order->{unitprice} == 0;

    my $rrp;
    my $ecost;
    my $unitprice;
    if ( $bookseller->{listincgst} ) {
        if ( $bookseller->{invoiceincgst} ) {
            $rrp = $order->{rrp};
            $ecost = $order->{ecost};
            $unitprice = $order->{unitprice};
        } else {
            $rrp = $order->{rrp} / ( 1 + $order->{gstrate} );
            $ecost = $order->{ecost} / ( 1 + $order->{gstrate} );
            $unitprice = $order->{unitprice} / ( 1 + $order->{gstrate} );
        }
    } else {
        if ( $bookseller->{invoiceincgst} ) {
            $rrp = $order->{rrp} * ( 1 + $order->{gstrate} );
            $ecost = $order->{ecost} * ( 1 + $order->{gstrate} );
            $unitprice = $order->{unitprice} * ( 1 + $order->{gstrate} );
        } else {
            $rrp = $order->{rrp};
            $ecost = $order->{ecost};
            $unitprice = $order->{unitprice};
        }
    }
    my $suggestion   = GetSuggestionInfoFromBiblionumber($order->{'biblionumber'});

    $template->param(
        count                 => 1,
        biblionumber          => $order->{'biblionumber'},
        ordernumber           => $order->{'ordernumber'},
        biblioitemnumber      => $order->{'biblioitemnumber'},
        supplierid            => $supplierid,
        freight               => $freight,
        gstrate               => $gstrate,
        name                  => $bookseller->{'name'},
        date                  => format_date($date),
        title                 => $order->{'title'},
        author                => $order->{'author'},
        copyrightdate         => $order->{'copyrightdate'},
        isbn                  => $order->{'isbn'},
        seriestitle           => $order->{'seriestitle'},
        bookfund              => $order->{'bookfundid'},
        quantity              => $order->{'quantity'},
        quantityreceivedplus1 => $order->{'quantityreceived'} + 1,
        quantityreceived      => $order->{'quantityreceived'},
        rrp                   => sprintf( "%.2f", $rrp ),
        ecost                 => sprintf( "%.2f", $ecost ),
        unitprice             => $unitprice,
        invoice               => $invoice,
        datereceived          => $datereceived->output(),
        datereceived_iso      => $datereceived->output('iso'),
        notes                 => $order->{notes},
        suggestionid          => $$suggestion{suggestionid},
        surnamesuggestedby    => $$suggestion{surnamesuggestedby},
        firstnamesuggestedby  => $$suggestion{firstnamesuggestedby},
    );
} else {
    my @loop;
    for ( my $i = 0 ; $i < $count ; $i++ ) {
        my %line = %{ @$results[$i] };

        $line{invoice}      = $invoice;
        $line{datereceived} = $datereceived->output();
        $line{freight}      = $freight;
        $line{gstrate}      = $gstrate;
        $line{title}        = @$results[$i]->{'title'};
        $line{author}       = @$results[$i]->{'author'};
        $line{supplierid}   = $supplierid;
        push @loop, \%line;
    }

    $template->param(
        loop       => \@loop,
        supplierid => $supplierid,
    );
}
my $op = $input->param('op');
if ( $op eq 'edit' ) {
    $template->param( edit => 1 );
}
output_html_with_http_headers $input, $cookie, $template->output;
