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

# Script to export borrowers
use strict;
use warnings;

use C4::Context;
use C4::Members;
use Getopt::Long;
#use Text::CSV;

use encoding 'utf8';

# Getting parameters
my @fields;
my $show_header;
my $help;


GetOptions( 'field|f=s' => \@fields, 'header' => \$show_header, 'help|?' => \$help );
    if ($help) {
        print "\nexport_borrowers.pl [--field=field] [--field=field] [...] [ --header ]  [ > outputfile]\n\n";
        print " * --field is repeatable and has to match keys returned by the GetMemberDetails function. If no field is specified, then all fields will be used.\n";
        print " * --header displays the fields name on first row.\n";
        
        exit;
    }



# Getting borrowers
my $dbh = C4::Context->dbh;
my $query = "SELECT borrowernumber FROM borrowers ORDER BY borrowernumber";
my $sth = $dbh->prepare($query);
$sth->execute;
my $header_displayed = 0;
while (my $borrowernumber = $sth->fetchrow_array) {
    # Getting borrower details
    my $member = GetMemberDetails($borrowernumber);

    # If the user did not specify any field to export, we assume he wants them all
    @fields = keys %$member unless (@fields);

    #TODO: We could use Text::CSV here
    print join('|', @fields) . "\n" if ($show_header and not $header_displayed);
    $header_displayed = 1;
    print join('|', map { $member->{$_} || '' } @fields) . "\n";
}

