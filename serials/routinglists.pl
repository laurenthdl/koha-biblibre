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

routinglists.pl

=head1 DESCRIPTION

View all routing lists for a subscription

=cut

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Output;

use C4::Biblio;
use C4::Serials;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'serials/routinglists.tmpl',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'serials' => '*' },
    debug           => 1,
} );

my $subscriptionid = $input->param('subscriptionid');
my $op = $input->param('op');

if($op && $op eq "export") {
    my $routinglistid = $input->param('routinglistid');
    print $input->header(
        -type       => 'text/csv',
        -attachment => 'routinglist' . $routinglistid . '.csv',
    );
    print GetSubscriptionRoutingListAsCSV($routinglistid);
    exit;
} elsif($op && $op eq "del") {
    my $routinglistid = $input->param('routinglistid');
    if(!defined $subscriptionid){
        my $routinglist = GetSubscriptionRoutingList($routinglistid);
        $subscriptionid = $routinglist->{'subscriptionid'};
    }
    DelSubscriptionRoutingList($routinglistid);
}

my $subscription = GetSubscription($subscriptionid);
my $biblio = GetBiblio($subscription->{'biblionumber'});
my $routinglists = GetSubscriptionRoutingLists($subscriptionid);

$template->param(
    subscriptionid => $subscriptionid,
    routinglists_loop => $routinglists,
    routing => scalar(@$routinglists),
    title => $biblio->{'title'},
);

output_html_with_http_headers $input, $cookie, $template->output;
