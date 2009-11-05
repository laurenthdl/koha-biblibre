#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


=head1 NAME

opac-ISBDdetail.pl : script to show a biblio in ISBD format


=head1 DESCRIPTION

This script needs a biblionumber as parameter 

It shows the biblio

The template is in <templates_dir>/catalogue/ISBDdetail.tmpl.
this template must be divided into 11 "tabs".

The first 10 tabs present the biblio, the 11th one presents
the items attached to the biblio

=head1 FUNCTIONS

=over 2

=cut

use strict;
use warnings;

use C4::Auth;
use C4::Context;
use C4::Output;
use CGI;
use MARC::Record;
use C4::Biblio;
use C4::Items;
use C4::Acquisition;
use C4::External::Amazon;
use C4::Review;
use C4::Serials;    # uses getsubscriptionfrom biblionumber
use C4::Koha;       # use getitemtypeinfo
use C4::Members;    # GetMember

my $query = CGI->new();
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-ISBDdetail.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
        debug           => 1,
    }
);

my $biblionumber = $query->param('biblionumber');

my $marcflavour      = C4::Context->preference("marcflavour");
my $record = GetMarcBiblio($biblionumber);

#coping with subscriptions
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);
my $dbh = C4::Context->dbh;
my $dat                 = TransformMarcToKoha( $dbh, $record );
my @subscriptions       =
  GetSubscriptions( $dat->{title}, $dat->{issn}, $biblionumber );
my @subs;
foreach my $subscription (@subscriptions) {
    my %cell;
    $cell{subscriptionid}    = $subscription->{subscriptionid};
    $cell{subscriptionnotes} = $subscription->{notes};
    $cell{branchcode}        = $subscription->{branchcode};

    #get the three latest serials.
    $cell{latestserials} =
      GetLatestSerials( $subscription->{subscriptionid}, 3 );
    push @subs, \%cell;
}

$template->param(
    subscriptions       => \@subs,
    subscriptionsnumber => $subscriptionsnumber,
);

my $norequests = 1;
my $res = GetISBDView($biblionumber, "opac");
my @items = &GetItemsInfo($biblionumber, 'opac');

my $itemtypes = GetItemTypes();
for my $itm (@items) {
    $norequests = 0
       if ( (not $itm->{'wthdrawn'} )
         && (not $itm->{'itemlost'} )
         && ($itm->{'itemnotforloan'}<0 || not $itm->{'itemnotforloan'} )
		 && (not $itemtypes->{$itm->{'itype'}}->{notforloan} )
         && ($itm->{'itemnumber'} ) );
}

my $reviews = getreviews( $biblionumber, 1 );
foreach ( @$reviews ) {
    my $borrower_number_review = $_->{borrowernumber};
    my $borrowerData           = GetMember($borrower_number_review,'borrowernumber');
    # setting some borrower info into this hash
    $_->{title}     = $borrowerData->{'title'};
    $_->{surname}   = $borrowerData->{'surname'};
    $_->{firstname} = $borrowerData->{'firstname'};
}


$template->param(
    RequestOnOpac       => C4::Context->preference("RequestOnOpac"),
    AllowOnShelfHolds   => C4::Context->preference('AllowOnShelfHolds'),
    norequests   => $norequests,
    ISBD         => $res,
    biblionumber => $biblionumber,
    reviews             => $reviews,
);
    my @services;
	my $amazon_reviews  = C4::Context->preference("AmazonReviews");
	my $amazon_similars = C4::Context->preference("AmazonSimilarItems");
		
    if ( $amazon_reviews ) {
        $template->param( AmazonReviews => 1 );
        push( @services, 'EditorialReview' );
    }
    if ( $amazon_similars ) {
        $template->param( AmazonSimilarItems => 1 );
        push( @services, 'Similarities' );
    }

## Amazon.com stuff
#not used unless preference set
if ( C4::Context->preference("AmazonContent") == 1 ) {
    use C4::External::Amazon;
    $dat->{'amazonisbn'} = $dat->{'isbn'};
    $dat->{'amazonisbn'} =~ s|-||g;

    $template->param( amazonisbn => $dat->{amazonisbn} );

    my $amazon_details = &get_amazon_details( $dat->{amazonisbn}, $record, $marcflavour );

    foreach my $result ( @{ $amazon_details->{Details} } ) {
        $template->param( item_description => $result->{ProductDescription} );
        $template->param( image            => $result->{ImageUrlMedium} );
        $template->param( list_price       => $result->{ListPrice} );
        $template->param( amazon_url       => $result->{url} );
    }

    my @products;
    my @reviews;
    for my $details ( @{ $amazon_details->{Details} } ) {
        next unless $details->{SimilarProducts};
        for my $product ( @{ $details->{SimilarProducts}->{Product} } ) {
            push @products, +{ Product => $product };
        }
        next unless $details->{Reviews};
        for my $product ( @{ $details->{Reviews}->{AvgCustomerRating} } ) {
            $template->param( rating => $product * 20 );
        }
        for my $reviews ( @{ $details->{Reviews}->{CustomerReview} } ) {
            push @reviews,
              +{
                Summary => $reviews->{Summary},
                Comment => $reviews->{Comment},
              };
        }
    }
    $template->param( SIMILAR_PRODUCTS => \@products );
    $template->param( AMAZONREVIEWS    => \@reviews );
}

output_html_with_http_headers $query, $cookie, $template->output;
