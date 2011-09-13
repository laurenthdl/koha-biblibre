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

use Modern::Perl;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Update::Database;

my $query = new CGI;
my $op = $query->param('op') || 'list';

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => "admin/updatedatabase.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 1 }, # FIXME Add a new flag
    }
);

if ( $op eq 'update' ) {
    my @versions = $query->param('version');
    @versions = sort {
        C4::Update::Database::TransformToNum( $a ) <=> C4::Update::Database::TransformToNum( $b )
    } @versions;

    my @reports;
    for my $version ( @versions ) {
        push @reports, C4::Update::Database::execute_version $version;
    }
    warn Data::Dumper::Dumper \@reports;
    my @report_loop = map {
        my ( $v, $r ) = each %$_;
        {
            version => $v,
            report  => $r,
        }
    } @reports;
    $template->param( report_loop => \@report_loop );

    $op = 'list';
}

if ( $op eq 'list' ) {
    my $versions_availables = C4::Update::Database::list_versions_availables;
    my $versions = C4::Update::Database::list_versions_already_knows;

    for my $v ( @$versions_availables ) {
        if ( not grep { $v eq $$_{version} } @$versions ) {
            push @$versions, {
                version => $v,
                available => 1
            };
        }
    }
    my @sorted = sort {
        C4::Update::Database::TransformToNum( $$a{version} ) <=> C4::Update::Database::TransformToNum( $$b{version} )
    } @$versions;

    my @availables = grep { defined $$_{available} and $$_{available} == 1 } @sorted;
    my @v_availables = map { {version => $$_{version}} } @availables;

    $template->param(
        versions => \@sorted,
        nb_availables => scalar @availables,
        availables => [ map { {version => $$_{version}} } @availables ],
    );
}

output_html_with_http_headers $query, $cookie, $template->output;
