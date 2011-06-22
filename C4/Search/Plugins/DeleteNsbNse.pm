package C4::Search::Plugins::DeleteNsbNse;

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
use C4::Charset;
use base 'Exporter';

our @EXPORT = qw/
       &ComputeValue
    /;
our $VERSION = 3.0.1;

=head2 fonction
    return values without nsb/nse characters
=cut

sub GetSF {
    my ($record, $mapping) = @_;

    my @values = ();
    for my $tag ( keys (%$mapping) ) {
        for my $code ( @{$$mapping{$tag}} ) {
            for my $f ( $record->field($tag) ) {
                for my $sf ($f->subfield($code)){
                    push @values, $sf;
                }
            }
        }
    }
    return @values;
}

sub ComputeValue {
    my ($record, $mapping) = @_;

    return map {
        nsb_clean($_)
    } GetSF($record, $mapping);

}

sub ComputeSrtValue {
    my ($record, $mapping) = @_;

    return map {
        nsb_rm_content($_)
    } GetSF($record, $mapping);

}
1;
