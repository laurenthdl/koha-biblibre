#!/usr/bin/perl

# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

# Copyright 2007 Tamil s.a.r.l.
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

=head1 ysearch.pl


=cut

use strict;

#use warnings; FIXME - Bug 2505
use CGI;
use C4::Context;
use C4::AuthoritiesMarc;
use C4::Auth qw/check_cookie_auth/;
use Switch;

my $query = new CGI;

binmode STDOUT, ":utf8";
print $query->header( -type => 'text/plain', -charset => 'UTF-8' );

my ( $auth_status, $sessionID ) = check_cookie_auth( $query->cookie('CGISESSID'), { } );
if ( $auth_status ne "ok" ) {
    exit 0;
}

    my $searchstr = $query->param('query');
    my $searchtype = $query->param('querytype');
    my @value;
    switch ($searchtype) {
	case "marclist"      { @value = (undef, undef, $searchstr); }
	case "mainentry"     { @value = (undef, $searchstr, undef); }
	case "mainmainentry" { @value = ($searchstr, undef, undef); }
    }
    my @marclist  = ($searchtype);
    my $authtypecode = $query->param('authtypecode');
    my @and_or    = $query->param('and_or');
    my @excluding = $query->param('excluding');
    my @operator  = $query->param('operator');
    my $orderby   = $query->param('orderby');

    my $resultsperpage = 50;
    my $startfrom = 0;

    my ( $results, $total ) = SearchAuthorities( \@marclist, \@and_or, \@excluding, \@operator, \@value, $startfrom * $resultsperpage, $resultsperpage, $authtypecode, $orderby );
#    print $searchtype;
    foreach (@$results) {
	my ($value) = $_->{'summary'} =~ /<b>(.*)<\/b>/;
	print nsb_clean($value) . "\n";
    }



sub nsb_clean {
    my $NSB = '\x88' ;        # NSB : begin Non Sorting Block
    my $NSE = '\x89' ;        # NSE : Non Sorting Block end
    my $NSB2 = '\x98' ;        # NSB : begin Non Sorting Block
    my $NSE2 = '\x9C' ;        # NSE : Non Sorting Block end
    my $htmlnewline = "<br />";
    my $newline = "\n";
    # handles non sorting blocks
    my ($string) = @_ ;
    $_ = $string ;
    s/$NSB//g ;
    s/$NSE//g ;
    s/$NSB2//g ;
    s/$NSE2//g ;
    s/$htmlnewline/ /g;
    s/$newline//g;
    $string = $_ ;

    return($string) ;
}

