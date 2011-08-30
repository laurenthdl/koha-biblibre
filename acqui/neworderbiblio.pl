#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2008-2009 BibLibre SARL
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

neworderbiblio.pl

=head1 DESCRIPTION

this script allows to perform a new order from an existing record.

=head1 CGI PARAMETERS

=over 4

=item search
the title the librarian has typed to search an existing record.

=item q
the keyword the librarian has typed to search an existing record.

=item author
the author of the new record.

=item num
the number of result per page to display

=item booksellerid
the id of the bookseller this script has to add an order.

=item basketno
the basket number to know on which basket this script have to add a new order.

=back

=cut

use strict;

#use warnings; FIXME - Bug 2505

use CGI;
use C4::Search;
use Data::Pagination;
use C4::Bookseller;
use C4::Biblio;
use C4::Auth;
use C4::Output;
use C4::Koha;
use C4::Search::Query;

my $input = new CGI;
my $params = $input->Vars;

my $query            = $params->{'q'}    || '*:*';
my $booksellerid     = $params->{'booksellerid'};
my $basketno         = $params->{'basketno'};
my $bookseller       = GetBookSellerFromId( $booksellerid );

my ( $template, $loggedinuser, $cookie ) = get_template_and_user( {
    template_name   => "acqui/neworderbiblio.tmpl",
    query           => $input,
    type            => "intranet",
    authnotrequired => 0,
    flagsrequired   => { acquisition => 'order_manage' },
} );

$template->param(
    basketno      => $basketno,
    booksellerid  => $bookseller->{'id'},
    name          => $bookseller->{'name'},
    query         => $query,
);

output_html_with_http_headers $input, $cookie, $template->output;
