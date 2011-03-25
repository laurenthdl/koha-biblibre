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
use YAML;
use Net::Ping;
use C4::Scheduler;
use POSIX qw(strftime);


my $input       = new CGI;
my $dbh         = C4::Context->dbh;
my $CONFIG_NAME = $ENV{'KOHA_CONF'};
my $base        = C4::Context->config('intranetdir');
my $ksspath     = '../Koha_Synchronize_System/';
my $conf        = YAML::LoadFile($ksspath . 'conf/kss.yaml');
my $manual      = $input->param('manual');

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

# If connection test is ok
if ($pingresult) {

    my $options = '';
    my $scheduledcommand = "EXPORT KOHA_CONF=\"$CONFIG_NAME\"; " . $base . "/Koha_Synchronize_System/tools/kss.pl $options";
    my $manualcommand = $ksspath . 'tools/kss.pl ' . $options;
    #my $manualcommand = $base . '/Koha_Synchronize_System/tools/kss.pl ' . $options;
    # Deleting next sync if it already has been scheduled
    remove_at_job_by_tag($scheduledcommand);

    # And the user asked for a manual execution
    if ($manual == 1) {

	my @output = qx{$manualcommand};
	my $tmploutput = "Execution of $manualcommand : " . join('', @output);
	$template->param('manualoutput' => $tmploutput);


    # Or a scheduled execution
    } else {

	my $date = strftime "%Y%m%d", localtime;
	$date .= $conf->{'cron'}->{'executiontime'};
	# TODO : use tomorrow's date if scheduled after midnight
	# Scheduling next execution
	my $jobid = add_at_job( $date, $scheduledcommand ) ;
	# Show execution time to the user
	$template->param(execution_time => $date) if ($jobid);

    }

}

output_html_with_http_headers $input, $cookie, $template->output;
