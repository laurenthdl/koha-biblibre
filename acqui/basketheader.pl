#!/usr/bin/perl

#script to add basket and edit header options (name, notes and contractnumber)
#written by john.soros@biblibre.com 15/09/2008

# Copyright 2008 - 2009 BibLibre SARL
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

basketheader.pl

=head1 DESCRIPTION

This script is used to edit the basket's "header", or add a new basket, the header contains the supplier ID,
notes to the supplier, local notes, and the contractnumber, which identifies the basket to a specific contract.

=head1 CGI PARAMETERS

=over 4

=item supplierid

C<$supplierid> is the id of the supplier we add the basket to.

=item basketid

If it exists, C<$basketno> is the basket we edit

=back

=cut

use strict;
use warnings;
use CGI;
use C4::Context;
use C4::Auth;
use C4::Branch;
use C4::Output;
use C4::Acquisition qw/GetBasket NewBasket GetContracts ModBasketHeader/;
use C4::Bookseller qw/GetBookSellerFromId/;

my $input = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "acqui/basketheader.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_manage' },
        debug           => 1,
    }
);

#parameters:
my $booksellerid = $input->param('booksellerid');
my $basketno = $input->param('basketno');
my $branches = GetBranches;

my $basket;
my $op         = $input->param('op');
my $is_an_edit = $input->param('is_an_edit');


if ( $op eq 'add_form' ) {
    my @contractloop;
    if ($basketno) {

        #this is an edit
        $basket = GetBasket($basketno);
        if ( !$booksellerid ) {
            $booksellerid = $basket->{'booksellerid'};
        }
        @contractloop = &GetContracts( $booksellerid, 1 );
        for (@contractloop) {
            if ( $basket->{'contractnumber'} eq $_->{'contractnumber'} ) {
                $_->{'selected'} = 1;
            }
        }
        $template->param( is_an_edit => 1 );
    } else {

        #new basket
        my $basket;
        push( @contractloop, &GetContracts( $booksellerid, 1 ) );
    }
    my $bookseller = GetBookSellerFromId($booksellerid);
    my $count      = scalar @contractloop;
    if ( $count > 0 ) {
        $template->param(
            contractloop         => \@contractloop,
            basketcontractnumber => $basket->{'contractnumber'}
        );
    }
    $template->param(
        add_form             => 1,
        basketname           => $basket->{'basketname'},
        basketnote           => $basket->{'note'},
        basketbooksellernote => $basket->{'booksellernote'},
        booksellername       => $bookseller->{'name'},
        booksellerid         => $booksellerid,
        basketno             => $basketno,
        deliveryplace        => $basket->{'deliveryplace'},
        billingplace         => $basket->{'billingplace'}
    );

    my $billingplace = $basket->{'billingplace'} || C4::Context->userenv->{"branch"};
    my $deliveryplace = $basket->{'deliveryplace'} || C4::Context->userenv->{"branch"};

    # Build the combobox to select the billing place
    my @billingplaceloop;

    # In case there's no branch selected
    if ($billingplace eq "NO_LIBRARY_SET") {
        my %row = (
          value => "",
          selected => 1,
          branchname => "--",
        );
        push @billingplaceloop, \%row;
    }

    for ( sort keys %$branches ) {
        my $selected = 1 if $_ eq $billingplace;
        my %row = (
            value      => $_,
            selected   => $selected,
            branchname => $branches->{$_}->{branchname},
        );
        push @billingplaceloop, \%row;
    }
    $template->param( billingplaceloop => \@billingplaceloop );

    # Build the combobox to select the delivery place
    my @deliveryplaceloop;

    # In case there's no branch selected
    if ($deliveryplace eq "NO_LIBRARY_SET") {
        my %row = (
          value => "",
          selected => 1,
          branchname => "--",
        );
        push @deliveryplaceloop, \%row;
    }

    for ( sort keys %$branches ) {
        my $selected = 1 if $_ eq $deliveryplace;
        my %row = (
            value      => $_,
            selected   => $selected,
            branchname => $branches->{$_}->{branchname},
        );
        push @deliveryplaceloop, \%row;
    }
    $template->param( deliveryplaceloop => \@deliveryplaceloop );

    #End Edit
} elsif ( $op eq 'add_validate' ) {

    my $basketname = $input->param('basketname');
    my $basketnote = $input->param('basketnote');
    my $basketbooksellernote = $input->param('basketbooksellernote');
    my $basketcontractnumber = $input->param('basketcontractnumber');
    my $deliveryplace = $input->param('deliveryplace');
    my $billingplace = $input->param('billingplace');

    #we are confirming the changes, save the basket
    if ($is_an_edit) {
        ModBasketHeader(
            $basketno,
            $basketname,
            $basketnote,
            $basketbooksellernote,
            $basketcontractnumber,
            $deliveryplace,
            $billingplace
        );
    } else {    #New basket
        $basketno = NewBasket(
            $booksellerid, $loggedinuser,
            $basketname,
            $basketnote,
            $basketbooksellernote,
            $basketcontractnumber,
            $deliveryplace,
            $billingplace
        );
    }
    print $input->redirect( 'basket.pl?basketno=' . $basketno );
    exit 0;
}
output_html_with_http_headers $input, $cookie, $template->output;
