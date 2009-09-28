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

use CGI;
use strict;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Context;
use C4::Koha; # XXX subfield_is_koha_internal_p
use C4::Branch; # XXX subfield_is_koha_internal_p
use C4::ClassSource;
use C4::Dates;
use C4::Debug;
use YAML;
use Switch;
use MARC::File::XML;

sub find_value {
    my ($tagfield,$insubfield,$record) = @_;
    my $result;
    my $indicator;
    foreach my $field ($record->field($tagfield)) {
        my @subfields = $field->subfields();
        foreach my $subfield (@subfields) {
            if (@$subfield[0] eq $insubfield) {
                $result .= @$subfield[1];
                $indicator = $field->indicator(1).$field->indicator(2);
            }
        }
    }
    return($indicator,$result);
}


my $input = new CGI;
my $dbh = C4::Context->dbh;
my $error        = $input->param('error');
my @itemnumbers  = $input->param('itemnumber');
my $op           = $input->param('op');

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "tools/batchMod.tmpl",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {editcatalogue => 1},
                 });


my $today_iso = C4::Dates->today('iso');
$template->param(today_iso => $today_iso);

my $itemrecord;
my $nextop="";
my @errors; # store errors found while checking data BEFORE saving item.
my $items_display_hashref;
my $frameworkcode="";
my $tagslib = &GetMarcStructure(1,$frameworkcode);

#--- ----------------------------------------------------------------------------
if ($op eq "action") {
#-------------------------------------------------------------------------------
	my @params=$input->param();
#	warn @params;
    my $marcitem = TransformHtmlToMarc(\@params,$input);
    my $localitem = TransformMarcToKoha( $dbh, $marcitem, "", 'items' );
	foreach my $itemnumber(@itemnumbers){
		my $itemdata=GetItem($itemnumber);
		if ($input->param("del")){
			DelItemCheck(C4::Context->dbh, $itemdata->{'biblionumber'}, $itemdata->{'itemnumber'})
		} else {
			my $localmarcitem=Item2Marc($itemdata);
			UpdateMarcWith($marcitem,$localmarcitem);
            eval{my ($oldbiblionumber,$oldbibnum,$oldbibitemnum) = ModItemFromMarc($localmarcitem,$itemdata->{biblionumber},$itemnumber)};
		#	eval{ModItem($localitem,$itemdata->{biblionumber},$itemnumber)};
		}
	}
	$items_display_hashref=BuildItemsData(@itemnumbers);
    $nextop="action";
}

#
#-------------------------------------------------------------------------------
# build screen with existing items. and "new" one
#-------------------------------------------------------------------------------

if ($op eq "show"){
	my $filefh = $input->upload('uploadfile');
	my $filecontent = $input->param('filecontent');

    my @barcodelist;
    if ($filefh){
        while (my $content=<$filefh>){
            chomp $content;
            push @barcodelist, $content;
        }
	}
    if ( my $list=$input->param('barcodelist')){
        push @barcodelist, split(/\s\n/, $list);
	}
	switch ($filecontent) {
	    case "barcode_file" {
			push @itemnumbers,map{GetItemnumberFromBarcode($_)} @barcodelist;
			# Remove not found barcodes
			@itemnumbers = grep(!/^$/, @itemnumbers);
	    }
	    case "itemid_file" {
			@itemnumbers = @barcodelist;
	    }
	}
	if (scalar(@itemnumbers)){
		$items_display_hashref=BuildItemsData(@itemnumbers);

# now, build the item form for entering a new item
		my $defaults;
		my $iteminput=PrepareItemrecordInput("",'',$defaults);
		$template->param( %$iteminput);

# what's the next op ? it's what we are not in : an add if we're editing, otherwise, and edit.
		$nextop="action"
	}
	else {
		warn "No Item matches any item of the list provided";
	}
}
$template->param(%$items_display_hashref) if $items_display_hashref;
$template->param(
    op      => $nextop,
    $op => 1,
    opisadd => ($nextop eq "saveitem") ? 0 : 1,
);
foreach my $error (@errors) {
    $template->param($error => 1);
}
output_html_with_http_headers $input, $cookie, $template->output;
exit;

sub BuildItemsData{
	my @itemnumbers=@_;
		# now, build existiing item list
		my %witness; #---- stores the list of subfields used at least once, with the "meaning" of the code
		my @big_array;
		#---- finds where items.itemnumber is stored
		my (  $itemtagfield,   $itemtagsubfield) = &GetMarcFromKohaField("items.itemnumber", "");
		my ($branchtagfield, $branchtagsubfield) = &GetMarcFromKohaField("items.homebranch", "");
		foreach my $itemnumber (@itemnumbers){
			my $itemdata=GetItem($itemnumber);
			my $itemmarc=Item2Marc($itemdata);
			my $biblio=GetBiblioData($$itemdata{biblionumber});
			my %this_row;
			foreach my $field (grep {$_->tag() eq $itemtagfield} $itemmarc->fields()) {
				# loop through each subfield
				if (my $itembranchcode=$field->subfield($branchtagsubfield) && C4::Context->preference("IndependantBranches")) {
						#verifying rights
						my $userenv = C4::Context->userenv();
						unless (($userenv->{'flags'} == 1) or (($userenv->{'branch'} eq $itembranchcode))){
								$this_row{'nomod'}=1;
						}
				}
				my $tag=$field->tag();
				foreach my $subfield ($field->subfields) {
					my ($subfcode,$subfvalue)=@$subfield;
					next if ($tagslib->{$tag}->{$subfcode}->{tab} ne 10 
							&& $tag        ne $itemtagfield 
							&& $subfcode   ne $itemtagsubfield);

					$witness{$subfcode} = $tagslib->{$tag}->{$subfcode}->{lib} if ($tagslib->{$tag}->{$subfcode}->{tab}  eq 10);
					if ($tagslib->{$tag}->{$subfcode}->{tab}  eq 10) {
						$this_row{$subfcode}=GetAuthorisedValueDesc( $tag,
									$subfcode, $subfvalue, '', $tagslib) 
									|| $subfvalue;
					}

					$this_row{itemnumber} = $subfvalue if ($tag eq $itemtagfield && $subfcode eq $itemtagsubfield);
				}
			}
			$this_row{0}=join("\n",@$biblio{qw(title author ISBN)});
			$witness{0}="&nbsp;";
			if (%this_row) {
				push(@big_array, \%this_row);
			}
		}
		@big_array = sort {$a->{0} cmp $b->{0}} @big_array;

		# now, construct template !
		# First, the existing items for display
		my @item_value_loop;
		my @witnesscodessorted=sort keys %witness;
		for my $row ( @big_array ) {
			my %row_data;
			my @item_fields = map +{ field => $_ || '' }, @$row{ @witnesscodessorted };
			$row_data{item_value} = [ @item_fields ];
			$row_data{itemnumber} = $row->{itemnumber};
			#reporting this_row values
			$row_data{'nomod'} = $row->{'nomod'};
			push(@item_value_loop,\%row_data);
		}
		my @header_loop=map { { header_value=> $witness{$_}} } @witnesscodessorted;
	return { item_loop        => \@item_value_loop, item_header_loop => \@header_loop };
}
#BE WARN : it is not the general case 
# This function can be OK in the item marc record special case
# Where subfield is not repeated
# And where we are sure that field should correspond
# And $tag>10
sub UpdateMarcWith($$){
  my ($marcfrom,$marcto)=@_;
  #warn "FROM :",$marcfrom->as_formatted;
	my (  $itemtag,   $itemtagsubfield) = &GetMarcFromKohaField("items.itemnumber", "");
	my $fieldfrom=$marcfrom->field($itemtag);
	my @fields_to=$marcto->field($itemtag);
    foreach my $subfield ($fieldfrom->subfields()){
		foreach my $field_to_update (@fields_to){
				$field_to_update->update($$subfield[0]=>$$subfield[1]) if ($$subfield[1]);
		}
    }
  #warn "TO edited:",$marcto->as_formatted;
}
