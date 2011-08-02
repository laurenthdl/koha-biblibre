package C4::Discharges;

#
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

=head1 NAME

C4::Discharges - functions for discharges

=head1 DESCRIPTION

This modules allows to retrieve informations about generated discharges

=cut

use strict;
use warnings;
use File::Basename;

our $debug;
use vars qw(@ISA @EXPORT);
BEGIN {
    $debug = $ENV{DEBUG} || 0;
    require Exporter;
    @ISA = qw( Exporter );

    push @EXPORT, qw(
      &GetDischarges
      &removeUnprocessedDischarges
    );


}


=head1 METHODS

=head2 getDischarges($borrowernumber)

=over 4

    my @list = GetDischarges($borrowernumber);

=back

=cut

sub GetDischarges {
    my $borrowernumber = shift;
    return unless $borrowernumber;
    my $dischargePath    = C4::Context->preference('dischargePath');
    my $dischargeWebPath = C4::Context->preference('dischargeWebPath');
    my @return;

    my @files = <$dischargePath/$borrowernumber/*.pdf>;
    foreach (@files) {
        warn $_;
        my ($file, $dir, $ext) = fileparse("$_");
        push @return, $file;
    }

    return @return;
}

=head2 removeUnprocessedDischarges($borrowernumber)

=over 4

    removeUnprocessedDischarges($borrowernumber);

=back

=cut

sub removeUnprocessedDischarges {

    my $borrowernumber = shift;
    return unless $borrowernumber;

    # Remove all DISCHARGEs with a pending status, because if the process had been complete, the status would be 'sent'
    my $dbh = C4::Context->dbh;
    my $query = "DELETE FROM message_queue WHERE borrowernumber=? AND letter_code='DISCHARGE' AND status='pending'";
    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);


}

1;

__END__

