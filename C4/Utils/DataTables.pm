package C4::Utils::DataTables;

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

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
    $VERSION    = 3.04,

    @ISA        = qw(Exporter);
    @EXPORT     = qw(dt_build_orderby dt_build_having);
}

=head1 NAME

C4::Utils::DataTables - Utility subs for building query when DataTables source is AJAX

=head1 SYNOPSYS

    use CGI;
    use C4::Context;
    use C4::Utils::DataTables;

    my $input = new CGI;
    my $vars = $input->Vars;

    my $query = qq{
        SELECT surname, firstname
        FROM borrowers
        WHERE borrowernumber = ?
    };
    my ($having, $having_params) = dt_build_having($vars);
    $query .= $having;
    $query .= dt_build_orderby($vars);
    $query .= " LIMIT ?,? ";

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute(
        $vars->{'borrowernumber'},
        @$having_params,
        $vars->{'iDisplayStart'},
        $vars->{'iDisplayLength'}
    );
    ...

=head1 DESCRIPTION

    This module provide two utility functions to build a part of the SQL query,
    depending on DataTables parameters.
    One function build the 'ORDER BY' part, and the other the 'HAVING' part.

=head1 FUNCTIONS

=over 2

=item dt_build_orderby

    my $orderby = dt_build_orderby($dt_param);

    This function takes a reference to a hash containing DataTables parameters
    and build the corresponding 'ORDER BY' clause.
    This hash must contains the following keys:

        iSortCol_N, where N is a number from 0 to the number of columns to sort on minus 1

        sSortDir_N is the sorting order ('asc' or 'desc) for the corresponding column

        mDataProp_N is a mapping between the column index, and the name of a SQL field

=cut

sub dt_build_orderby {
    my $param = shift;

    my $i = 0;
    my @orderbys;
    while(exists $param->{'iSortCol_'.$i}){
        my $iSortCol = $param->{'iSortCol_'.$i};
        my $sSortDir = $param->{'sSortDir_'.$i};
        my $mDataProp = $param->{'mDataProp_'.$iSortCol};
        my @sort_fields = $param->{$mDataProp.'_sorton'}
            ? split(' ', $param->{$mDataProp.'_sorton'})
            : ();
        if(@sort_fields > 0) {
            push @orderbys, "$_ $sSortDir" foreach (@sort_fields);
        } else {
            push @orderbys, "$mDataProp $sSortDir";
        }
        $i++;
    }

    my $orderby = " ORDER BY " . join(',', @orderbys) . " " if @orderbys;
    return $orderby;
}

=item dt_build_having

    my ($having, $having_params) = dt_build_having($dt_params)

    This function takes a reference to a hash containing DataTables parameters
    and build the corresponding 'HAVING' clause.
    This hash must contains the following keys:

        sSearch is the text entered in the global filter

        iColumns is the number of columns

        bSearchable_N is a boolean value that is true if the column is searchable

        mDataProp_N is a mapping between the column index, and the name of a SQL field

        sSearch_N is the text entered in individual filter for column N

=back

=cut

sub dt_build_having {
    my $param = shift;

    my @filters;
    my @params;

    # Global filter
    if($param->{'sSearch'}) {
        my $sSearch = $param->{'sSearch'};
        my $i = 0;
        my @gFilters;
        my @gParams;
        while($i < $param->{'iColumns'}) {
            if($param->{'bSearchable_'.$i} eq 'true') {
                my $mDataProp = $param->{'mDataProp_'.$i};
                my @filter_fields = $param->{$mDataProp.'_filteron'}
                    ? split(' ', $param->{$mDataProp.'_filteron'})
                    : ();
                if(@filter_fields > 0) {
                    foreach my $field (@filter_fields) {
                        push @gFilters, " $field LIKE ? ";
                        push @gParams, "%$sSearch%";
                    }
                } else {
                    push @gFilters, " $mDataProp LIKE ? ";
                    push @gParams, "%$sSearch%";
                }
            }
            $i++;
        }
        push @filters, " (" . join(" OR ", @gFilters) . ") ";
        push @params, @gParams;
    }

    # Individual filters
    my $i = 0;
    while($i < $param->{'iColumns'}) {
        my $sSearch = $param->{'sSearch_'.$i};
        if($sSearch) {
            my $mDataProp = $param->{'mDataProp_'.$i};
            my @filter_fields = $param->{$mDataProp.'_filteron'}
                ? split(' ', $param->{$mDataProp.'_filteron'})
                : ();
            if(@filter_fields > 0) {
                my @localfilters;
                foreach my $field (@filter_fields) {
                    push @localfilters, " $field LIKE ? ";
                    push @params, "%$sSearch%";
                }
                push @filters, " ( ". join(" OR ", @localfilters) ." ) ";
            } else {
                push @filters, " $mDataProp LIKE ? ";
                push @params, "%$sSearch%";
            }
        }
        $i++;
    }

    return (\@filters, \@params);
}

1;
