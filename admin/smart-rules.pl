#!/usr/bin/perl
# vim: et ts=4 sw=4
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

use strict;
use CGI;
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Koha;
use C4::Debug;
use C4::Branch;
use C4::IssuingRules;

my $input = new CGI;
my $dbh = C4::Context->dbh;

my ($template, $loggedinuser, $cookie) = get_template_and_user({
    template_name   => "admin/smart-rules.tmpl",
    query           => $input,
    type            => "intranet",
    authnotrequired => 0,
    flagsrequired   => {parameters => 1},
    debug           => 1,
});

my $type   = $input->param('type');
my $branch = $input->param('branch') || ( C4::Branch::onlymine() ? ( C4::Branch::mybranch() || '*' ) : '*' );
my $op     = $input->param('op');

if ( $op eq 'delete' ) {
    DelIssuingRule({
        branchcode   => $branch,
        categorycode => $input->param('categorycode'),
        itemtype     => $input->param('itemtype'),
    });
}
# save the values entered
elsif ( $op eq 'add' ) {

    my $maxissueqty      = $input->param('maxissueqty');
    $maxissueqty         =~ s/\s//g;
    $maxissueqty         = undef if $maxissueqty !~ /^\d+/;

    my $issuingrule = {
        branchcode      => $branch,
        categorycode    => $input->param('categorycode'),
        itemtype        => $input->param('itemtype'),
        maxissueqty     => $maxissueqty,
        renewalsallowed => $input->param('renewalsallowed'),
        reservesallowed => $input->param('reservesallowed'),
        issuelength     => $input->param('issuelength'),
        fine            => $input->param('fine'),
        finedays        => $input->param('finedays'),
        firstremind     => $input->param('firstremind'),
        chargeperiod    => $input->param('chargeperiod'),
        holdspickupdelay => $input->param('holdspickupdelay'),
        allowonshelfholds=> ($input->param('allowonshelfholds') eq "on") ? 1 : 0 
    };

    # If the (branchcode,categorycode,itemtype) combination already exists...
    my @issuingrules = GetIssuingRules({
        branchcode      => $issuingrule->{'branchcode'},
        categorycode    => $issuingrule->{'categorycode'},
        itemtype        => $issuingrule->{'itemtype'},
    });

    # ...we modify the existing rule...
    if ( @issuingrules ) {
        ModIssuingRule( $issuingrule );
    # ...else we add a new rule.
    } else {
        AddIssuingRule( $issuingrule );
    }
}

# This block builds the branch list
my $branches = GetBranches();
my @branchloop;
for my $thisbranch (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %$branches) {
    my $selected = 1 if $thisbranch eq $branch;
    my %row =(value => $thisbranch,
                selected => $selected,
                branchname => $branches->{$thisbranch}->{'branchname'},
            );
    push @branchloop, \%row;
}

# Get the patron category list
my @category_loop = C4::Category->all;

# Get the item types list
my @itemtypes = C4::ItemType->all;

# Get the issuing rules list...
my @issuingrules = GetIssuingRulesByBranchCode($branch);

# ...and refine its data, row by row.
for ( @issuingrules ) {
    $_->{'humanitemtype'}             ||= $_->{'itemtype'};
    $_->{'default_humanitemtype'}       = $_->{'humanitemtype'} eq '*';
    $_->{'humancategorycode'}         ||= $_->{'categorycode'};
    $_->{'default_humancategorycode'}   = $_->{'humancategorycode'} eq '*';
    $_->{'fine'}                        = sprintf('%.2f', $_->{'fine'});
}

$template->param(
    categoryloop  => \@category_loop,
    itemtypeloop  => \@itemtypes,
    rules         => \@issuingrules,
    branchloop    => \@branchloop,
    humanbranch   => ($branch ne '*' ? $branches->{$branch}->{branchname} : ''),
    branch        => $branch,
    definedbranch => scalar(@issuingrules) > 0,
);
output_html_with_http_headers $input, $cookie, $template->output;

exit 0;

