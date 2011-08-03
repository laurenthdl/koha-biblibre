#!/usr/bin/perl

# Copyright 2009 BibLibre SARL
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

use C4::Auth qw(:DEFAULT get_session);
use CGI;
use C4::Context;
use C4::Output;
use C4::Log;
use C4::Debug;
use C4::Branch;
use C4::Members;
use C4::Discharges;
use Mail::Sendmail;

my $cgi = new CGI;

my $dischargePath    = C4::Context->preference('dischargePath');
my $dischargeWebPath = C4::Context->preference('dischargeWebPath');

# Getting the template and auth
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "opac-discharge.tmpl",
        query           => $cgi,
        type            => "opac",
        debug           => 1,
    }
);

# Getting already generated discharges
my @list = GetDischarges($loggedinuser);
my @loop = map {{ url => $dischargeWebPath . "/" . $loggedinuser . "/" . $_, filename => $_ }} @list;
$template->param("dischargeloop" => \@loop) if (@list);



my $generate = $cgi->param('generate');
# Sending an email to the librarian if user requested a discharge
if ($generate) {
    my $title = "Discharge request";
    my $member = GetMember('borrowernumber' => $loggedinuser);
    my $membername = $member->{'firstname'} . " " . $member->{'surname'} . " (" . $member->{'cardnumber'} . ")";
    my $content = "Discharge request from $membername";
    my $branch = GetBranchDetail($member->{'branchcode'});
    my $sender_email_address = GetFirstValidEmailAddress($loggedinuser);
    $sender_email_address = $branch->{'branchemail'} unless ($sender_email_address);

    # Note : perhaps we should use C4::Messages here?
    my %mail    = (
          To             => $branch->{'branchemail'},
          From           => $sender_email_address,
          Subject        => "Discharge request",
          Message        => $content,
          'Content-Type' => 'text/plain; charset="utf8"',
    );

    my $result = sendmail(%mail);
    $template->param("success" => $result);
    $template->param("generated" => 1);


}


$template->param( dischargeview => 1 );

output_html_with_http_headers $cgi, $cookie, $template->output;

