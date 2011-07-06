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
use warnings;

use C4::Context;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {

    # set the version for version checking
    $VERSION = 3.01;
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
        &GetSubscriptionNumberpatterns
        &GetSubscriptionNumberpattern
        &GetSubscriptionNumberpatternByName
        &AddSubscriptionNumberpattern
        &ModSubscriptionNumberpattern
        &DelSubscriptionNumberpattern

    );
}

=head3 GetSubscriptionNumberpatterns

=over 4

@results = GetSubscriptionNumberpatterns;
this function get all subscription number patterns entered in table

=back

=cut

sub GetSubscriptionNumberpatterns {
    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT *
        FROM subscription_numberpatterns
        ORDER by displayorder
    };
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my $results = $sth->fetchall_arrayref({});

    return @$results;
}

=head3 GetSubscriptionNumberpattern

=over 4

$result = GetSubscriptionNumberpattern($numberpatternid);
this function get the data of the subscription numberpatterns which id is $numberpatternid

=back

=cut

sub GetSubscriptionNumberpattern {
    my $numberpatternid = shift;
    my $dbh = C4::Context->dbh;
    my $query = qq(
        SELECT *
        FROM subscription_numberpatterns
        WHERE id = ?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute($numberpatternid);

    return $sth->fetchrow_hashref;
}

=head3 GetSubscriptionNumberpatternByName

=over 4

$result = GetSubscriptionNumberpatternByName($name);
this function get the data of the subscription numberpatterns which name is $name

=back

=cut

sub GetSubscriptionNumberpatternByName {
    my $name = shift;
    my $dbh = C4::Context->dbh;
    my $query = qq(
        SELECT *
        FROM subscription_numberpatterns
        WHERE label = ?
    );
    my $sth = $dbh->prepare($query);
    my $rv = $sth->execute($name);

    return $sth->fetchrow_hashref;
}

=head3 AddSubscriptionNumberpattern

=over 4

=item C<$numberpatternid> = &AddSubscriptionNumberpattern($numberpattern)

Add a new numberpattern

=item C<$frequency> is a hashref that contains values of the number pattern

=item Only label and numberingmethod are mandatory

=back

=cut

sub AddSubscriptionNumberpattern {
    my $numberpattern = shift;

    unless(
      ref($numberpattern) eq 'HASH'
      && defined $numberpattern->{'label'}
      && $numberpattern->{'label'} ne ''
      && defined $numberpattern->{'numberingmethod'}
      && $numberpattern->{'numberingmethod'} ne ''
    ) {
        return undef;
    }

    my @keys;
    my @values;
    foreach (qw/ label description numberingmethod displayorder
      label1 label2 label3 add1 add2 add3 every1 every2 every3
      setto1 setto2 setto3 whenmorethan1 whenmorethan2 whenmorethan3
      numbering1 numbering2 numbering3 /) {
        if(exists $numberpattern->{$_}) {
            push @keys, $_;
            push @values, $numberpattern->{$_};
        }
    }

    my $dbh = C4::Context->dbh;
    my $query = "INSERT INTO subscription_numberpatterns";
    $query .= '(' . join(',', @keys) . ')';
    $query .= ' VALUES (' . ('?,' x (scalar(@keys)-1)) . '?)';
    my $sth = $dbh->prepare($query);
    my $rv = $sth->execute(@values);

    if(defined $rv) {
        return $dbh->last_insert_id(undef, undef, "subscription_numberpatterns", undef);
    }

    return $rv;
}

=head3 ModSubscriptionNumberpattern

=over 4

=item &ModSubscriptionNumberpattern($numberpattern)

Modifies a numberpattern

=item C<$frequency> is a hashref that contains values of the number pattern

=item Only id is mandatory

=back

=cut

sub ModSubscriptionNumberpattern {
    my $numberpattern = shift;

    unless(
      ref($numberpattern) eq 'HASH'
      && defined $numberpattern->{'id'}
      && $numberpattern->{'id'} > 0
      && (
        (defined $numberpattern->{'label'}
        && $numberpattern->{'label'} ne '')
        || !defined $numberpattern->{'label'}
      )
      && (
        (defined $numberpattern->{'numberingmethod'}
        && $numberpattern->{'numberingmethod'} ne '')
        || !defined $numberpattern->{'numberingmethod'}
      )
    ) {
        return undef;
    }

    my @keys;
    my @values;
    foreach (qw/ label description numberingmethod displayorder
      label1 label2 label3 add1 add2 add3 every1 every2 every3
      setto1 setto2 setto3 whenmorethan1 whenmorethan2 whenmorethan3
      numbering1 numbering2 numbering3 /) {
        if(exists $numberpattern->{$_}) {
            push @keys, $_;
            push @values, $numberpattern->{$_};
        }
    }

    my $dbh = C4::Context->dbh;
    my $query = "UPDATE subscription_numberpatterns";
    $query .= ' SET ' . join(' = ?,', @keys) . ' = ?';
    $query .= ' WHERE id = ?';
    my $sth = $dbh->prepare($query);

    return $sth->execute(@values, $numberpattern->{'id'});
}

=head3 DelSubscriptionNumberpattern

=over 4

=item &DelSubscriptionNumberpattern($numberpatternid)

Delete a number pattern

=back

=cut

sub DelSubscriptionNumberpattern {
    my $numberpatternid = shift;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        DELETE FROM subscription_numberpatterns
        WHERE id = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($numberpatternid);
}



1;

__END__

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
