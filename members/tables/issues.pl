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

my $input = new CGI;
my $vars = $input->Vars;

my $borrowernumber = $input->param('borrowernumber');
my $ccode = $input->param('ccode');
my $itype = $input->param('itype');
my $dateduefrom = $input->param('dateduefrom');
my $datedueto = $input->param('datedueto');
my $issuedatefrom = $input->param('issuedatefrom');
my $issuedateto = $input->param('issuedateto');

# Fetch DataTables parameters
my %dtparam = dt_get_params( $input );

my $dbh = C4::Context->dbh;

# Build the query
my $select = "SELECT SQL_CALC_FOUND_ROWS ".
    "issues.itemnumber, issues.date_due, issues.renewals, issues.issuedate,".
    "items.barcode, items.itemcallnumber, items.itype, itemtypes.imageurl,".
    "itemtypes.description AS itemtype_description, itemtypes.itemtype,".
    "biblio.biblionumber, biblio.title, biblio.author, biblioitems.publishercode,".
    "biblioitems.publicationyear, authorised_values.lib AS collection,".
    "items.stocknumber, items.ccode, items.replacementprice,".
    "( (itemtypes.rentalcharge * (100 - issuingrules.rentaldiscount) ) / 100 ) AS charge";
my $from = " FROM issues ";
$from .= " LEFT JOIN items USING(itemnumber) ";
$from .= " LEFT JOIN biblio USING(biblionumber) ";
$from .= " LEFT JOIN biblioitems USING(biblioitemnumber) ";
$from .=
      ( C4::Context->preference('item-level_itypes') )
      ? " LEFT JOIN itemtypes ON items.itype = itemtypes.itemtype "
      : " LEFT JOIN itemtypes ON biblioitems.itemtype = itemtypes.itemtype ";
$from .= " LEFT JOIN borrowers ON borrowers.borrowernumber = issues.borrowernumber ";
$from .= " LEFT JOIN issuingrules ON borrowers.categorycode = issuingrules.categorycode AND borrowers.branchcode = issuingrules.branchcode AND items.itype = issuingrules.itemtype ";
$from .= " LEFT JOIN authorised_values ON authorised_values.category = 'CCODE' AND authorised_values.authorised_value = items.ccode ";
my @where_params;
my $where = " WHERE issues.borrowernumber = ? ";
push @where_params, $borrowernumber;
my $where_filters;
my @where_filters_params;
if($ccode) {
    $where_filters .= " AND items.ccode = ? ";
    push @where_filters_params, $ccode;
}
if($itype) {
    $where_filters .= (C4::Context->preference('item-level_itypes'))
        ? " AND items.itype = ? "
        : " AND biblioitems.itemtype = ? ";
    push @where_filters_params, $itype;
}

my ( $datedue_q   , $datedue_f    ) = dt_build_query( 'range_dates', $dateduefrom, , $datedueto, 'issues.date_due' );
my ( $issuedate_q , $issuedate_f  ) = dt_build_query( 'range_dates', $issuedatefrom, , $issuedateto, 'issues.issuedate' );

$where_filters .= ( $datedue_q    ? $datedue_q : '' )
                 . ( $issuedate_q  ? $issuedate_q : '' );

push @where_filters_params,
          scalar( @$datedue_f )    > 0 ? @$datedue_f : ()
        , scalar( @$issuedate_f )  > 0 ? @$issuedate_f : ();

my ($filters, $filter_params) = dt_build_having(\%dtparam);
my $having = @$filters ? " HAVING " . join(" AND ", @$filters) : "";
my $order_by = dt_build_orderby(\%dtparam);
my $limit .= " LIMIT ?,? ";

my $query = $select . $from . $where . ( $where_filters || '' ) . ( $having || '' ) . $order_by . $limit;
my @bind_params;
push @bind_params, @where_params, @where_filters_params, @$filter_params, $dtparam{'iDisplayStart'}, $dtparam{'iDisplayLength'};
my $sth = $dbh->prepare($query);
$sth->execute(@bind_params);
my $results = $sth->fetchall_arrayref({});

$sth = $dbh->prepare("SELECT FOUND_ROWS()");
$sth->execute;
my ($iTotalDisplayRecords) = $sth->fetchrow_array;

# This is mandatory for DataTables to show the total number of results
my $select_total_count = "SELECT COUNT(*) ";
$sth = $dbh->prepare($select_total_count.$from.$where);
$sth->execute(@where_params);
my ($iTotalRecords) = $sth->fetchrow_array;

my @aaData = ();
foreach(@$results) {
    my %row = %{$_};
    $row{'date_due'} = C4::Dates->new($row{'date_due'}, 'iso')->output();
    $row{'issuedate'} = C4::Dates->new($row{'issuedate'}, 'iso')->output();
    $row{'charge'} ||= 0;
    $row{'charge'} = sprintf("%.2f", $row{'charge'});
    $row{'imageurl'} = getitemtypeimagelocation('intranet', $row{'imageurl'});

    my ($can_renew, $can_renew_error) = CanBookBeRenewed($borrowernumber, $row{'itemnumber'});
    if(defined $can_renew_error->{'message'}) {
        $row{'renew_error_'.$can_renew_error->{'message'}} = 1;
        $row{'renew_error'} = 1;
    }
    $row{'renewals'} ||= 0;
    $row{$_} = $can_renew_error->{$_} for (qw(renewalsallowed reserves));
    my ( $restype, $reserves ) = CheckReserves( $row{'itemnumber'} );
    if ($restype) {
        $row{'reserved'} = 1;
        $row{$restype} = 1;
    }
    $row{'can_renew'}    = $can_renew;

    push @aaData, \%row;
}

my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user({
    template_name   => 'members/tables/issues.tmpl',
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

print $input->header('application/json');
print $template->output();
