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

kss-logs.pl

=head1 SYNOPSIS


=head1 DESCRIPTION

Shows kss log file

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
use File::Slurp qw(slurp read_file);
use File::Basename;

use Koha_Synchronize_System::tools::kss;


my $debug       = 1;
my $input       = new CGI;
my $dbh         = C4::Context->dbh;
my $CONFIG_NAME = $ENV{'KOHA_CONF'};

# Getting conf
my $conf = Koha_Synchronize_System::tools::kss::get_conf();

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "tools/kss-logs.tmpl",
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

# Getting log file
my $logfile = $$conf{abspath}{logfile_stderr};
my @logarray = reverse(read_file($logfile));
my $logcontent = join('', @logarray);


$template->param(logcontent => $logcontent);
$template->param("Debug" => $debug);
output_html_with_http_headers $input, $cookie, $template->output  unless ($input->param("save"));
