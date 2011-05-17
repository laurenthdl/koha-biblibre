#!/usr/bin/perl

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

checkexpiration.pl

=head1 DESCRIPTION

This script check what subscription will expire before C<$datenumber $datelimit>

=head1 PARAMETERS

=over 4

=item title
    To filter subscription on title

=item issn
    To filter subscription on issn

=item date
The date to filter on.

=back

=cut

use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Serials;    # GetExpirationDate
use C4::Output;
use C4::Context;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Branch;
use Date::Calc qw/Today Date_to_Days/;

my $query = new CGI;

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {   template_name   => "serials/checkexpiration.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { serials => 'check_expiration' },
        debug           => 1,
    }
);

my $title = $query->param('title');
my $issn  = $query->param('issn');
my $branch = $query->param('branch');
my $date  = format_date_in_iso( $query->param('date') );

if ($date) {
    my @subscriptions = GetSubscriptions( $title, $issn );
    my @subscriptions_loop;

    foreach my $subscription (@subscriptions) {
        my $subscriptionid = $subscription->{'subscriptionid'};
        my $expirationdate = GetExpirationDate($subscriptionid);

        $subscription->{expirationdate} = $expirationdate;
        next if $expirationdate !~ /\d{4}-\d{2}-\d{2}/;    # next if not in ISO format.
        if($template->{'param_map'}->{'CAN_user_serials_superserials'}){
            $subscription->{'cannotedit'} = 0;
        }
        next if $subscription->{'cannotedit'};
        if (   Date_to_Days( split "-", $expirationdate ) < Date_to_Days( split "-", $date )
            && Date_to_Days( split "-", $expirationdate ) > Date_to_Days(&Today)
            && ( ($branch && $subscription->{'branchcode'} eq $branch) || !$branch) ) {
            $subscription->{expirationdate} = format_date( $subscription->{expirationdate} );
            push @subscriptions_loop, $subscription;
        }
    }

    $template->param(
        title               => $title,
        issn                => $issn,
        numsubscription     => scalar @subscriptions_loop,
        date                => format_date($date),
        subscriptions_loop  => \@subscriptions_loop,
        "BiblioDefaultView" . C4::Context->preference("BiblioDefaultView") => 1,
    );
}
$template->param( DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(), );

if($flags->{'superlibrarian'} % 2 == 1
|| $template->{'param_map'}->{'CAN_user_serials_superserials'}){
    my $branches = GetBranches();
    my $branchname;
    my @branches_loop = ();
    foreach (sort keys %$branches) {
        my $selected = 0;
        if( $branch eq $_ ){
            $selected = 1;
            $branchname = $branches->{$_}->{'branchname'};
        }
        push @branches_loop, {
            branchcode => $_,
            branchname => $branches->{$_}->{'branchname'},
            selected   => $selected,
        };
    }
    $template->param(
        branches_loop   => \@branches_loop,
        branchcode      => $branch,
        branchname      => $branchname,
    );
}

output_html_with_http_headers $query, $cookie, $template->output;
