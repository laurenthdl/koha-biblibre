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

routinglist.pl

=head1 DESCRIPTION

Create or modify a routing list

=cut

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Output;

use C4::Members;
use C4::Serials;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'serials/routinglist.tmpl',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'serials' => '*' },
    debug           => 1,
} );

my $op = $input->param('op');
my $routinglistid;

if($op && $op eq 'new') {
    my $subscriptionid = $input->param('subscriptionid');
    $template->param(
        new => 1,
        subscriptionid => $subscriptionid,
        routing => check_routing($subscriptionid),
    );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

if($op && $op eq 'savenew') {
    my $title = $input->param('title');
    my $subscriptionid = $input->param('subscriptionid');

    $routinglistid = AddSubscriptionRoutingList($subscriptionid, $title);
} else {
    $routinglistid = $input->param('routinglistid');
}

if($op && $op eq 'mod') {
    my $borrowersids = $input->param('borrowersids');
    my $notes = $input->param('notes');
    my @borrowernumbers = split /:/, $borrowersids;
    ModSubscriptionRoutingList($routinglistid, undef, undef, $notes, @borrowernumbers);
    my $routinglist = GetSubscriptionRoutingList($routinglistid);
    print $input->redirect("/cgi-bin/koha/serials/routinglists.pl?subscriptionid=".$routinglist->{'subscriptionid'});
    exit;
}

my $routinglist = GetSubscriptionRoutingList($routinglistid);
my @borrowers = getroutinglist($routinglistid);
foreach (@borrowers) {
    my $member = GetMemberDetails($_->{'borrowernumber'});
    $_->{'firstname'} = $member->{'firstname'};
    $_->{'surname'} = $member->{'surname'};
    my @ranking_loop;
    for(my $i=0; $i<scalar(@borrowers); $i++){
        my $selected;
        $selected = 1 if ($_->{'ranking'} == $i+1);
        push @ranking_loop, {
            rank => $i+1,
            selected => $selected,
        };
    }
    $_->{'ranking_loop'} = \@ranking_loop;
}

$template->param(
    borrowers_loop => \@borrowers,
    borrowersids => join(':', map ($_->{'borrowernumber'}, @borrowers)),
    max_rank => scalar(@borrowers),
    title => $routinglist->{'title'},
    notes => $routinglist->{'notes'},
    routinglistid => $routinglistid,
);

output_html_with_http_headers $input, $cookie, $template->output;
