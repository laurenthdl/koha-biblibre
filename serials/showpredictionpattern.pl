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
use Date::Calc qw(Today Day_of_Year Week_of_Year Day_of_Week Days_in_Year Delta_Days Add_Delta_Days Add_Delta_YM);
use C4::Auth;
use C4::Output;
use C4::Serials;
use C4::Serials::Frequency;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'serials/showpredictionpattern.tmpl',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'serials' => '*' },
    debug           => 1,
} );

my $frequencyid = $input->param('frequency');
my $firstacquidate = $input->param('firstacquidate');
my $enddate = $input->param('enddate');
my $subtype = $input->param('subtype');
my $sublength = $input->param('sublength');
my $custompattern = $input->param('custompattern');

my $debug = 0;

if($custompattern){
    $template->param(custompattern => 1);
}

my %val = (
    locale      => "en-GB",
    numberingmethod => $input->param('numberingmethod') // '',
    numbering1      => $input->param('numbering1') // '',
    numbering2      => $input->param('numbering2') // '',
    numbering3      => $input->param('numbering3') // '',
    lastvalue1      => $input->param('lastvalue1') // '',
    lastvalue2      => $input->param('lastvalue2') // '',
    lastvalue3      => $input->param('lastvalue3') // '',
    add1            => $input->param('add1') // '',
    add2            => $input->param('add2') // '',
    add3            => $input->param('add3') // '',
    whenmorethan1   => $input->param('whenmorethan1') // '',
    whenmorethan2   => $input->param('whenmorethan2') // '',
    whenmorethan3   => $input->param('whenmorethan3') // '',
    setto1          => $input->param('setto1') // '',
    setto2          => $input->param('setto2') // '',
    setto3          => $input->param('setto3') // '',
    every1          => $input->param('every1') // '',
    every2          => $input->param('every2') // '',
    every3          => $input->param('every3') // '',
    innerloop1      => $input->param('innerloop1') // '',
    innerloop2      => $input->param('innerloop2') // '',
    innerloop3      => $input->param('innerloop3') // '',
);

my %subscription = (
    irregularity    => '',
    periodicity     => $frequencyid,
    countissuesperunit  => 0,
);

if(!defined $firstacquidate || $firstacquidate eq ''){
    my ($year, $month, $day) = Today();
    $firstacquidate = C4::Dates->new("$year-$month-$day", "iso");
} else {
    $firstacquidate = C4::Dates->new($firstacquidate);
}
my $firstacquidate_iso = $firstacquidate->output("iso");
my $date_iso = $firstacquidate_iso;
my $enddate_iso;
if($enddate){
    $enddate_iso = C4::Dates->new($enddate)->output("iso");
}
my $date = C4::Dates->new($firstacquidate->output());

my $issuenumber = 1;
my ($year, $month, $day) = split("-", $date->output("iso"));
my $frequency = GetSubscriptionFrequency($frequencyid);
if ($frequency->{'unit'} eq "day") {
    my $doy = Day_of_Year($year, $month, $day);
    $issuenumber = ($doy - 1) * $frequency->{'issuesperunit'} / $frequency->{'unitsperissue'} + 1;
} elsif ($frequency->{'unit'} eq "week") {
    my ($wkno, $yr) = Week_of_Year($year, $month, $day);
    my $issue_of_week = (Day_of_Week($year, $month, $day) - 1) / int( 7 / $frequency->{'issuesperunit'} ) + 1;
    if($issue_of_week > $frequency->{'issuesperunit'}){
        $issue_of_week = $frequency->{'issuesperunit'};
    }
    $subscription{'countissuesperunit'} = $issue_of_week - 1;
    $issuenumber = ($wkno - 1) * $frequency->{'issuesperunit'} / $frequency->{'unitsperissue'} + $issue_of_week;
} elsif ($frequency->{'unit'} eq "month") {
    $issuenumber = ($month - 1) * $frequency->{'issuesperunit'} / $frequency->{'unitsperissue'} + 1;
} elsif ( $frequency->{'unit'} eq "year") {
    $issuenumber = (Day_of_Year($year, $month, $day) - 1) / ( Days_in_Year($year, 12) / $frequency->{'issuesperunit'} ) + 1;
}
$issuenumber = int($issuenumber);

my @predictions_loop;
my ($calculated) = GetSeq(\%val);
push @predictions_loop, {
    number => $calculated,
    publicationdate => $date->output(),
    issuenumber => $issuenumber,
    dow => Day_of_Week(split /-/, $date->output("iso")),
};

my $i = 1;
while( $i < 1000 ) {
    my %line;

    if(defined $date){
        $date = GetNextDate($date->output("iso"), \%subscription, 1);
    }
    if(defined $date){
        $line{'publicationdate'} = $date->output();
        $line{'dow'} = Day_of_Week(split /-/, $date->output("iso"));
        $date_iso = $date->output("iso");
    } else {
        undef $date_iso;
    }

    # Check if we don't have exceed end date
    if($sublength){
        if($subtype eq "issues" && $i >= $sublength){
            last;
        } elsif($subtype eq "weeks" && $date_iso && Delta_Days( split(/-/, $date_iso), Add_Delta_Days( split(/-/, $firstacquidate_iso), 7*$sublength - 1 ) ) < 0) {
            last;
        } elsif($subtype eq "months" && $date_iso && (Delta_Days( split(/-/, $date_iso), Add_Delta_YM( split(/-/, $firstacquidate_iso), 0, $sublength) ) - 1) < 0 ) {
            last;
        }
    } elsif($enddate_iso && $date_iso && Delta_Days( split(/-/, $date_iso), split(/-/, $enddate_iso) ) < 0 ) {
        last;
    }

    ($calculated, $val{'lastvalue1'}, $val{'lastvalue2'}, $val{'lastvalue3'}, $val{'innerloop1'}, $val{'innerloop2'}, $val{'innerloop3'}) = GetNextSeq(\%val);
    $issuenumber++;
    $line{'number'} = $calculated;
    $line{'issuenumber'} = $issuenumber;
    push @predictions_loop, \%line;

    $i++;
}

$template->param(
    predictions_loop => \@predictions_loop,
);

if($frequency->{'unit'} eq 'day' && $frequency->{'unitsperissue'} == 1) {
    my (@mondays, @tuesdays, @wednesdays, @thursdays, @fridays, @saturdays, @sundays);
    my $i = 0;
    foreach (@predictions_loop) {
        my $date = C4::Dates->new($_->{'publicationdate'})->output("iso");
        my ($year, $month, $day) = split /-/, $date;
        my $dow = Day_of_Week($year, $month, $day);
        if($dow == 1) {
            push @mondays, $_->{'issuenumber'};
        } elsif ($dow == 2) {
            push @tuesdays, $_->{'issuenumber'};
        } elsif ($dow == 3) {
            push @wednesdays, $_->{'issuenumber'};
        } elsif ($dow == 4) {
            push @thursdays, $_->{'issuenumber'};
        } elsif ($dow == 5) {
            push @fridays, $_->{'issuenumber'};
        } elsif ($dow == 6) {
            push @saturdays, $_->{'issuenumber'};
        } elsif ($dow == 7) {
            push @sundays, $_->{'issuenumber'};
        }
    }
    $template->param(
        daily_options => 1,
        mondays     => join(":", @mondays),
        tuesdays    => join(":", @tuesdays),
        wednesdays  => join(":", @wednesdays),
        thursdays   => join(":", @thursdays),
        fridays     => join(":", @fridays),
        saturdays   => join(":", @saturdays),
        sundays     => join(":", @sundays),
    );
}


output_html_with_http_headers $input, $cookie, $template->output;
