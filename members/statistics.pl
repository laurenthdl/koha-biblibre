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

use Modern::Perl;

use CGI;
use C4::Auth;
use C4::Branch;
use C4::Context;
use C4::Members;
use C4::Members::Statistics;
use C4::Output;

my $input       = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "members/statistics.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { borrowers => 1 },
        debug           => 1,
    }
);

my $borrowernumber = $input->param('borrowernumber');

SetMemberInfosInTemplate( $borrowernumber, $template );


my $precedent_state = GetPrecedentStateByBorrower $borrowernumber;
my $total_issues_today = GetTotalIssuesTodayByBorrower $borrowernumber;
my $total_issues_returned_today = GetTotalIssuesReturnedTodayByBorrower $borrowernumber;

$precedent_state = replace_key( $precedent_state );
$total_issues_today = replace_key( $total_issues_today );
$total_issues_returned_today = replace_key( $total_issues_returned_today );

my @datas = values %{merge( $precedent_state, $total_issues_today, $total_issues_returned_today )};

my $fields = C4::Context->preference('StatisticsFields');
my @keys = split '\|', $fields;
my @column_name = map {
    name => $_
}, @keys;


# Template engine is very stupid !
# FIXME When another tmpl engine will be use
my @real_datas;
for my $d (@datas) {
    my $hash;
    while (my ($k, $v) = each %$d) {
        my $i = 0;
        my $find = 0;
        for my $key (@keys) {
            if ($key eq $k){
                $find = 1;
                last
            }
            $i++;
        }
        if ($find) {
            $$hash{$i} = $v;
        }else{
            $$hash{$k} = $v;
        }
    }
    push @real_datas, $hash;
}

$template->param(
    statisticsview => 1,
    datas          => \@real_datas,
    column_name    => \@column_name,
    length_keys    => scalar(@keys),
);

sub replace_key {
    my $elt = shift;
    my $r;
    for my $hash ( @$elt ) {
        my $photo;
        for my $k ( keys %$hash ) {
            if ( not $k =~ /count_/ ) {
                my $v = $$hash{ $k };
                $photo .= "$v:" if $v;
            }
        }
        $photo =~ s/.$//;
        $$r{ $photo } = $hash;
    }
    return $r;
}

sub merge {
    my ( @hashes ) = @_;
    my $merged;
    for my $hash (@hashes) {
        while ( my ($id, $subhash) = each %$hash ) {
            while ( my ($key, $val) = each %$subhash ) {
                $$merged{ $id }{$key} = $val;
            }
        }
    }
    return $merged;
}


output_html_with_http_headers $input, $cookie, $template->output;
