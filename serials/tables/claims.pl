#!/usr/bin/perl
#

use strict;
use warnings;

use CGI;
use JSON;

use C4::Auth;
use C4::Circulation qw/CanBookBeRenewed/;
use C4::Context;
use C4::Koha qw/getitemtypeimagelocation/;
use C4::Reserves qw/CheckReserves/;
use C4::Utils::DataTables;
use Log::LogLite;

my $input = new CGI;

my $planneddate_to = $input->param('planneddate_to');
my $planneddate_from = $input->param('planneddate_from');

# Fetch DataTables parameters
my %dtparam;
foreach(qw/ iDisplayStart iDisplayLength iColumns sSearch bRegex iSortingCols sEcho /) {
    $dtparam{$_} = $input->param($_);
}
for(my $i=0; $i<$dtparam{'iColumns'}; $i++) {
    foreach(qw/ bSearchable sSearch bRegex bSortable iSortCol mDataProp sSortDir /) {
        my $key = $_ . '_' . $i;
        $dtparam{$key} = $input->param($key) if defined $input->param($key);
    }
}

warn Data::Dumper::Dumper \%dtparam;

my $dbh = C4::Context->dbh;

# Build the query
my $select = <<EOQ;
    SELECT SQL_CALC_FOUND_ROWS
    serialid, aqbooksellerid, name AS suppliername, biblio.title, planneddate, serialseq,
    serial.status, serial.subscriptionid, claimdate, claims_count,
    branches.branchname
EOQ
my $from = <<EOQ;
    FROM serial
    LEFT JOIN subscription  ON serial.subscriptionid=subscription.subscriptionid 
    LEFT JOIN biblio        ON subscription.biblionumber=biblio.biblionumber
    LEFT JOIN aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
    LEFT JOIN branches ON branches.branchcode = subscription.branchcode
EOQ
my $where = <<EOQ;
    WHERE (serial.STATUS = 4 OR ((planneddate < now() AND serial.STATUS =1) OR serial.STATUS = 3 OR serial.STATUS = 7))
EOQ
my @bind_params;
if($planneddate_to){
    $where .= " AND planneddate <= ? ";
    push @bind_params, C4::Dates->new($planneddate_to)->output('iso');
}
if($planneddate_from){
    $where .= " AND planneddate >= ? ";
    push @bind_params, C4::Dates->new($planneddate_from)->output('iso');
}
my ($filters, $filter_params) = dt_build_having(\%dtparam);
my $having = @$filters ? " HAVING ". join(" AND ", @$filters) : '';
my $order_by = dt_build_orderby(\%dtparam);
my $limit .= " LIMIT ?,? ";

my $query = $select.$from.$where.$having.$order_by.$limit;
push @bind_params, @$filter_params, $dtparam{'iDisplayStart'}, $dtparam{'iDisplayLength'};
my $sth = $dbh->prepare($query);
$sth->execute(@bind_params);
my $results = $sth->fetchall_arrayref({});

$sth = $dbh->prepare("SELECT FOUND_ROWS()");
$sth->execute;
my ($iTotalDisplayRecords) = $sth->fetchrow_array;

# This is mandatory for DataTables to show the total number of results
my $select_total_count = "SELECT COUNT(*) ";
$sth = $dbh->prepare($select_total_count.$from.$where);
$sth->execute();
my ($iTotalRecords) = $sth->fetchrow_array;

warn Data::Dumper::Dumper $results;
my @aaData = ();
foreach(@$results) {
    my %row = %{$_};
    $row{'planneddate'} = C4::Dates->new($row{'planneddate'}, 'iso')->output();
    #given ($row{'status'}) {
    #    when (/1/){
    #        $row{'status'} = "";
    #    }
    #}

    push @aaData, \%row;
}

my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user({
    template_name   => 'serials/tables/claims.tmpl',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { circulate => 'circulate_remaining_permission' },
});

$template->param(
    sEcho => $dtparam{'sEcho'},
    iTotalRecords => $iTotalRecords,
    iTotalDisplayRecords => $iTotalDisplayRecords,
    aaData => \@aaData,
);

my $logger = Log::LogLite->new("/tmp/logJSON", 7);
$logger and $logger->template("<date> <message>\n");
$logger->write($template->output);
print $input->header('application/json');
print $template->output();
