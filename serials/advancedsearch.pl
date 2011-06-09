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

=head1 NAME

advancedsearch.pl

=head1 DESCRIPTION

Advanced search for the serials module

=cut

use strict;

#use warnings; FIXME - Bug 2505
use CGI;
use C4::Auth;    # get_template_and_user
use C4::Output;
use C4::Acquisition;
use C4::Dates;
use C4::Debug;
use C4::Branch;
use C4::Koha;

my $input          = new CGI;

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {   template_name   => "serials/advancedsearch.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { serials => '*' },
        debug           => 1,
    }
);


my $branches = GetBranches();
my @branches_loop;
foreach (sort keys %$branches){
    push @branches_loop, {
        branchcode  => $_,
        branchname  => $branches->{$_}->{'branchname'},
    };
}




$template->param(
    branches_loop            => \@branches_loop,
    debug                    => $debug || $input->param('debug') || 0,
);

output_html_with_http_headers $input, $cookie, $template->output;
