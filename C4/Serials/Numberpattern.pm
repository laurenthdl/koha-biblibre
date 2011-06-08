package C4::Serials::Numberpattern;

# Copyright 2000-2002 Biblibre SARL
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

#use warnings; FIXME - Bug 2505
use C4::Context;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {

    # set the version for version checking
    $VERSION = 3.01;
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(

      &AddNumberpattern
      &ModNumberpattern
      &DelNumberpattern

    );
}

sub AddNumberpattern {
    my ($label, $numberingmethod, $label1, $label2, $label3, $add1, $add2, $add3, $every1, $every2, $every3, $setto1, $setto2, $setto3, $whenmorethan1, $whenmorethan2, $whenmorethan3, $numbering1, $numbering2, $numbering3) = @_;

    my $query = qq{
        INSERT INTO subscription_numberpatterns (label, numberingmethod, label1, label2, label3, add1, add2, add3, every1, every2, every3, setto1, setto2, setto3, whenmorethan1, whenmorethan2, whenmorethan3, numbering1, numbering2, numbering3)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    };

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute($label, $numberingmethod, $label1, $label2, $label3, $add1, $add2, $add3, $every1, $every2, $every3, $setto1, $setto2, $setto3, $whenmorethan1, $whenmorethan2, $whenmorethan3, $numbering1, $numbering2, $numbering3);

    return $dbh->last_insert_id(undef, undef, "subscription_numberpatterns", undef);
}

# -------------------------------------------------------------------
sub ModNumberpattern {
    my ( $class, $numberpattern ) = @_;
    return UpdateInTable( "subscription_numberpatterns", $numberpattern );
}

# -------------------------------------------------------------------
sub DelNumberpattern {
    my ( $class, $numberpattern ) = @_;
    return DeleteInTable( "subscription_numberpatterns", $numberpattern );
}


END { }    # module clean-up code here (global destructor)

1;
__END__

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
