#!/usr/bin/perl

# Copyright 2011 BibLibre
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

use CGI;
use C4::Auth;
use C4::Branch;
use C4::Members;
use C4::Members::Attributes qw(GetBorrowerAttributes);
use C4::Output;
use Modern::Perl;

my $input = new CGI;
my $op = $input->param('op') || 'show_form';
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "tools/modborrowers.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => "edit_patrons",
    }
);

my %cookies   = parse CGI::Cookie($cookie);
my $sessionID = $cookies{'CGISESSID'}->value;
my $dbh       = C4::Context->dbh;



if ( $op eq 'show' ) {
    my $filefh      = $input->upload('uploadfile');
    my $filecontent = $input->param('filecontent');
    my @borrowers;
    my @cardnumbers;
    my @notfoundcardnumbers;

    my @contentlist;
    if ($filefh) {
        while ( my $content = <$filefh> ) {
            $content =~ s/[\r\n]*$//g;
            push @cardnumbers, $content if $content;
        }
    } else {
        if ( my $list = $input->param('cardnumberlist') ) {
            push @cardnumbers, split( /\s\n/, $list );
        }
    }

    my $max_nb_attr = 0;
    my $attributes = C4::Members::Attributes::GetBorrowerAttributes(10);
    foreach my $cardnumber (@cardnumbers) {
        my $borrower = GetMember( cardnumber => $cardnumber );
        if ( $borrower ) {
            $$borrower{branchname} = GetBranchName( $$borrower{branchcode} );
            foreach ( qw(dateenrolled dateexpiry debarred) ) {
                my $userdate = $$borrower{$_};
                unless ($userdate && $userdate ne "0000-00-00" and $userdate ne "9999-12-31") {
                    $borrower->{$_} = '';
                    next;
                }
                $userdate = C4::Dates->new( $userdate, 'iso' )->output('syspref');
                $borrower->{$_} = $userdate || '';
            }
            my $attr_loop = C4::Members::Attributes::GetBorrowerAttributes( $$borrower{borrowernumber} );
            $$borrower{patron_attributes} = $attr_loop;
            $max_nb_attr = scalar( @{ $$borrower{patron_attributes} } )
                if scalar( $$borrower{patron_attributes} ) > $max_nb_attr;
            push @borrowers, $borrower;
        } else {
            push @notfoundcardnumbers, $cardnumber;
        }
    }

    for my $borrower ( @borrowers ) {
        my $length = scalar( @{ $$borrower{patron_attributes} } );
        push @{ $$borrower{patron_attributes} }, {} for ( $length .. $max_nb_attr - 1);
    }

    my @attributes_header = ();
    for ( 1 .. scalar( $max_nb_attr ) ) {
        push @attributes_header, { attribute => "Attributes $_" };
    }
    $template->param( borrowers => \@borrowers );
    $template->param( attributes_header => \@attributes_header );
    $template->param( notfoundcardnumbers => map { { cardnumber => $_ } } @notfoundcardnumbers )
        if @notfoundcardnumbers;

    my @branches = GetBranchesLoop;
    push my @branches_option, { value => $$_{branchcode}, lib => $$_{branchname} } for @branches;
    my $branchcategories = GetBranchCategories;
    push my @branchcategories_option, { value => $$_{categorycode}, lib => $$_{categoryname} } for @branchcategories;
    my @Bsort1 = GetAuthorisedValues("Bsort1");
    push my @sort1_option, { value => $$_{authorised_valued}, lib => $$_{lib} } for @bSort1;
    my @Bsort2 = GetAuthorisedValues("Bsort2");
    push my @sort2_option, { value => $$_{authorised_valued}, lib => $$_{lib} } for @bsort2;
    my @fields = (
        {
            name => "surname",
            lib  => "Surname",
            type => "text"
        }
        ,
        {
            name => "firstname",
            lib  => "Firstname",
            type => "text"
        }
        ,
        {
            name => "branchcode",
            lib  => "Branchname",
            type => "select",
            option => \@branches_option,
        }
        ,
        {
            name => "categorycode",
            lib  => "Category",
            type => "select",
            option => \@branchcategories_option,
        }
        ,
        {
            name => "sort1",
            lib  => "Sort 1",
            type => "select",
            option => \@sort1_option,
        }
        ,
        {
            name => "sort2",
            lib  => "Sort 2",
            type => "select",
            option => \@sort2_option,
        }
        ,
        {
            name => "dateenrolled",
            lib  => "Date enrolled",
            type => "text"
        }
        ,
        {
            name => "dateexpiry",
            lib  => "Date expiry",
            type => "text"
        }
        ,
        {
            name => "debarred",
            lib  => "Debarred",
            type => "text"
        }
        ,
        {
            name => "debarredcomment",
            lib  => "Debarred comment",
            type => "text"
        }
        ,
        {
            name => "notes",
            lib  => "Notes",
            type => "text"
        }
        ,
    );
    $template->param( 'fields' => \@fields );
    my $op = "show";
}

$template->param(
    op => $op,
);
output_html_with_http_headers $input, $cookie, $template->output;
exit;
