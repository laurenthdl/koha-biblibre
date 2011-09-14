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
use List::MoreUtils qw /any uniq/;

my $input = new CGI;
my $op = $input->param('op') || 'show_form';
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "tools/modborrowers.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => "edit_patrons" },
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
    for my $cardnumber ( @cardnumbers ) {
        my $borrower = GetBorrowerInfos( cardnumber => $cardnumber );
        if ( $borrower ) {
            $max_nb_attr = scalar( @{ $$borrower{patron_attributes} } )
                if scalar( @{ $$borrower{patron_attributes} } ) > $max_nb_attr;
            push @borrowers, $borrower;
        } else {
            push @notfoundcardnumbers, $cardnumber;
        }
    }

    my @patron_attributes;
    for my $borrower ( @borrowers ) {
        push @patron_attributes, $$_{code} for @{ $$borrower{patron_attributes} };
        my $length = scalar( @{ $$borrower{patron_attributes} } );
        push @{ $$borrower{patron_attributes} }, {} for ( $length .. $max_nb_attr - 1);
    }

    @patron_attributes = uniq @patron_attributes;

    my @patron_attributes_values;
    my @patron_attributes_codes;
    for ( @patron_attributes ) {
        my $attr_type = C4::Members::AttributeTypes->fetch( $_ );
        next if not $attr_type->authorised_value_category;
        my $options = GetAuthorisedValues( $attr_type->authorised_value_category );
        push @patron_attributes_values,
            {
                attribute_code => $_,
                options => $options
            };
        push @patron_attributes_codes,
            {
                attribute_code => $_
            };
    }

    my @attributes_header = ();
    for ( 1 .. scalar( $max_nb_attr ) ) {
        push @attributes_header, { attribute => "Attributes $_" };
    }
    $template->param( borrowers => \@borrowers );
    $template->param( attributes_header => \@attributes_header );
    @notfoundcardnumbers = map { { cardnumber => $_ } } @notfoundcardnumbers;
    $template->param( notfoundcardnumbers => \@notfoundcardnumbers )
        if @notfoundcardnumbers;

    my $branches = GetBranchesLoop;
    my @branches_option;
    push @branches_option, { value => $$_{branchcode}, lib => $$_{branchname} } for @$branches;
    unshift @branches_option, { value => "", lib => "" };
    my $categories = GetBorrowercategoryList;
    my @categories_option;
    push @categories_option, { value => $$_{categorycode}, lib => $$_{description} } for @$categories;
    unshift @categories_option, { value => "", lib => "" };
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
            option => \@categories_option,
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
            name => "borrowernotes",
            lib  => "Borrower Notes",
            type => "text",
        }
    );

    $template->param('patron_attributes_codes', \@patron_attributes_codes);
    $template->param('patron_attributes_values', \@patron_attributes_values);

    $template->param( 'fields' => \@fields );
    $template->param( DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar() );
}

if ( $op eq 'action' ) {

    my @disabled = $input->param('disable_input');
    my $infos;
    for my $field ( qw/surname firstname branchcode categorycode sort1 sort2 dateenrolled dateexpiry debarred debarredcomment borrowernotes/ ) {
        my $value = $input->param($field);
        $$infos{$field} = $value if $value;
        $$infos{$field} = "" if grep { /^$field$/ } @disabled;
    }

    my @attributes = $input->param('patron_attributes');
    my @attr_values = $input->param('patron_attributes_value');

    my @errors;
    my @borrowernumbers = $input->param('borrowernumber');
    for my $borrowernumber ( @borrowernumbers ) {
        if ( defined $infos ) {
            $$infos{borrowernumber} = $borrowernumber;
            my $success = ModMember(%$infos);
            push @errors, { error => "can_not_update", borrowernumber => $$infos{borrowernumber} } if not $success;
        }

        my $i=0;
        for ( @attributes ) {
            my $attribute;
            $$attribute{code} = $_;
            $$attribute{attribute} = $attr_values[$i];
            next if not $$attribute{attribute};
            my $valuename = "attr" . $i . "_value";
            if ( grep { /^$valuename$/ } @disabled ) {
                eval {
                    DeleteBorrowerAttribute $borrowernumber, $attribute;
                };
                push @errors, { error => $@ } if $@;
            } else {
                eval {
                    UpdateBorrowerAttribute $borrowernumber, $attribute;
                };
                push @errors, { error => $@ } if $@;
            }
            $i++;
        }

    }
    $op = "show_results";

    my @borrowers;
    my $max_nb_attr = 0;
    for my $borrowernumber ( @borrowernumbers ) {
        my $borrower = GetBorrowerInfos( borrowernumber => $borrowernumber );
        if ( $borrower ) {
            $max_nb_attr = scalar( @{ $$borrower{patron_attributes} } )
                if scalar( @{ $$borrower{patron_attributes} } ) > $max_nb_attr;
            push @borrowers, $borrower;
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

    $template->param( borrowers => \@borrowers );
    $template->param( errors => \@errors );
}

$template->param(
    op => $op,
);
output_html_with_http_headers $input, $cookie, $template->output;
exit;

sub GetBorrowerInfos {
    my ( %info ) = @_;
    my $borrower = GetMember( %info );
    if ( $borrower ) {
        $$borrower{branchname} = GetBranchName( $$borrower{branchcode} );
        for ( qw(dateenrolled dateexpiry debarred) ) {
            my $userdate = $$borrower{$_};
            unless ($userdate && $userdate ne "0000-00-00" and $userdate ne "9999-12-31") {
                $borrower->{$_} = '';
                next;
            }
            $userdate = C4::Dates->new( $userdate, 'iso' )->output('syspref');
            $borrower->{$_} = $userdate || '';
        }
        $$borrower{category_description} = GetBorrowercategory( $$borrower{categorycode} )->{description};
        my $attr_loop = C4::Members::Attributes::GetBorrowerAttributes( $$borrower{borrowernumber} );
        $$borrower{patron_attributes} = $attr_loop;
    }
    return $borrower;
}

