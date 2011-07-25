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

opac-serials.pl

=head1 DESCRIPTION

Show all serials, classified by first letter

=cut

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;

use C4::Search;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'opac-serials.tmpl',
    query           => $input,
    type            => 'opac',
    authnotrequired => 1,
    debug           => 1,
} );

my $letter = $input->param('letter');

my $dbh = C4::Context->dbh;
my $query = qq{
    SELECT COUNT(*)
    FROM subscription
        LEFT JOIN biblio USING (biblionumber)
    WHERE title LIKE ?
};
my $sth = $dbh->prepare($query);

my @letters = qw(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z);
my @letters_loop = ();
foreach (@letters) {
    $sth->execute("$_%");
    my ($count) = $sth->fetchrow_array;
    push @letters_loop, {
        letter => $_,
        count => $count,
        active => ($_ eq $letter) ? 1 : 0,
    };
}

my $query = qq{
    SELECT biblio.*, biblioitems.issn, subscription.branchcode
    FROM subscription
        LEFT JOIN biblio USING (biblionumber)
        LEFT JOIN biblioitems USING (biblionumber)
    WHERE title LIKE ?
};
my $sth = $dbh->prepare($query);
$sth->execute("$letter%");
my $results = $sth->fetchall_arrayref({});
my @results_loop;
foreach (@$results) {
    push @results_loop, C4::Search::getItemsInfos($_->{'biblionumber'}, 'opac', {}, {}, {}, {});
}

$template->param(
    letters_loop => \@letters_loop,
    letter => $letter,
    results_loop => \@results_loop,
);

output_html_with_http_headers $input, $cookie, $template->output;
