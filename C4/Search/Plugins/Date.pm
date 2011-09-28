package C4::Search::Plugins::Date;

# Copyright (C) 2010 BibLibre
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
use base 'Exporter';

our @EXPORT = qw/
       &ComputeValue
    /;
our $VERSION = 3.0.1;

sub ComputeValue {
    my ( $record, $mapping ) = @_;

    return if (!defined $mapping);

    my @dates = ();
    my @values = ();
    for my $tag ( keys (%$mapping) ) {
        for my $code ( @{$$mapping{$tag}} ) {
            for my $f ( $record->field($tag) ) {
                for my $sf ($f->subfield($code)){
                    my @tmp = ();
                    while ( $sf =~ m/\S+/g ) {
                        my $string = $&;
                        given ( $string ) {
                            # YYYY-YYYY (range year)
                            when ( /\d{4}-\d{4}/ ) {
                                my @d = split('-', $&);
                                for ( my $i = $d[0] ; $i <= $d[1] ; $i++ ) {
                                    push @tmp, C4::Search::Engine::Solr::NormalizeDate($i);
                                }
                            }
                            # YYYY-MM-DD
                            when ( /\d{4}-\d{2}-\d{2}/ ) {
                                push @tmp, C4::Search::Engine::Solr::NormalizeDate($&);
                                my @d = split('-', $&);
                                push @tmp, C4::Search::Engine::Solr::NormalizeDate($d[0]);
                            }
                            # DD-MM-YYYY
                            when ( /\d{2}-\d{2}-\d{4}/ ) {
                                push @tmp, C4::Search::Engine::Solr::NormalizeDate($&);
                                my @d = split('-', $&);
                                push @tmp, C4::Search::Engine::Solr::NormalizeDate($d[2]);
                            }
                            # YYYY
                            when ( /\d{4}/ ) {
                                push @tmp, C4::Search::Engine::Solr::NormalizeDate($&);
                            }
                        }
                    }
                    push @dates, @tmp;
                }
            }
        }
    }
    return @dates;
}

1;
