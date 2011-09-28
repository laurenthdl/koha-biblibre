#!/usr/bin/perl

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

use CGI;
use Date::Calc qw(Today Day_of_Year Week_of_Year Add_Delta_Days Add_Delta_YM);
use C4::Koha;
use C4::Biblio;
use C4::Auth;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Acquisition;
use C4::Output;
use C4::Context;
use C4::Branch;    # GetBranches
use C4::Serials;
use C4::Serials::Frequency;
use C4::Serials::Numberpattern;
use C4::Letters;
use Carp;

#use Smart::Comments;

my $query = CGI->new;
my $op    = $query->param('op') || '';
my $dbh   = C4::Context->dbh;
my $sub_length;

# Permission needed if it is a modification : edit_subscription
# Permission needed otherwise (nothing or dup) : create_subscription
my $permission = ($op eq "mod") ? "edit_subscription" : "create_subscription";

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {   template_name   => "serials/subscription-add.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { serials => $permission },
        debug           => 1,
    }
);

my $sub_on;
my @subscription_types = ( 'issues', 'weeks', 'months' );
my @sub_type_data;

my $subs;
my $nextexpected;

if ( $op eq 'mod' || $op eq 'dup' || $op eq 'modsubscription' ) {

    my $subscriptionid = $query->param('subscriptionid');
    $subs = GetSubscription($subscriptionid);
    if( $flags->{'superlibrarian'} == 1
     || $template->{'param_map'}->{'CAN_user_serials_superserials'}
     || !defined $subs->{'branchcode'}
     || $subs->{'branchcode'} eq ''
     || $subs->{'branchcode'} eq C4::Context->userenv->{'branch'} ) {
        $subs->{'cannotedit'} = 0;
    } else {
        $subs->{'cannotedit'} = 1;
    }
## FIXME : Check rights to edit if mod. Could/Should display an error message.
    if ( $subs->{'cannotedit'} && $op eq 'mod' ) {
        carp "Attempt to modify subscription $subscriptionid by " . C4::Context->userenv->{'id'} . " not allowed";
        print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    }
    for (qw(startdate firstacquidate histstartdate enddate histenddate)) {
        next unless defined $subs->{$_};

        # TODO : Handle date formats properly.
        if ( $subs->{$_} eq '0000-00-00' ) {
            $subs->{$_} = '';
        } else {
            $subs->{$_} = format_date( $subs->{$_} );
        }
    }
    $subs->{'letter'} = '' unless ( $subs->{'letter'} );
    letter_loop( $subs->{'letter'}, $template );
    $nextexpected = GetNextExpected($subscriptionid);
    $subs->{nextacquidate} = (defined $nextexpected->{planneddate} and $op eq 'mod') ? $nextexpected->{planneddate}->output() : undef;
    unless ( $op eq 'modsubscription' ) {
        foreach my $length_unit qw(numberlength weeklength monthlength) {
            if ( $subs->{$length_unit} ) {
                $sub_length = $subs->{$length_unit};
                if($length_unit eq "numberlength"){
                    $sub_on = "issues";
                }elsif($length_unit eq "weeklength"){
                    $sub_on = "weeks";
                }elsif($length_unit eq "monthlength"){
                    $sub_on = "months";
                }
                last;
            }
        }

        $template->param($subs);
        $template->param( "dow" . $subs->{'dow'} => 1 ) if defined $subs->{'dow'};
        $template->param(
            $op         => 1,
            sublength   => $sub_length,
        );

        my ($serials_number) = GetSerials($subscriptionid);
        if($serials_number > 1 && $op eq "mod") {
            $template->param(more_than_one_serial => 1);
        }
    }
    if ( $op eq 'dup' ) {
        my $dont_copy_fields = C4::Context->preference('SubscriptionDuplicateDroppedInput');
        my @fields_id = map { fieldid => $_ }, split ';', $dont_copy_fields;
        $template->param( dont_export => \@fields_id );
    }
}

my $onlymine =
     C4::Context->preference('IndependantBranches')
  && C4::Context->userenv
  && C4::Context->userenv->{flags} % 2 != 1
  && C4::Context->userenv->{branch};
my $branches = GetBranches($onlymine);
my $branchloop;
for my $thisbranch ( sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %{$branches} ) {
    my $selected = 0;
    $selected = 1 if ( defined($subs) && $thisbranch eq $subs->{'branchcode'} );
    push @{$branchloop},
      { value      => $thisbranch,
        selected   => $selected,
        branchname => $branches->{$thisbranch}->{'branchname'},
      };
}

my $shelflocations = GetKohaAuthorisedValues( 'items.location', '' );

my @locationarg =
  map { { code => $_, value => $shelflocations->{$_}, selected => ( ( $_ eq $subs->{location} ) ? "selected=\"selected\"" : "" ), } } sort keys %{$shelflocations};

$template->param( shelflocations => \@locationarg );

$template->param(
    branchloop               => $branchloop,
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
);

# prepare template variables common to all $op conditions:
$template->param( 'dateformat_' . C4::Context->preference('dateformat') => 1, );

if ( $op eq 'addsubscription' ) {
    redirect_add_subscription();
} elsif ( $op eq 'modsubscription' ) {
    redirect_mod_subscription();
} else {
    while (@subscription_types) {
        my $sub_type = shift @subscription_types;
        my %row = ( 'name' => $sub_type );
        if ( defined $sub_on and $sub_on eq $sub_type ) {
            $row{'selected'} = ' selected';
        } else {
            $row{'selected'} = '';
        }
        push( @sub_type_data, \%row );
    }
    $template->param( subtype => \@sub_type_data, );

    letter_loop( '', $template ) if ($op ne 'modsubscription' && $op ne 'dup' && $op ne 'mod');

    my $new_biblionumber = $query->param('biblionumber_for_new_subscription');
    if ( defined $new_biblionumber ) {
        my $bib = GetBiblioData($new_biblionumber);
        if ( defined $bib ) {
            $template->param( bibnum      => $new_biblionumber );
            $template->param( bibliotitle => $bib->{title} );
        }
    }
    my @frequencies = GetSubscriptionFrequencies;
    my @frqloop;
    foreach my $thisfrq (@frequencies) {
        my $selected = 1 if $thisfrq->{'id'} eq $subs->{'periodicity'};
        my %row =(id => $thisfrq->{'id'},
                    selected => $selected,
                    label=> $thisfrq->{'description'},
                );
        push @frqloop, \%row;
    }
    $template->param(frequencies => \@frqloop);

    my @numpatterns = GetSubscriptionNumberpatterns;
    my @numberpatternloop;
    foreach my $thisnumpattern (@numpatterns) {
        my $selected = 1 if $thisnumpattern->{'id'} eq $subs->{'numberpattern'};
        my %row =(id => $thisnumpattern->{'id'},
                    selected => $selected,
                    label=> $thisnumpattern->{'label'},
                );
        push @numberpatternloop, \%row;
    }
    $template->param(numberpatterns => \@numberpatternloop);

    output_html_with_http_headers $query, $cookie, $template->output;
}

sub letter_loop {
    my ( $selected_letter, $templte ) = @_;
    my $letters = GetLetters('serial');
    my @letterloop;
    foreach my $thisletter ( keys %$letters ) {
        my $selected = $thisletter eq $selected_letter ? 1 : 0;
        push @letterloop,
          { value      => $thisletter,
            selected   => $selected,
            lettername => $letters->{$thisletter},
          };
    }
    $templte->param( letterloop => \@letterloop ) if @letterloop;
    return;
}

sub _get_sub_length {
    my ( $type, $length ) = @_;
    return ( $type eq 'issues' ? $length : 0, $type eq 'weeks' ? $length : 0, $type eq 'months' ? $length : 0, );
}

sub _guess_enddate {
    my ($startdate_iso, $frequencyid, $numberlength, $weeklength, $monthlength) = @_;
    my ($year, $month, $day);
    my $enddate;
    if($numberlength != 0) {
        my $frequency = GetSubscriptionFrequency($frequencyid);
        if($frequency->{'unit'} eq 'day') {
            ($year, $month, $day) = Add_Delta_Days(split(/-/, $startdate_iso), $numberlength * $frequency->{'unitsperissue'} / $frequency->{'issuesperunit'});
        } elsif($frequency->{'unit'} eq 'week') {
            ($year, $month, $day) = Add_Delta_Days(split(/-/, $startdate_iso), $numberlength * 7 * $frequency->{'unitsperissue'} / $frequency->{'issuesperunit'});
        } elsif($frequency->{'unit'} eq 'month') {
            ($year, $month, $day) = Add_Delta_YM(split(/-/, $startdate_iso), 0, $numberlength * $frequency->{'unitsperissue'} / $frequency->{'issuesperunit'});
        } elsif($frequency->{'unit'} eq 'year') {
            ($year, $month, $day) = Add_Delta_YM(split(/-/, $startdate_iso), $numberlength * $frequency->{'unitsperissue'} / $frequency->{'issuesperunit'}, 0);
        }
    } elsif($weeklength != 0) {
        ($year, $month, $day) = Add_Delta_Days(split(/-/, $startdate_iso), $weeklength * 7);
    } elsif($monthlength != 0) {
        ($year, $month, $day) = Add_Delta_YM(split(/-/, $startdate_iso), 0, $monthlength);
    }
    if(defined $year) {
        $enddate = sprintf("%04d-%02d-%02d", $year, $month, $day);
    } else {
        undef $enddate;
    }
    return $enddate;
}

sub redirect_add_subscription {
    my $auser          = $query->param('user');
    my $branchcode     = $query->param('branchcode');
    my $aqbooksellerid = $query->param('aqbooksellerid');
    my $cost           = $query->param('cost');
    my $aqbudgetid     = $query->param('aqbudgetid');
    my $periodicity    = $query->param('frequency');
    my $dow            = $query->param('dow');
    my @irregularity   = $query->param('irregularity');
    my $numberpattern  = $query->param('numbering_pattern');
    my $graceperiod    = $query->param('graceperiod') || 0;

    my $subtype = $query->param('subtype');
    my $sublength = $query->param('sublength');
    my ( $numberlength, $weeklength, $monthlength ) = _get_sub_length( $subtype, $sublength );
    my $lastvalue1        = $query->param('lastvalue1');
    my $lastvalue2        = $query->param('lastvalue2');
    my $lastvalue3        = $query->param('lastvalue3');
    my $innerloop1        = $query->param('innerloop1');
    my $innerloop2        = $query->param('innerloop2');
    my $innerloop3        = $query->param('innerloop3');
    my $numberingmethod   = $query->param('numberingmethod');
    my $status            = 1;
    my $biblionumber      = $query->param('biblionumber');
    my $callnumber        = $query->param('callnumber');
    my $notes             = $query->param('notes');
    my $internalnotes     = $query->param('internalnotes');
    my $hemisphere        = $query->param('hemisphere') || 1;
    my $letter            = $query->param('letter');
    my $manualhistory     = $query->param('manualhist');
    my $serialsadditems   = $query->param('serialsadditems');
    my $staffdisplaycount = $query->param('staffdisplaycount');
    my $opacdisplaycount  = $query->param('opacdisplaycount');
    my $location          = $query->param('location');
    my $skip_serialseq    = $query->param('skip_serialseq');
    my $startdate = format_date_in_iso( $query->param('startdate') );
    my $enddate = format_date_in_iso( $query->param('enddate') );
    my $firstacquidate  = format_date_in_iso($query->param('firstacquidate'));
    if(!defined $enddate || $enddate eq '') {
        if($subtype eq "issues") {
            $enddate = _guess_enddate($firstacquidate, $periodicity, $numberlength, $weeklength, $monthlength);
        } else {
            $enddate = _guess_enddate($startdate, $periodicity, $numberlength, $weeklength, $monthlength);
        }
    }

    my $subscriptionid = NewSubscription(
        $auser, $branchcode, $aqbooksellerid, $cost, $aqbudgetid, $biblionumber,
        $startdate, $periodicity, $dow, $numberlength, $weeklength,
        $monthlength, $lastvalue1, $innerloop1, $lastvalue2, $innerloop2,
        $lastvalue3, $innerloop3, $status, $notes, $letter, $firstacquidate,
        join(";",@irregularity), $numberpattern, $callnumber, $hemisphere,
        ($manualhistory ? $manualhistory : 0), $internalnotes, $serialsadditems,
        $staffdisplaycount, $opacdisplaycount, $graceperiod, $location, $enddate,
        $skip_serialseq
    );

    print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    return;
}


sub redirect_mod_subscription {
    my $subscriptionid = $query->param('subscriptionid');
    my @irregularity   = $query->param('irregularity');
    my $auser          = $query->param('user');
    my $librarian => $query->param('librarian'),
    my $branchcode   = $query->param('branchcode');
    my $cost           = $query->param('cost');
    my $aqbooksellerid = $query->param('aqbooksellerid');
    my $biblionumber   = $query->param('biblionumber');
    my $aqbudgetid     = $query->param('aqbudgetid');
    my $startdate      = format_date_in_iso( $query->param('startdate') );
    my $firstacquidate = format_date_in_iso( $query->param('firstacquidate') );
    my $nextacquidate =
      $query->param('nextacquidate')
      ? format_date_in_iso( $query->param('nextacquidate') )
      : $firstacquidate;
    my $enddate = format_date_in_iso( $query->param('enddate') );
    my $periodicity = $query->param('frequency');
    my $dow         = $query->param('dow');

    my $subtype = $query->param('subtype');
    my $sublength = $query->param('sublength');
    my ( $numberlength, $weeklength, $monthlength ) = _get_sub_length( $subtype, $sublength );
    my $numberpattern   = $query->param('numbering_pattern');
    my $lastvalue1        = $query->param('lastvalue1');
    my $lastvalue2        = $query->param('lastvalue2');
    my $lastvalue3        = $query->param('lastvalue3');
    my $innerloop1        = $query->param('innerloop1');
    my $innerloop2        = $query->param('innerloop2');
    my $innerloop3        = $query->param('innerloop3');
    my $numberingmethod = $query->param('numberingmethod');
    my $status          = 1;
    my $callnumber      = $query->param('callnumber');
    my $notes           = $query->param('notes');
    my $internalnotes   = $query->param('internalnotes');
    my $hemisphere      = $query->param('hemisphere');
    my $letter          = $query->param('letter');
    my $manualhistory   = $query->param('manualhist');
    my $serialsadditems = $query->param('serialsadditems');

    my $staffdisplaycount = $query->param('staffdisplaycount');
    my $opacdisplaycount  = $query->param('opacdisplaycount');
    my $graceperiod       = $query->param('graceperiod') || 0;
    my $location          = $query->param('location');
    my $skip_serialseq    = $query->param('skip_serialseq');

    # Guess end date
    if(!defined $enddate || $enddate eq '') {
        if($subtype eq "issues") {
            $enddate = _guess_enddate($firstacquidate, $periodicity, $numberlength, $weeklength, $monthlength);
        } else {
            $enddate = _guess_enddate($startdate, $periodicity, $numberlength, $weeklength, $monthlength);
        }
    }

    #  If it's  a mod, we need to check the current 'expected' issue, and mod it in the serials table if necessary.
    if ($nextexpected->{'planneddate'} && $nextacquidate ne $nextexpected->{planneddate}->output('iso') ) {
        ModNextExpected( $subscriptionid, C4::Dates->new( $nextacquidate, 'iso' ) );
    }

    ModSubscription(
        $auser, $branchcode, $aqbooksellerid, $cost, $aqbudgetid, $startdate,
        $periodicity, $firstacquidate, $dow, join(";",@irregularity),
        $numberpattern, $numberlength, $weeklength, $monthlength, $lastvalue1,
        $innerloop1, $lastvalue2, $innerloop2, $lastvalue3, $innerloop3,
        $status, $biblionumber, $callnumber, $notes, $letter, $hemisphere,
        $manualhistory, $internalnotes, $serialsadditems, $staffdisplaycount,
        $opacdisplaycount, $graceperiod, $location, $enddate, $subscriptionid,
        $skip_serialseq
    );
    print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    return;
}
