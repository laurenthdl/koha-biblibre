#!/usr/bin/perl

# Copyright 2009 BibLibre
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

use strict;
use warnings;

use CGI;
use Encode qw(encode);
use Switch;

use C4::Auth;
use C4::Biblio;
use C4::Items;
use C4::Output;
use C4::VirtualShelves;
use C4::Record;
use C4::Ris;
use C4::Csv;
use utf8;
my $query = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => "opac-downloadshelf.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
        flagsrequired   => { borrow => 1 },
    }
);

my $shelfid = $query->param('shelfid');
my $format  = $query->param('format');
my $dbh     = C4::Context->dbh;

if ( $shelfid && $format ) {

    my @shelf = GetShelf($shelfid);
    my ( $items, $totitems ) = GetShelfContents($shelfid);
    my $marcflavour = C4::Context->preference('marcflavour');
    my $output;

    # CSV
    if ( $format =~ /^\d+$/ ) {
        my @biblios;
        foreach (@$items) {
            push @biblios, $_->{biblionumber};
        }
        $output = marc2csv( \@biblios, $format );

        # Other formats
    } else {
        foreach my $biblio (@$items) {
            my $biblionumber = $biblio->{biblionumber};

            my $record = GetMarcBiblio($biblionumber);
            next unless $record;
            switch ($format) {
                case "iso2709" { $output .= $record->as_usmarc(); }
                case "ris"     { $output .= marc2ris($record); }
                case "bibtex"  { $output .= marc2bibtex( $record, $biblionumber ); }
            }
        }
    }

    # If it was a CSV export we change the format after the export so the file extension is fine
    $format = "csv" if ( $format =~ m/^\d+$/ );

    print $query->header(
        -type                        => 'application/octet-stream',
        -'Content-Transfer-Encoding' => 'binary',
        -attachment                  => "shelf.$format"
    );
    print $output;

} else {
    $template->param( csv_profiles => GetCsvProfilesLoop() );
    $template->param( shelfid      => $shelfid );
    output_html_with_http_headers $query, $cookie, $template->output;
}
