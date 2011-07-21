#!/usr/bin/perl
 
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use warnings;
use HTML::Template::Pro;
use CGI;
use DBI;
use YAML;

my $query = new CGI;

    my $template       = HTML::Template::Pro->new(
        filename          => "./about.tmpl",
        die_on_bad_params => 1,
        global_vars       => 1,
        case_sensitive    => 1,
        loop_context_vars => 1, # enable: __first__, __last__, __inner__, __odd__, __counter__
        path              => ["."]
    );

my $osVersion     = `uname -a`;
my $perl_path = $^X;
my $perlVersion   = $];
my $mysqlVersion  = `mysql -V`;
my $apacheVersion = (`/usr/sbin/apache2 -V`)[0] ;
my $zebraVersion = `zebraidx -V`;

    my $dbh= DBI->connect("DBI:mysql:dbname=koha;host=localhost;port=3306",
        "kohauser", "password");
my $sysprefs_arrayref = $dbh->selectall_arrayref( "SELECT * from systempreferences", {Slice =>{} });
warn Dump($sysprefs_arrayref);
$template->param(
    osVersion     => $osVersion,
    perlPath      => $perl_path,
    perlVersion   => $perlVersion,
    perlIncPath   => [ map { perlinc => $_ }, @INC ],
    mysqlVersion  => $mysqlVersion,
    apacheVersion => $apacheVersion,
    zebraVersion  => $zebraVersion,
    components  => $sysprefs_arrayref,
);


print  $query->header,$template->output;
