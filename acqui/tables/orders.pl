#!/usr/bin/perl

use CGI;
use C4::Search;
use C4::Search::Query;
use C4::Output;
use C4::Auth;
use C4::Biblio;

my $input = new CGI;

my $query = $input->param('query') || "*:*";
my $count = $input->param('iDisplayLength');
my $page = int($input->param('iDisplayStart') / $count) + 1;

my @filters = $input->param('filters');
my @filters_values = $input->param('filters_values');

my $search_filters = { recordtype => "biblio" };
for (my $i = 0; $i < scalar(@filters); $i++) {
    my $idx = C4::Search::Query::getIndexName($filters[$i]);
    $search_filters->{$idx} = $filters_values[$i];
}

# Sorting on only one column
my $sort;
my $sortingCol = $input->param('iSortCol_0');
if(defined $sortingCol) {
    my $colName = $input->param("mDataProp_$sortingCol");
    if($colName) {
        my $sortIdx = $input->param($colName."_sorton") || $colName;
        my $sortIdxName = C4::Search::Query::getIndexName($sortIdx);
        if($sortIdxName) {
            $sort = $sortIdxName . " " . $input->param('sSortDir_0');
        }
    }
}

my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user({
    template_name   => "acqui/tables/orders.tmpl",
    query           => $input,
    type            => "intranet",
    authnotrequired => 0,
    flagsrequired   => { acquisition => 'order_manage' },
});

$query = C4::Search::Query->normalSearch($query);
my $res = SimpleSearch($query, $search_filters, $page, $count, $sort);

if($res) {
    my @results = map { GetBiblioData $_->{'values'}->{'recordid'} } @{ $res->items };

    $template->param(
        booksellerid    => $input->param('booksellerid'),
        basketno    => $input->param('basketno'),
        iTotalDisplayRecords    => $res->{'pager'}->{'total_entries'},
        aaData  => \@results,
    );
}

# This is just to find total number of results for initial query (without filters)
my $total_res = SimpleSearch($query, {recordtype => "biblio"}, 1, 1);
if($total_res) {
    $template->param(
        iTotalRecords   => $total_res->{'pager'}->{'total_entries'},
    );
}

$template->param(
    sEcho   => $input->param('sEcho'),
);

output_with_http_headers $input, $cookie, $template->output, "json";
