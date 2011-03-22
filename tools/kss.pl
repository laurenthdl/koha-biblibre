#!/usr/bin/perl

# Copyright 2011 BibLibre
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

kss.pl

=head1 SYNOPSIS


=head1 DESCRIPTION

Home of the Koha Synchronize System

=head1 FUNCTIONS

=over 2

=cut

use strict;

use C4::Auth;
use C4::Context;
use C4::Output;
use CGI;
use C4::Koha;
use Schedule::Cron;
use YAML;
use Net::Ping;
use C4::Scheduler;
use POSIX qw(strftime);


my $input = new CGI;
my $dbh   = C4::Context->dbh;
my $conf  = YAML::LoadFile('../Koha_Synchronize_System/conf/kss.yaml');

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "tools/kss.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'kss' },
        debug           => 1,
    }
);

# Trying to reach the server
my $ping = Net::Ping->new();
my $pingresult = $ping->ping($conf->{'cron'}->{'serverhost'});
$template->param(pingresult => $pingresult);

# If connection test is ok, let's schedule an automatic execution
if ($pingresult) {

    my $command = 'ls';
    my $date = strftime "%Y%m%d", localtime;
    $date .= $conf->{'cron'}->{'executiontime'};
    # TODO : use tomorrow's date if scheduled after midnight
    my $jobs = get_at_jobs();
    # Deleting next sync if it already has been scheduled
    remove_at_job_by_tag($command);
    # Scheduling next execution
    my $jobid = add_at_job( $date, $command ) ;
    # Show execution time to the user
    $template->param(execution_time => $date) if ($jobid);

}

output_html_with_http_headers $input, $cookie, $template->output;
