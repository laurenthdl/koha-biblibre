#!/usr/bin/perl

# Copyright 2008 Garry Collum and the Koha Koha Development team
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

# Script to perform searching
# Mostly copied from search.pl, see POD there
use strict;            # always use
use warnings;

## STEP 1. Load things that are used in both search page and
# results page and decide which template to load, operations 
# to perform, etc.
## load Koha modules
use C4::Context;
use C4::Output;
use C4::Auth qw(:DEFAULT get_session);
use C4::Languages qw(getAllLanguages);
use C4::Search;
use C4::Biblio;  # GetBiblioData
use C4::Koha;
use C4::Tags qw(get_tags);
use C4::Branch; # GetBranches
use POSIX qw(ceil floor strftime);
use URI::Escape;
use Storable qw(thaw freeze);
use Data::SearchEngine::Query;
use Data::SearchEngine::Item;
use Data::SearchEngine::Solr;


# create a new CGI object
# FIXME: no_undef_params needs to be tested
use CGI qw('-no_undef_params');
my $cgi = new CGI;

BEGIN {
	if (C4::Context->preference('BakerTaylorEnabled')) {
		require C4::External::BakerTaylor;
		import C4::External::BakerTaylor qw(&image_url &link_url);
	}
}

my ($template,$borrowernumber,$cookie);

# decide which template to use
my $template_name;
my $template_type = 'basic';
my @params = $cgi->param("limit");

my $format = $cgi->param("format") || '';
my $build_grouped_results = C4::Context->preference('OPACGroupResults');
if ($format =~ /(rss|atom|opensearchdescription)/) {
	$template_name = 'opac-opensearch.tmpl';
}
elsif ($build_grouped_results) {
    $template_name = 'opac-results-grouped.tmpl';
}
elsif ((@params>=1) || ($cgi->param("q")) || ($cgi->param('multibranchlimit')) || ($cgi->param('limit-yr')) ) {
	$template_name = 'opac-results.tmpl';
}
else {
    $template_name = 'opac-advsearch.tmpl';
    $template_type = 'advsearch';
}
# load the template
($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => $template_name,
    query => $cgi,
    type => "opac",
    authnotrequired => 1,
    }
);

if ($format eq 'rss2' or $format eq 'opensearchdescription' or $format eq 'atom') {
	$template->param($format => 1);
    $template->param(timestamp => strftime("%Y-%m-%dT%H:%M:%S-00:00", gmtime)) if ($format eq 'atom'); 
    # FIXME - the timestamp is a hack - the biblio update timestamp should be used for each
    # entry, but not sure if that's worth an extra database query for each bib
}
if (C4::Context->preference("marcflavour") eq "UNIMARC" ) {
    $template->param('UNIMARC' => 1);
}
elsif (C4::Context->preference("marcflavour") eq "MARC21" ) {
    $template->param('usmarc' => 1);
}
$template->param( 'AllowOnShelfHolds' => C4::Context->preference('AllowOnShelfHolds') );

if (C4::Context->preference('BakerTaylorEnabled')) {
	$template->param(
		BakerTaylorEnabled  => 1,
		BakerTaylorImageURL => &image_url(),
		BakerTaylorLinkURL  => &link_url(),
		BakerTaylorBookstoreURL => C4::Context->preference('BakerTaylorBookstoreURL'),
	);
}
if (C4::Context->preference('TagsEnabled')) {
	$template->param(TagsEnabled => 1);
	foreach (qw(TagsShowOnList TagsInputOnList)) {
		C4::Context->preference($_) and $template->param($_ => 1);
	}
}

## URI Re-Writing
# Deprecated, but preserved because it's interesting :-)
# The same thing can be accomplished with mod_rewrite in
# a more elegant way
#                  
#my $rewrite_flag;
#my $uri = $cgi->url(-base => 1);
#my $relative_url = $cgi->url(-relative=>1);
#$uri.="/".$relative_url."?";
#warn "URI:$uri";
#my @cgi_params_list = $cgi->param();
#my $url_params = $cgi->Vars;
#
#for my $each_param_set (@cgi_params_list) {
#    $uri.= join "",  map "\&$each_param_set=".$_, split("\0",$url_params->{$each_param_set}) if $url_params->{$each_param_set};
#}
#warn "New URI:$uri";
# Only re-write a URI if there are params or if it already hasn't been re-written
#unless (($cgi->param('r')) || (!$cgi->param()) ) {
#    print $cgi->redirect(     -uri=>$uri."&r=1",
#                            -cookie => $cookie);
#    exit;
#}

# load the branches
my $mybranch = ( C4::Context->preference('SearchMyLibraryFirst') && C4::Context->userenv && C4::Context->userenv->{branch} ) ? C4::Context->userenv->{branch} : '';
my $branches = GetBranches();   # used later in *getRecords, probably should be internalized by those functions after caching in C4::Branch is established
$template->param(
    branchloop       => GetBranchesLoop($mybranch, 0),
    searchdomainloop => GetBranchCategories(undef,'searchdomain'),
);

# load the language limits (for search)
my $languages_limit_loop = getAllLanguages();
$template->param(search_languages_loop => $languages_limit_loop,);

# load the Type stuff
my $itemtypes = GetItemTypes;
# the index parameter is different for item-level itemtypes
my $itype_or_itemtype = (C4::Context->preference("item-level_itypes"))?'itype':'itemtype';
my @itemtypesloop;
my $selected=1;
my $cnt;
my $advanced_search_types = C4::Context->preference("AdvancedSearchTypes");

if (!$advanced_search_types or $advanced_search_types eq 'itemtypes') {
	foreach my $thisitemtype ( sort {$itemtypes->{$a}->{'description'} cmp $itemtypes->{$b}->{'description'} } keys %$itemtypes ) {
        my %row =(  number=>$cnt++,
				ccl => $itype_or_itemtype,
                code => $thisitemtype,
                selected => $selected,
                description => $itemtypes->{$thisitemtype}->{'description'},
                count5 => $cnt % 4,
                imageurl=> getitemtypeimagelocation( 'opac', $itemtypes->{$thisitemtype}->{'imageurl'} ),
            );
    	$selected = 0; # set to zero after first pass through
    	push @itemtypesloop, \%row;
	}
} else {
    my $advsearchtypes = GetAuthorisedValues($advanced_search_types, '', 'opac');
	for my $thisitemtype (@$advsearchtypes) {
		my %row =(
				number=>$cnt++,
				ccl => $advanced_search_types,
                code => $thisitemtype->{authorised_value},
                selected => $selected,
                description => $thisitemtype->{'lib'},
                count5 => $cnt % 4,
                imageurl=> getitemtypeimagelocation( 'opac', $thisitemtype->{'imageurl'} ),
            );
		push @itemtypesloop, \%row;
	}
}
$template->param(itemtypeloop => \@itemtypesloop);

# # load the itypes (Called item types in the template -- just authorized values for searching)
# my ($itypecount,@itype_loop) = GetCcodes();
# $template->param(itypeloop=>\@itype_loop,);

# The following should only be loaded if we're bringing up the advanced search template
if ( $template_type && $template_type eq 'advsearch' ) {

    # load the servers (used for searching -- to do federated searching, etc.)
    my $primary_servers_loop;# = displayPrimaryServers();
    $template->param(outer_servers_loop =>  $primary_servers_loop,);
    
    my $secondary_servers_loop;
    $template->param(outer_sup_servers_loop => $secondary_servers_loop,);

    # set the default sorting
    my $default_sort_by = C4::Context->preference('OPACdefaultSortField')."_".C4::Context->preference('OPACdefaultSortOrder') 
        if (C4::Context->preference('OPACdefaultSortField') && C4::Context->preference('OPACdefaultSortOrder'));
    $template->param($default_sort_by => 1);

    # determine what to display next to the search boxes (ie, boolean option
    # shouldn't appear on the first one, scan indexes should, adding a new
    # box should only appear on the last, etc.
    my @search_boxes_array;
    my $search_boxes_count = C4::Context->preference("OPACAdvSearchInputCount") || 3;
    for (my $i=1;$i<=$search_boxes_count;$i++) {
        # if it's the first one, don't display boolean option, but show scan indexes
        if ($i==1) {
            push @search_boxes_array,
                {
                scan_index => 1,
                };
        
        }
        # if it's the last one, show the 'add field' box
        elsif ($i==$search_boxes_count) {
            push @search_boxes_array,
                {
                boolean => 1,
                add_field => 1,
                };
        }
        else {
            push @search_boxes_array,
                {
                boolean => 1,
                };
        }

    }
    $template->param(uc(C4::Context->preference("marcflavour")) => 1,   # we already did this for UNIMARC
					  advsearch => 1,
                      search_boxes_loop => \@search_boxes_array);

# use the global setting by default
	if ( C4::Context->preference("expandedSearchOption") == 1 ) {
		$template->param( expanded_options => C4::Context->preference("expandedSearchOption") );
	}
	# but let the user override it
	if (defined $cgi->param('expanded_options')) {
   	    if ( ($cgi->param('expanded_options') == 0) || ($cgi->param('expanded_options') == 1 ) ) {
    	    $template->param( expanded_options => $cgi->param('expanded_options'));
	    }
        }
    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit;
}

### OK, if we're this far, we're performing an actual search

# Fetch the paramater list as a hash in scalar context:
#  * returns paramater list as tied hash ref
#  * we can edit the values by changing the key
#  * multivalued CGI paramaters are returned as a packaged string separated by "\0" (null)
my $params = $cgi->Vars;
my $tag;
$tag = $params->{tag} if $params->{tag};

# Params that can have more than one value
# sort by is used to sort the query
# in theory can have more than one but generally there's just one
my @sort_by;
my $default_sort_by = C4::Context->preference('OPACdefaultSortField')."_".C4::Context->preference('OPACdefaultSortOrder') 
    if (C4::Context->preference('OPACdefaultSortField') && C4::Context->preference('OPACdefaultSortOrder'));

@sort_by = split("\0",$params->{'sort_by'}) if $params->{'sort_by'};
$sort_by[0] = $default_sort_by if !$sort_by[0] && defined($default_sort_by);
foreach my $sort (@sort_by) {
    $template->param($sort => 1);   # FIXME: security hole.  can set any TMPL_VAR here
}
$template->param('sort_by' => $sort_by[0]);

# Use the servers defined, or just search our local catalog(default)
my @servers;
@servers = split("\0",$params->{'server'}) if $params->{'server'};
unless (@servers) {
    #FIXME: this should be handled using Context.pm
    @servers = ("biblioserver");
    # @servers = C4::Context->config("biblioserver");
}

# operators include boolean and proximity operators and are used
# to evaluate multiple operands
my @operators;
@operators = split("\0",$params->{'op'}) if $params->{'op'};

# indexes are query qualifiers, like 'title', 'author', etc. They
# can be single or multiple parameters separated by comma: kw,right-Truncation 
my @indexes;
@indexes = split("\0",$params->{'idx'}) if $params->{'idx'};

# if a simple index (only one)  display the index used in the top search box
if ($indexes[0] && !$indexes[1]) {
    $template->param("ms_".$indexes[0] => 1);
}
# an operand can be a single term, a phrase, or a complete ccl query
my @operands;
@operands = split("\0",$params->{'q'}) if $params->{'q'};

# if a simple search, display the value in the search box
if ($operands[0] && !$operands[1]) {
    $template->param(ms_value => $operands[0]);
}

# limits are use to limit to results to a pre-defined category such as branch or language
my @limits;
@limits = split("\0",$params->{'limit'}) if $params->{'limit'};

if($params->{'multibranchlimit'}) {
  push @limits, join(" or ", map { "branch: $_ "}  @{GetBranchesInCategory($params->{'multibranchlimit'})}) ;
}

my $available;
foreach my $limit(@limits) {
    if ($limit =~/available/) {
        $available = 1;
    }
}
$template->param(available => $available);


# Params that can only have one value
my $scan = $params->{'scan'};
my $count = C4::Context->preference('OPACnumSearchResults') || 20;
my $results_per_page = $params->{'count'} || $count;
my $offset = $params->{'offset'} || 0;
my $page = $cgi->param('page') || 1;
$offset = ($page-1)*$results_per_page if $page>1;
my $hits;
my $expanded_facet = $params->{'expand'};

# Define some global variables
my ($error,$query,$simple_query,$query_cgi,$query_desc,$limit,$limit_cgi,$limit_desc,$stopwords_removed,$query_type);

my @results;

########## PROOF OF CONCEPT ##########
if ($@ || $error) {
    $template->param(query_error => $error.$@);
    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit;
}

my $solr_url = "http://descartes.biblibre.com:8180/solr/";
my $solr = Data::SearchEngine::Solr->new(
  url => $solr_url,
);

$solr->options->{'facet'} = 'true';
$solr->options->{'facet.mincount'} = 1;
$solr->options->{'facet.limit'} = 10;
$solr->options->{'facet.field'} = [ 'holdingbranch','homebranch','authorStr' ];

my $solr_query = Data::SearchEngine::Query->new(
   page => $page,
   query => $params->{'q'}
);

my $res = $solr->search($solr_query);

for my $item ( @{$res->items} ) {
	my (undef, $record ) = GetBiblio($item->id);
        push @results, $record;
}

my @facets;
for my $index ( keys %{$res->facets} ) {
  my $facet = $res->facets->{$index};
  my @values;
  for( my $i = 0 ; $i < scalar(@$facet) ; $i++ ) {
    my $value = $facet->[$i++];
    my $count = $facet->[$i];
    push @values, {
      value => $value,
      count => $count,
    };
  }
  push @facets, {
      index  => $index,
      values => \@values,
    }
}

$template->param(
            #classlist => $classlist,
#            results => $results,
            total => $res->count,
            opacfacets => 1,
            scan => $scan,
            search_error => $error,
            SEARCH_RESULTS => \@results,
            facets_loop => \@facets,
            query => $params->{'q'},
);

if ($query_desc || $limit_desc) {
    $template->param(searchdesc => 1);
}

# VI. BUILD THE TEMPLATE
# Build drop-down list for 'Add To:' menu...
my $session = get_session($cgi->cookie("CGISESSID"));
my @addpubshelves;
my $pubshelves = $session->param('pubshelves');
my $barshelves = $session->param('barshelves');
foreach my $shelf (@$pubshelves) {
	next if ( ($shelf->{'owner'} != ($borrowernumber ? $borrowernumber : -1)) && ($shelf->{'category'} < 3) );
	push (@addpubshelves, $shelf);
}

if (@addpubshelves) {
	$template->param( addpubshelves     => scalar (@addpubshelves));
	$template->param( addpubshelvesloop => \@addpubshelves);
}

if (defined $barshelves) {
	$template->param( addbarshelves     => scalar (@$barshelves));
	$template->param( addbarshelvesloop => $barshelves);
}

my $content_type = ($format eq 'rss' or $format eq 'atom') ? $format : 'html';

# If GoogleIndicTransliteration system preference is On Set paramter to load Google's javascript in OPAC search screens 
if (C4::Context->preference('GoogleIndicTransliteration')) {
        $template->param('GoogleIndicTransliteration' => 1);
}

output_with_http_headers $cgi, $cookie, $template->output, $content_type;
