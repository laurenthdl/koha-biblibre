#!/usr/bin/perl

# Script to move an order from a bookseller to another

# Copyright 2011 BibLibre SARL
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

use warnings;
use strict;
use CGI;

use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Acquisition;
use C4::Bookseller;
use C4::Members;
use C4::Dates qw/format_date_in_iso/;
use Date::Calc qw/Today/;

my $input = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "acqui/transferorder.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 1,
        flagsrequired   => { acquisition => 'order_manage' },
        debug           => 1,
    }
);

my $dbh = C4::Context->dbh;

my $bookselleridfrom    = $input->param('bookselleridfrom');
my $ordernumber     = $input->param('ordernumber');
my $bookselleridto  = $input->param('bookselleridto');
my $basketno        = $input->param('basketno');
my $op              = $input->param('op');
my $query           = $input->param('query');

my $booksellerfrom = GetBookSellerFromId($bookselleridfrom);
my $booksellerfromname;
if($booksellerfrom){
    $booksellerfromname = $booksellerfrom->{name};
}
my $booksellerto = GetBookSellerFromId($bookselleridto);
my $booksellertoname;
if($booksellerto){
    $booksellertoname = $booksellerto->{name};
}

# Transfer order and exit
if( $basketno && $ordernumber) {
    my ($year, $month, $day) = Today();
    my $today = "$year-$month-$day";
    my $order = GetOrder( $ordernumber );
    my $basket = GetBasket($order->{basketno});
    my $booksellerfrom = GetBookSellerFromId($basket->{booksellerid});
    my $bookselleridfrom = $booksellerfrom->{id};
    $basket = GetBasket($basketno);
    my $booksellerto = GetBookSellerFromId($basket->{booksellerid});

    $order->{internalnotes} = "Cancelled and transfered to $booksellerto->{name} on $today";
    ModOrder($order);
    DelOrder($order->{biblionumber}, $order->{ordernumber});

    delete $order->{ordernumber};
    delete $order->{datecancellationprinted};
    delete $order->{cancelledby};
    $order->{basketno} = $basketno;
    $order->{internalnotes} = "Transfered from $booksellerfrom->{name} on $today";
    NewOrder($order);
    print $input->redirect("/cgi-bin/koha/acqui/parcels.pl?supplierid=$bookselleridfrom");
    exit;
# Show open baskets for this bookseller
} elsif ( $bookselleridto && $ordernumber) {
    my $order = GetOrder( $ordernumber );
    my $basketfrom = GetBasket( $order->{basketno} );
    my $booksellerfrom = GetBookSellerFromId( $basketfrom->{booksellerid} );
    $booksellerfromname = $booksellerfrom->{name};
    my $baskets = GetBasketsByBookseller( $bookselleridto );
    my $basketscount = scalar @$baskets;
    my @basketsloop = ();
    for( my $i = 0 ; $i < $basketscount ; $i++ ){
        my %line;
        %line = %{ $baskets->[$i] };
        my $createdby = GetMember(borrowernumber => $line{authorisedby});
        $line{createdby} = "$createdby->{surname}, $createdby->{firstname}";
        push @basketsloop, \%line unless $line{closedate};
    }
    $template->param(
        show_baskets => 1,
        basketsloop => \@basketsloop,
        basketfromname => $basketfrom->{basketname},
    );
# Show pending orders
} elsif ( $bookselleridfrom && !defined $ordernumber) {
    my $pendingorders = GetPendingOrders($bookselleridfrom);
    my $orderscount = scalar @$pendingorders;
    my @ordersloop = ();
    for( my $i = 0 ; $i < $orderscount ; $i++ ){
        my %line;
        %line = %{ $pendingorders->[$i] };
        push @ordersloop, \%line;
    }
    $template->param(
        ordersloop  => \@ordersloop,
    );
# Search for booksellers to transfer from/to
} else {
    $op = '' unless $op;
    if( $op eq "do_search" ) {
        my @booksellers = GetBookSeller($query);
        $template->param(
            query => $query,
            do_search => 1,
            booksellersloop => \@booksellers,
        );
    } else {
        $template->param(
            search_form => 1,
        );
    }
}

$template->param(
    bookselleridfrom    => $bookselleridfrom,
    booksellerfromname  => $booksellerfromname,
    bookselleridto      => $bookselleridto,
    booksellertoname    => $booksellertoname,
    ordernumber         => $ordernumber,
    basketno            => $basketno,
);

output_html_with_http_headers $input, $cookie, $template->output;

