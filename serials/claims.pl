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
use C4::Auth;
use C4::Serials;
use C4::Acquisition;
use C4::Output;
use C4::Bookseller;
use C4::Context;
use C4::Letters;
use C4::Branch;    # GetBranches GetBranchesLoop

my $input = CGI->new;

my $serialid     = $input->param('serialid');
my $op           = $input->param('op');
my $claimletter  = $input->param('claimletter');
my $supplierid   = $input->param('supplierid');
my $suppliername = $input->param('suppliername');
my $order        = $input->param('order');

# open template first (security & userenv set here)
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {   template_name   => 'serials/claims.tmpl',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { serials => 'claim_serials' },
        debug           => 1,
    }
);

my $supplierlist = GetSuppliersWithLateIssues();
my @suploop;
foreach my $s ( @{$supplierlist} ) {
    push @suploop, { %$s };
}

my $letters = GetLetters("claimissues");
my @letters;
foreach ( keys %{$letters} ) {
    push @letters, { code => $_, name => $letters->{$_} };
}

my $letter = ( ( scalar(@letters) > 1 ) || ( $letters[0]->{name} || $letters[0]->{code} ) );
my @missingissues;
my $supplierinfo;

my $preview = 0;
if ( $op && $op eq 'preview' ) {
    $preview = 1;
    if ($supplierid) {
        @missingissues = GetLateOrMissingIssues( $supplierid, $serialid, $order );
        $supplierinfo = GetBookSellerFromId($supplierid);
    }
    unless( $flags->{'superlibrarian'} == 1
     || $template->{'param_map'}->{'CAN_user_serials_superserials'} ){
        foreach (@missingissues) {
            if( $_->{'branchcode'}
             && $_->{'branchcode'} ne C4::Context->userenv->{'branch'} ) {
                $_->{'cannot_claim'} = 1;
            }
        }
    }
} else {
    my @serialnums = $input->param('serialid');
    if (@serialnums) {    # i.e. they have been flagged to generate claims
        SendAlerts( 'claimissues', \@serialnums, $input->param("letter_code") );
        my $cntupdate = UpdateClaimdateIssues( \@serialnums );
        ### $cntupdate SHOULD be equal to scalar(@$serialnums)
    }
}
$template->param( 'letters' => \@letters, 'letter' => $letter );
$template->param(
    order                    => $order,
    %$supplierinfo,
    preview                  => $preview,
    missingissues            => \@missingissues,
    supplierid               => $supplierid,
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
);
output_html_with_http_headers $input, $cookie, $template->output;
