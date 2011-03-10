package C4::Members::Statistics;

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

use C4::Context;

our ( $VERSION, @ISA, @EXPORT, @EXPORT_OK, $debug );

BEGIN {
    $VERSION = 3.02;
    $debug = $ENV{DEBUG} || 0;
    require Exporter;
    @ISA = qw(Exporter);

    push @EXPORT, qw(
        &GetTotalIssuesTodayByBorrower
        &GetTotalIssuesReturnedTodayByBorrower
        &GetPrecedentStateByBorrower
        &GetActualStateByBorrower
    );
}

sub construct_query {
    my $count    = shift;
    my $subquery = shift;
    my $fields = C4::Context->preference('StatisticsFields');
    my @select_fields = split '\|', $fields;
    my $query = "SELECT COUNT(*) as count_$count";
    $query .= ", $_" for @select_fields;

    $query .= " " . $subquery;

    $fields =~ s/\|/,/g;
    $query .= " GROUP BY $fields;";

    return $query;
   
}

# Return total issues for a borrower at this current day
sub GetTotalIssuesTodayByBorrower {
    my ($borrowernumber) = @_;
    my $dbh   = C4::Context->dbh;

    my $query = construct_query "total_issues_today", "FROM issues i, items it WHERE i.itemnumber=it.itemnumber AND i.borrowernumber=? AND DATE_FORMAT(i.issuedate, '%Y-%m-%d') = CURDATE() AND i.returndate IS NULL ";

    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    return $sth->fetchall_arrayref( {} );
}

# Return total issues returned by a borrower at this current day
sub GetTotalIssuesReturnedTodayByBorrower {
    my ($borrowernumber) = @_;
    my $dbh   = C4::Context->dbh;

    my $query = construct_query "total_issues_returned_today", "FROM old_issues i, items it WHERE i.itemnumber=it.itemnumber AND i.borrowernumber=? AND DATE_FORMAT(i.returndate, '%Y-%m-%d') = CURDATE() ";

    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    return $sth->fetchall_arrayref( {} );
}

sub GetPrecedentStateByBorrower {
    my ($borrowernumber) = @_;
    my $dbh   = C4::Context->dbh;

    my $query = construct_query "precedent_state", "FROM issues i, items it WHERE i.itemnumber=it.itemnumber AND i.borrowernumber=? AND DATE_FORMAT(i.issuedate,'%Y-%m-%d') < DATE_FORMAT(NOW(), '%Y-%m-%d') AND i.returndate is NULL ";

    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    return $sth->fetchall_arrayref( {});
}

sub GetActualStateByBorrower {
    my ($borrowernumber) = @_;
    my $dbh   = C4::Context->dbh;

    my $query = construct_query "actual_state", "FROM issues i, items it WHERE i.itemnumber=it.itemnumber AND i.borrowernumber=? AND DATE_FORMAT(i.returndate,'%Y-%m-%d') = DATE_FORMAT(NOW(), '%Y-%m-%d') ";

    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    return $sth->fetchall_arrayref( {} );
}

1;
