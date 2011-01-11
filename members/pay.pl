#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2010 BibLibre
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

=head1 pay.pl

 part of the koha library system, script to facilitate paying off fines

=cut

use strict;
use warnings;

use C4::Context;
use C4::Auth;
use C4::Output;
use CGI;
use C4::Members;
use C4::Context;
use C4::Accounts;
use C4::Stats;
use C4::Koha;
use C4::Overdues;
use C4::Branch;    # GetBranches

my $input = new CGI;
my $lastinsertid = 0;
#warn Data::Dumper::Dumper $input;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "members/pay.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { borrowers => 1, updatecharges => 1 },
        debug           => 1,
    }
);

my $manager_id = C4::Context->userenv->{'number'};
my $borrowernumber = $input->param('borrowernumber');
if ( $borrowernumber eq '' ) {
    $borrowernumber = $input->param('borrowernumber0');
}

# get borrower details
my $data = GetMember( borrowernumber => $borrowernumber );
my $user = $input->remote_user;

# get account details
my $branches = GetBranches();
my $branch = GetBranch( $input, $branches );

my @names = $input->param;
my %inp;
my $check = 0;
for ( my $i = 0 ; $i < @names ; $i++ ) {
	if(defined($input->param( $names[ $i + 1 ] )) && $names[ $i + 1 ] =~ /^accountlineid/)
	{
	    if(defined($input->param( "payfine".$input->param( $names[ $i + 1 ] ) )))
	    {
	    	my $accountlineid      = $input->param( $names[ $i + 1 ] );#7
		    my $temp = $input->param( "payfine".$accountlineid );
		    if ( $temp eq 'wo' ) {
		        $inp{ $names[$i] } = $temp;
		        $check = 1;
		    }
		    if ( $temp eq 'yes' ) {
				#my $accountlineid      = $input->param( $names[ $i + 1 ] );#7
		        # FIXME : using array +4, +5, +6 is dirty. Should use arrays for each accountline
		        my $amount         = $input->param( "amount".$accountlineid );#4
		        my $borrowernumber = $input->param( "borrowernumber".$accountlineid );#5
		        my $accountno      = $input->param( "accountno".$accountlineid );#6
		        my $note     = $input->param( "note".$accountlineid );#12
		        my $meansofpayment     = $input->param( "meansofpayment".$accountlineid );#11
		        #$accountnoupdated = getnextacctno($borrowernumber);
		        $lastinsertid = makepayment( $accountlineid, $borrowernumber, $accountno, $amount, $user, $branch, $note, $meansofpayment, $manager_id, 0 );
		        $check = 2;
		    }
		    elsif($temp eq 'pp')
		    {
		    	#my $accountlineid      = $input->param( $names[ $i +1 ] );#7
		    	my $amount         = $input->param( "amount".$accountlineid );#4
		        my $borrowernumber = $input->param( "borrowernumber".$accountlineid );#5
		        my $accountno      = $input->param( "accountno".$accountlineid );#6
		        my $note     = $input->param( "note".$accountlineid );#12
		        my $meansofpayment     = $input->param( "meansofpayment".$accountlineid );#11
		        my $partpaymentamount         = $input->param( "partpaymentamount".$accountlineid );#13
		    	$lastinsertid = makepayment( $accountlineid, $borrowernumber, $accountno, $amount, $user, $branch, $note, $meansofpayment, $manager_id, $partpaymentamount);
		        $check = 2;
		    }
	    }
	}
}

my $total = $input->param('total') || '';
if ( $check == 0 ) {
    if ( $total ne '' ) {
        recordpayment( $borrowernumber, $total );
    }

    my ( $total, $accts, $numaccts ) = GetMemberAccountRecords($borrowernumber);

    my @allfile;
    my @notify = NumberNotifyId($borrowernumber);

    my $numberofnotify = scalar(@notify);
    for ( my $j = 0 ; $j < scalar(@notify) ; $j++ ) {
        my @loop_pay;
        my ( $total, $accts, $numaccts ) = GetBorNotifyAcctRecord( $borrowernumber, $notify[$j] );
        for ( my $i = 0 ; $i < $numaccts ; $i++ ) {
            my %line;
            if ( $accts->[$i]{'amountoutstanding'} != 0 ) {
                $accts->[$i]{'amount'}            += 0.00;
                $accts->[$i]{'amountoutstanding'} += 0.00;
                $line{i}                 = $accts->[$i]{'id'};
                $line{accountlineid}     = $accts->[$i]{'id'};
                $line{itemnumber}        = $accts->[$i]{'itemnumber'};
                $line{accounttype}       = $accts->[$i]{'accounttype'};
                $line{amount}            = sprintf( "%.2f", $accts->[$i]{'amount'} );
                $line{amountoutstanding} = sprintf( "%.2f", $accts->[$i]{'amountoutstanding'} );
                $line{borrowernumber}    = $borrowernumber;
                $line{accountno}         = $accts->[$i]{'accountno'};
                $line{description}       = $accts->[$i]{'description'};
                $line{note}              = $accts->[$i]{'note'};
                $line{meansofpaymentoptions}=getMeansOfPaymentList($accts->[$i]{'meansofpayment'});
                $line{meansofpayment}     = $accts->[$i]{'meansofpayment'};
                $line{title}             = $accts->[$i]{'title'};
                $line{notify_id}         = $accts->[$i]{'notify_id'};
                $line{notify_level}      = $accts->[$i]{'notify_level'};
                $line{net_balance}       = 1 if ( $accts->[$i]{'amountoutstanding'} > 0 );         # you can't pay a credit.
                push( @loop_pay, \%line );
            }
        }

        my $totalnotify = AmountNotify( $notify[$j], $borrowernumber );
        ( $totalnotify = '0' ) if ( $totalnotify =~ /^0.00/ );
        push @allfile, {
            'loop_pay' => \@loop_pay,
            'notify'   => $notify[$j],
            'total'    => sprintf( "%.2f", $totalnotify ),

        };
    }

    if ( $data->{'category_type'} eq 'C' ) {
        my ( $catcodes, $labels ) = GetborCatFromCatType( 'A', 'WHERE category_type = ?' );
        my $cnt = scalar(@$catcodes);
        $template->param( 'CATCODE_MULTI' => 1 ) if $cnt > 1;
        $template->param( 'catcode' => $catcodes->[0] ) if $cnt == 1;
    }

    $template->param( adultborrower => 1 ) if ( $data->{'category_type'} eq 'A' );
    my ( $picture, $dberror ) = GetPatronImage( $data->{'cardnumber'} );
    $template->param( picture => 1 ) if $picture;

    $template->param(
        allfile        => \@allfile,
        firstname      => $data->{'firstname'},
        surname        => $data->{'surname'},
        borrowernumber => $borrowernumber,
        cardnumber     => $data->{'cardnumber'},
        categorycode   => $data->{'categorycode'},
        category_type  => $data->{'category_type'},
        categoryname   => $data->{'description'},
        address        => $data->{'address'},
        address2       => $data->{'address2'},
        city           => $data->{'city'},
        zipcode        => $data->{'zipcode'},
        country        => $data->{'country'},
        phone          => $data->{'phone'},
        email          => $data->{'email'},
        branchcode     => $data->{'branchcode'},
        branchname     => GetBranchName( $data->{'branchcode'} ),
        is_child       => ( $data->{'category_type'} eq 'C' ),
        total          => sprintf( "%.2f", $total )
    );
    output_html_with_http_headers $input, $cookie, $template->output;

} else {

    my %inp;
    my @name = $input->param;
    for ( my $i = 0 ; $i < @name ; $i++ ) {
        my $test = $input->param( $name[$i] );
        if ( $test eq 'wo' ) {
            my $temp = $name[$i];
            $temp =~ s/payfine//;
            $inp{ $name[$i] } = $temp;
        }
    }
    my $borrowernumber;
    while ( my ( $key, $value ) = each %inp ) {

        my $accounttype = $input->param("accounttype$value");
        $borrowernumber = $input->param("borrowernumber$value");
        my $itemno    = $input->param("itemnumber$value");
        my $amount    = $input->param("amount$value");
        my $accountno = $input->param("accountno$value");
        my $accountlineid = $input->param("accountlineid$value");
        writeoff( $borrowernumber, $accountno, $itemno, $accounttype, $amount, $accountlineid );
    }
    $borrowernumber = $input->param('borrowernumber');
    print $input->redirect("/cgi-bin/koha/members/boraccount.pl?borrowernumber=$borrowernumber");
}

sub writeoff {
    my ( $borrowernumber, $accountnum, $itemnum, $accounttype, $amount, $accountlineid ) = @_;
    my $user = $input->remote_user;
    my $dbh  = C4::Context->dbh;
    undef $itemnum unless $itemnum;    # if no item is attached to fine, make sure to store it as a NULL
    my $sth = $dbh->prepare( "Update accountlines set amountoutstanding=0 where id=?" );
    $sth->execute( $accountlineid );
    $sth->finish;
    $sth = $dbh->prepare("select max(accountno) from accountlines");
    $sth->execute;
    my $account = $sth->fetchrow_hashref;
    $sth->finish;
    $account->{'max(accountno)'}++;
    $sth = $dbh->prepare(
        "insert into accountlines (borrowernumber,accountno,itemnumber,date,time,amount,description,accounttype,manager_id)
						values (?,?,?,now(),CURRENT_TIME,?,?,'W', ?)"
    );
    $sth->execute( $borrowernumber, $account->{'max(accountno)'}, $itemnum, $amount,"Writeoff for account n°".$accountnum, $manager_id);
    $sth->finish;
    UpdateStats( $branch, 'writeoff', $amount, '', '', '', $borrowernumber );
}
