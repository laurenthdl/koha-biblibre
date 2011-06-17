#!/usr/bin/perl

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

subscription-renew.pl

=head1 DESCRIPTION

this script renew an existing subscription.

=head1 Parameters

=over 4

=item op
op use to know the operation to do on this template.
 * renew : to renew the subscription.

Note that if op = modsubscription there are a lot of other parameters.

=item subscriptionid
Id of the subscription this script has to renew

=back

=cut

use strict;
use warnings;

use CGI;
use Carp;
use C4::Koha;
use C4::Auth;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Serials;

my $query = new CGI;

my $op             = $query->param('op') || q{};
my $subscriptionid = $query->param('subscriptionid');
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {   template_name   => "serials/subscription-renew.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { serials => 'renew_subscription' },
        debug           => 1,
    }
);

if ( $op eq "renew" ) {
    my $startdate = $query->param('startdate');
    my $firstacquidate = $query->param('firstacquidate');
    my $subtype = $query->param('subtype');
    my $sublength = $query->param('sublength');
    ReNewSubscription(
        $subscriptionid, $loggedinuser,
        format_date_in_iso($startdate),
        format_date_in_iso($firstacquidate),
        $subtype,
        $sublength
    );
    ModNextExpected($subscriptionid, C4::Dates->new($firstacquidate));
}

my $subscription = GetSubscription($subscriptionid);
if( $flags->{'superlibrarian'} == 1
 || $template->{'param_map'}->{'CAN_user_serials_superserials'}
 || !defined $subscription->{'branchcode'}
 || $subscription->{'branchcode'} eq ''
 || $subscription->{'branchcode'} eq C4::Context->userenv->{'branch'} ) {
    $subscription->{'cannotedit'} = 0;
} else {
    $subscription->{'cannotedit'} = 1;
}
if ( $subscription->{'cannotedit'} ) {
    carp "Attempt to renew subscription $subscriptionid by " . C4::Context->userenv->{'id'} . " not allowed";
    print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
}

my @subtypes = qw(issues weeks months);
my $sublength;
my @subtypes_loop;
foreach my $subtype (@subtypes) {
    my $selected;
    if($subtype eq "issues" && $subscription->{'numberlength'} > 0) {
        $selected = 1;
        $sublength = $subscription->{'numberlength'};
    } elsif($subtype eq "weeks" && $subscription->{'weeklength'} > 0) {
        $selected = 1;
        $sublength = $subscription->{'weeklength'};
    } elsif($subtype eq "months" && $subscription->{'monthlength'} > 0) {
        $selected = 1;
        $sublength = $subscription->{'monthlength'};
    }

    push @subtypes_loop, {
        value   => $subtype,
        selected => $selected,
    }
}

my $nextexpected = GetNextExpected($subscriptionid);
my $startdate = $subscription->{'enddate'} || $nextexpected->{'planneddate'}->output("iso") || POSIX::strftime("%Y-%m-%d", localtime);
$startdate = format_date($startdate);

$template->param(
    startdate => $startdate,
    subtypes_loop  => \@subtypes_loop,
    sublength      => $sublength,
    subscriptionid => $subscriptionid,
    bibliotitle    => $subscription->{bibliotitle},
    $op            => 1,
);

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;
