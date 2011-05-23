package C4::Front::Solr;

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

use utf8;
use Modern::Perl;

use Encode;
use C4::Search::Engine::Solr;
use C4::AuthoritiesMarc;
use C4::Branch;

sub DisplayFacets{
    my ($res,$filters,$tplfilters)=@_;
    my $search_index = C4::Search::Engine::Solr::GetAllIndexes;
    my @facets;
    while ( my ($index,$facet) = each %{$res->facets} ) {
        if ( @$facet > 1 ) {
            my @values;
            my ($type, $code) = split /_/, $index;
    
            for ( my $i = 0 ; $i < scalar(@$facet) ; $i++ ) {
                my $value = $facet->[$i++];
                my $count = $facet->[$i];
                $value=decode_utf8($value);
                my $lib;
                if ( $code =~/branch/ ) {
                    $lib = GetBranchName $value;
                }
                if ( $code =~/itype/ ) {
                    $lib = GetSupportName $value;
                }
                if ( my $avlist=C4::Search::Engine::Solr::GetAvlistFromCode($code) ) {
                    $lib = GetAuthorisedValueLib $avlist,$value;
                }
                if ( $search_index->{'biblio'}->{$code}->{$type}->{'plugin'}=~/Author/ig){
                    my $record=C4::AuthoritiesMarc::GetAuthority($value);
                    $lib=C4::AuthoritiesMarc::BuildSummary($record,$value,C4::AuthoritiesMarc::GetAuthtypecode($value));
                }
                $lib ||=$value;
                push @values, {
                    'lib'     => $lib,
                    'value'   => $value,
                    'count'   => $count,
                    'active'  => $filters->{$index} && $filters->{$index} eq "\"$value\"",
                    'filters' => $tplfilters,
                };
            }
    
            push @facets, {
                'index'  => $index,
                'label'  => C4::Search::Engine::Solr::GetIndexLabelFromCode($code),
              'values' => \@values,
          };
      }
  }
  return \@facets;
}
1
