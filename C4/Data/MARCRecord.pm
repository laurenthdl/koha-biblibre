package C4::Data::MARCRecord;

# Copyright 2009 LibLime
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

use strict;
use warnings;

use Carp;

use C4::Debug;
use MARC::Record;
use C4::Biblio;
use C4::Koha;
use C4::Branch qw(GetBranches GetBranchesLoop onlymine);
use C4::ItemType;
use C4::Dates;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use vars qw($debug $cgi_debug);	# from C4::Debug, of course
use vars qw($max $prefformat);

BEGIN {
    $VERSION = 0.01;
	require Exporter;
    @ISA = qw(Exporter);
    @EXPORT = qw(BuildSubfieldInput FindValues CreateKey build_tabs);
    @EXPORT_OK = qw();
}


=item GetMandatoryFieldZ3950

    This function return an hashref which containts all mandatory field
    to search with z3950 server.
    
=cut
my $frameworkcode   = '';
my $tagslib         = &GetMarcStructure( 1, $frameworkcode );
my $usedTagsLib     = &GetUsedMarcStructure( $frameworkcode );
my $mandatory_z3950 = GetMandatoryFieldZ3950($frameworkcode);

sub GetMandatoryFieldZ3950($){
    my $frameworkcode = shift;
    my @isbn   = GetMarcFromKohaField('biblioitems.isbn',$frameworkcode);
    my @title  = GetMarcFromKohaField('biblio.title',$frameworkcode);
    my @author = GetMarcFromKohaField('biblio.author',$frameworkcode);
    my @issn   = GetMarcFromKohaField('biblioitems.issn',$frameworkcode);
    my @lccn   = GetMarcFromKohaField('biblioitems.lccn',$frameworkcode);
    
    return {
        $isbn[0].$isbn[1]     => 'isbn',
        $title[0].$title[1]   => 'title',
        $author[0].$author[1] => 'author',
        $issn[0].$issn[1]     => 'issn',
        $lccn[0].$lccn[1]     => 'lccn',
    };
}

=item build_authorized_values_list

=cut

sub build_authorized_values_list ($$$$$) {
    my ( $tag, $subfield, $value, $index_tag,$index_subfield ) = @_;

    my @authorised_values;
    my %authorised_lib;

    # builds list, depending on authorised value...

    #---- branch
    if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
        #Use GetBranches($onlymine)
        my $branches       = GetBranchesLoop();
        push @authorised_values, ""
          unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );
		push @authorised_values, map{$$_{value}}@$branches;
		%authorised_lib=map {$$_{value}=>$$_{branchname}}@$branches;
        #----- itemtypes
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{authorised_value} eq "itemtypes" ) {
		my @itemtypes=C4::ItemType->all;
        push @authorised_values, ""
          unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );
          
        
        foreach my $itemtype  (sort {$$a{description} cmp $$b{description}} @itemtypes) {
            push @authorised_values, $$itemtype{itemtype};
            $authorised_lib{$$itemtype{itemtype}} = $$itemtype{description};
        }

          #---- class_sources
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{authorised_value} eq "cn_source" ) {
        push @authorised_values, ""
          unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );

        my $class_sources = GetClassSources();

        my $default_source = C4::Context->preference("DefaultClassificationSource");

        foreach my $class_source (sort keys %$class_sources) {
            next unless $class_sources->{$class_source}->{'used'} or
                        ($value and $class_source eq $value) or
                        ($class_source eq $default_source);
            push @authorised_values, $class_source;
            $authorised_lib{$class_source} = $class_sources->{$class_source}->{'description'};
            $value = $class_source unless ($value);
            $value = $default_source unless ($value);
        }
        #---- "true" authorised value
    }
    else {
        
		my $authorisedvalues=GetAuthorisedValues($tagslib->{$tag}->{$subfield}->{authorised_value},$value);

        push @authorised_values, ""
          unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );
		push @authorised_values, map{$$_{authorised_value}} sort {$$a{lib} cmp $$b{lib}}@$authorisedvalues;

        foreach my $authvalue(@$authorisedvalues){
            $authorised_lib{$$authvalue{authorised_value}} = $$authvalue{lib};
        }
    }
    return CGI::scrolling_list(
        -name     => "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield,
        -values   => \@authorised_values,
        -default  => $value,
        -labels   => \%authorised_lib,
        -override => 1,
        -size     => 1,
        -multiple => 0,
        -tabindex => 1,
        -id       => "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield,
        -class    => "input_marceditor",
    );
}

=item CreateKey

    Create a random value to set it into the input name

=cut

sub CreateKey(){
    return int(rand(1000000));
}
sub _check_visible{
	my ($tag,$subfield,$value)=@_;
	my ($itemtag,$itemsubf)=GetMarcFromKohaField("items.itemnumber",$frameworkcode);
	if ($tag eq $itemtag || $tagslib->{$tag}->{$subfield}->{tab} eq "10"){
		return ($tagslib->{$tag}->{$subfield}->{hidden} > 4) || ($tagslib->{$tag}->{$subfield}->{hidden} < -4);
	}
	else {
    	return ($tagslib->{$tag}->{$subfield}->{hidden} % 2 == 1) and $value ne ''
            or ($value eq '' and !$tagslib->{$tag}->{$subfield}->{mandatory})
	}
}

=item BuildSubfieldInput

 builds the <input ...> entry for a subfield.

=cut

sub BuildSubfieldInput {
    my ( $tag, $subfield, $value, $index_tag, $tabloop, $rec, $defaultvalues ) = @_;
    
    my $index_subfield = CreateKey(); # create a specifique key for each subfield

    $value =~ s/"/&quot;/g;

    # determine maximum length; 9999 bytes per ISO 2709 except for leader and MARC21 008
    my $max_length = 9999;
    if ($tag eq '000') {
        $max_length = 24;
    } elsif ($tag eq '008' and C4::Context->preference('marcflavour') eq 'MARC21')  {
        $max_length = 40;
    }

    # if there is no value provided but a default value in parameters, get it
    unless ($value) {
		$value  =  $$defaultvalues{$tagslib->{$tag}->{$subfield}->{kohafield}} if ($defaultvalues);
		$value ||= $tagslib->{$tag}->{$subfield}->{defaultvalue};

        # get today date & replace YYYY, MM, DD if provided in the default value
		my $today_iso = C4::Dates->today('iso');
        my ( $year, $month, $day ) = split /-/, $today_iso;
        $month = sprintf( "%02d", $month );
        $day   = sprintf( "%02d", $day );
        $value =~ s/YYYY/$year/g;
        $value =~ s/MM/$month/g;
        $value =~ s/DD/$day/g;
        my $username=(C4::Context->userenv?C4::Context->userenv->{'surname'}:"superlibrarian");    
        $value=~s/user/$username/g;
    
    }
    my $dbh = C4::Context->dbh;

    # map '@' as "subfield" label for fixed fields
    # to something that's allowed in a div id.
    my $id_subfield = $subfield;
    $id_subfield = "00" if $id_subfield eq "@";

    my %subfield_data = (
        tag        => $tag,
        subfield   => $id_subfield,
        marc_lib   => substr( $tagslib->{$tag}->{$subfield}->{lib}, 0, 22 ),
        marc_lib_plain => $tagslib->{$tag}->{$subfield}->{lib}, 
        tag_mandatory  => $tagslib->{$tag}->{mandatory},
        mandatory      => $tagslib->{$tag}->{$subfield}->{mandatory},
        repeatable     => $tagslib->{$tag}->{$subfield}->{repeatable},
        kohafield      => $tagslib->{$tag}->{$subfield}->{kohafield},
        index          => $index_tag,
        id             => "tag_".$tag."_subfield_".$id_subfield."_".$index_tag."_".$index_subfield,
        value          => $value,
        random         => CreateKey(),
    );

    if(exists $mandatory_z3950->{$tag.$subfield}){
        $subfield_data{z3950_mandatory} = $mandatory_z3950->{$tag.$subfield};
    }
    # decide if the subfield must be expanded (visible) by default or not
    # if it is mandatory, then expand. If it is hidden explicitly by the hidden flag, hidden anyway
    $subfield_data{visibility} = "display:none;"
        if ( _check_visible($tag,$subfield,$value));
    # always expand all subfields of a mandatory field
    $subfield_data{visibility} = "" if $tagslib->{$tag}->{mandatory};
    # it's an authorised field
    if ( $tagslib->{$tag}->{$subfield}->{authorised_value} ) {
        $subfield_data{marc_value} =
          build_authorized_values_list( $tag, $subfield, $value, $index_tag,$index_subfield );

    # it's a subfield $9 linking to an authority record - see bug 2206
    }
    elsif ($subfield eq "9" and
           exists($tagslib->{$tag}->{'a'}->{authtypecode}) and
           defined($tagslib->{$tag}->{'a'}->{authtypecode}) and
           $tagslib->{$tag}->{'a'}->{authtypecode} ne '') {

        $subfield_data{marc_value} =
            "<input type=\"text\"
                    id=\"".$subfield_data{id}."\"
                    name=\"".$subfield_data{id}."\"
                    value=\"$value\"
                    class=\"input_marceditor\"
                    tabindex=\"1\"
                    size=\"5\"
                    maxlength=\"$max_length\"
                    readonly=\"readonly\"
                    \/>";

    }
    elsif ( $tagslib->{$tag}->{$subfield}->{authtypecode} ) {
    # it's a thesaurus / authority field
     my $readonly=(C4::Context->preference("BiblioAddsAuthorities")?"readonly=\"readonly\"":"");
     $subfield_data{marc_value} =
            "<input type=\"text\"
                    id=\"".$subfield_data{id}."\"
                    name=\"".$subfield_data{id}."\"
                    value=\"$value\"
                    class=\"input_marceditor\"
                    tabindex=\"1\"
                    size=\"67\"
                    maxlength=\"$max_length\"
					$readonly
                    \/><a href=\"#\" class=\"buttonDot\"
                        onclick=\"openAuth(this.parentNode.getElementsByTagName('input')[1].id,'".$tagslib->{$tag}->{$subfield}->{authtypecode}."'); return false;\" tabindex=\"1\" title=\"Tag Editor\">...</a>
            ";
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{'value_builder'} ) {
    # it's a plugin field

        # opening plugin. Just check wether we are on a developper computer on a production one
        # (the cgidir differs)
        my $cgidir = C4::Context->intranetdir . "/cgi-bin/cataloguing/value_builder";
        unless ( opendir( DIR, "$cgidir" ) ) {
            $cgidir = C4::Context->intranetdir . "/cataloguing/value_builder";
            closedir( DIR );
        }
        my $plugin = $cgidir . "/" . $tagslib->{$tag}->{$subfield}->{'value_builder'};
        if (do $plugin) {
            my $extended_param = plugin_parameters( $dbh, $rec, $tagslib, $subfield_data{id}, $tabloop );
            my ( $function_name, $javascript ) = plugin_javascript( $dbh, $rec, $tagslib, $subfield_data{id}, $tabloop );
        
            $subfield_data{marc_value} =
                    "<input tabindex=\"1\"
                            type=\"text\"
                            id=\"".$subfield_data{id}."\"
                            name=\"".$subfield_data{id}."\"
                            value=\"$value\"
                            class=\"input_marceditor\"
                            onfocus=\"Focus$function_name($index_tag)\"
                            size=\"67\"
                            maxlength=\"$max_length\"
                            onblur=\"Blur$function_name($index_tag); \" \/>
                            <a href=\"#\" class=\"buttonDot\" onclick=\"Clic$function_name('$subfield_data{id}'); return false;\" tabindex=\"1\" title=\"Tag Editor\">...</a>
                    $javascript";
        } else {
            warn "Plugin Failed: $plugin";
            # supply default input form
            $subfield_data{marc_value} =
                "<input type=\"text\"
                        id=\"".$subfield_data{id}."\"
                        name=\"".$subfield_data{id}."\"
                        value=\"$value\"
                        tabindex=\"1\"
                        size=\"67\"
                        maxlength=\"$max_length\"
                        class=\"input_marceditor\"
                \/>
                ";
        }
        # it's an hidden field
    }
    elsif ( $tag eq '' ) {
        $subfield_data{marc_value} =
            "<input tabindex=\"1\"
                    type=\"hidden\"
                    id=\"".$subfield_data{id}."\"
                    name=\"".$subfield_data{id}."\"
                    size=\"67\"
                    maxlength=\"$max_length\"
                    value=\"$value\" \/>
            ";
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{'hidden'} ) {
        $subfield_data{marc_value} =
            "<input type=\"text\"
                    id=\"".$subfield_data{id}."\"
                    name=\"".$subfield_data{id}."\"
                    class=\"input_marceditor\"
                    tabindex=\"1\"
                    size=\"67\"
                    maxlength=\"$max_length\"
                    value=\"$value\"
            \/>";

        # it's a standard field
    }
    else {
        if (
            length($value) > 100
            or
            ( C4::Context->preference("marcflavour") eq "UNIMARC" && $tag >= 300
                and $tag < 400 && $subfield eq 'a' )
            or (    $tag >= 500
                and $tag < 600
                && C4::Context->preference("marcflavour") eq "MARC21" )
          )
        {
            $subfield_data{marc_value} =
                "<textarea cols=\"70\"
                           rows=\"4\"
                           id=\"".$subfield_data{id}."\"
                           name=\"".$subfield_data{id}."\"
                           class=\"input_marceditor\"
                           tabindex=\"1\"
                           >$value</textarea>
                ";
        }
        else {
            $subfield_data{marc_value} =
                "<input type=\"text\"
                        id=\"".$subfield_data{id}."\"
                        name=\"".$subfield_data{id}."\"
                        value=\"$value\"
                        tabindex=\"1\"
                        size=\"67\"
                        maxlength=\"$max_length\"
                        class=\"input_marceditor\"
                \/>
                ";
        }
    }
    $subfield_data{'index_subfield'} = $index_subfield;
    return \%subfield_data;
}


=item format_indicator

Translate indicator value for output form - specifically, map
indicator = ' ' to ''.  This is for the convenience of a cataloger
using a mouse to select an indicator input.

=cut

sub format_indicator {
    my $ind_value = shift;
    return '' if not defined $ind_value;
    return '' if $ind_value eq ' ';
    return $ind_value;
}

=item build_tabs


=cut

sub build_tabs ($$$) {
    my ( $template, $record, $encoding) = @_;

    # fill arrays
    my @loop_data = ();
    my $tag;

    # in this array, we will push all the 10 tabs
    # to avoid having 10 tabs in the template : they will all be in the same BIG_LOOP
    my @BIG_LOOP;
    my %seen;
    my @tab_data; # all tags to display
    
    foreach my $used ( @$usedTagsLib ){
        push @tab_data,$used->{tagfield} if not $seen{$used->{tagfield}};
        $seen{$used->{tagfield}}++;
    }
        
    my $max_num_tab=-1;
    foreach(@$usedTagsLib){
        if($_->{tab} > -1 && $_->{tab} >= $max_num_tab && $_->{tagfield} != '995'){ # FIXME : MARC21 ?
            $max_num_tab = $_->{tab}; 
        }
    }
    if($max_num_tab >= 9){
        $max_num_tab = 9;
    }
    # loop through each tab 0 through 9
    for ( my $tabloop = 0 ; $tabloop <= $max_num_tab ; $tabloop++ ) {
        my @loop_data = (); #innerloop in the template.
        my $i = 0;
        foreach my $tag (@tab_data) {
            $i++;
            next if ! $tag;
            my ($indicator1, $indicator2);
            my $index_tag = CreateKey;

            # if MARC::Record is not empty =>use it as master loop, then add missing subfields that should be in the tab.
            # if MARC::Record is empty => use tab as master loop.
            if ( $record ne -1 && ( $record->field($tag) || $tag eq '000' ) ) {
                my @fields;
		if ( $tag ne '000' ) {
                    @fields = $record->field($tag);
		}
		else {
		   push @fields, $record->leader(); # if tag == 000
		}
		# loop through each field
                foreach my $field (@fields) {
                    
                    my @subfields_data;
                    if ( $tag < 10 ) {
                        my ( $value, $subfield );
                        if ( $tag ne '000' ) {
                            $value    = $field->data();
                            $subfield = "@";
                        }
                        else {
                            $value    = $field;
                            $subfield = '@';
                        }
                        next if ( $tagslib->{$tag}->{$subfield}->{tab} ne $tabloop );
                        next
                          if ( $tagslib->{$tag}->{$subfield}->{kohafield} eq
                            'biblio.biblionumber' );
                        push(
                            @subfields_data,
                            &BuildSubfieldInput(
                                $tag, $subfield, $value, $index_tag, $tabloop, $record,
                            )
                        );
                    }
                    else {
                        my @subfields = $field->subfields();
                        foreach my $subfieldcount ( 0 .. $#subfields ) {
                            my $subfield = $subfields[$subfieldcount][0];
                            my $value    = $subfields[$subfieldcount][1];
                            next if ( length $subfield != 1 );
                            next if ( $tagslib->{$tag}->{$subfield}->{tab} ne $tabloop );
                            push(
                                @subfields_data,
                                &BuildSubfieldInput(
                                    $tag, $subfield, $value, $index_tag, $tabloop,
                                    $record
                                )
                            );
                        }
                    }

                    # now, loop again to add parameter subfield that are not in the MARC::Record
                    foreach my $subfield ( sort( keys %{ $tagslib->{$tag} } ) )
                    {
                        next if ( length $subfield != 1 );
                        next if ( $tagslib->{$tag}->{$subfield}->{tab} ne $tabloop );
                        next if ( $tag < 10 );
                        next
                          if ( ( $tagslib->{$tag}->{$subfield}->{hidden} <= -4 )
                            or ( $tagslib->{$tag}->{$subfield}->{hidden} >= 5 ) )
                            and not ( $subfield eq "9" and
                                      exists($tagslib->{$tag}->{'a'}->{authtypecode}) and
                                      defined($tagslib->{$tag}->{'a'}->{authtypecode}) and
                                      $tagslib->{$tag}->{'a'}->{authtypecode} ne ""
                                    )
                          ;    #check for visibility flag
                               # if subfield is $9 in a field whose $a is authority-controlled,
                               # always include in the form regardless of the hidden setting - bug 2206
                        next if ( defined( $field->subfield($subfield) ) );
                        push(
                            @subfields_data,
                            &BuildSubfieldInput(
                                $tag, $subfield, '', $index_tag, $tabloop, $record,
                            )
                        );
                    }
                    if ( $#subfields_data >= 0 ) {
                        # build the tag entry.
                        # note that the random() field is mandatory. Otherwise, on repeated fields, you'll 
                        # have twice the same "name" value, and cgi->param() will return only one, making
                        # all subfields to be merged in a single field.
                        my %tag_data = (
                            tag           => $tag,
                            index         => $index_tag,
                            tag_lib       => $tagslib->{$tag}->{lib},
                            repeatable       => $tagslib->{$tag}->{repeatable},
                            mandatory       => $tagslib->{$tag}->{mandatory},
                            subfield_loop => \@subfields_data,
                            fixedfield    => $tag < 10?1:0,
                            random        => CreateKey,
                        );
                        if ($tag >= 10){ # no indicator for 00x tags
                           $tag_data{indicator1} = format_indicator($field->indicator(1)),
                           $tag_data{indicator2} = format_indicator($field->indicator(2)),
                        }
                        push( @loop_data, \%tag_data );
                    }
                 } # foreach $field end

            # if breeding is empty
            }
            else {
                my @subfields_data;
                foreach my $subfield ( sort( keys %{ $tagslib->{$tag} } ) ) {
                    next if ( length $subfield != 1 );
                    next
                      if ( ( $tagslib->{$tag}->{$subfield}->{hidden} <= -5 )
                        or ( $tagslib->{$tag}->{$subfield}->{hidden} >= 4 ) )
                      and not ( $subfield eq "9" and
                                exists($tagslib->{$tag}->{'a'}->{authtypecode}) and
                                defined($tagslib->{$tag}->{'a'}->{authtypecode}) and
                                $tagslib->{$tag}->{'a'}->{authtypecode} ne ""
                              )
                      ;    #check for visibility flag
                           # if subfield is $9 in a field whose $a is authority-controlled,
                           # always include in the form regardless of the hidden setting - bug 2206
                    next
                      if ( $tagslib->{$tag}->{$subfield}->{tab} ne $tabloop );
                    push(
                        @subfields_data,
                        &BuildSubfieldInput(
                            $tag, $subfield, '', $index_tag, $tabloop, $record,
                        )
                    );
                }
                if ( $#subfields_data >= 0 ) {
                    my %tag_data = (
                        tag              => $tag,
                        index            => $index_tag,
                        tag_lib          => $tagslib->{$tag}->{lib},
                        repeatable       => $tagslib->{$tag}->{repeatable},
                        mandatory       => $tagslib->{$tag}->{mandatory},
                        indicator1       => $indicator1,
                        indicator2       => $indicator2,
                        subfield_loop    => \@subfields_data,
                        tagfirstsubfield => $subfields_data[0],
                        fixedfield       => $tag < 10?1:0,
                    );
                    
                    push @loop_data, \%tag_data ;
                }
            }
        }
        if ( $#loop_data >= 0 ) {
            push @BIG_LOOP, {
                number    => $tabloop,
                innerloop => \@loop_data,
            };
        }
    }
    $template->param( BIG_LOOP => \@BIG_LOOP );
}

=head2 _find_value

=over 4

($indicators, $value) = FindValues($tag, $subfield, $record,$encoding);

Find the given $subfield in the given $tag in the given
MARC::Record $record.  If the subfield is found, returns
the (indicators, value) pair; otherwise, (undef, undef) is
returned.

PROPOSITION :
Such a function is used in addbiblio AND additem and serial-edit and maybe could be used in Authorities.
I suggest we export it from this module.

=back

=cut

sub FindValues {
    my ( $tagfield, $insubfield, $record, $encoding ) = @_;
    my @result;
    my $indicator;
    if ( $tagfield < 10 ) {
        if ( $record->field($tagfield) ) {
            push @result, $record->field($tagfield)->data();
        }
        else {
            push @result, "";
        }
    }
    else {
        foreach my $field ( $record->field($tagfield) ) {
            my @subfields = $field->subfields();
            foreach my $subfield (@subfields) {
                if ( @$subfield[0] eq $insubfield ) {
                    push @result, @$subfield[1];
                    $indicator = $field->indicator(1) . $field->indicator(2);
                }
            }
        }
    }
    return ( $indicator, @result );
}

__END__
