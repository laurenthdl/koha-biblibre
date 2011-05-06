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
use C4::Budgets;
use List::MoreUtils qw(none);

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

# Getting items
if ( C4::Context->preference('AcqCreateItem') eq 'ordering' ) {
    # now, build existiing item list
    my $biblionumber  = $order->{'biblionumber'};
    my $frameworkcode = &GetFrameworkCode($biblionumber);
    my $tagslib       = &GetMarcStructure( 1, $frameworkcode );
    my $temp          = GetMarcBiblio($biblionumber);
    my @fields        = $temp->fields();
    my @orderitems    = GetItemnumbersFromOrder($ordernumber);

    #my @fields = $record->fields();
    my %witness;    #---- stores the list of subfields used at least once, with the "meaning" of the code
    my @big_array;

    #---- finds where items.itemnumber is stored
    my ( $itemtagfield,   $itemtagsubfield )   = &GetMarcFromKohaField( "items.itemnumber", $frameworkcode );
    my ( $branchtagfield, $branchtagsubfield ) = &GetMarcFromKohaField( "items.homebranch", $frameworkcode );

    foreach my $field (@fields) {
        next if ($field->tag()<10);

        my @subf = $field->subfields or (); # don't use ||, as that forces $field->subfelds to be interpreted in scalar context
        my %this_row;
    # loop through each subfield
        my $i = 0;
        foreach my $subfield (@subf){
            my $subfieldcode = $subfield->[0];
            my $subfieldvalue= $subfield->[1];

            next if ($tagslib->{$field->tag()}->{$subfieldcode}->{tab} ne 10 
                    && ($field->tag() ne $itemtagfield 
                    && $subfieldcode   ne $itemtagsubfield));
            $witness{$subfieldcode} = $tagslib->{$field->tag()}->{$subfieldcode}->{lib} if ($tagslib->{$field->tag()}->{$subfieldcode}->{tab}  eq 10);
                    if ($tagslib->{$field->tag()}->{$subfieldcode}->{tab}  eq 10) {
                        $this_row{$subfieldcode} .= " | " if($this_row{$subfieldcode});
                    $this_row{$subfieldcode} .= GetAuthorisedValueDesc( $field->tag(),
                            $subfieldcode, $subfieldvalue, '', $tagslib) 
                                                    || $subfieldvalue;
                    }

            if (($field->tag eq $branchtagfield) && ($subfieldcode eq $branchtagsubfield) && C4::Context->preference("IndependantBranches")) {
                #verifying rights
                my $userenv = C4::Context->userenv();
                unless (($userenv->{'flags'} == 1) or (($userenv->{'branch'} eq $subfieldvalue))){
                        $this_row{'nomod'}=1;
                }
            }
            $this_row{itemnumber} = $subfieldvalue if ($field->tag() eq $itemtagfield && $subfieldcode eq $itemtagsubfield);
        }
        if (%this_row) {
            push( @big_array, \%this_row );
        }
    }

    my ( $holdingbrtagf, $holdingbrtagsubf ) = &GetMarcFromKohaField( "items.holdingbranch", $frameworkcode );
    @big_array = sort { $a->{$holdingbrtagsubf} cmp $b->{$holdingbrtagsubf} } @big_array;

    # now, construct template !
    # First, the existing items for display
    my @item_value_loop;
    my @header_value_loop;

    for my $row (@big_array) {

        # Only keeping items associated with this order
        next if (none { $row->{itemnumber} eq $_ } @orderitems);
        my %row_data;
        my @item_fields = map +{ field => $_ || '' }, @$row{ sort keys(%witness) };
        $row_data{item_value} = [@item_fields];
        $row_data{itemnumber} = $row->{itemnumber};

        #reporting this_row values
        $row_data{'nomod'} = $row->{'nomod'};
        push( @item_value_loop, \%row_data );
    }
    foreach my $subfield_code ( sort keys(%witness) ) {
        my %header_value;
        $header_value{header_value} = $witness{$subfield_code};
        push( @header_value_loop, \%header_value );
    }
    $template->param(
        item_loop        => \@item_value_loop,
        item_header_loop => \@header_value_loop,
    );
}

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
    if ( $bookseller->{listincgst} ) {
        if ( $bookseller->{invoiceincgst} ) {
            $rrp = $order->{rrp};
            $ecost = $order->{ecost};
        } else {
            $rrp = $order->{rrp} / ( 1 + $order->{gstrate} );
            $ecost = $order->{ecost} / ( 1 + $order->{gstrate} );
        }
    } else {
        if ( $bookseller->{invoiceincgst} ) {
            $rrp = $order->{rrp} * ( 1 + $order->{gstrate} );
            $ecost = $order->{ecost} * ( 1 + $order->{gstrate} );
        } else {
            $rrp = $order->{rrp};
            $ecost = $order->{ecost};
        }
    }
    my $suggestion   = GetSuggestionInfoFromBiblionumber($order->{'biblionumber'});
    my $budget       = GetBudget($order->{'budget_id'});
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
        budget_name           => $budget->{'budget_name'},
        quantity              => $order->{'quantity'},
        quantityreceivedplus1 => $order->{'quantityreceived'} + 1,
        quantityreceived      => $order->{'quantityreceived'},
        rrp                   => sprintf( "%.2f", $rrp ),
        ecost                 => sprintf( "%.2f", $ecost ),
        unitprice             => $order->{'unitprice'},
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
