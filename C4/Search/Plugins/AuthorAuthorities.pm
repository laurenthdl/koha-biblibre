package C4::Search::Plugins::AuthorAuthorities;

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
use C4::AuthoritiesMarc;
use base 'Exporter';

our @EXPORT = qw/
       &ComputeValue
    /;
our $VERSION = 3.0.1;

# We want to concatenate values returned by ComputeValue with others mappings
sub ConcatMappings {
    1;
}

=head2 fonction
    return vedette, rejected and parrallel forms
    @see t/solr/plugin_authorities.pl
=cut

sub ComputeValue {
    my ($brecord, $mapping) = @_;

    return if (!defined $mapping);

    my @bfieldstoindex = keys (%$mapping);
    my @afieldstoindex = ( '400', '410', '700', '710' );
    my @asubfieldstoindex = ( 'a', 'b' );

    my @values;
    #for each $9 in field in $mapping take authority linked
    for my $bfieldtoindex ( @bfieldstoindex ) {

        for my $bfield ( $brecord->field( $bfieldtoindex ) ) {
            for my $bsubfield ( $bfield->subfield( '9' ) ) {
                my $arecord = C4::AuthoritiesMarc::GetAuthority( $bsubfield );

                next unless $arecord;
                #for each 4.., 41.; 7.. and 71. (wich contains vedette, rejected and parralleles forms) of the authority return all subfields
                for my $afieldtoindex ( @afieldstoindex ) {
                    for my $afield ( $arecord->field( $afieldtoindex ) ) {
                        my @asubfields = $afield->subfields;
                        my $tempauthor;
                        for my $f (@asubfields) {
                            if ($f->[0] ~~ @asubfieldstoindex) {
                                $tempauthor .= $f->[1]." ";
                            }
                        }
                        push @values, $tempauthor;
                    }
                }
            }
        }
    }

    return @values;
}

1;
