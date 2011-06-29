#!/usr/bin/perl

# Copyright 2011 BibLibre SARL
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

late_returns.pl

=head1 DESCRIPTION

Report that show items which were returned in late.

=cut

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Output;

use C4::Members;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'reports/late_returns.tmpl',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'reports' => 'execute_reports' },
    debug           => 1,
} );

my $op = $input->param('op');

if($op eq "execute") {
    my $borrowernumber = $input->param('borrowernumber');
    if(!defined $borrowernumber || $borrowernumber eq '') {
        print $input->redirect("/cgi-bin/koha/reports/late_returns.pl");
        exit;
    }
    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT date_due, returndate, DATEDIFF(returndate, date_due) AS dayslate,
               title, author
        FROM old_issues
            LEFT JOIN items ON old_issues.itemnumber = items.itemnumber
            LEFT JOIN biblio ON items.biblionumber = biblio.biblionumber
        WHERE old_issues.borrowernumber = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    my $results = $sth->fetchall_arrayref( {} );
    $sth->finish;
    my @issues_loop = ();
    foreach (@$results) {
        my %line = %{ $_ };
        $line{'dayslate'} = 0 if($line{'dayslate'} < 0);
        $line{'late'} = 1 if($line{'dayslate'} > 0);
        $line{'date_due'} = C4::Dates->new($line{'date_due'}, "iso")->output();
        $line{'returndate'} = C4::Dates->new($line{'returndate'}, "iso")->output();
        push @issues_loop, \%line;
    }

    $query = qq{
        SELECT surname, firstname
        FROM borrowers
        WHERE borrowernumber = ?
    };
    $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    my $borrowerinfos = $sth->fetchrow_hashref();
    $sth->finish;

    $template->param(
        display_report => 1,
        issues_loop => \@issues_loop,
        surname => $borrowerinfos->{'surname'},
        firstname => $borrowerinfos->{'firstname'},
    );
} elsif ($op eq "search") {
    my $search = $input->param('search');
    my ($resultscount, $results) = SearchMember($search, "surname,firstname");
    if($resultscount == 1){
        print $input->redirect("/cgi-bin/koha/reports/late_returns.pl?op=execute&borrowernumber=".$results->[0]->{'borrowernumber'});
        exit;
    }
    $template->param(
        display_borrowers_search_results => 1,
        results_loop => $results,
        search => $search,
    );
} else {
    $template->param(
        display_borrowers_search_form => 1,
    );
}

output_html_with_http_headers $input, $cookie, $template->output;
