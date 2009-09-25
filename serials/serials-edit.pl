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

serials-edit.pl

=head1 Parameters

=over 4

=item op
op can be :
    * modsubscriptionhistory :to modify the subscription history
    * serialchangestatus     :to modify the status of this subscription

=item subscriptionid

=item user

=item histstartdate

=item enddate

=item recievedlist

=item missinglist

=item opacnote

=item librariannote

=item serialid

=item serialseq

=item planneddate

=item notes

=item status

=back

=cut


use strict;
use warnings;
use CGI;
use C4::Debug;
use C4::Auth;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Biblio;
use C4::Items;
use C4::Koha;
use C4::Output;
use C4::Data::MARCRecord;
use C4::Context;
use C4::Serials;
use List::MoreUtils qw(first_index);
#use Smart::Comments;

my $cgi = new CGI;
my $dbh = C4::Context->dbh;
my @serialids = $cgi->param('serialid');
my @serialseqs = $cgi->param('serialseq');
my @planneddates = $cgi->param('planneddate');
my @publisheddates = $cgi->param('publisheddate');
my @status = $cgi->param('status');
my @notes = $cgi->param('notes');
my @subscriptionids = $cgi->param('subscriptionid');
my $op = $cgi->param('op');
if (scalar(@subscriptionids)==1 && index($subscriptionids[0],",")>0){
  @subscriptionids =split (/,/,$subscriptionids[0]);
}
my @errors;
my @errseq;
# If user comes from subscription details
unless (@serialids){
  foreach my $subscriptionid (@subscriptionids){
    my $serstatus=$cgi->param('serstatus');
    if ($serstatus){
      my ($count,@tmpser)=GetSerials2($subscriptionid,$serstatus);
      foreach (@tmpser) {
        push @serialids, $_->{'serialid'};
      }
    }
  }
}

unless (scalar(@serialids)){
  my $string="serials-collection.pl?subscriptionid=".join(",",@subscriptionids);
  $string=~s/,$//;
#  warn $string;
  print $cgi->redirect($string);
}
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/serials-edit.tmpl",
                query => $cgi,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => {serials => 1},
                debug => 1,
                });

my @serialdatalist;
my %processedserialid;
foreach my $tmpserialid (@serialids){
    #filtering serialid for duplication
    #NEW serial should appear only once and are created afterwards
    next unless (defined($tmpserialid) && $tmpserialid =~/^[0-9]+$/ && !$processedserialid{$tmpserialid});
    my $data=GetSerialInformation($tmpserialid);
    $data->{publisheddate}=format_date($data->{publisheddate});
    $data->{planneddate}=format_date($data->{planneddate});
    $data->{'editdisable'}=((HasSubscriptionExpired($data->{subscriptionid})&& $data->{'status1'})||$data->{'cannotedit'});
    push @serialdatalist,$data;
    $processedserialid{$tmpserialid}=1;
}
my $bibdata=GetBiblioData($serialdatalist[0]->{'biblionumber'});

my @newserialloop;
my @subscriptionloop;
# check, for each subscription edited, that we have an empty item line if applicable for the subscription
my %processedsubscriptionid;
foreach my $subscriptionid (@subscriptionids){
    #Donot process subscriptionid twice if it was already processed.
    next unless (defined($subscriptionid) && !$processedsubscriptionid{$subscriptionid});
    my $cell;
    if ($serialdatalist[0]->{'serialsadditems'}){
    #Create New empty item
		my $subscription=GetSubscription($subscriptionid);
		my $defaults;
		$$defaults{"items.$_"}=$$subscription{$_} for qw(location branchcode callnumber);
        $cell =
        PrepareItemrecordInput( "", $serialdatalist[0]->{'biblionumber'}, $defaults);
        $cell->{serialsadditems} = 1;
    }
    $cell->{'subscriptionid'}=$subscriptionid;
    $cell->{'itemid'}       = "NNEW";
    $cell->{'serialid'}     = "NEW";
    $cell->{'issuesatonce'}   = 1;
    push @newserialloop,$cell;
    push @subscriptionloop, {'subscriptionid'=>$subscriptionid,
                            'abouttoexpire'=>abouttoexpire($subscriptionid),
                            'subscriptionexpired'=>HasSubscriptionExpired($subscriptionid),
    };
    $processedsubscriptionid{$subscriptionid}=1;
}
$template->param(newserialloop=>\@newserialloop);
$template->param(subscriptions=>\@subscriptionloop);

if ($op and $op eq 'serialchangestatus') {
#     my $sth = $dbh->prepare("select status from serial where serialid=?");
    my $newserial;
	my @params=$cgi->param();
	my @itemnumbers=$cgi->param("itemnumber");
	my @biblionumbers=$cgi->param("biblionumber");
	my @serials=$cgi->param("serial");
	my $index_latestitemnumber;
	my $index_serialid;
	my $count;
    for (my $i=0;$i<=$#serialids;$i++) {
#         $sth->execute($serialids[$i]);
#         my ($oldstatus) = $sth->fetchrow;
        if ($serialids[$i] && $serialids[$i] eq "NEW") {
          if ($serialseqs[$i]){
            #IF newserial was provided a name Then we have to create a newSerial
            ### FIXME if NewIssue is modified to use subscription biblionumber, then biblionumber would not be useful.
            $newserial = NewIssue( $serialseqs[$i],$subscriptionids[$i],$serialdatalist[0]->{'biblionumber'},
                      $status[$i],
                      format_date_in_iso($planneddates[$i]),
                      format_date_in_iso($publisheddates[$i]),
                      $notes[$i]);
          }
        }elsif ($serialids[$i]){
            ModSerialStatus($serialids[$i],
                            $serialseqs[$i],
                            format_date_in_iso($planneddates[$i]),
                            format_date_in_iso($publisheddates[$i]),
                            $status[$i],
                            $notes[$i]);
        }

		if ($status[$i]==2){
			$index_serialid=($index_latestitemnumber>0?$index_latestitemnumber:first_index{ $_ eq "serialid"}@params[$index_serialid ..$#params]);
			$index_latestitemnumber=first_index{ $_ eq "serialid"}@params[$index_serialid + 1 ..$#params];
			$debug && warn "serial $index_serialid $index_latestitemnumber";
			if ($index_latestitemnumber<0){$index_latestitemnumber=$#params};
			my @localparams=@params[$index_serialid+1 .. $index_latestitemnumber];
			while (my $indexsup=first_index{$_ eq "itemnumber"} @localparams){
				my $indexmin=first_index{$_ =~/tag_/} @localparams;
			
				$debug && warn "item $indexmin $indexsup";
				last if ($indexsup<0);
				my @itemsparams=@localparams[$indexmin..$indexsup];
				my $itemmarcrecord=TransformHtmlToMarc(\@itemsparams,$cgi);

					if ($itemnumbers[$count]=~/^N/){
						#New Item
						
						# if autoBarcode is set to 'incremental', calculate barcode...
						my ($barcodetagfield,$barcodetagsubfield) = &GetMarcFromKohaField("items.barcode", GetFrameworkCode($biblionumbers[$i]));
						if (C4::Context->preference("autoBarcode") eq 'incremental'  ) {
						  if (!$itemmarcrecord->field($barcodetagfield)->subfield($barcodetagsubfield)) {
							my $sth_barcode = $dbh->prepare("select max(abs(barcode)) from items");
							$sth_barcode->execute;
							my ($newbarcode) = $sth_barcode->fetchrow;
							# OK, we have the new barcode, add the entry in MARC record # FIXME -> should be  using barcode plugin here.
							$itemmarcrecord->field($barcodetagfield)->update( $barcodetagsubfield => ++$newbarcode );
						  }
						}
						# check for item barcode # being unique
						my $exists;
						if ($itemmarcrecord->subfield($barcodetagfield,$barcodetagsubfield)) {
							$exists = GetItemnumberFromBarcode($itemmarcrecord->subfield($barcodetagfield,$barcodetagsubfield));
						}
						#           push @errors,"barcode_not_unique" if($exists);
						# if barcode exists, don't create, but report The problem.
						if ($exists){
							push @errors,"barcode_not_unique" if($exists);
							push @errseq,{"serialseq"=>$serialseqs[$count]};
						} else {
			                my ($biblionumber,$bibitemnum,$itemnumber) = AddItemFromMarc($itemmarcrecord,$biblionumbers[$i]);
			                AddItem2Serial($serialids[$i],$itemnumber);
						}
					  } else {
						#modify item
			            my ($oldbiblionumber,$oldbibnum,$itemnumber) = ModItemFromMarc($itemmarcrecord,$biblionumbers[$i],$itemnumbers[$count]);
					  }
				$count++;
				@localparams=@localparams[$indexsup + 1 ..$#localparams];
			}
		}
    }
#      #Rebuilding ALL the data for items into a hash
#      # parting them on $itemid.
#      foreach my $item (keys %itemhash){
#        # Verify Itemization is "Valid", i.e. serial status is Arrived or Missing
#        my $index=-1;
#        for (my $i=0; $i<scalar(@serialids);$i++){
#          $index = $i if ($itemhash{$item}->{'serial'} eq $serialids[$i] || ($itemhash{$item}->{'serial'} == $newserial && $serialids[$i] eq "NEW"));
#        }
#        if ($index>=0 && $status[$index]==2){
#          my $xml = TransformHtmlToXml( $itemhash{$item}->{'tags'},
#                                  $itemhash{$item}->{'subfields'},
#                                  $itemhash{$item}->{'field_values'},
#                                  $itemhash{$item}->{'ind_tag'},
#                                  $itemhash{$item}->{'indicator'});
#  #           warn $xml;
#          my $record=MARC::Record::new_from_xml($xml, 'UTF-8');
#        }
#      }
#    }
#     ### FIXME this part of code is not very pretty. Nor is it very efficient... There MUST be a more perlish way to write it. But it works.
#     my $redirect ="serials-home.pl?";
#     $redirect.=join("&",map{"serialseq=".$_} @serialseqs);
#     $redirect.="&".join("&",map{"planneddate=".$_} @planneddates);
#     $redirect.="&".join("&",map{"publisheddate=".$_} @publisheddates);
#     $redirect.="&".join("&",map{"status=".$_} @status);
#     $redirect.="&".join("&",map{"notes=".$_} @notes);

   if (scalar(@errors)>0){
        $template->param("Errors" => 1);
        if (scalar(@errseq)>0){
            $template->param("barcode_not_unique" => 1);
            $template->param('errseq'=>\@errseq);
        }
   } else {
        my $redirect ="serials-collection.pl?";
        my %hashsubscription;
	      foreach (@subscriptionids) {
            $hashsubscription{$_}=1;
	      }
        $redirect.=join("&",map{"subscriptionid=".$_} sort keys %hashsubscription);
        print $cgi->redirect("$redirect");
   }
}

$template->param(
	serialsadditems => $serialdatalist[0]->{'serialsadditems'},
	bibliotitle  => $bibdata->{'title'},
	biblionumber => $serialdatalist[0]->{'biblionumber'},
	serialslist  => \@serialdatalist,
);
output_html_with_http_headers $cgi, $cookie, $template->output;
