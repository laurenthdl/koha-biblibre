#!/usr/bin/perl

# Copyright 2011 BibLibre SARL
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

=head1 NAME

cancel.pl

=head1 DESCRIPTION

Ask confirmation for cancelling an order line
and add possibility to indicate a reason for cancellation
(saved in aqorders.internalnotes)

=cut

use Modern::Perl;

use CGI;
use C4::Auth;
use C4::Output;
use C4::Acquisition;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'acqui/cancelorder.tmpl',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'acquisition' => 'order_manage' },
    debug           => 1,
} );

my $action = $input->param('action');
my $referrer = $input->param('referrer');
my $ordernumber = $input->param('ordernumber');
my $biblionumber = $input->param('biblionumber');
my %vars = $input->Vars;

delete $vars{$_} foreach (qw/ action referrer ordernumber biblionumber del_biblio reason /);
my @vars_loop;
my $referrer_url = $referrer;
if($referrer_url) {
    $referrer_url .= "?" if (scalar(keys %vars) > 0);
    foreach (keys %vars) {
        push @vars_loop, {
            variable => $_,
            value => $vars{$_},
        };

        # Build referrer url
        $referrer_url .= "$_=$vars{$_}&";
    }
    $referrer_url =~ s/&$//;
} else {
    $referrer_url = $input->referer;
}

if($action and $action eq "confirmcancel") {
    my $del_biblio = $input->param('del_biblio') ? 1 : 0;
    my $reason = $input->param('reason');
    my $error = DelOrder($biblionumber, $ordernumber, $del_biblio, $reason);

    if($error) {
        $template->param(error_delitem => 1) if $error->{'delitem'};
        $template->param(error_delbiblio => 1) if $error->{'delbiblio'};
    } else {
        $template->param(success_cancelorder => 1);
    }
} else {
    # Asks for confirmation
    $template->param(
        vars_loop => \@vars_loop,
    );
}


$template->param(
    $action => 1,
    ordernumber => $ordernumber,
    biblionumber => $biblionumber,
    referrer => $referrer,
    referrer_url => $referrer_url,
);

output_html_with_http_headers $input, $cookie, $template->output;
