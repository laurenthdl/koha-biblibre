#!/usr/bin/perl
#
# Copyright 2006 Katipo Communications.
# Parts Copyright 2009 Foundations Bible College.
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

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::Creators 1.000000;
use C4::Labels 1.000000;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "labels/label-edit-template.tmpl",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $op = $cgi->param('op');
warn "operation = $op\n";
my $template_id    = $cgi->param('template_id') || $cgi->param('element_id');
my $label_template = undef;
my $profile_list   = undef;

my $units = get_unit_values();

if ( $op eq 'edit' ) {
    $label_template = C4::Labels::Template->retrieve( template_id => $template_id );
    $profile_list = get_all_profiles( field_list => 'profile_id,printer_name,paper_bin', filter => "template_id=$template_id OR template_id=''" );
} elsif ( $op eq 'save' ) {
    my @params = (
        profile_id => $cgi->param('profile_id') || '',
        template_code    => $cgi->param('template_code'),
        template_desc    => $cgi->param('template_desc'),
        page_width       => $cgi->param('page_width'),
        page_height      => $cgi->param('page_height'),
        label_width      => $cgi->param('label_width'),
        label_height     => $cgi->param('label_height'),
        top_text_margin  => $cgi->param('top_text_margin'),
        left_text_margin => $cgi->param('left_text_margin'),
        top_margin       => $cgi->param('top_margin'),
        left_margin      => $cgi->param('left_margin'),
        cols             => $cgi->param('cols'),
        rows             => $cgi->param('rows'),
        col_gap          => $cgi->param('col_gap'),
        row_gap          => $cgi->param('row_gap'),
        units            => $cgi->param('units'),
    );
    if ($template_id) {    # if a label_id was passed in, this is an update to an existing layout
        $label_template = C4::Labels::Template->retrieve( template_id => $template_id );
        if ( $cgi->param('profile_id') && ( $label_template->get_attr('template_id') != $cgi->param('profile_id') ) ) {
            if ( $label_template->get_attr('profile_id') > 0 ) {    # no need to get the old one if there was no profile associated
                my $old_profile = C4::Labels::Profile->retrieve( profile_id => $label_template->get_attr('profile_id') );
                $old_profile->set_attr( template_id => 0 );
                $old_profile->save();
            }
            my $new_profile = C4::Labels::Profile->retrieve( profile_id => $cgi->param('profile_id') );
            $new_profile->set_attr( template_id => $label_template->get_attr('template_id') );
            $new_profile->save();
        }

        #        if ($cgi->param('profile_id')) {
        #            my $old_profile = ($label_template->get_attr('profile_id') ? C4::Labels::Profile->retrieve(profile_id => $label_template->get_attr('profile_id')) : undef);
        #            my $new_profile = C4::Labels::Profile->retrieve(profile_id => $cgi->param('profile_id'));
        #            if ($label_template->get_attr('template_id') != $new_profile->get_attr('template_id')) {
        #                $new_profile->set_attr(template_id => $label_template->get_attr('template_id'));
        #                $new_profile->save();
        #                if ($old_profile) {
        #                    $old_profile->set_attr(template_id => 0);
        #                    $old_profile->save();
        #                }
        #            }
        #        }
        $label_template->set_attr(@params);
        $label_template->save();
    } else {    # if no label_id, this is a new layout so insert it
        $label_template = C4::Labels::Template->new(@params);
        my $template_id = $label_template->save();
        if ( $cgi->param('profile_id') ) {
            my $profile = C4::Labels::Profile->retrieve( profile_id => $cgi->param('profile_id') );
            $profile->set_attr( template_id => $template_id ) if $template_id != $profile->get_attr('template_id');
            $profile->save();
        }
    }
    print $cgi->redirect("label-manage.pl?label_element=template");
    exit;
} else {    # if we get here, this is a new layout
    $label_template = C4::Labels::Template->new();
}
if ($template_id) {
    foreach my $profile (@$profile_list) {
        if ( $profile->{'profile_id'} == $label_template->get_attr('profile_id') ) {
            $profile->{'selected'} = 1;
        } else {
            $profile->{'selected'} = 0;
        }
    }
}

foreach my $unit (@$units) {
    if ( $unit->{'type'} eq $label_template->get_attr('units') ) {
        $unit->{'selected'} = 1;
    }
}

$template->param(
    profile_list     => $profile_list,
    template_id      => ( $label_template->get_attr('template_id') > 0 ) ? $label_template->get_attr('template_id') : '',
    template_code    => $label_template->get_attr('template_code'),
    template_desc    => $label_template->get_attr('template_desc'),
    page_width       => $label_template->get_attr('page_width'),
    page_height      => $label_template->get_attr('page_height'),
    label_width      => $label_template->get_attr('label_width'),
    label_height     => $label_template->get_attr('label_height'),
    top_text_margin  => $label_template->get_attr('top_text_margin'),
    left_text_margin => $label_template->get_attr('left_text_margin'),
    top_margin       => $label_template->get_attr('top_margin'),
    left_margin      => $label_template->get_attr('left_margin'),
    cols             => $label_template->get_attr('cols'),
    rows             => $label_template->get_attr('rows'),
    col_gap          => $label_template->get_attr('col_gap'),
    row_gap          => $label_template->get_attr('row_gap'),
    units            => $units,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
