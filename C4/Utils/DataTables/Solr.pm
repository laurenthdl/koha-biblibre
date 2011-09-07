package C4::Utils::DataTables::Solr;

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

use Modern::Perl;
require Exporter;

use C4::Search;
use C4::Search::Query;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
    $VERSION    = 3.04,

    @ISA        = qw(Exporter);
    @EXPORT     = qw(dt_build_filters dt_build_sort);
}

sub dt_build_filters {
    my ($indexes, $values) = @_;
    my $filters = {};

    for (my $i = 0; $i < scalar(@$indexes); $i++) {
        my $idx = C4::Search::Query::getIndexName($indexes->[$i]);
        $filters->{$idx} = $values->[$i];
    }

    return $filters;
}

sub dt_build_sort {
    my ($dtparam) = @_;
    my $sort;

    my $i = 0;
    my @sorts;
    while(exists $dtparam->{'iSortCol_'.$i}){
        my $iSortCol = $dtparam->{'iSortCol_'.$i};
        my $sSortDir = $dtparam->{'sSortDir_'.$i};
        my $mDataProp = $dtparam->{'mDataProp_'.$iSortCol};
        my @sort_indexes = $dtparam->{$mDataProp.'_sorton'}
            ? split(' ', $dtparam->{$mDataProp.'_sorton'})
            : ();
        if(@sort_indexes > 0) {
            foreach (@sort_indexes) {
                my $idx = C4::Search::Query::getIndexName($_);
                push @sorts, "$idx $sSortDir";
            }
        } else {
            my $idx = C4::Search::Query::getIndexName($mDataProp);
            push @sorts, "$idx $sSortDir";
        }
        $i++;
    }

    $sort = join(',', @sorts);
    return $sort;
}

