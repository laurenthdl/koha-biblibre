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

serials-home.pl

=head1 DESCRIPTION

this script is the main page for serials/

=head1 PARAMETERS

=over 4

=item title

=item ISSN

=item biblionumber

=back

=cut

use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Serials;
use C4::Output;
use C4::Context;
use C4::Branch;

my $query        = new CGI;
my $title        = $query->param('title_filter');
my $ISSN         = $query->param('ISSN_filter');
my $EAN          = $query->param('EAN_filter');
my $publisher    = $query->param('publisher_filter');
my $supplier     = $query->param('supplier_filter');
my $branch       = $query->param('branch_filter');
my $routing      = $query->param('routing') || C4::Context->preference("RoutingSerials");
my $searched     = $query->param('searched');
my $biblionumber = $query->param('biblionumber');

my @serialseqs     = $query->param('serialseq');
my @planneddates   = $query->param('planneddate');
my @publisheddates = $query->param('publisheddate');
my @status         = $query->param('status');
my @notes          = $query->param('notes');

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {   template_name   => "serials/serials-home.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { serials => '*' },
        debug           => 1,
    }
);

if (@serialseqs) {
    my @information;
    my $index;
    foreach my $seq (@serialseqs) {
        if ($seq) {
            ### FIXME  This limitation that a serial must be given a title may not be very efficient for some library who do not update serials titles.
            push @information,
              { serialseq     => $seq,
                publisheddate => $publisheddates[$index],
                planneddate   => $planneddates[$index],
                notes         => $notes[$index],
                status        => $status[$index]
              };
        }
        $index++;
    }
    $template->param( 'information' => \@information );
}
my @subscriptions;
if ($searched) {
    @subscriptions = SearchSubscriptions($title, $ISSN, $EAN, $publisher, $supplier, $branch);
}

my @subs_loop = ();
foreach my $sub (@subscriptions) {
    my $enddate = C4::Dates->new($sub->{'enddate'}, "iso");
    $sub->{'enddate'} = $enddate->output();

    if( $flags->{'superlibrarian'} == 1
     || $template->{'param_map'}->{'CAN_user_serials_superserials'}
     || ( $sub->{'branchcode'}
     && $sub->{'branchcode'} eq C4::Context->userenv->{'branch'} ) ) {
        $sub->{'cannotedit'} = 0;
    } else {
        $sub->{'cannotedit'} = 1;
    }
    unless($sub->{'cannotedit'}){
        push @subs_loop, $sub;
    }
}

# to toggle between create or edit routing list options
if ($routing) {
    for my $subscription (@subscriptions) {
        $subscription->{routingedit} = check_routing( $subscription->{subscriptionid} );
    }
}

my $branches = GetBranches();
my @branches_loop;
foreach (sort keys %$branches){
    my $selected = 0;
    $selected = 1 if( $branch eq $_ );
    push @branches_loop, {
        branchcode  => $_,
        branchname  => $branches->{$_}->{'branchname'},
        selected    => $selected,
    };
}

$template->param(
    subs_loop     => \@subs_loop,
    title_filter  => $title,
    ISSN_filter   => $ISSN,
    EAN_filter    => $EAN,
    publisher_filter => $publisher,
    supplier_filter  => $supplier,
    branch_filter => $branch,
    branches_loop => \@branches_loop,
    done_searched => $searched,
    routing       => $routing,
);
output_html_with_http_headers $query, $cookie, $template->output;
