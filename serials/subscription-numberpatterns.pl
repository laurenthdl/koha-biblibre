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

subscription-numberpatterns.pl

=head1 DESCRIPTION

Manage number patterns

=cut

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Output;

use C4::Serials::Numberpattern;
use C4::Serials::Frequency;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'serials/subscription-numberpatterns.tmpl',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'serials' => '*' },
    debug           => 1,
} );

my $op = $input->param('op');

if($op && $op eq 'savenew') {
    my $label = $input->param('label');
    my $numberpattern;
    foreach(qw/ label description numberingmethod displayorder
      label1 label2 label3 add1 add2 add3 every1 every2 every3
      setto1 setto3 setto3 whenmorethan1 whenmorethan2 whenmorethan3
      numbering1 numbering2 numbering3 /) {
        $numberpattern->{$_} = $input->param($_) || undef;
    }
    my $numberpattern2 = GetSubscriptionNumberpatternByName($label);

    if(!defined $numberpattern2) {
        AddSubscriptionNumberpattern($numberpattern);
    } else {
        $op = 'new';
        $template->param(error_existing_numberpattern => 1);
        $template->param(%$numberpattern);
    }
} elsif ($op && $op eq 'savemod') {
    my $id = $input->param('id');
    my $label = $input->param('label');
    my $numberpattern = GetSubscriptionNumberpattern($id);
    my $mod_ok = 1;
    if($numberpattern->{'label'} ne $label) {
        my $numberpattern2 = GetSubscriptionNumberpatternByName($label);
        if(defined $numberpattern2 && $id != $numberpattern2->{'id'}) {
            $mod_ok = 0;
        }
    }
    if($mod_ok) {
        foreach(qw/ id label description numberingmethod displayorder
          label1 label2 label3 add1 add2 add3 every1 every2 every3
          setto1 setto3 setto3 whenmorethan1 whenmorethan2 whenmorethan3
          numbering1 numbering2 numbering3 /) {
            $numberpattern->{$_} = $input->param($_) || undef;
        }
        ModSubscriptionNumberpattern($numberpattern);
    } else {
        $op = 'mod';
        $template->param(error_existing_numberpattern => 1);
    }
}

if($op && ($op eq 'new' || $op eq 'mod')) {
    if($op eq 'mod') {
        my $id = $input->param('id');
        if(defined $id) {
            my $numberpattern = GetSubscriptionNumberpattern($id);
            $template->param(%$numberpattern);
        } else {
            $op = 'new';
        }
    }
    my @frequencies = GetSubscriptionFrequencies();
    my @subtypes;
    push @subtypes, { value => $_ } for (qw/ issues weeks months /);
    $template->param(
        new_or_mod => 1,
        $op => 1,
        frequencies_loop => \@frequencies,
        subtypes_loop => \@subtypes,
    );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

if($op && $op eq 'del') {
    my $id = $input->param('id');
    if(defined $id) {
        DelSubscriptionNumberpattern($id);
    }
}

my @numberpatterns_loop = GetSubscriptionNumberpatterns();

$template->param(
    numberpatterns_loop => \@numberpatterns_loop,
);

output_html_with_http_headers $input, $cookie, $template->output;
