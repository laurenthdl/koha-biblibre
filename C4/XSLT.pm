package C4::XSLT;

# Copyright (C) 2006 LibLime
# <jmf at liblime dot com>
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
use warnings;

use C4::Context;
use C4::Branch;
use C4::Items;
use C4::Koha;
use C4::Biblio;
use C4::Circulation;
use C4::Dates qw/format_date/;
use C4::Reserves;
use Encode;
use XML::LibXML;
use XML::LibXSLT;
use LWP::Simple;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
    require Exporter;
    $VERSION = 0.03;
    @ISA     = qw(Exporter);
    @EXPORT  = qw(
      &XSLTParse4Display
      &GetURI
    );
}

=head1 NAME

C4::XSLT - Functions for displaying XSLT-generated content

=head1 FUNCTIONS

=head1 GetURI

=head2 GetURI file and returns the xslt as a string

=cut

sub GetURI {
    my ($uri) = @_;
    my $string;
    $string = get $uri ;
    return $string;
}

=head1 transformMARCXML4XSLT

=head2 replaces codes with authorized values in a MARC::Record object

=cut

sub transformMARCXML4XSLT {
    my ( $biblionumber, $record ) = @_;
    my $frameworkcode = GetFrameworkCode($biblionumber);
    my $tagslib = &GetMarcStructure( 1, $frameworkcode );
    my @fields;

    # FIXME: wish there was a better way to handle exceptions
    eval { @fields = $record->fields(); };
    if ($@) { warn "$record PROBLEM WITH RECORD"; return;}
    my $av = getAuthorisedValues4MARCSubfields($frameworkcode);
    foreach my $tag ( keys %$av ) {
        foreach my $field ( $record->field($tag) ) {
            if ( $av->{$tag} ) {
                my @new_subfields = ();
                for my $subfield ( $field->subfields() ) {
                    my ( $letter, $value ) = @$subfield;
                    $value = GetAuthorisedValueDesc( $tag, $letter, $value, '', $tagslib )
                      if $av->{$tag}->{$letter};
                    push( @new_subfields, $letter, $value );
                }
                $field->replace_with( MARC::Field->new( $tag, $field->indicator(1), $field->indicator(2), @new_subfields ) );
            }
        }
    }
    return $record;
}

=head1 getAuthorisedValues4MARCSubfields

=head2 returns an ref of hash of ref of hash for tag -> letter controled bu authorised values

=cut

# Cache for tagfield-tagsubfield to decode per framework.
# Should be preferably be placed in Koha-core...
my %authval_per_framework;

sub getAuthorisedValues4MARCSubfields {
    my ($frameworkcode) = @_;
    unless ( $authval_per_framework{$frameworkcode} ) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare(
            "SELECT DISTINCT tagfield, tagsubfield
                                 FROM marc_subfield_structure
                                 WHERE authorised_value IS NOT NULL
                                   AND authorised_value!=''
                                   AND frameworkcode=?"
        );
        $sth->execute($frameworkcode);
        my $av = {};
        while ( my ( $tag, $letter ) = $sth->fetchrow() ) {
            $av->{$tag}->{$letter} = 1;
        }
        $authval_per_framework{$frameworkcode} = $av;
    }
    return $authval_per_framework{$frameworkcode};
}

my $stylesheet;
sub _buildfilename{
   my ($interface,$xsl_suffix)=@_;
   my $xslfile;
   if ($interface eq 'intranet') {
       $xslfile = C4::Context->config('intrahtdocs') . 
                  "/prog/en/xslt/" .
                  C4::Context->preference('marcflavour') .
                  "slim2intranet$xsl_suffix.xsl";
   } else {
        $xslfile = C4::Context->config('opachtdocs') . 
                  "/prog/en/xslt/" .
                  C4::Context->preference('marcflavour') .
                  "slim2OPAC$xsl_suffix.xsl";
   }
   return $xslfile;
}
sub XSLTParse4Display {
    my ( $biblionumber, $orig_record, $xslfilename ) = @_;

    # grab the XML, run it through our stylesheet, push it out to the browser
    my $record = transformMARCXML4XSLT( $biblionumber, $orig_record );
    my $itemsimageurl = GetKohaImageurlFromAuthorisedValues( "CCODE", $orig_record->subfield("099", "t")) || '';
    my $logoxml = "<logo>" . $itemsimageurl . "</logo>\n";
    #return $record->as_formatted();
    my $itemsxml  = buildKohaItemsNamespace($biblionumber);
    my $xmlrecord = $record->as_xml( C4::Context->preference('marcflavour') );
    my $sysxml    = "<sysprefs>\n";
    foreach my $syspref (qw/OPACURLOpenInNewWindow singleBranchMode Version item-level_itypes OPACShelfBrowser DisplayOPACiconsXSLT URLLinkText viewISBD/) {
        $sysxml .= "<syspref name=\"$syspref\">" . C4::Context->preference($syspref) . "</syspref>\n";
    }
    $sysxml .= "</sysprefs>\n";
    $xmlrecord =~ s/\<\/record\>/$itemsxml$sysxml$logoxml\<\/record\>/;
    $xmlrecord =~ s/\& /\&amp\; /;
    $xmlrecord =~ s/\&amp\;amp\; /\&amp\; /;

    my $parser = XML::LibXML->new();

    # don't die when you find &, >, etc
    $parser->recover_silently(1);

    my $source = $parser->parse_string($xmlrecord);
    $debug and warn "$stylesheet, $interface,$xsl_suffix";
    my $filename=_buildfilename($interface,$xsl_suffix);
    if ( !$stylesheet or ($filename and !$stylesheet->{$filename})) {
        my $xslt = XML::LibXSLT->new();
        my $style_doc = $parser->parse_file($filename);
        $stylesheet->{$filename} = $xslt->parse_stylesheet($style_doc);
    }
    my $results = $stylesheet->{$filename}->transform($source);
    my $newxmlrecord = $stylesheet->{$filename}->output_string($results);
    return $newxmlrecord;
}

sub buildKohaItemsNamespace {
    my ($biblionumber) = @_;
    my @items          = C4::Items::GetItemsInfo($biblionumber);
    my $branches       = GetBranches();
    my $itemtypes      = GetItemTypes();
    my $xml            = '';
    for my $item (@items) {
        my $status;
		my $displayedstatus;
        my ( $transfertwhen, $transfertfrom, $transfertto ) = C4::Circulation::GetTransfers( $item->{itemnumber} );

        my ( $reservestatus, $reserveitem ) = C4::Reserves::CheckReserves( $item->{itemnumber} );
        if ( C4::Context->preference('hidelostitems') and $item->{itemlost} ) {
            next;
        }
        if (   $itemtypes->{ $item->{itype} }->{notforloan}
            || $item->{notforloan}
            || $item->{onloan}
            || $item->{wthdrawn}
            || $item->{itemlost}
            || $item->{damaged}
            || ( defined $transfertwhen && $transfertwhen ne '' )
            || $item->{itemnotforloan}
            || ( defined $reservestatus && $reservestatus eq "Waiting" ) ) {
            if ( $item->{notforloan} < 0 ) {
                $status = "On order"; $displayedstatus = "On order";
            }
            if ( $item->{itemnotforloan} > 0 || $item->{notforloan} > 0 || $itemtypes->{ $item->{itype} }->{notforloan} == 1 ) {
                $status = "reference"; $displayedstatus = "Not for loan";
            }
            if ( $item->{onloan} ) {
                $status = "Checked out"; $displayedstatus = "Checked out";
            }
            if ( $item->{wthdrawn} ) {
                $status = "Withdrawn"; $displayedstatus = "Withdrawn";
            }
            if ( $item->{itemlost} ) {
                $status = "Lost"; $displayedstatus = "Lost";
            }
            if ( $item->{damaged} ) {
                $status = "Damaged"; $displayedstatus = "Damaged";
            }
            if ( defined $transfertwhen && $transfertwhen ne '' ) {
                $status = 'In transit'; $displayedstatus = "In transit";
            }
            if ( defined $reservestatus && $reservestatus eq "Waiting" ) {
                $status = 'Waiting'; $displayedstatus = "Waiting";
            }
        } else {
            $status = "available"; $displayedstatus = "Available";
        }
        
        my $itemnumber = $item->{itemnumber} || '';
        my $biblioitemnumber = $item->{biblioitemnumber} || '';
        my $homebranch = $branches->{ $item->{homebranch} }->{'branchname'};
        my $itembarcode = $item->{barcode} || '';
        my $itemprice = $item->{price} || '';
        my $itemstack = $item->{stack} || '';
        my $itemdamaged = $item->{damaged} || '';
        my $itemonloan = $item->{onloan} || '';
        my $itemlost = $item->{itemlost} || '';
        my $itemwthdrawn = $item->{wthdrawn} || '';
        my $itemnotforloan = $item->{notforloan} || '';
        my $itemcallnumber = $item->{itemcallnumber} || '';
        my $itemdescription = $item->{description} || '';
        my $itemlocation = GetAuthorisedValueByCode( "LOC", $item->{location}) || '';
        my $itemitype = $item->{itype} || '';
        my $itembranchurl = $item->{branchurl} || '';
        my $itemccode = $item->{ccode} || '';
        my $itemenumchron = $item->{enumchron} || '';
        my $itemuri = $item->{uri} || '';
        my $itemcopynumber = $item->{copynumber} || '';
        my $itemitemnotes = $item->{itemnotes} || '';
        my $itemserialseq = $item->{serialseq} || '';
        my $itempublisheddate = format_date( $item->{publisheddate} ) || '';
        my $itemdatedue = format_date( $item->{datedue} ) || '';
        my $itemimageurl = getitemtypeimagelocation( 'opac', $itemtypes->{$itemitype}->{'imageurl'} ) || '';
        my $itemreserves = $item->{reserves} || '';
        my $itemholdingbranch = $branches->{ $item->{holdingbranch} }->{'branchname'} || '';
        my $itemcn_source = $item->{cn_source} || '';
        my $itemcn_sort = $item->{cn_sort} || '';
        my $itemmaterials = $item->{materials} || '';
        my $itemstocknumber = $item->{stocknumber} || '';
        my $itemstatisticvalue = $item->{statisticvalue} || '';
        my $itemnew = $item->{new} || '';
        #warn Data::Dumper::Dumper $item;
        $itemcallnumber =~ s/\&/\&amp\;/g;
        $xml .= "<item>
        <displayedstatus>$displayedstatus</displayedstatus>
        <status>$status</status>
        <itemnumber>$itemnumber</itemnumber>
        <biblioitemnumber>$biblioitemnumber</biblioitemnumber>
        <homebranch>$homebranch</homebranch>
        <itembarcode>$itembarcode</itembarcode>
        <itemprice>$itemprice</itemprice>
        <itemstack>$itemstack</itemstack>
        <itemdamaged>$itemdamaged</itemdamaged>
        <itemonloan>$itemonloan</itemonloan>
        <itemlost>$itemlost</itemlost>
        <itemwthdrawn>$itemwthdrawn</itemwthdrawn>
        <itemnotforloan>$itemnotforloan</itemnotforloan>
        <itemcallnumber>$itemcallnumber</itemcallnumber>
        <itemdescription>$itemdescription</itemdescription>
        <itemlocation>$itemlocation</itemlocation>
        <itemitype>$itemitype</itemitype>
        <itembranchurl>$itembranchurl</itembranchurl>
        <itemccode>$itemccode</itemccode>
        <itemenumchron>$itemenumchron</itemenumchron>
        <itemuri>$itemuri</itemuri>
        <itemcopynumber>$itemcopynumber</itemcopynumber>
        <itemitemnotes>$itemitemnotes</itemitemnotes>
        <itemserialseq>$itemserialseq</itemserialseq>
        <itempublisheddate>$itempublisheddate</itempublisheddate>
        <itemdatedue>$itemdatedue</itemdatedue>
        <itemimageurl>$itemimageurl</itemimageurl>
        <itemreserves>$itemreserves</itemreserves>
        <itemholdingbranch>$itemholdingbranch</itemholdingbranch>
        <itemcn_source>$itemcn_source</itemcn_source>
        <itemcn_sort>$itemcn_sort</itemcn_sort>
        <itemmaterials>$itemmaterials</itemmaterials>
        <itemstocknumber>$itemstocknumber</itemstocknumber>
        <itemstatisticvalue>$itemstatisticvalue</itemstatisticvalue>
        <itemnew>$itemnew</itemnew>
        </item>";
    }
    $xml = "<items xmlns=\"http://www.koha.org/items\">" . $xml . "</items>";
    return $xml;
}

1;
__END__

=head1 NOTES

=head1 AUTHOR

Joshua Ferraro <jmf@liblime.com>

=cut
