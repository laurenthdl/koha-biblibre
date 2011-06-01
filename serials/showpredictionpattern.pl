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

showpredictionpattern.pl

=head1 DESCRIPTION

This script calculate numbering of serials based on numbering pattern, and
publication date, based on frequency and first publication date.

=cut

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Output;
use C4::Serials;
use C4::Serials::PredictiveModel;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'serials/showpredictionpattern.tmpl',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'catalogue' => '*' },
    debug           => 1,
} );

my $frequencyid = $input->param('frequency');
my $numberpatternid = $input->param('numberpattern');
my $lastvaluetemp1 = $input->param('lastvaluetemp1');
my $lastvaluetemp2 = $input->param('lastvaluetemp2');
my $lastvaluetemp3 = $input->param('lastvaluetemp3');
my $firstacquidate = $input->param('firstacquidate');

my $predictivemodel = ComputePredictiveModel($frequencyid, $numberpatternid,
                        $lastvaluetemp1, $lastvaluetemp2, $lastvaluetemp3);

my %val = (
    locale          => "en-GB",
    numberpattern   => $numberpatternid,
    numberingmethod => $predictivemodel->{'numberingmethod'},
    numbering1      => $predictivemodel->{'numbering1'},
    numbering2      => $predictivemodel->{'numbering2'},
    numbering3      => $predictivemodel->{'numbering3'},
    lastvalue1      => $predictivemodel->{'lastvalue1'},
    lastvalue2      => $predictivemodel->{'lastvalue2'},
    lastvalue3      => $predictivemodel->{'lastvalue3'},
    add1            => $predictivemodel->{'add1'},
    add2            => $predictivemodel->{'add2'},
    add3            => $predictivemodel->{'add3'},
    whenmorethan1   => $predictivemodel->{'whenmorethan1'},
    whenmorethan2   => $predictivemodel->{'whenmorethan2'},
    whenmorethan3   => $predictivemodel->{'whenmorethan3'},
    setto1          => $predictivemodel->{'setto1'},
    setto2          => $predictivemodel->{'setto2'},
    setto3          => $predictivemodel->{'setto3'},
    every1          => $predictivemodel->{'every1'},
    every2          => $predictivemodel->{'every2'},
    every3          => $predictivemodel->{'every3'},
    innerloop1      => $predictivemodel->{'innerloop1'},
    innerloop2      => $predictivemodel->{'innerloop2'},
    innerloop3      => $predictivemodel->{'innerloop3'},
);
my %subscription = (
    irregularity    => '',
    periodicity     => $frequencyid,
    countissuesperunit  => 0,
);
my $date = C4::Dates->new("2000-01-23", "iso");
my @predictions_loop;
my ($calculated) = GetSeq(\%val);
push @predictions_loop, {
    number => $calculated,
    publicationdate => $date->output(),
};
for( my $i = 1 ; $i < 20 ; $i++){
    ($calculated, $val{'lastvalue1'}, $val{'lastvalue2'}, $val{'lastvalue3'}, $val{'innerloop1'}, $val{'innerloop2'}, $val{'innerloop3'}) = GetNextSeq(\%val);
    $date = GetNextDate($date->output(), \%subscription, 1);
    push @predictions_loop, {
        number => $calculated,
        publicationdate => $date->output(),
    };
}

$template->param(
    predictions_loop => \@predictions_loop,
    calcnumberpattern    => $numberpatternid,
    calcnumberingmethod  => $predictivemodel->{'numberingmethod'},
    calclastvalue1       => $predictivemodel->{'lastvalue1'},
    calclastvalue2       => $predictivemodel->{'lastvalue2'},
    calclastvalue3       => $predictivemodel->{'lastvalue3'},
    calcinnerloop1       => $predictivemodel->{'innerloop1'},
    calcinnerloop2       => $predictivemodel->{'innerloop2'},
    calcinnerloop3       => $predictivemodel->{'innerloop3'},
    calcadd1             => $predictivemodel->{'add1'},
    calcadd2             => $predictivemodel->{'add2'},
    calcadd3             => $predictivemodel->{'add3'},
    calcsetto1           => $predictivemodel->{'setto1'},
    calcsetto2           => $predictivemodel->{'setto2'},
    calcsetto3           => $predictivemodel->{'setto3'},
    calcevery1           => $predictivemodel->{'every1'},
    calcevery2           => $predictivemodel->{'every2'},
    calcevery3           => $predictivemodel->{'every3'},
    calcwhenmorethan1    => $predictivemodel->{'whenmorethan1'},
    calcwhenmorethan2    => $predictivemodel->{'whenmorethan2'},
    calcwhenmorethan3    => $predictivemodel->{'whenmorethan3'},
);

output_html_with_http_headers $input, $cookie, $template->output;
