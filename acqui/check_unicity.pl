#!/usr/bin/perl

# Copyright 2011 BibLibre SARL
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

use CGI;
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Budgets;
use Modern::Perl;

my $input     = new CGI;
my @field     = $input->param('field');
my @value     = $input->param('value');

my $dbh = C4::Context->dbh;

my $r;
my $index = 0;
for my $f ( @field ) {
    my $query;
    given ( $f ) {
        when ( "barcode" ) {
            $query = "SELECT barcode FROM items WHERE barcode=?";
        }
        when ( "stocknumber" ) {
            $query = "SELECT stocknumber FROM items WHERE stocknumber=?";
        }
    }

    my $sth = $dbh->prepare( $query );
    $sth->execute( $value[$index] );
    my @values = $sth->fetchrow_array;
    warn Data::Dumper::Dumper \@values;
    if ( @values ) {
        $r .= "$f:$values[0];";
    }
    $index++;
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "acqui/ajax.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        debug           => 1,
    }
);
$template->param( return => $r );

output_html_with_http_headers $input, $cookie, $template->output;
1;
