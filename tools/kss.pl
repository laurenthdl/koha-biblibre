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
use Koha_Synchronize_System::tools::kss;


my $input       = new CGI;
my $dbh         = C4::Context->dbh;
my $CONFIG_NAME = $ENV{'KOHA_CONF'};
my $manual      = $input->param('manual');

# Getting conf
my $conf = Koha_Synchronize_System::tools::kss::get_conf();

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

# Are we a master or a slave?
my $master = $$conf{cron}{master};
$template->param('master' => $master);

# If we are a master, we gather the informations for all the clients
if ($master) {
   my $stats = Koha_Synchronize_System::tools::kss::get_stats($dbh);
   # Preparing loop
   my @stats_loop;
   foreach my $hostname (keys %{$stats}) {
	my @innerloop;
	push @innerloop, $stats->{$hostname};

	my $last_status     = Koha_Synchronize_System::tools::kss::get_last_status($dbh, $hostname);
	my $last_errors     = Koha_Synchronize_System::tools::kss::get_last_errors($dbh, $hostname);
	my $last_sql_errors = Koha_Synchronize_System::tools::kss::get_last_sql_errors($dbh, $hostname);
	my $last_log        = Koha_Synchronize_System::tools::kss::get_last_log($dbh, $hostname);
	my ($stats_doctype,$stats_location) = Koha_Synchronize_System::tools::kss::get_stats_details($dbh, $hostname);

	push @stats_loop, { 
	    client         => $hostname, 
	    stats          => \@innerloop, 
	    status         => $last_status, 
	    errors         => $last_errors, 
	    stats_doctype  => $stats_doctype,
	    stats_location => $stats_location,
	    sql_errors     => $last_sql_errors,
	    log_status     => $last_log->{'status'},
	    log_start      => $last_log->{'start_time'},
	    log_end        => $last_log->{'end_time'}
        };	
   }
   $template->param(stats_loop => \@stats_loop);

} else {
    # And if we are a slave, we only gather our own informations

    # What is our hostname?
    my $hostname = qx{hostname -f};
    $hostname =~ s/\s$//;
    $template->param("hostname" => $hostname);

    # Getting stats
    my $last_stats_result = Koha_Synchronize_System::tools::kss::get_stats_by_host($dbh, $hostname);
    foreach (keys %$last_stats_result) {
	$template->param('last_stats_' . $_ => $last_stats_result->{$_});
    }

    # Getting detailled stats
    my ($stats_doctype,$stats_location) = Koha_Synchronize_System::tools::kss::get_stats_details($dbh, $hostname);
    $template->param(stats_doctype => $stats_doctype, stats_location => $stats_location);

    # Getting last execution log
    my $last_log_result = Koha_Synchronize_System::tools::kss::get_last_log($dbh, $hostname);
    foreach (keys %$last_log_result) {
	$template->param('last_log_' . $_ => $last_log_result->{$_});
    }

    # Getting last execution status
    my $last_status_result = Koha_Synchronize_System::tools::kss::get_last_status($dbh, $hostname);
    $template->param(last_status_loop => $last_status_result);

    # Getting last execution errors
    my $last_errors_result = Koha_Synchronize_System::tools::kss::get_last_errors($dbh, $hostname);
    $template->param(last_errors_loop => $last_errors_result);

    # Getting last sql errors
    my $last_sql_errors_result = Koha_Synchronize_System::tools::kss::get_last_sql_errors($dbh, $hostname);
    $template->param(last_sql_errors_loop => $last_sql_errors_result);



}

# Trying to reach the server
my $ping = Net::Ping->new();
my $pingresult = $ping->ping($conf->{'cron'}->{'serverhost'});
$template->param(pingresult => $pingresult);

# If connection test is ok
if ($pingresult) {

    my $options = '';
    my $scheduledcommand = "EXPORT KOHA_CONF=\"$CONFIG_NAME\"; " . $$conf{path}{kss_dir} . "tools/kss.pl $options";
    my $manualcommand = "perl " . $$conf{path}{kss_dir} . 'tools/kss.pl ' . $options;

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
