#!/usr/bin/perl

# Copyright 2011 BibLibre SARL
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

invoice.pl

=head1 DESCRIPTION

Invoice details

=cut

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Output;
use C4::Acquisition;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'acqui/invoice.tmpl',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'acquisition' => '*' },
    debug           => 1,
} );

my $invoicenumber = $input->param('invoicenumber');
my $op = $input->param('op');

if($op && $op eq 'close') {
    CloseInvoice($invoicenumber);
    my $referer = $input->referer;
    if($referer) {
        print $input->redirect($referer);
    }
}elsif($op && $op eq 'reopen') {
    ReopenInvoice($invoicenumber);
    my $referer = $input->referer;
    if($referer) {
        print $input->redirect($referer);
    }
}elsif($op && $op eq 'modbillingdate') {
    my $billingdate = $input->param('billingdate');
    ModInvoice(invoicenumber => $invoicenumber,
               billingdate   => C4::Dates->new($billingdate)->output("iso"));
    $template->param(billingdate_saved => 1);
}

my $details = GetInvoiceDetails($invoicenumber);
my @orders_loop = ();
my $orders = $details->{'orders'};
my $total = 0;
my $odd = 1;
foreach my $order (@$orders) {
    my %row = %{ $order };
    $row{'orderline'} = $row{'parent_ordernumber'};
    $row{'total_ecost'} = sprintf("%.2f", $row{'quantity'} * $row{'ecost'});
    $row{'odd'} = $odd if $odd;
    $total += $row{'total_ecost'};
    $odd = $odd ? 0 : 1;
    push @orders_loop, \%row;
}

$template->param(
    invoicenumber   => $details->{'invoicenumber'},
    suppliername    => $details->{'suppliername'},
    billingdate     => C4::Dates->new($details->{'billingdate'}, "iso")->output(),
    invoiceclosedate => $details->{'invoiceclosedate'},
    orders_loop     => \@orders_loop,
    total           => sprintf("%.2f", $total),
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
);

output_html_with_http_headers $input, $cookie, $template->output;
