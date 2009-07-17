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

=head1 branches.pl

 FIXME: individual fields in branch address need to be exported to templates,
        in order to fix bug 180; need to notify translators
FIXME: looped html (e.g., list of checkboxes) need to be properly
        TMPL_LOOP'ized; doing this properly will fix bug 130; need to
        notify translators
 FIXME: need to implement the branch categories stuff
 FIXME: there are too many TMPL_IF's; the proper way to do it is to have
        separate templates for each individual action; need to notify
        translators
 FIXME: there are lots of error messages exported to the template; a lot
        of these should be converted into exported booleans / counters etc
        so that the error messages can be localized; need to notify translators

 NOTE:  heading() should now be called like this:
        1. Use heading() as before
        2. $template->param('heading-LISPISHIZED-HEADING-p' => 1);
        3. $template->param('use-heading-flags-p' => 1);
        This ensures that both converted and unconverted templates work

 Finlay working on this file from 26-03-2002
 Reorganising this branches admin page.....
 
=cut

use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Koha;
use C4::Branch;

# Fixed variables
my $script_name = "/cgi-bin/koha/admin/branches.pl";
my $pagesize    = 20;

################################################################################
# Main loop....
my $input        = new CGI;
my $branchcode   = $input->param('branchcode');
my $branchname   = $input->param('branchname');
my $categorycode = $input->param('categorycode');
my $op           = $input->param('op') || '';

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/branches.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 1},
        debug           => 1,
    }
);
$template->param(
     script_name => $script_name,
     action      => $script_name,
);
$template->param( ($op || 'else') => 1 );

if ( $op eq 'add' ) {

    # If the user has pressed the "add new branch" button.
    $template->param( 'heading-branches-add-branch-p' => 1 );
    editbranchform($branchcode,$template);

}
elsif ( $op eq 'edit' ) {

    # if the user has pressed the "edit branch settings" button.
    $template->param( 'heading-branches-add-branch-p' => 0,
                        'add' => 1, );
    editbranchform($branchcode,$template);
}
elsif ( $op eq 'add_validate' ) {

    # confirm settings change...
    my $params = $input->Vars;
    unless ( $params->{'branchcode'} && $params->{'branchname'} ) {
        $template->param( else => 1 );
        default("MESSAGE1",$template);
    }
    else {
        my $error = ModBranch($params); # FIXME: causes warnings to log on duplicate branchcode
        # if error saving, stay on edit and rise error
        if ($error) {
            # copy input parameters back to form
            # FIXME - doing this doesn't preserve any branch group selections, but good enough for now
            editbranchform($branchcode,$template);
            $template->param( 'heading-branches-add-branch-p' => 1, 'add' => 1, "ERROR$error" => 1 );
        } else {
            $template->param( else => 1);
            default("MESSAGE2",$template);
        }
    }
}
elsif ( $op eq 'delete' ) {
    # if the user has pressed the "delete branch" button.
    
    # check to see if the branchcode is being used in the database somewhere....
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("select count(*) from items where holdingbranch=? or homebranch=?");
    $sth->execute( $branchcode, $branchcode );
    my ($total) = $sth->fetchrow_array;
    if ($total) {
        $template->param( else => 1 );
        default("MESSAGE7", $template);
    }
    else {
        $template->param( delete_confirm => 1 );
        $template->param( branchname     => $branchname );
        $template->param( branchcode     => $branchcode );
    }
}
elsif ( $op eq 'delete_confirmed' ) {

    # actually delete branch and return to the main screen....
    DelBranch($branchcode);
    $template->param( else => 1 );
    default("MESSAGE3",$template);
}
elsif ( $op eq 'editcategory' ) {

    # If the user has pressed the "add new category" or "modify" buttons.
    $template->param( 'heading-branches-edit-category-p' => 1 );
    editcatform($categorycode,$template);
}
elsif ( $op eq 'addcategory_validate' ) {

    $template->param( else => 1 );
    # confirm settings change...
    my $params = $input->Vars;
    unless ( $params->{'categorycode'} && $params->{'categoryname'} ) {
        default("MESSAGE4",$template);
    }
    else {
        ModBranchCategoryInfo($params);
        default("MESSAGE5",$template);
    }
}
elsif ( $op eq 'delete_category' ) {

    # if the user has pressed the "delete branch" button.
    my $message = "MESSAGE8" if CheckBranchCategorycode($categorycode);
    if ($message) {
        $template->param( else => 1 );
        default($message,$template);
    }
    else {
        $template->param( delete_category => 1 );
        $template->param( categorycode    => $categorycode );
    }
}
elsif ( $op eq 'categorydelete_confirmed' ) {

    # actually delete branch and return to the main screen....
    DelBranchCategory($categorycode);
    $template->param( else => 1 );
    default("MESSAGE6",$template);

}
else {
    # if no operation has been set...
    default("",$template);
}

################################################################################
#
# html output functions....

sub default {
    my $message       = shift || '';
    my $innertemplate = shift or return;
    $innertemplate->param($message => 1) if $message;
    $innertemplate->param(
        'heading-branches-p' => 1,
    );
    branchinfotable("",$innertemplate);
}

sub editbranchform {
    my ($branchcode,$innertemplate) = @_;
    # initiate the scrolling-list to select the printers
    my $printers = GetPrinters();
    my @printerloop;
    my $data;
    my $oldprinter = "";

    if ($branchcode) {
        $data = GetBranchInfo($branchcode);
        $data = $data->[0];

        # get the old printer of the branch
        $oldprinter = $data->{'branchprinter'} || '';
        $innertemplate->param( 
             %$data 
        );
    }

    foreach my $thisprinter ( keys %$printers ) {
        push @printerloop, {
            value         => $thisprinter,
            selected      => ( $oldprinter eq $printers->{$thisprinter} ),
            branchprinter => $printers->{$thisprinter}->{'printqueue'},
        };
    }

    $innertemplate->param( printerloop => \@printerloop );
    # make the checkboxes.....
    #
    # We export a "categoryloop" array to the template, each element of which
    # contains separate 'categoryname', 'categorycode', 'codedescription', and
    # 'checked' fields. The $checked field is either '' or 'checked'
    # (see bug 130)
    #
    my $catinfo = GetBranchCategory();
    my @categoryloop = ();
    foreach my $cat (@$catinfo) {
        my $checked = "";
        my $tmp     = quotemeta( $cat->{'categorycode'} );
        if ( grep { /^$tmp$/ } @{ $data->{'categories'} } ) {
            $checked = "checked=\"checked\"";
        }
        push @categoryloop, {
            %$cat,
	        checked         => $checked,
        };
    }
    $innertemplate->param( categoryloop => \@categoryloop );

    for my $obsolete ( 'categoryname', 'categorycode', 'codedescription' ) {
        $innertemplate->param(
            $obsolete => 'Your template is out of date (bug 130)' );
    }
}

sub editcatform {

    # prepares the edit form...
    my ($categorycode,$innertemplate) = @_;
    # warn "cat : $categorycode";
	my @cats;
    my $data;
	if ($categorycode) {
        $data = GetBranchCategory($categorycode);
        $data = $data->[0];
        $innertemplate->param(%$data);
    }
	for my $ctype (GetCategoryTypes()) {
		push @cats , { type => $ctype , selected => ($data->{'categorytype'} and $data->{'categorytype'} eq $ctype) };
	}
    $innertemplate->param(categorytype => \@cats);
}

sub branchinfotable {

# makes the html for a table of branch info from reference to an array of hashs.

    my ($branchcode,$innertemplate) = @_;
    my $branchinfo = $branchcode ? GetBranchInfo($branchcode) : GetBranchInfo();
    my @loop_data = ();
    foreach my $branch (@$branchinfo) {
        #
        # We export the following fields to the template. These are not
        # pre-composed as a single "address" field because the template
        # might (and should) escape what is exported here. (See bug 180)
        #
        # - branch_name     (Note: not "branchname")
        # - branch_code     (Note: not "branchcode")
        # - address         (containing a static error message)
        # - branchaddress1 \
        # - branchaddress2  |
        # - branchaddress3  | comprising the old "address" field
        # - branchphone     |
        # - branchfax       |
        # - branchemail    /
        # - address-empty-p (1 if no address information, 0 otherwise)
        # - categories      (containing a static error message)
        # - category_list   (loop containing "categoryname")
        # - no-categories-p (1 if no categories set, 0 otherwise)
        # - value
        #
        my %row = ();

        # Handle address fields separately
        my $address_empty_p = 1;
        for my $field (
            'branchaddress1', 'branchaddress2',
            'branchaddress3', 'branchphone',
            'branchfax',      'branchemail',
            'branchip',       'branchprinter'
          )
        {
            $row{$field} = $branch->{$field};
            $address_empty_p = 0 if ( $branch->{$field} );
        }
        $row{'address-empty-p'} = $address_empty_p;

        # Handle categories
        my $no_categories_p = 1;
        my @categories;
        foreach my $cat ( @{ $branch->{'categories'} } ) {
            my ($catinfo) = @{ GetBranchCategory($cat) };
            push @categories, { 'categoryname' => $catinfo->{'categoryname'} };
            $no_categories_p = 0;
        }

        %row = %$branch;
        $row{'category_list'}   = \@categories;
        $row{'no-categories-p'} = $no_categories_p;
        $row{'value'}       = $branch->{'branchcode'};
        push @loop_data, \%row;
    }
    my @branchcategories = ();
	for my $ctype ( GetCategoryTypes() ) {
    	my $catinfo = GetBranchCategories(undef,$ctype);
    	my @categories;
		foreach my $cat (@$catinfo) {
            push @categories, $cat;
    	}
        push @branchcategories, { categorytype => $ctype , $ctype => 1 , catloop => \@categories};
	}
    $innertemplate->param(
        branches         => \@loop_data,
        branchcategories => \@branchcategories
    );

}

output_html_with_http_headers $input, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End:
