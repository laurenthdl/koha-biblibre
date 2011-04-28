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
use File::Slurp qw(slurp);
use File::Basename;

use Koha_Synchronize_System::tools::kss;


my $debug       = 1;
my $input       = new CGI;
my $dbh         = C4::Context->dbh;
my $CONFIG_NAME = $ENV{'KOHA_CONF'};
my $manual      = $input->param('manual');

# Getting conf
my $conf = Koha_Synchronize_System::tools::kss::get_conf();
my $kss_dir   = $$conf{path}{kss_dir};
my $koha_dir  = $$conf{path}{koha_dir};
my $ip_server = $$conf{cron}{serverhost};

# Setting ENV
my $COMMAND_EXPORT = "KOHA_CONF=\"$CONFIG_NAME\" PERL5LIB=\"$koha_dir\" ";
my $COMMAND_SUDO   = "sudo -u kss perl ";

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

# Is the server reachable?
my $ping = Net::Ping->new();
my $pingresult = $ping->ping($conf->{'cron'}->{'serverhost'});
$template->param(pingresult => $pingresult);

# Are we a master or a slave?
my $master = $$conf{cron}{master};
$template->param('master' => $master);

# Parse kss.pl --status to tell if kss is running
sub is_kss_running {
    my $kssreturn = shift;
    my $return = -1;
    $return = 1 if ($kssreturn =~ /is running$/);
    $return = 0 if ($kssreturn =~ /not running$/);
    return $return;
}

# ------
# MASTER
# ------

# If we are a master, we gather the informations for all the clients
if ($master) {

    # Is kss already running on the server ? (from the server)
    my $command = $COMMAND_EXPORT . $COMMAND_SUDO .  $$conf{path}{kss_dir} . "tools/kss.pl --status";
    my $result = qx{$command};
    my $kssalreadyrunning = is_kss_running($result);
    $template->param("KSS_already_running" => 1) if ($kssalreadyrunning);
    $template->param("KSS_already_running_unknown" => 1) if ($kssalreadyrunning == -1);

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

    # Actions

    # Process backup file
    if ($input->param("processbackup")) {

	my $lightweight_fh = $input->upload('backupfile');
        my $filename = $input->param('backupfile');
	
	# undef may be returned if it's not a valid file handle
	if (defined $lightweight_fh) {
	# Upgrade the handle to one compatible with IO::Handle:
	    my $io_handle = $lightweight_fh->handle;
	    open (OUTFILE,'>>', '/tmp/' . $filename);
	    my $buffer;
	    while (my $bytesread = $io_handle->read($buffer,1024)) {
		print OUTFILE $buffer;
	    }
	    close (OUTFILE);

	    # Moving from tmp to kss inbox
	    my $command = qx|sudo -u kss $$conf{which_cmd}{cp} /tmp/$filename $$conf{abspath}{server_inbox}|;
	    qx{$command};
	    $command = qx|$$conf{which_cmd}{rm} /tmp/$filename|;
	    qx{$command};

	    # Processing the file
	    my $command = qx|$COMMAND_EXPORT $COMMAND_SUDO $$conf{path}{kss_dir}tools/kss.pl --file $filename|; 
	    qx{$command};

	    $template->param("processbackupoutput" => "done");
	    $template->param("display_actions" => 1);

      } else {
	warn "error while getting uploaded file";
      }

    }


# -----
# SLAVE
# -----

} else {
    # And if we are a slave, we only gather our own informations

    # Is kss already running on the server?
    my $runningcommand = $COMMAND_SUDO . $$conf{path}{kss_dir} . "scripts/client/remote_kss.pl --status";
    my $result = qx{$runningcommand};
    my $kssalreadyrunning = is_kss_running($result);
    $template->param("KSS_already_running" => 1) if ($kssalreadyrunning);
    $template->param("KSS_already_running_unknown" => 1) if ($kssalreadyrunning == -1);

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


    # Actions

    # Save the current state
    if ($input->param("save")) {
	my $command = "$COMMAND_EXPORT $COMMAND_SUDO" . $$conf{path}{kss_dir} . "scripts/client/backup.pl";	
	$debug and warn "save command : $command";
	my @output = qx{$command};	

	# Last line of output is the filename to send
	$debug and warn "save results : " . Data::Dumper::Dumper(@output);
	my $file = pop(@output);
	if ($file) {
	    my $filename = basename($file);

	    # Sending file
	    print $input->header(
		-type                        => 'application/x-compressed',
		-'Content-Transfer-Encoding' => 'binary',
		-attachment                  => "$filename"
	    );
	    my $output = slurp($file); 
	    print $output;
	} else {
	    $template->param("save_error" => 1);
	    $template->param("display_actions" => 1);
	}
    }

    # Launch manual execution
    if ($input->param("manual")) {

	if ($pingresult) {

	    # Check if not already running
	    if ($kssalreadyrunning == 0) {

		# Creating backup
		my $command = "$COMMAND_EXPORT $COMMAND_SUDO" . $$conf{path}{kss_dir} . "scripts/client/backup.pl";	
		$debug and warn "save command : $command";
		qx{$command};
		
		# Sending backup
		$command = "$COMMAND_EXPORT $COMMAND_SUDO" . $$conf{path}{kss_dir} . "scripts/client/send_backups.pl";
		qx{$command};

		# Executing remote kss.pl
		$command = $COMMAND_SUDO . $$conf{path}{kss_dir} . "scripts/client/remote_kss.pl"; 
		qx{$command};

		# Getting new database
		$command = "$COMMAND_EXPORT $COMMAND_SUDO" . $$conf{path}{kss_dir} . "scripts/client/pull_new_db.pl";
		qx{$command};

		$template->param("manualoutput" => "done");

	    }

	} else {
	    $template->param("Server_unreachable" => 1);
	}

	$template->param("display_actions" => 1);
    }

}

$template->param("Debug" => $debug);
output_html_with_http_headers $input, $cookie, $template->output;
