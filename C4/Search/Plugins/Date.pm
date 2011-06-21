package C4::Search::Plugins::PubDate;

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

use strict;
use warnings;
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
    for my $field ( keys %$mapping ) {
        for my $subfield ( @{$$mapping{$field}} ) {
            my @tmp = ();
            my $f = $record->field($field);
            next if not $f;
            my $sf = $f->subfield($subfield);
            next if not $sf;
            while ( $sf =~ m/\d{4}-\d{4}/g ) {
                my @d = split('-', $&);
                for ( my $i = $d[0] ; $i <= $d[1] ; $i++ ) {
                    push @tmp, C4::Search::Engine::Solr::NormalizeDate($i);
                }
            }
            if ( @tmp ) {
                push @dates, @tmp;
                next;
            }

            while ( $sf =~ m/\d{4}/g ) {
                push @tmp, C4::Search::Engine::Solr::NormalizeDate($&);
            }
            push @dates, @tmp;
        }
    }

    return @dates;
}

1;
