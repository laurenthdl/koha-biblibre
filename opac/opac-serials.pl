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
use Data::Pagination;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'opac-serials.tmpl',
    query           => $input,
    type            => 'opac',
    authnotrequired => 1,
    debug           => 1,
} );

my $letter = $input->param('letter');

my $srt_title_indexname = 'srt_'.C4::Search::Query::getIndexName('title');
my $isserial_indexname = C4::Search::Query::getIndexName('is-serial');
my $sort_by = C4::Search::Query::getIndexName('title')." asc";

my @letters = qw(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z);
my @letters_loop = ();
foreach (@letters) {
    my %row = (
        letter => $_,
        active => ($letter && $_ eq $letter),
        count => 1,
    );

    # NOTE: This can be uncommented to disable letters that
    # have no results
    #my $q = "( $srt_title_indexname:".uc($_)."*"
    #    ." OR $srt_title_indexname:".lc($_)."* )"
    #    ." AND $isserial_indexname:1";
    #my $res = SimpleSearch($q, undef, 1, 1);
    #$row->{'count'} = scalar @{ $res->{'items'} };

    push @letters_loop, \%row;
}

if($letter) {
    my $page = $input->param('page') || 1;
    my $count = C4::Context->preference('OPACnumSearchResults') || 20;
    my $q = "( $srt_title_indexname:".uc($letter)."*"
        ." OR $srt_title_indexname:".lc($letter)."* )"
        ." AND $isserial_indexname:1";
    my $res = SimpleSearch($q, undef, $page, $count, $sort_by);

    my @results_loop;
    foreach (@{$res->{'items'}}) {
        my $recordid = $_->{'values'}->{'recordid'};
        my $record = C4::Search::getItemsInfos($recordid, 'opac', {}, {}, {}, {});
        push @results_loop, $record;
    }

    $template->param(
        results_loop => \@results_loop,
    );

    my $total = $res->{'pager'}->{'total_entries'};
    my $pager = Data::Pagination->new(
        $total,
        $count,
        20,
        $page,
    );
    my @follower_params;
    push @follower_params, {
        ind => 'letter',
        val => $letter,
    };
    $template->param(
        previous_page   => $pager->{'prev_page'},
        next_page       => $pager->{'next_page'},
        PAGE_NUMBERS    => [ map { { page => $_, current => $_ == $page } } @{ $pager->{'numbers_of_set'} } ],
        current_page    => $page,
        follower_params => \@follower_params,
    );
}

$template->param(
    letters_loop => \@letters_loop,
    letter => $letter,
);

output_html_with_http_headers $input, $cookie, $template->output;
