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

ajax-getauthvaluedropbox.pl

=head1 DESCRIPTION
this script returns an authorised values dropbox

=head1 CGI PARAMETERS

=over 4

=item name
The name of the dropbox.

=item category
The category of authorised values.

=item default
Default value for the dropbox.

=back

=cut

use warnings;
use strict;

use CGI;
use C4::Budgets;

my $input = new CGI;
my $name = $input->param('name');
my $category = $input->param('category');
my $default = $input->param('default');

binmode STDOUT, ":utf8";
print $input->header(-type => 'text/plain', -charset => 'UTF-8');
print GetAuthvalueDropbox($name, $category, $default);

