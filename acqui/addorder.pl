#!/usr/bin/perl

#script to add an order into the system
#written 29/2/00 by chris@katipo.co.nz

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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

addorder.pl

=head1 DESCRIPTION

this script allows to add an order.
It is called by :

=item neworderbiblio.pl to add an order from nothing.

=item neworderempty.pl to add an order from an existing biblio.

=item newordersuggestion.pl to add an order from an existing suggestion.

=head1 CGI PARAMETERS

All of the cgi parameters below are related to the new order.

=over 4

=item C<ordernumber>
the number of this new order.

=item C<basketno>
the number of this new basket

=item C<booksellerid>
the bookseller the librarian has to pay.

=item C<existing>

=item C<title>
the title of the record ordered.

=item C<author>
the author of the record ordered.

=item C<copyrightdate>
the copyrightdate of the record ordered.

=item C<ISBN>
the ISBN of the record ordered.

=item C<format>

=item C<quantity>
the quantity to order.

=item C<list_price>
the price of this order.

=item C<uncertainprice>
uncertain price, can't close basket until prices of all orders are known.

=item C<branch>
the branch where this order will be received.

=item C<series>

=item C<notes>
Notes on this basket.

=item C<budget_id>
budget_id used to pay this order.

=item C<sort1> & C<sort2>

=item C<rrp>

=item C<ecost>

=item C<GST>

=item C<budget>

=item C<cost>

=item C<sub>

=item C<invoice>
the number of the invoice for this order.

=item C<publishercode>

=item C<suggestionid>
if it is an order from an existing suggestion : the id of this suggestion.

=item C<donation>

=back

=cut

use strict;
use warnings;
use CGI;
use C4::Auth;           # get_template_and_user
use C4::Acquisition;    # NewOrder DelOrder ModOrder
use C4::Suggestions;    # ModStatus
use C4::Biblio;         # AddBiblio TransformKohaToMarc
use C4::Bookseller;     # GetBookSellerFromId
use C4::Budgets;
use C4::Items;
use C4::Output;

### "-------------------- addorder.pl ----------"

# FIXME: This needs to do actual error checking and possibly return user to the same form,
# not just blindly call C4 functions and print a redirect.

my $input = new CGI;
### $input

# Check if order total amount exceed allowed budget
my $confirm_budget_exceeding = $input->param('confirm_budget_exceeding');
unless($confirm_budget_exceeding) {
    my $budget_id = $input->param('budget_id');
    my $total = $input->param('total');
    my $budget = GetBudget($budget_id);
    my $budget_spent = GetBudgetSpent($budget_id);
    my $budget_ordered = GetBudgetOrdered($budget_id);
    my $budget_used = $budget_spent + $budget_ordered;
    my $budget_remaining = $budget->{'budget_amount'} - $budget_used;
    my $budget_encumbrance = $budget->{'budget_amount'} * $budget->{'budget_encumb'} / 100;
    my $budget_expenditure = $budget->{'budget_expend'};

    if ( $total > $budget_remaining
      || ( ($budget_encumbrance+0) && ($budget_used + $total) > $budget_encumbrance)
      || ( ($budget_expenditure+0) && ($budget_used + $total) > $budget_expenditure) )
    {
        my ($template, $loggedinuser, $cookie) = get_template_and_user({
            template_name   => "acqui/addorder.tmpl",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => {acquisition => 'order_manage'},
        });

        my $url = $input->referer();
        if(!defined $url) {
            my $basketno = $input->param('basketno');
            $url = "/cgi-bin/koha/acqui/basket.pl?basketno=$basketno";
        }

        my $vars = $input->Vars;
        my @vars_loop;
        foreach (keys %$vars) {
            unless($_ eq "field_value" || $_ eq "itemid" || $_ eq "kohafield" || $_ eq "tag" || $_ eq "subfield" || $_ eq "mandatory") {
                push @vars_loop, {
                    name => $_,
                    value => $vars->{$_},
                };
            }
        }

        my @field_value_loop;
        push @field_value_loop, {value => $_} for $input->param('field_value');

        my @itemid_loop;
        push @itemid_loop, {value => $_} for $input->param('itemid');

        my @kohafield_loop;
        push @kohafield_loop, {value => $_} for $input->param('kohafield');

        my @tag_loop;
        push @tag_loop, {value => $_} for $input->param('tag');

        my @subfield_loop;
        push @subfield_loop, {value => $_} for $input->param('subfield');

        my @mandatory_loop;
        push @mandatory_loop, {value => $_} for $input->param('mandatory');

        if( ($budget_encumbrance+0) && ($budget_used + $total) > $budget_encumbrance
          && $total <= $budget_remaining)
        {
            $template->param(
                encumbrance_exceeded => 1,
                encumbrance => sprintf("%.2f", $budget->{'budget_encumb'}),
            );
        }
        if( ($budget_expenditure+0) && ($budget_used + $total) > $budget_expenditure
          && $total <= $budget_remaining )
        {
            my $currency = GetCurrency;
            $template->param(
                expenditure_exceeded => 1,
                expenditure => sprintf("%.2f", $budget_expenditure),
                currency => ($currency) ? $currency->{'symbol'} : '',
            );
        }
        if($total > $budget_remaining){
            $template->param(budget_exceeded => 1);
        }

        $template->param(
            not_enough_budget => 1,
            referer => $url,
            vars_loop => \@vars_loop,
            field_value => \@field_value_loop,
            itemid => \@itemid_loop,
            kohafield => \@kohafield_loop,
            tag => \@tag_loop,
            subfield => \@subfield_loop,
            mandatory => \@mandatory_loop,
        );
        output_html_with_http_headers $input, $cookie, $template->output;
        exit;
    }
}

# get_template_and_user used only to check auth & get user id
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "acqui/booksellers.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_manage' },
        debug           => 1,
    }
);

# get CGI parameters
my $orderinfo = $input->Vars;
$orderinfo->{'list_price'} ||= 0;
$orderinfo->{'uncertainprice'} ||= 0;
$$orderinfo{subscriptionid} ||= undef;

my $user = $input->remote_user;

# create, modify or delete biblio
# create if $quantity>=0 and $existing='no'
# modify if $quantity>=0 and $existing='yes'
# delete if $quantity has been set to 0 by the librarian
my $bibitemnum;
if ( $orderinfo->{quantity} ne '0' ) {

# Getting bookseller's name
my $supplierreference;
if ($$orderinfo{booksellerid}) {
    my $bookseller = GetBookSellerFromId($$orderinfo{booksellerid});
    $supplierreference = $bookseller->{name};
}


# Do we have to add order informations to the marc record?
my ($ordertag, $ordersubtag) = GetMarcFromKohaField('aqorders.ordernumber', 'ACQ'); 
my $record;
my $existingbiblio; # Was the order made on an existing biblio?
my $ordermodif;     # Is this an order modification?

   #TODO:check to see if biblio exists
    unless ( $$orderinfo{biblionumber} ) {

        #if it doesnt create it
        my $tmprecord = TransformKohaToMarc(
            {   "biblio.title"                => "$$orderinfo{title}",
                "biblio.author"               => "$$orderinfo{author}",
                "biblio.seriestitle"          => $$orderinfo{series} ? $$orderinfo{series} : "",
                "biblioitems.isbn"            => $$orderinfo{isbn} ? $$orderinfo{isbn} : "",
                "biblioitems.ean"             => $$orderinfo{ean} ? $$orderinfo{ean} : "",
                "biblioitems.publishercode"   => $$orderinfo{publishercode} ? $$orderinfo{publishercode} : "",
                "biblioitems.publicationyear" => $$orderinfo{publicationyear} ? $$orderinfo{publicationyear} : "",
                "biblioitems.itemtype"        => $$orderinfo{itemtype} ? $$orderinfo{itemtype} : "",
                "biblioitems.editionstatement" => $$orderinfo{editionstatement} ? $$orderinfo{editionstatement} : "",
                "aqorders.branchcode"         => $$orderinfo{branchcode} ? $$orderinfo{branchcode} : "",
                "aqorders.quantity"           => $$orderinfo{quantity} ? $$orderinfo{quantity} : "",
                "aqorders.listprice"          => $$orderinfo{listprice} ? $$orderinfo{listprice} : "",
                "aqorders.uncertainprice"     => $$orderinfo{uncertainprice} ? $$orderinfo{uncertainprice} : "",
                "aqorders.rrp"                => $$orderinfo{rrp} ? $$orderinfo{rrp} : "",
                "aqorders.ecost"              => $$orderinfo{ecost} ? $$orderinfo{ecost} : "",
                "aqorders.discount"           => $$orderinfo{discount} ? $$orderinfo{discount} : "",
                "aqorders.notes"              => $$orderinfo{notes} ? $$orderinfo{notes} : "",
                "aqorders.supplierreference"  => $supplierreference ? $supplierreference : "",
                "aqorders.sort1"              => $$orderinfo{sort1} ? $$orderinfo{sort1} : "",
                "aqorders.sort2"              => $$orderinfo{sort2} ? $$orderinfo{sort2} : ""
            }
        );

        # create the record in catalogue, with framework ''
        my ( $biblionumber, $bibitemnum ) = AddBiblio( $tmprecord, '' );


        # change suggestion status if applicable
        if ( $$orderinfo{suggestionid} ) {
            ModSuggestion( { suggestionid => $$orderinfo{suggestionid}, status => 'ORDERED', biblionumber => $biblionumber } );
        }
        $orderinfo->{biblioitemnumber} = $bibitemnum;
        $orderinfo->{biblionumber}     = $biblionumber;
    } else {
	$existingbiblio = 1;
    }

    # Getting record
    $record = GetMarcBiblio($$orderinfo{biblionumber});

    $$orderinfo{unitprice} = $$orderinfo{ecost} if not defined $$orderinfo{unitprice} or $$orderinfo{unitprice} eq '';

     # if we already have $ordernumber, then it's an ordermodif
    if ( $$orderinfo{ordernumber} ) {
        ModOrder($orderinfo);
	$ordermodif = 1;
	
    } else {    # else, it's a new line
        @$orderinfo{qw(basketno ordernumber )} = NewOrder($orderinfo);

	# We have to add the ordernumber in the designated subfield
	if ($ordertag && $record && !$ordermodif) {
	    # To which field do we add it : to the one with currently no ordernumber
	    foreach ($record->field($ordertag)) {
		if (!$_->subfield($ordersubtag)) {
		    $_->update($ordersubtag, $$orderinfo{ordernumber});
		}
	    }
	    ModBiblio($record, $$orderinfo{biblionumber}, 'ACQ');
	}


    }

    if ($record) {

	# If we have to add order infos to the marc record
	if ($ordertag) {

	    # If the order was made on an existing biblio and it is not a modification, we add the field 
	    $record->insert_fields_ordered(new MARC::Field($ordertag, '', '', $ordersubtag => $$orderinfo{ordernumber})) if (!$ordermodif && $existingbiblio);

	    foreach ($record->field($ordertag)) {
		# Looking for the matching one
		if ($_->subfield($ordersubtag) eq $$orderinfo{ordernumber}) {

		    # Replacing or creating subfields
		    my ($t, $st);
		    for my $tablefield (qw/branchcode quantity listprice uncertainprice rrp ecost notes supplierreference sort1 sort2/) {
			($t, $st) = GetMarcFromKohaField("aqorders.$tablefield", 'ACQ');
			$_->update($st, $$orderinfo{$tablefield}) if ($$orderinfo{$tablefield} and $st);
		    }
		    ModBiblio($record, $$orderinfo{biblionumber}, 'ACQ');
		}
	    }

	}

    }


    
      # now, add items if applicable
    if ( C4::Context->preference('AcqCreateItem') eq 'ordering' ) {

        my @tags         = $input->param('tag');
        my @subfields    = $input->param('subfield');
        my @field_values = $input->param('field_value');
        my @serials      = $input->param('serial');
        my @itemid       = $input->param('itemid');
        my @ind_tag      = $input->param('ind_tag');
        my @indicator    = $input->param('indicator');

        #Rebuilding ALL the data for items into a hash
        # parting them on $itemid.

        my %itemhash;
        my $countdistinct;
        my $range = scalar(@itemid);
        for ( my $i = 0 ; $i < $range ; $i++ ) {
            unless ( $itemhash{ $itemid[$i] } ) {
                $countdistinct++;
            }
            push @{ $itemhash{ $itemid[$i] }->{'tags'} },         $tags[$i];
            push @{ $itemhash{ $itemid[$i] }->{'subfields'} },    $subfields[$i];
            push @{ $itemhash{ $itemid[$i] }->{'field_values'} }, $field_values[$i];
            push @{ $itemhash{ $itemid[$i] }->{'ind_tag'} },      $ind_tag[$i];
            push @{ $itemhash{ $itemid[$i] }->{'indicator'} },    $indicator[$i];
        }
        foreach my $item ( keys %itemhash ) {

            my $xml = TransformHtmlToXml(
                $itemhash{$item}->{'tags'},
                $itemhash{$item}->{'subfields'},
                $itemhash{$item}->{'field_values'},
                $itemhash{$item}->{'ind_tag'},
                $itemhash{$item}->{'indicator'}, 'ITEM'
            );
            my $record = MARC::Record::new_from_xml( $xml, 'UTF-8' );
            my ( $biblionumber, $bibitemnum, $itemnumber ) = AddItemFromMarc( $record, $$orderinfo{biblionumber} );
            NewOrderItem( $itemnumber, $$orderinfo{parent_ordernumber} );

        }
    }

}

else {    # qty=0, delete the line
    my $biblionumber = $input->param('biblionumber');
    DelOrder( $biblionumber, $$orderinfo{ordernumber} );
}
my $basketno     = $$orderinfo{basketno};
my $booksellerid = $$orderinfo{booksellerid};
if ( my $import_batch_id = $$orderinfo{import_batch_id} ) {
    print $input->redirect("/cgi-bin/koha/acqui/addorderiso2709.pl?import_batch_id=$import_batch_id&basketno=$basketno&booksellerid=$booksellerid");
} else {
    print $input->redirect("/cgi-bin/koha/acqui/basket.pl?basketno=$basketno");
}
