#!/usr/bin/perl
# Script to perform searching
# For documentation try 'perldoc /path/to/search'
#
# Copyright 2006 LibLime
#
# This file is part of Koha
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

search - a search script for finding records in a Koha system (Version 3)

=head1 OVERVIEW

This script utilizes a new search API for Koha 3. It is designed to be 
simple to use and configure, yet capable of performing feats like stemming,
field weighting, relevance ranking, support for multiple  query language
formats (CCL, CQL, PQF), full support for the bib1 attribute set, extended
attribute sets defined in Zebra profiles, access to the full range of Z39.50
and SRU query options, federated searches on Z39.50/SRU targets, etc.

The API as represented in this script is mostly sound, even if the individual
functions in Search.pm and Koha.pm need to be cleaned up. Of course, you are
free to disagree :-)

I will attempt to describe what is happening at each part of this script.
-- Joshua Ferraro <jmf AT liblime DOT com>

=head2 INTRO

This script performs two functions:

=over 

=item 1. interacts with Koha to retrieve and display the results of a search

=item 2. loads the advanced search page

=back

These two functions share many of the same variables and modules, so the first
task is to load what they have in common and determine which template to use.
Once determined, proceed to only load the variables and procedures necessary
for that function.

=head2 LOADING ADVANCED SEARCH PAGE

This is fairly straightforward, and I won't go into detail ;-)

=head2 PERFORMING A SEARCH

If we're performing a search, this script  performs three primary
operations:

=over 

=item 1. builds query strings (yes, plural)

=item 2. perform the search and return the results array

=item 3. build the HTML for output to the template

=back

There are several additional secondary functions performed that I will
not cover in detail.

=head3 1. Building Query Strings
    
There are several types of queries needed in the process of search and retrieve:

=over

=cut

use strict;

#use warnings; FIXME - Bug 2505

## load Koha modules
use C4::Context;
use C4::Output;
use C4::Auth qw(:DEFAULT get_session);
use C4::Biblio;
use C4::Search;
use C4::Search::Query;
use C4::Languages qw(getAllLanguagesAuthorizedValues);
use C4::Koha;
use C4::VirtualShelves qw(GetRecentShelves);
use POSIX qw(ceil floor);
use C4::Branch;    # GetBranches
use Data::Pagination;

# create a new CGI object
# FIXME: no_undef_params needs to be tested
use CGI qw('-no_undef_params');
my $cgi = new CGI;

my ( $template, $borrowernumber, $cookie );

# decide which template to use
my $template_name;
my $template_type;
if ( ($cgi->param("filters")) || ( $cgi->param("idx") ) || ( $cgi->param("q") ) || ( $cgi->param('multibranchlimit') ) || ( $cgi->param('limit-yr') ) ) {
    $template_name = 'catalogue/results.tmpl';
} else {
    $template_name = 'catalogue/advsearch.tmpl';
    $template_type = 'advsearch';
}

# load the template
( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => $template_name,
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
    }
);
if ( C4::Context->preference("marcflavour") eq "UNIMARC" ) {
    $template->param( 'UNIMARC' => 1 );
}

# load the branches
my $branches = GetBranches();
my @branch_loop;

# we need to know the borrower branch code to set a default branch
my $borrowerbranchcode = C4::Context->userenv->{'branch'};

for my $branch_hash ( sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %$branches ) {

    # if independantbranches is activated, set the default branch to the borrower branch
    my $selected = ( C4::Context->preference("independantbranches") and ( $borrowerbranchcode eq $branch_hash ) ) ? 1 : undef;
    push @branch_loop, { value => "$branch_hash", branchcode =>  $branches->{$branch_hash}->{'branchcode'}, branchname => $branches->{$branch_hash}->{'branchname'}, selected => $selected };
}

my $categories = GetBranchCategories( undef, 'searchdomain' );

$template->param( branchloop => \@branch_loop, searchdomainloop => $categories );

$template->param( holdingbranch_index => C4::Search::Query::getIndexName('holdingbranch') );

# load the Type stuff
my $itemtypes = GetItemTypes;

#Give ability to search in authorised values
my $indexandavlist = C4::Search::Engine::Solr::GetIndexesWithAvlist;

# the index parameter is different for item-level itemtypes
my $itype_or_itemtype = ( C4::Context->preference("item-level_itypes") ) ? 'itype' : 'itemtype';
my @itemtypesloop;
my $cnt;
my $advanced_search_types = C4::Context->preference("AdvancedSearchTypes");
my $itype_or_ccode;
my @itypes = $cgi->param('itypes');
my @indexes = $cgi->param('idx');
my @operators = $cgi->param('op');
my @operands = $cgi->param('q');

if ( !$advanced_search_types or $advanced_search_types eq 'itemtypes' ) {
    $itype_or_ccode = 'itype';
} else {
    $itype_or_ccode = 'ccode';
}

my $itype_indexname = C4::Search::Query::getIndexName($itype_or_ccode);
# If @itypes exists, we delete idx, op and q in the corresponding arrays
# => Advsearch of filter by itypes
# Else we must push in @itypes values existing in @operands
# => Facets, sort, pagination
if ( @itypes ) {
    for my $i (0..$#indexes){
        if ( $indexes[$i] =~ /$itype_or_ccode/ ) {
            splice @indexes, $i, 1;
            splice @operands, $i, 1;
            splice @operators, $i - 1, 1;
        }
    }
} else {
    for my $i (0..$#indexes){
        if ( $indexes[$i] =~ /$itype_or_ccode/ ) {
            $operands[$i] =~ m/\(([^\)]*)\)/;
            push @itypes, map { $_ } split ' OR ', $1 ;
        }
    }
}

# Build itemtypesloop
# Set selected itypes
if ( $itype_or_ccode ne 'ccode' ) {
    foreach my $thisitemtype ( sort { $itemtypes->{$a}->{'description'} cmp $itemtypes->{$b}->{'description'} } keys %$itemtypes ) {
        my $selected = grep {$_ eq $thisitemtype} @itypes;
        my %row = (
            number      => $cnt++,
            index       => $itype_indexname,
            code        => $thisitemtype,
            selected    => $selected,
            description => $itemtypes->{$thisitemtype}->{'description'},
            count5      => $cnt % 4,
            imageurl    => getitemtypeimagelocation( 'intranet', $itemtypes->{$thisitemtype}->{'imageurl'} ),
        );
        push @itemtypesloop, \%row;
    }
} else {
    my $advsearchtypes = GetAuthorisedValues($advanced_search_types);
    for my $thisitemtype ( sort { $a->{'lib'} cmp $b->{'lib'} } @$advsearchtypes ) {
        my $selected = grep {$_ eq $thisitemtype} @itypes;
        my %row = (
            number      => $cnt++,
            index       => $itype_indexname,
            code        => $thisitemtype->{authorised_value},
            selected    => $selected,
            description => $thisitemtype->{'lib'},
            count5      => $cnt % 4,
            imageurl    => getitemtypeimagelocation( 'intranet', $thisitemtype->{'imageurl'} ),
        );
        push @itemtypesloop, \%row;
    }
}

$template->param(
    itemtypeloop => \@itemtypesloop,
    itemtypelib => C4::Search::Engine::Solr::GetIndexLabelFromCode( $itype_or_ccode ) # Lib for category
);

# set the default sorting
my $sort_by = $cgi->param('sort_by') || join(' ', grep { defined } ( 
        C4::Search::Query::getIndexName(C4::Context->preference('defaultSortField'))
                                      , C4::Context->preference('defaultSortOrder') ) );
my $sortloop = C4::Search::Engine::Solr::GetSortableIndexes('biblio');
for ( @$sortloop ) { # because html template is stupid
    $_->{'asc_selected'}  = $sort_by eq $_->{'type'}.'_'.$_->{'code'}.' asc';
    $_->{'desc_selected'} = $sort_by eq $_->{'type'}.'_'.$_->{'code'}.' desc';
}

$template->param(
    'sort_by'  => $sort_by,
    'sortloop' => $sortloop,
);

$template->param(
    itemtypeloop => \@itemtypesloop,
    itemtypelib => C4::Search::Engine::Solr::GetIndexLabelFromCode( $itype_or_ccode ) # Lib for category
);

# set the default sorting
my $sort_by = $cgi->param('sort_by') || join(' ', grep { defined } ( 
        C4::Search::Query::getIndexName(C4::Context->preference('defaultSortField'))
                                      , C4::Context->preference('defaultSortOrder') ) );
my $sortloop = C4::Search::Engine::Solr::GetSortableIndexes('biblio');
for ( @$sortloop ) { # because html template is stupid
    $_->{'asc_selected'}  = $sort_by eq $_->{'type'}.'_'.$_->{'code'}.' asc';
    $_->{'desc_selected'} = $sort_by eq $_->{'type'}.'_'.$_->{'code'}.' desc';
}

$template->param(
    'sort_by'  => $sort_by,
    'sortloop' => $sortloop,
);

# The following should only be loaded if we're bringing up the advanced search template
if ( $template_type eq 'advsearch' ) {

    $template->param(
        $sort_by => 1
    );

    # determine what to display next to the search boxes (ie, boolean option
    # shouldn't appear on the first one, scan indexes should, adding a new
    # box should only appear on the last, etc.
    my @search_boxes_array;
    my $search_boxes_count = C4::Context->preference("OPACAdvSearchInputCount") || 3;    # FIXME: using OPAC sysprefs?
                                                                                         # FIXME: all this junk can be done in TMPL using __first__ and __last__

    for ( my $i = 1 ; $i <= $search_boxes_count ; $i++ ) {

        # if it's the first one, don't display boolean option, but show scan indexes
        if ( $i == 1 ) {
            push @search_boxes_array, { scan_index => 1 };
        }

        # if it's the last one, show the 'add field' box
        elsif ( $i == $search_boxes_count ) {
            push @search_boxes_array,
              { boolean   => 1,
                add_field => 1,
              };
        } else {
            push @search_boxes_array, { boolean => 1, };
        }
    }
    $template->param(
        uc( C4::Context->preference("marcflavour") ) => 1,
        search_boxes_loop                            => \@search_boxes_array,
        indexandavlist                               => $indexandavlist
    );

    # load the language limits (for search)
    $template->param( search_languages_loop => getAllLanguagesAuthorizedValues() );
    $template->param( lang_index => C4::Search::Query::getIndexName('lang') );

    # use the global setting by default
    if ( C4::Context->preference("expandedSearchOption") == 1 ) {
        $template->param( expanded_options => C4::Context->preference("expandedSearchOption") );
    }

    # but let the user override it
    if ( ( $cgi->param('expanded_options') == 0 ) || ( $cgi->param('expanded_options') == 1 ) ) {
        $template->param( expanded_options => $cgi->param('expanded_options') );
    }

    if ( C4::Context->preference("AdvancedSearchContent") ne '' ) {
        $template->param( AdvancedSearchContent => C4::Context->preference("AdvancedSearchContent") ); 
    }

    $template->param( virtualshelves => C4::Context->preference("virtualshelves") );

    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit;
}

### OK, if we're this far, we're performing a search, not just loading the advanced search page

# Params that can only have one value
my $count            = C4::Context->preference('OPACnumSearchResults') || 20;
my $page             = $cgi->param('page') || 1;

#clean operands array
for (my $i = $#indexes; $i >= 0; $i--) {
  splice @indexes,$i,1 if $i > $#operands;
}

# construct query as itype:(@itypes[0] OR @itypes[1]) - item type advanced search
my $itype_val_str="";
if ( scalar( @itypes ) != 0 and $cgi->param('itypes') ) {
    $itype_val_str = join ' OR ', @itypes ;
    $itype_val_str = "($itype_val_str)";
    if ( not @indexes ) {
        $operands[0] .= " AND " if $operands[0];
        $operands[0] .= "$itype_or_ccode:$itype_val_str";
    } else {
        push @operators, "AND";
        push @operands, $itype_val_str;
        push @indexes, $itype_or_ccode;
    }
}

my %filters;
# This array is used to build facets GUI
my @tplfilters;
for my $filter ( $cgi->param('filters') ) {
    my ($k, $v) = split /:/, $filter; #FIXME If ':' exists in value
    $filters{$k} = $v;
    $v =~ s/"//g;
    push @tplfilters, {
        'ind' => $k,
        'val' => $v,
    };
}
$filters{recordtype} = 'biblio';
$template->param('filters' => \@tplfilters );


# append year limits if they exist
my $limit_yr = $cgi->param('limit-yr');
if ( $limit_yr ) {
    my $op;
    if ( $limit_yr =~ /\d{4}-\d{4}/ ) {
        my ( $yr1, $yr2 ) = split( /-/, $limit_yr );
        $op = '["' . C4::Search::Engine::Solr::NormalizeDate( $yr1 ) . '" TO "' . C4::Search::Engine::Solr::NormalizeDate( $yr2 ) . '"]';
    } elsif ( $limit_yr =~ /-\d{4}/ ) {
        $limit_yr =~ /-(\d{4})/;
        $op = '[* TO "' . C4::Search::Engine::Solr::NormalizeDate( $1 ) . '"]';
    } elsif ( $limit_yr =~ /\d{4}-/ ) {
        $limit_yr =~ /(\d{4})-/;
        $op = '["' . C4::Search::Engine::Solr::NormalizeDate( $1 ) . '" TO *]';
    } elsif ( $limit_yr =~ /\d{4}/ ) {
        $op = '"' . C4::Search::Engine::Solr::NormalizeDate( $limit_yr ) . '"';
    } else {
        #FIXME: Should return a error to the user, incorect date format specified
    }
    if ( not @indexes ) {
        $operands[0] .= " AND " if $operands[0];
        $operands[0] .= "$op";
    } else {
        push @operands, $op;
        push @operators, 'AND';
        push @indexes, "date_pubdate";
    }
}

my $q = C4::Search::Query->buildQuery(\@indexes, \@operands, \@operators);

my $res = SimpleSearch( $q, \%filters, $page, $count, $sort_by);
C4::Context->preference("DebugLevel") eq '2' && warn "ProSolrSimpleSearch:q=$q:";

if (!$res){
    $template->param(query_error => "Bad request! help message ?");
    output_with_http_headers $cgi, $cookie, $template->output, 'html';
    exit;
}

my $pager = Data::Pagination->new(
    $res->{'pager'}->{'total_entries'},
    $count,
    20,
    $page,
);

# This array is used to build pagination, facets links and itypes, sort form
my @follower_params = map { {
    ind => 'filters',
    val => $_->{'ind'}.':"'.$_->{'val'}.'"'
} } @tplfilters;
push @follower_params, map { { ind => 'q'      , val => $_ } } @operands;
push @follower_params, map { { ind => 'idx'    , val => $_ } } @indexes;
push @follower_params, map { { ind => 'op'     , val => $_ } } @operators;
push @follower_params, { ind => 'sort_by', val => $sort_by };

# Pager template params
$template->param(
    previous_page => $pager->{'prev_page'},
    next_page     => $pager->{'next_page'},
    PAGE_NUMBERS  => [ map { { page => $_, current => $_ == $page } } @{ $pager->{'numbers_of_set'} } ],
    current_page  => $page,
    follower_params  => \@follower_params,
);

# populate results with records
my @results;
my $subfieldstosearch = C4::Search::getSubfieldsToSearch();
my $itemtag = C4::Search::getItemTag();
my $b = C4::Search::getBranches();
for my $searchresult ( @{ $res->items } ) {
    my $interface = 'intranet';
    my $biblionumber = $searchresult->{'values'}->{'recordid'};

    my $biblio = C4::Search::getItemsInfos($biblionumber, $interface,
        $itemtypes, $subfieldstosearch, $itemtag, $b);

    push( @results, $biblio );
}

# build facets
my @facets;
while ( my ($index,$facet) = each %{$res->facets} ) {
    if ( @$facet > 1 ) {
        my @values;
        my ($type, $code) = split /_/, $index;
        for ( my $i = 0 ; $i < scalar(@$facet) ; $i++ ) {
            my $value = $facet->[$i++];
            my $count = $facet->[$i];
            utf8::encode($value);            
            my $lib;
            if ( $code =~/branch/ ) {
                $lib = GetBranchName $value;
            }
            if ( $code =~/itype/ ) {
                $lib = GetSupportName $value;
            }
            if ( my $avlist=C4::Search::Engine::Solr::GetAvlistFromCode($code) ) {
                $lib = GetAuthorisedValueLib $avlist,$value;
            }
            $lib ||=$value;
            push @values, {
                'lib'     => $lib,
                'value'   => $value,
                'count'   => $count,
                'active'  => $filters{$index} && $filters{$index} eq "\"$value\"",
                'filters' => \@tplfilters,
            };
        }
        push @facets, {
            'index'  => $index,
            'label'  => C4::Search::Engine::Solr::GetIndexLabelFromCode($code),
            'values' => \@values,
        };
    }
}

$template->param(
    'total'          => $res->{'pager'}->{'total_entries'},
    'opacfacets'     => 1,
    'SEARCH_RESULTS' => \@results,
    'facets_loop'    => \@facets,
    'query'          => $q,
    'query_desc'     => $q,
    'search_desc'    => $q,
    'availability'   => $filters{'int_availability'},
    'count'          => C4::Context->preference('OPACnumSearchResults') || 20,
    author_indexname => C4::Search::Query::getIndexName('author'),
);

# VI. BUILD THE TEMPLATE

# Build drop-down list for 'Add To:' menu...

my $row_count = 10;    # FIXME:This probably should be a syspref
my ( $pubshelves, $total ) = GetRecentShelves( 2, $row_count, undef );
my ( $barshelves, $total ) = GetRecentShelves( 1, undef,      $borrowernumber );

my @pubshelves = @{$pubshelves};
my @barshelves = @{$barshelves};

if (@pubshelves) {
    $template->param( addpubshelves     => scalar(@pubshelves) );
    $template->param( addpubshelvesloop => @pubshelves );
}

if (@barshelves) {
    $template->param( addbarshelves     => scalar(@barshelves) );
    $template->param( addbarshelvesloop => @barshelves );
}

output_html_with_http_headers $cgi, $cookie, $template->output;
