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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;

#use warnings; FIXME - Bug 2505
use CGI;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Context;
use C4::Koha;      # XXX subfield_is_koha_internal_p
use C4::Branch;    # XXX subfield_is_koha_internal_p
use C4::ClassSource;
use C4::Dates;
use List::MoreUtils qw/any/;
use Storable qw(thaw freeze);
use URI::Escape;



use MARC::File::XML;

sub find_value {
    my ( $tagfield, $insubfield, $record ) = @_;
    my $result;
    my $indicator;
    foreach my $field ( $record->field($tagfield) ) {
        my @subfields = $field->subfields();
        foreach my $subfield (@subfields) {
            if ( @$subfield[0] eq $insubfield ) {
                $result .= @$subfield[1];
                $indicator = $field->indicator(1) . $field->indicator(2);
            }
        }
    }
    return ( $indicator, $result );
}

sub get_item_from_barcode {
    my ($barcode) = @_;
    my $dbh = C4::Context->dbh;
    my $result;
    my $rq = $dbh->prepare("SELECT itemnumber from items where items.barcode=?");
    $rq->execute($barcode);
    ($result) = $rq->fetchrow;
    return ($result);
}

sub set_item_default_location {
    my $itemnumber = shift;
    if ( C4::Context->preference('NewItemsDefaultLocation') ) {
        my $item = GetItem($itemnumber);
        $item->{'permanent_location'} = $item->{'location'};
        $item->{'location'}           = C4::Context->preference('NewItemsDefaultLocation');
        ModItem( $item, undef, $itemnumber );
    }
}

sub generate_subfield_form {
        my ($tag, $subfieldtag, $value, $tagslib,$subfieldlib, $branches, $today_iso, $biblionumber, $temp, $loop_data, $i) = @_;
        
        my %subfield_data;
        my $dbh = C4::Context->dbh;        
        my $authorised_values_sth = $dbh->prepare("SELECT authorised_value,lib FROM authorised_values WHERE category=? ORDER BY lib");
        
        my $index_subfield = int(rand(1000000)); 
        if ($subfieldtag eq '@'){
            $subfield_data{id} = "tag_".$tag."_subfield_00_".$index_subfield;
        } else {
            $subfield_data{id} = "tag_".$tag."_subfield_".$subfieldtag."_".$index_subfield;
        }
        
        $subfield_data{tag}        = $tag;
        $subfield_data{subfield}   = $subfieldtag;
        $subfield_data{random}     = int(rand(1000000));    # why do we need 2 different randoms?
        $subfield_data{marc_lib}   ="<span id=\"error$i\" title=\"".$subfieldlib->{lib}."\">".$subfieldlib->{lib}."</span>";
        $subfield_data{mandatory}  = $subfieldlib->{mandatory};
        $subfield_data{repeatable} = $subfieldlib->{repeatable};
        
        $value =~ s/"/&quot;/g;
        if ( ! defined( $value ) || $value eq '')  {
            $value = $subfieldlib->{defaultvalue};
            # get today date & replace YYYY, MM, DD if provided in the default value
            my ( $year, $month, $day ) = split ',', $today_iso;     # FIXME: iso dates don't have commas!
            $value =~ s/YYYY/$year/g;
            $value =~ s/MM/$month/g;
            $value =~ s/DD/$day/g;
        }
        
        $subfield_data{visibility} = "display:none;" if (($subfieldlib->{hidden} > 4) || ($subfieldlib->{hidden} < -4));
        
        my $pref_itemcallnumber = C4::Context->preference('itemcallnumber');
        if (!$value && $subfieldlib->{kohafield} eq 'items.itemcallnumber' && $pref_itemcallnumber) {
            my $CNtag       = substr($pref_itemcallnumber, 0, 3);
            my $CNsubfield  = substr($pref_itemcallnumber, 3, 1);
            my $CNsubfield2 = substr($pref_itemcallnumber, 4, 1);
            my $temp2 = $temp->field($CNtag);
            if ($temp2) {
                $value = ($temp2->subfield($CNsubfield)).' '.($temp2->subfield($CNsubfield2));
                #remove any trailing space incase one subfield is used
                $value =~ s/^\s+|\s+$//g;
            }
        }
        
        my $attributes_no_value = qq(tabindex="1" id="$subfield_data{id}" name="field_value" class="input_marceditor" size="67" maxlength="255" );
        my $attributes          = qq($attributes_no_value value="$value" );
        
        if ( $subfieldlib->{authorised_value} ) {
            my @authorised_values;
            my %authorised_lib;
            # builds list, depending on authorised value...
            if ( $subfieldlib->{authorised_value} eq "branches" ) {
                foreach my $thisbranch (@$branches) {
                    push @authorised_values, $thisbranch->{value};
                    $authorised_lib{$thisbranch->{value}} = $thisbranch->{branchname};
                    $value = $thisbranch->{value} if ($thisbranch->{selected} and !$value);
                }
            }
            elsif ( $subfieldlib->{authorised_value} eq "itemtypes" ) {
                  push @authorised_values, "" unless ( $subfieldlib->{mandatory} );
                  my $sth = $dbh->prepare("SELECT itemtype,description FROM itemtypes ORDER BY description");
                  $sth->execute;
                  while ( my ( $itemtype, $description ) = $sth->fetchrow_array ) {
                      push @authorised_values, $itemtype;
                      $authorised_lib{$itemtype} = $description;
                  }
        
                  unless ( $value ) {
                      my $itype_sth = $dbh->prepare("SELECT itemtype FROM biblioitems WHERE biblionumber = ?");
                      $itype_sth->execute( $biblionumber );
                      ( $value ) = $itype_sth->fetchrow_array;
                  }
          
                  #---- class_sources
            }
            elsif ( $subfieldlib->{authorised_value} eq "cn_source" ) {
                  push @authorised_values, "" unless ( $subfieldlib->{mandatory} );
                    
                  my $class_sources = GetClassSources();
                  my $default_source = C4::Context->preference("DefaultClassificationSource");
                  
                  foreach my $class_source (sort keys %$class_sources) {
                      next unless $class_sources->{$class_source}->{'used'} or
                                  ($value and $class_source eq $value)      or
                                  ($class_source eq $default_source);
                      push @authorised_values, $class_source;
                      $authorised_lib{$class_source} = $class_sources->{$class_source}->{'description'};
                  }
        		  $value = $default_source unless ($value);
        
                  #---- "true" authorised value
            }
            else {
                  push @authorised_values, "" unless ( $subfieldlib->{mandatory} );
                  $authorised_values_sth->execute( $subfieldlib->{authorised_value} );
                  while ( my ( $value, $lib ) = $authorised_values_sth->fetchrow_array ) {
                      push @authorised_values, $value;
                      $authorised_lib{$value} = $lib;
                  }
            }

            $subfield_data{marc_value} =CGI::scrolling_list(      # FIXME: factor out scrolling_list
                  -name     => "field_value",
                  -values   => \@authorised_values,
                  -default  => $value,
                  -labels   => \%authorised_lib,
                  -override => 1,
                  -size     => 1,
                  -multiple => 0,
                  -tabindex => 1,
                  -id       => "tag_".$tag."_subfield_".$subfieldtag."_".$index_subfield,
                  -class    => "input_marceditor",
            );

            # it's a thesaurus / authority field
        }
        elsif ( $subfieldlib->{authtypecode} ) {
                $subfield_data{marc_value} = "<input type=\"text\" $attributes />
                    <a href=\"#\" class=\"buttonDot\"
                        onclick=\"Dopop('/cgi-bin/koha/authorities/auth_finder.pl?authtypecode=".$subfieldlib->{authtypecode}."&index=$subfield_data{id}','$subfield_data{id}'); return false;\" title=\"Tag Editor\">...</a>
            ";
            # it's a plugin field
        }
        elsif ( $subfieldlib->{value_builder} ) {
                # opening plugin
                my $plugin = C4::Context->intranetdir . "/cataloguing/value_builder/" . $subfieldlib->{'value_builder'};
                if (do $plugin) {
                    my $extended_param = plugin_parameters( $dbh, $temp, $tagslib, $subfield_data{id}, $loop_data );
                    my ( $function_name, $javascript ) = plugin_javascript( $dbh, $temp, $tagslib, $subfield_data{id}, $loop_data );
                    $subfield_data{marc_value} = qq[<input $attributes
                        onfocus="Focus$function_name($subfield_data{random}, '$subfield_data{id}');"
                         onblur=" Blur$function_name($subfield_data{random}, '$subfield_data{id}');" />
                        <a href="#" class="buttonDot" onclick="Clic$function_name('$subfield_data{id}'); return false;" title="Tag Editor">...</a>
                        $javascript];
                } else {
                    warn "Plugin Failed: $plugin";
                    $subfield_data{marc_value} = "<input $attributes />"; # supply default input form
                }
        }
        elsif ( $tag eq '' ) {       # it's an hidden field
            $subfield_data{marc_value} = qq(<input type="hidden" $attributes />);
        }
        elsif ( $subfieldlib->{'hidden'} ) {   # FIXME: shouldn't input type be "hidden" ?
            $subfield_data{marc_value} = qq(<input type="text" $attributes />);
        }
        elsif ( length($value) > 100
                    or (C4::Context->preference("marcflavour") eq "UNIMARC" and
                          300 <= $tag && $tag < 400 && $subfieldtag eq 'a' )
                    or (C4::Context->preference("marcflavour") eq "MARC21"  and
                          500 <= $tag && $tag < 600                     )
                  ) {
            # oversize field (textarea)
            $subfield_data{marc_value} = "<textarea $attributes_no_value>$value</textarea>\n";
        } else {
           # it's a standard field
           $subfield_data{marc_value} = "<input $attributes />";
        }
        
        return \%subfield_data;
}

sub removeFieldsForPrefill {
    #FIXME: this is not generic enough
    my $item = shift;
    my $subfieldsToDiscardWhenPrefill = C4::Context->preference('SubfieldsToDiscardWhenPrefill') || "f u";
    my @subfieldsToDiscard= split(/ /,$subfieldsToDiscardWhenPrefill);
    my $field = $item->field('995');
    foreach my $subfieldsDiscard(@subfieldsToDiscard) {
		$field->delete_subfield(code => $subfieldsDiscard);
	}
    return $item;

}

my $input = new CGI;
my $dbh = C4::Context->dbh;
my $error        = $input->param('error');
my $biblionumber = $input->param('biblionumber');
my $itemnumber   = $input->param('itemnumber');
my $op           = $input->param('op');

my $frameworkcode = &GetFrameworkCode($biblionumber);

# Defining which userflag is needing according to the framework currently used
my $userflags;
if ( defined $input->param('frameworkcode') ) {
    $userflags = ( $input->param('frameworkcode') eq 'FA' ) ? "fast_cataloging" : "edit_items";
}

if ( not defined $userflags ) {
    $userflags = ( $frameworkcode eq 'FA' ) ? "fast_cataloging" : "edit_items";
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "cataloguing/additem.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => $userflags },
        debug           => 1,
    }
);

my $today_iso = C4::Dates->today('iso');
$template->param( today_iso => $today_iso );

my $tagslib   = &GetMarcStructure( 1, $frameworkcode );
my $record    = GetMarcBiblio($biblionumber);
my $oldrecord = TransformMarcToKoha( $dbh, $record );
my $itemrecord;
my $nextop = "additem";
my @errors;    # store errors found while checking data BEFORE saving item.

# Getting last created item cookie
my $prefillitem = C4::Context->preference('PrefillItem');
my $justaddeditem;
my $cookieitemrecord;
if ($prefillitem) {
    my $lastitemcookie = $input->cookie('LastCreatedItem');
    if ($lastitemcookie) {
	$lastitemcookie = uri_unescape($lastitemcookie);
	if ( thaw($lastitemcookie) ) {
	    $cookieitemrecord = thaw($lastitemcookie) ;
	    $cookieitemrecord = removeFieldsForPrefill($cookieitemrecord);
	}
    }
}

#-------------------------------------------------------------------------------
if ( $op eq "additem" ) {

    #-------------------------------------------------------------------------------
    # rebuild
    my @tags      = $input->param('tag');
    my @subfields = $input->param('subfield');
    my @values    = $input->param('field_value');

    # build indicator hash.
    my @ind_tag   = $input->param('ind_tag');
    my @indicator = $input->param('indicator');
    my $xml       = TransformHtmlToXml( \@tags, \@subfields, \@values, \@indicator, \@ind_tag, 'ITEM' );
    my $record    = MARC::Record::new_from_xml( $xml, 'UTF-8' );

    # type of add
    my $add_submit                 = $input->param('add_submit');
    my $add_duplicate_submit       = $input->param('add_duplicate_submit');
    my $add_multiple_copies_submit = $input->param('add_multiple_copies_submit');
    my $number_of_copies           = $input->param('number_of_copies');

    # This is a bit tricky : if there is a cookie for the last created item and
    # we just added an item, the cookie value is not correct yet (it will be updated
    # next page). To prevent the form from being filled with outdated values, we
    # force the use of "add and duplicate" feature, so the form will be filled with 
    # correct values.
    $add_duplicate_submit = 1 if ($prefillitem);
    $justaddeditem = 1;

    # if autoBarcode is set to 'incremental', calculate barcode...
    # NOTE: This code is subject to change in 3.2 with the implemenation of ajax based autobarcode code
    # NOTE: 'incremental' is the ONLY autoBarcode option available to those not using javascript
    if ( C4::Context->preference('autoBarcode') eq 'incremental' ) {
        my ( $tagfield, $tagsubfield ) = &GetMarcFromKohaField( "items.barcode", $frameworkcode );
        unless ( $record->field($tagfield)->subfield($tagsubfield) ) {
            my $sth_barcode = $dbh->prepare("select max(abs(barcode)) from items");
            $sth_barcode->execute;
            my ($newbarcode) = $sth_barcode->fetchrow;
            $newbarcode++;

            # OK, we have the new barcode, now create the entry in MARC record
            my $fieldItem = $record->field($tagfield);
            $record->delete_field($fieldItem);
            $fieldItem->add_subfields( $tagsubfield => $newbarcode );
            $record->insert_fields_ordered($fieldItem);
        }
    }

  
    my $addedolditem = TransformMarcToKoha( $dbh, $record );

    # If we have to add or add & duplicate, we add the item
    if ( $add_submit || $add_duplicate_submit ) {

        # check for item barcode # being unique
        my $exist_itemnumber = get_item_from_barcode( $addedolditem->{'barcode'} );
        push @errors, "barcode_not_unique" if ($exist_itemnumber);

        # if barcode exists, don't create, but report The problem.
        unless ($exist_itemnumber) {
            my ( $oldbiblionumber, $oldbibnum, $oldbibitemnum ) = AddItemFromMarc( $record, $biblionumber );
            set_item_default_location($oldbibitemnum);

	  # Pushing the last created item cookie back
	  if ($prefillitem && defined $record) {
                my $itemcookie = $input->cookie(
                    -name => 'LastCreatedItem',
                    # We uri_escape the whole freezed structure so we're sure we won't have any encoding problems
                    -value   => uri_escape( freeze( $record ) ),
                    -expires => ''
                );

		$cookie = ( $cookie, $itemcookie );
	    }

        }
        $nextop = "additem";
        if ($exist_itemnumber) {
            $itemrecord = $record;
        }
    }

    # If we have to add & duplicate
    if ($add_duplicate_submit) {

        # We try to get the next barcode
        use C4::Barcodes;
        my $barcodeobj = C4::Barcodes->new;
        my $barcodevalue = $barcodeobj->next_value( $addedolditem->{'barcode'} ) if $barcodeobj;
        my ( $tagfield, $tagsubfield ) = &GetMarcFromKohaField( "items.barcode", $frameworkcode );
        if ( $record->field($tagfield)->subfield($tagsubfield) ) {

            # If we got the next codebar value, we put it in the record
            if ($barcodevalue) {
                $record->field($tagfield)->update( $tagsubfield => $barcodevalue );

                # If not, we delete the recently inserted barcode from the record (so the user can input a barcode himself)
            } else {
                $record->field($tagfield)->update( $tagsubfield => '' );
            }
        }
        $itemrecord = $record;
	$itemrecord = removeFieldsForPrefill($itemrecord) if ($prefillitem);
    }

    # If we have to add multiple copies
    if ($add_multiple_copies_submit) {

        use C4::Barcodes;
        my $barcodeobj = C4::Barcodes->new;
        my $oldbarcode = $addedolditem->{'barcode'};
        my ( $tagfield, $tagsubfield ) = &GetMarcFromKohaField( "items.barcode", $frameworkcode );

        # If there is a barcode and we can't find him new values, we can't add multiple copies
        my $testbarcode = $barcodeobj->next_value($oldbarcode) if $barcodeobj;
        if ( $oldbarcode && !$testbarcode ) {

            push @errors, "no_next_barcode";
            $itemrecord = $record;

        } else {

            # We add each item

            # For the first iteration
            my $barcodevalue = $oldbarcode;
            my $exist_itemnumber;

            for ( my $i = 0 ; $i < $number_of_copies ; ) {

                # If there is a barcode
                if ($barcodevalue) {

                    # Getting a new barcode (if it is not the first iteration or the barcode we tried already exists)
                    $barcodevalue = $barcodeobj->next_value($oldbarcode) if ( $i > 0 || $exist_itemnumber );

                    # Putting it into the record
                    if ($barcodevalue) {
                        $record->field($tagfield)->update( $tagsubfield => $barcodevalue );
                    }

                    # Checking if the barcode already exists
                    $exist_itemnumber = get_item_from_barcode($barcodevalue);
                }

                # Adding the item
                if ( !$exist_itemnumber ) {
                    my ( $oldbiblionumber, $oldbibnum, $oldbibitemnum ) = AddItemFromMarc( $record, $biblionumber );
                    set_item_default_location($oldbibitemnum);

                    # We count the item only if it was really added
                    # That way, all items are added, even if there was some already existing barcodes
                    # FIXME : Please note that there is a risk of infinite loop here if we never find a suitable barcode
                    $i++;
                }

                # Preparing the next iteration
                $oldbarcode = $barcodevalue;
            }
            undef($itemrecord);
        }
    }

    #-------------------------------------------------------------------------------
} elsif ( $op eq "edititem" ) {

    #-------------------------------------------------------------------------------
    # retrieve item if exist => then, it's a modif
    $itemrecord = C4::Items::GetMarcItem( $biblionumber, $itemnumber );
    $nextop = "saveitem";

    #-------------------------------------------------------------------------------
} elsif ( $op eq "delitem" ) {

    #-------------------------------------------------------------------------------
    # check that there is no issue on this item before deletion.
    $error = &DelItemCheck( $dbh, $biblionumber, $itemnumber );
    if ( $error == 1 ) {
        print $input->redirect("additem.pl?biblionumber=$biblionumber&frameworkcode=$frameworkcode");
    } else {
        push @errors, $error;
        $nextop = "additem";
    }

    #-------------------------------------------------------------------------------
} elsif ( $op eq "delallitems" ) {

    #-------------------------------------------------------------------------------
    my @biblioitems = &GetBiblioItemByBiblioNumber($biblionumber);
    my $errortest=0;
    my $itemfail;
    foreach my $biblioitem (@biblioitems) {
        my $items = &GetItemsByBiblioitemnumber( $biblioitem->{biblioitemnumber} );

        foreach my $item (@$items) {
            $error =&DelItemCheck( $dbh, $biblionumber, $item->{itemnumber} );
            $itemfail =$item;
        if($error == 1){
            next
            }
        else {
            push @errors,$error;
            $errortest++
            }
        }
        if($errortest > 0){
            $nextop="additem";
        } 
        else {
            print $input->redirect("/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=$biblionumber");
            exit;
        }
    }

    #-------------------------------------------------------------------------------
} elsif ( $op eq "saveitem" ) {

    #-------------------------------------------------------------------------------
    # rebuild
    my @tags      = $input->param('tag');
    my @subfields = $input->param('subfield');
    my @values    = $input->param('field_value');

    # build indicator hash.
    my @ind_tag   = $input->param('ind_tag');
    my @indicator = $input->param('indicator');

    # my $itemnumber = $input->param('itemnumber');
    my $xml = TransformHtmlToXml( \@tags, \@subfields, \@values, \@indicator, \@ind_tag, 'ITEM' );
    my $itemtosave = MARC::Record::new_from_xml( $xml, 'UTF-8' );

    # MARC::Record builded => now, record in DB
    # warn "R: ".$record->as_formatted;
    # check that the barcode don't exist already
    my $addedolditem = TransformMarcToKoha( $dbh, $itemtosave );
    my $exist_itemnumber = get_item_from_barcode( $addedolditem->{'barcode'} );
    if ( $exist_itemnumber && $exist_itemnumber != $itemnumber ) {
        push @errors, "barcode_not_unique";
    } else {
        my ( $oldbiblionumber, $oldbibnum, $oldbibitemnum ) = ModItemFromMarc( $itemtosave, $biblionumber, $itemnumber );
        $itemnumber = "";
    }
    $nextop = "additem";
}

#
#-------------------------------------------------------------------------------
# build screen with existing items. and "new" one
#-------------------------------------------------------------------------------

# now, build existiing item list
my $temp   = GetMarcBiblio($biblionumber);
my @fields = $temp->fields();

#my @fields = $record->fields();
my %witness;    #---- stores the list of subfields used at least once, with the "meaning" of the code
my @big_array;

#---- finds where items.itemnumber is stored
my ( $itemtagfield,   $itemtagsubfield )   = &GetMarcFromKohaField( "items.itemnumber", $frameworkcode );
my ( $branchtagfield, $branchtagsubfield ) = &GetMarcFromKohaField( "items.homebranch", $frameworkcode );

foreach my $field (@fields) {
    next if ($field->tag()<10);

    my @subf = $field->subfields or (); # don't use ||, as that forces $field->subfelds to be interpreted in scalar context
    my %this_row;
# loop through each subfield
    my $i = 0;
    foreach my $subfield (@subf){
        my $subfieldcode = $subfield->[0];
        my $subfieldvalue= $subfield->[1];
        
        next if ($tagslib->{$field->tag()}->{$subfieldcode}->{tab} ne 10 
                && ($field->tag() ne $itemtagfield 
                && $subfieldcode   ne $itemtagsubfield));
        $witness{$subfieldcode} = $tagslib->{$field->tag()}->{$subfieldcode}->{lib} if ($tagslib->{$field->tag()}->{$subfieldcode}->{tab}  eq 10);
		if ($tagslib->{$field->tag()}->{$subfieldcode}->{tab}  eq 10) {
		    $this_row{$subfieldcode} .= " | " if($this_row{$subfieldcode});
        	$this_row{$subfieldcode} .= GetAuthorisedValueDesc( $field->tag(),
                        $subfieldcode, $subfieldvalue, '', $tagslib) 
						|| $subfieldvalue;
		}

        if (($field->tag eq $branchtagfield) && ($subfieldcode eq $branchtagsubfield) && C4::Context->preference("IndependantBranches")) {
            #verifying rights
            my $userenv = C4::Context->userenv();
            unless (($userenv->{'flags'} == 1) or (($userenv->{'branch'} eq $subfieldvalue))){
                    $this_row{'nomod'}=1;
            }
        }
        $this_row{itemnumber} = $subfieldvalue if ($field->tag() eq $itemtagfield && $subfieldcode eq $itemtagsubfield);
    }
    if (%this_row) {
        push( @big_array, \%this_row );
    }
}

my ( $holdingbrtagf, $holdingbrtagsubf ) = &GetMarcFromKohaField( "items.holdingbranch", $frameworkcode );
@big_array = sort { $a->{$holdingbrtagsubf} cmp $b->{$holdingbrtagsubf} } @big_array;

# now, construct template !
# First, the existing items for display
my @item_value_loop;
my @header_value_loop;
for my $row (@big_array) {
    my %row_data;
    my @item_fields = map +{ field => $_ || '' }, @$row{ sort keys(%witness) };
    $row_data{item_value} = [@item_fields];
    $row_data{itemnumber} = $row->{itemnumber};

    #reporting this_row values
    $row_data{'nomod'} = $row->{'nomod'};
    push( @item_value_loop, \%row_data );
}
foreach my $subfield_code ( sort keys(%witness) ) {
    my %header_value;
    $header_value{header_value} = $witness{$subfield_code};
    push( @header_value_loop, \%header_value );
}

# now, build the item form for entering a new item
my @loop_data =();
my $i=0;

my $onlymine = C4::Context->preference('IndependantBranches') && 
               C4::Context->userenv                           && 
               C4::Context->userenv->{flags}!=1               && 
               C4::Context->userenv->{branch};
my $branches = GetBranchesLoop(C4::Context->userenv->{branch},$onlymine);  # build once ahead of time, instead of multiple times later.

# Using last created item if it exists

$itemrecord = $cookieitemrecord if ($prefillitem and not $justaddeditem and $op ne "edititem"); 

# We generate form, and fill with values if defined
foreach my $tag ( keys %{$tagslib}){
    foreach my $subtag (sort keys %{$tagslib->{$tag}}){
        next if subfield_is_koha_internal_p($subtag);
        next if ($tagslib->{$tag}->{$subtag}->{'tab'} ne "10");
        
        #if there is data, fill it

        my @values = (undef);
        @values = $itemrecord->field($tag)->subfield($subtag) if ($itemrecord && defined($itemrecord->field($tag)->subfield($subtag)));
        for my $value (@values){
            my $subfield_data = generate_subfield_form($tag, $subtag, $value, $tagslib, $tagslib->{$tag}->{$subtag}, $branches, $today_iso, $biblionumber, $temp, \@loop_data, $i); 
            push (@loop_data, $subfield_data);
            $i++;
        }
    }
}
# what's the next op ? it's what we are not in : an add if we're editing, otherwise, and edit.
$template->param( title => $record->title() ) if ( $record ne "-1" );
$template->param(
    biblionumber     => $biblionumber,
    title            => $oldrecord->{title},
    author           => $oldrecord->{author},
    item_loop        => \@item_value_loop,
    item_header_loop => \@header_value_loop,
    item             => \@loop_data,
    itemnumber       => $itemnumber,
    itemtagfield     => $itemtagfield,
    itemtagsubfield  => $itemtagsubfield,
    op               => $nextop,
    opisadd          => ( $nextop eq "saveitem" ) ? 0 : 1,
    C4::Search::enabled_staff_search_views,
);
foreach my $error (@errors) {
    $template->param( $error => 1 );
}
output_html_with_http_headers $input, $cookie, $template->output;
