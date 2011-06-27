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

subscription-frequencies.pl

=head1 DESCRIPTION

Manage subscription frequencies

=cut

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Output;

use C4::Serials;
use C4::Serials::Frequency;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'serials/subscription-frequencies.tmpl',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'serials' => '*' },
    debug           => 1,
} );

my $op = $input->param('op');

if($op && ($op eq 'new' || $op eq 'mod')) {
    my @units_loop;
    push @units_loop, {val => $_} for (qw/ day week month year /);

    if($op eq 'mod') {
        my $frequencyid = $input->param('frequencyid');
        my $frequency = GetSubscriptionFrequency($frequencyid);
        foreach (@units_loop) {
            if($_->{'val'} eq $frequency->{'unit'}) {
                $_->{'selected'} = 1;
                last;
            }
        }
        $template->param( %$frequency );
    }

    $template->param(
        units_loop => \@units_loop,
        new_or_mod => 1,
        $op        => 1,
    );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

if($op && $op eq 'savenew') {
    my $frequency;
    foreach (qw/ description unit issuesperunit unitsperissue expectedissuesayear displayorder /) {
        $frequency->{$_} = $input->param($_);
    }
    AddSubscriptionFrequency($frequency);
} elsif($op && $op eq 'savemod') {
    my $frequency;
    foreach (qw/ id description unit issuesperunit unitsperissue expectedissuesayear displayorder /) {
        $frequency->{$_} = $input->param($_);
    }
    ModSubscriptionFrequency($frequency);
} elsif($op && $op eq 'del') {
    my $frequencyid = $input->param('frequencyid');

    DelSubscriptionFrequency($frequencyid);
}


my @frequencies = GetSubscriptionFrequencies();

$template->param(
    $op => 1,
    new_or_mod => ($op && ($op eq 'new' || $op eq 'mod')) ? 1 : 0,
    frequencies_loop => \@frequencies,
);

output_html_with_http_headers $input, $cookie, $template->output;
