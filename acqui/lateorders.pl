#!/usr/bin/perl

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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

=head1 NAME

lateorders.pl

=head1 DESCRIPTION

this script shows late orders for a specific supplier, branch and delay
given on input arg.

=head1 CGI PARAMETERS

=over 4

=item supplierid
To know on which supplier this script have to display late order.

=item delay
To know the time boundary. Default value is 30 days.

=item branch
To know on which branch this script have to display late order.

=back

=cut

use strict;
use warnings;
use CGI;
use C4::Bookseller;
use C4::Auth;
use C4::Koha;
use C4::Output;
use C4::Context;
use C4::Acquisition;
use C4::Letters;
use C4::Branch;    # GetBranches
use C4::Budgets;
use C4::Members;

my $input = new CGI;
my ( $template, $loggedinuser, $cookie, $staff_flags ) = get_template_and_user(
    {   template_name   => "acqui/lateorders.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_receive' },
        debug           => 1,
    }
);

my $supplierid = $input->param('supplierid') || undef;    # we don't want "" or 0
my $delay      = $input->param('delay');
my $estimateddeliverydatefrom      = $input->param('estimateddeliverydatefrom');
my $estimateddeliverydateto      = $input->param('estimateddeliverydateto');
my $branch     = $input->param('branch');
my $op         = $input->param('op');
my @errors = ();
if ( defined $delay and not $delay =~ /^\d{1,3}$/ ) {
    push @errors, { delay_digits => 1, bad_delay => $delay };
}

if ( $op and $op eq "send_alert" ) {
    my @ordernums = $input->param("claim_for");    # FIXME: Fallback values?
    eval {
        SendAlerts( 'claimacquisition', \@ordernums, $input->param("letter_code") );    # FIXME: Fallback value?
        AddClaim ( $_ ) for @ordernums;
    };
    if ( $@ ) {
        $template->param(error_claim => $@);
    } else {
        $template->param(info_claim => "Emails have been sent");
    }
}

my %supplierlist = GetBooksellersWithLateOrders( $delay, $branch, C4::Dates->new($estimateddeliverydatefrom)->output("iso"), C4::Dates->new($estimateddeliverydateto)->output("iso") );
my (@sloopy);                                             # supplier loop
foreach ( keys %supplierlist ) {
    push @sloopy,
      (   ( $supplierid and $supplierid eq $_ )
        ? { id => $_, name => $supplierlist{$_}, selected => 1 }
        : { id => $_, name => $supplierlist{$_} }
      );
}
$template->param( SUPPLIER_LOOP => \@sloopy );
$template->param( Supplier => $supplierlist{$supplierid} ) if ($supplierid);

my @lateorders = GetLateOrders( $delay, $supplierid, undef, C4::Dates->new($estimateddeliverydatefrom)->output("iso"), C4::Dates->new($estimateddeliverydateto)->output("iso") );

my $total;
my @orders_loop = ();
foreach (@lateorders) {
    $total += $_->{subtotal};
    $_->{'branch'} ||= $_->{'basket_branch'};

    unless( $staff_flags->{'superlibrarian'} % 2 == 1 || $template->{param_map}->{'CAN_user_acquisition_order_claim_for_all'} ) {
        # Check if order belong to a basket the user is owner or user,
        # or if order branch is the current working branch.
        # Otherwise, the user can't claim for this order.
        my $basket = GetBasket($_->{'basketno'});
        my $basketusers = GetBasketUsers($_->{'basketno'});
        my $isabasketuser = 0;
        foreach (@$basketusers) {
            if ($_->{'borrowernumber'} == $loggedinuser) {
                $isabasketuser = 1;
                last;
            }
        }
        if($_->{'branch'} ne C4::Context->userenv->{'branch'}
        && $basket->{'authorisedby'} != $loggedinuser
        && $isabasketuser == 0) {
            next;
        }
    }
    push @orders_loop, $_;
}

my @letters;
my $letters = GetLetters("claimacquisition");
foreach ( keys %$letters ) {
    push @letters, { code => $_, name => $letters->{$_} };
}
$template->param( letters => \@letters ) if (@letters);

$template->param( ERROR_LOOP => \@errors ) if (@errors);
$template->param(
    lateorders              => \@orders_loop,
    delay                   => $delay,
    estimateddeliverydatefrom   => $estimateddeliverydatefrom,
    estimateddeliverydateto   => $estimateddeliverydateto,
    total                   => $total,
    intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
);
output_html_with_http_headers $input, $cookie, $template->output;
