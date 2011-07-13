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

use Modern::Perl;
use CGI;
use C4::Auth;
use C4::Branch;
use C4::Koha;
use C4::Members;
use C4::Members::Attributes qw(GetBorrowerAttributes UpdateBorrowerAttribute DeleteBorrowerAttribute);
use C4::Output;
use List::MoreUtils qw /any/;

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

    my @patron_attributes_option;
    for my $borrower ( @borrowers ) {
        push @patron_attributes_option, { value => "$$_{code}", lib => $$_{code} } for @{ $$borrower{patron_attributes} };
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

    my $branches = GetBranchesLoop;
    my @branches_option;
    push @branches_option, { value => $$_{branchcode}, lib => $$_{branchname} } for @$branches;
    unshift @branches_option, { value => "", lib => "" };
    my $branchcategories = GetBranchCategories;
    my @branchcategories_option;
    push @branchcategories_option, { value => $$_{categorycode}, lib => $$_{categoryname} } for @$branchcategories;
    unshift @branchcategories_option, { value => "", lib => "" };
    my $bsort1 = GetAuthorisedValues("Bsort1");
    my @sort1_option;
    push @sort1_option, { value => $$_{authorised_value}, lib => $$_{lib} } for @$bsort1;
    unshift @sort1_option, { value => "", lib => "" };
    my $bsort2 = GetAuthorisedValues("Bsort2");
    my @sort2_option;
    push @sort2_option, { value => $$_{authorised_value}, lib => $$_{lib} } for @$bsort2;
    unshift @sort2_option, { value => "", lib => "" };

    my @fields = (
        {
            name => "surname",
            lib  => "Surname",
            type => "text",
        }
        ,
        {
            name => "firstname",
            lib  => "Firstname",
            type => "text",
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
            type => "date",
        }
        ,
        {
            name => "dateexpiry",
            lib  => "Date expiry",
            type => "date",
        }
        ,
        {
            name => "debarred",
            lib  => "Debarred",
            type => "date",
        }
        ,
        {
            name => "debarredcomment",
            lib  => "Debarred comment",
            type => "text",
        }
        ,
        {
            name => "notes",
            lib  => "Notes",
            type => "text",
        }
    );

    $template->param('patron_attributes', \@patron_attributes_option);

    $template->param( 'fields' => \@fields );
    $template->param( DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar() );
    my $op = "show";
}

if ( $op eq 'action' ) {

    my @disabled = $input->param('disable_input');
    warn Data::Dumper::Dumper \@disabled;
    my $infos;
    for my $field ( qw/surname firstname branchcode categorycode sort1 sort2 dateenrolled dateexpiry debarred debarredcomment notes/ ) {
        my $value = $input->param($field);
        $$infos{$field} = $value if $value;
        $$infos{$field} = "" if grep { /^$field$/ } @disabled;
    }

    my @attributes = $input->param('patron_attributes');
    my @attr_values = $input->param('patron_attributes_value');

    my @borrowernumbers = $input->param('borrowernumber');
    for my $borrowernumber ( @borrowernumbers ) {
        $$infos{borrowernumber} = $borrowernumber;
        warn "Update borrower $borrowernumber with";
        warn Data::Dumper::Dumper $infos;
        ModMember(%$infos);

        my $i=0;
        for ( @attributes ) {
            my $attribute;
            $$attribute{code} = $_;
            $$attribute{attribute} = $attr_values[$i];
            my $valuename = "attr" . $i . "_value";
            if ( grep { /^$valuename$/ } @disabled ) {
                warn "Delete attribute for $borrowernumber";
                warn Data::Dumper::Dumper $attribute;
                DeleteBorrowerAttribute $borrowernumber, $attribute;
            } else {
                warn "Update attribute for $borrowernumber";
                warn Data::Dumper::Dumper $attribute;
                UpdateBorrowerAttribute $borrowernumber, $attribute;
            }
            $i++;
        }


    }
}

$template->param(
    op => $op,
);
output_html_with_http_headers $input, $cookie, $template->output;
exit;
