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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Output;

use C4::Branch;
use C4::Koha;

=head1

plugin_parameters : other parameters added when the plugin is called by the dopop function

=cut

sub plugin_parameters {
    my ($dbh, $record, $tagslib, $i, $tabloop) = @_;
    return "";
}

=head1

plugin_javascript : the javascript function called when the user enters the subfield.
contain 3 javascript functions :
* one called when the field is entered (OnFocus). Named FocusXXX
* one called when the field is leaved (onBlur). Named BlurXXX
* one called when the ... link is clicked (<a href="javascript:function">) named ClicXXX

returns :
* XXX
* a variable containing the 3 scripts.
the 3 scripts are inserted after the <input> in the html code

=cut

sub plugin_javascript {
    my ( $dbh, $record, $tagslib, $field_number, $tabloop ) = @_;

    my $js = <<END_OF_JS;
<script type="text/javascript">
//<![CDATA[

function Blur$field_number(index) {
    return 1;
}

function Focus$field_number(subfield_managed, id, force) {
    return 1;
}

function Clic$field_number(id) {
    window.open("../cataloguing/plugin_launcher.pl?plugin_name=stocknumberujm.pl&field_number=$field_number", 'StockNumberStE', 'menubar=false, toolbar=false, scrollbars=yes, width=600, height=500');
    return 1;
}
//]]>
</script>
END_OF_JS
    return ( $field_number, $js );
}

sub plugin {
    my ($input) = @_;

    my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user({
        template_name   => "cataloguing/value_builder/stocknumberujm.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => '*' },
        debug           => 1,
    });

    my $op = $input->param('op');
    if($op && $op eq 'search_and_retrieve') {
        my $prefix = $input->param('prefix');
        my $branch = $input->param('branch');

        my $dbh = C4::Context->dbh;
        my $query = qq{
            SELECT CAST(SUBSTRING(stocknumber, ?) AS UNSIGNED) AS number_part
            FROM items
            WHERE stocknumber LIKE ?
              AND homebranch = ?
            ORDER BY CAST(SUBSTRING(stocknumber, ?) AS UNSIGNED) DESC
            LIMIT 1
        };
        my $sth = $dbh->prepare($query);
        $sth->execute((length $prefix)+1, "$prefix %", $branch, (length $prefix)+1);
        my ($last_sn) = $sth->fetchrow_array;
        my $new_sn;
        if(defined $last_sn){
            $new_sn = $prefix . ' ' . ($last_sn+1);
        }else{
            $new_sn = $prefix . ' 1';
        }

        $template->param(
            $op     => 1,
            return  => $new_sn,
        );
    } else {
        my $prefixes = GetAuthorisedValues("SNPREFIX");
        my $branches_loop = GetBranchesLoop();

        $template->param(
            prefixes_loop   => $prefixes,
            branches_loop   => $branches_loop,
        );
    }
    my $field_number = $input->param('field_number');
    $template->param( field_number => $field_number );

    output_html_with_http_headers $input, $cookie, $template->output;
}

1;
