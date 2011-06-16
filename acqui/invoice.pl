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

invoice.pl

=head1 DESCRIPTION

Invoice details

=cut

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Output;
use C4::Acquisition;
use C4::Bookseller;
use C4::Budgets;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'acqui/invoice.tmpl',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'acquisition' => '*' },
    debug           => 1,
} );

my $invoicenumber = $input->param('invoicenumber');
my $op = $input->param('op');

if($op && $op eq 'close') {
    CloseInvoice($invoicenumber);
    my $referer = $input->referer;
    if($referer) {
        print $input->redirect($referer);
    }
}elsif($op && $op eq 'reopen') {
    ReopenInvoice($invoicenumber);
    my $referer = $input->referer;
    if($referer) {
        print $input->redirect($referer);
    }
}elsif($op && $op eq 'modbillingdate') {
    my $billingdate = $input->param('billingdate');
    ModInvoice(invoicenumber => $invoicenumber,
               billingdate   => C4::Dates->new($billingdate)->output("iso"));
    $template->param(billingdate_saved => 1);
}



my $details = GetInvoiceDetails($invoicenumber);
my ($bookseller) = GetBookSellerFromId($details->{supplierid});
my $basketno = $details->{basketno};
my @orders_loop = ();
my $orders = $details->{'orders'};
my $qty_total;
my @books_loop;
my @book_foot_loop;
my %foot;
my $total_quantity = 0;
my $total_gste = 0;
my $total_gsti = 0;
my $total_gstvalue = 0;
foreach my $order (@$orders) {
    my $line = get_infos( $order, $bookseller);

    $foot{$$line{gstgsti}}{gstgsti} = $$line{gstgsti};
    $foot{$$line{gstgsti}}{gstvalue} += $$line{gstvalue};
    $total_gstvalue += $$line{gstvalue};
    $foot{$$line{gstgsti}}{quantity}  += $$line{quantity};
    $total_quantity += $$line{quantity};
    $foot{$$line{gstgsti}}{totalgste} += $$line{totalgste};
    $total_gste += $$line{totalgste};
    $foot{$$line{gstgsti}}{totalgsti} += $$line{totalgsti};
    $total_gsti += $$line{totalgsti};

    my %row = %{ $order, $line };
    $row{'orderline'} = $row{'parent_ordernumber'};
    push @orders_loop, \%row;
}

push @book_foot_loop, map {
    $_
} values %foot;

$template->param(
    invoicenumber    => $details->{'invoicenumber'},
    suppliername     => $details->{'suppliername'},
    supplierid       => $details->{'supplierid'},
    datereceived     => $details->{'datereceived'},
    billingdate      => C4::Dates->new($details->{'billingdate'}, "iso")->output(),
    invoiceclosedate => $details->{'invoiceclosedate'},
    orders_loop      => \@orders_loop,
    book_foot_loop   => \@book_foot_loop,
    total_quantity   => $total_quantity,
    total_gste       => sprintf( "%.2f", $total_gste ),
    total_gsti       => sprintf( "%.2f", $total_gsti ),
    total_gstvalue   => sprintf( "%.2f", $total_gstvalue ),
    invoiceincgst    => $bookseller->{invoiceincgst},
    currency         => $bookseller->{listprice},
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
);

# FIXME
# Fonction dupplicated from basket.pl
# Code must to be exported. Where ??
sub get_infos {
    my $order = shift;
    my $bookseller = shift;
    my $qty = $order->{'quantity'} || 0;
    if ( !defined $order->{quantityreceived} ) {
        $order->{quantityreceived} = 0;
    }
    my $budget = GetBudget( $order->{'budget_id'} );

    my %line = %{ $order };
    $line{order_received} = ( $qty == $order->{'quantityreceived'} );
    $line{basketno}       = $basketno;
    $line{budget_name}    = $budget->{budget_name};
    if ( $bookseller->{'listincgst'} ) {
        $line{gstgsti} = sprintf( "%.2f", $line{gstrate} * 100 );
        $line{gstgste} = sprintf( "%.2f", $line{gstgsti} / ( 1 + ( $line{gstgsti} / 100 ) ) );
        $line{actualcostgsti} = sprintf( "%.2f", $line{unitprice} );
        $line{actualcostgste} = sprintf( "%.2f", $line{unitprice} / ( 1 + ( $line{gstgsti} / 100 ) ) );
        $line{gstvalue} = sprintf( "%.2f", ( $line{rrpgsti} - $line{rrpgste} ) * $line{quantity});
        $line{totalgste} = sprintf( "%.2f", $order->{quantity} * $line{actualcostgste} );
        $line{totalgsti} = sprintf( "%.2f", $order->{quantity} * $line{actualcostgsti} );
    } else {
        $line{gstgsti} = sprintf( "%.2f", $line{gstrate} * 100 );
        $line{gstgste} = sprintf( "%.2f", $line{gstrate} * 100 );
        $line{actualcostgsti} = sprintf( "%.2f", $line{unitprice} * ( 1 + ( $line{gstrate} ) ) );
        $line{actualcostgste} = sprintf( "%.2f", $line{unitprice} );
        $line{gstvalue} = sprintf( "%.2f", ( $line{rrpgsti} - $line{rrpgste} ) * $line{quantity});
        $line{totalgste} = sprintf( "%.2f", $order->{quantity} * $line{actualcostgste} );
        $line{totalgsti} = sprintf( "%.2f", $order->{quantity} * $line{actualcostgsti} );
    }

    if ( $line{uncertainprice} ) {
        $template->param( uncertainprices => 1 );
        $line{rrp} .= ' (Uncertain)';
    }
    if ( $line{'title'} ) {
        my $volume      = $order->{'volume'};
        my $seriestitle = $order->{'seriestitle'};
        $line{'title'} .= " / $seriestitle" if $seriestitle;
        $line{'title'} .= " / $volume"      if $volume;
    } else {
        $line{'title'} = "Deleted bibliographic notice, can't find title.";
    }

    return \%line;
}


output_html_with_http_headers $input, $cookie, $template->output;
