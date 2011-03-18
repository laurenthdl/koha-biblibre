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

my $input = new CGI;
my $dbh   = C4::Context->dbh;

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

output_html_with_http_headers $input, $cookie, $template->output;
