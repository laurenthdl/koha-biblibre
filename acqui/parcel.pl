#!/usr/bin/perl

#script to recieve orders

# Copyright 2000-2002 Katipo Communications
# Copyright 2008-2009 BibLibre SARL
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

=head1 NAME

parcel.pl

=head1 DESCRIPTION
This script shows all orders receipt or pending for a given supplier.
It allows to write an order as 'received' when he arrives.

=head1 CGI PARAMETERS

=over 4

=item supplierid
To know the supplier this script has to show orders.

=item code
is the bookseller invoice number.

=item freight


=item gst


=item datereceived
To filter the results list on this given date.

=back

=cut

use strict;

#use warnings; FIXME - Bug 2505
use C4::Auth;
use C4::Acquisition;
use C4::Budgets;
use C4::Bookseller;
use C4::Biblio;
use C4::Items;
use C4::Members;
use CGI;
use C4::Output;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Suggestions;
use JSON;

my $input      = new CGI;
my $supplierid = $input->param('supplierid');
my $bookseller = GetBookSellerFromId($supplierid);

my $op = $input->param('op');
my $invoice = $input->param('invoice') || '';
my $freight = $input->param('freight');
my $datereceived =
  ( $op eq 'new' )
  ? C4::Dates->new( $input->param('datereceived') )
  : C4::Dates->new( $input->param('datereceived'), 'iso' );
$datereceived = C4::Dates->new() unless $datereceived;
my $invoiceinfos = GetInvoice($invoice);
my $invoiceclosedate = C4::Dates->new($invoiceinfos->{'invoiceclosedate'}, "iso")->output();
my $code            = $input->param('code');
my @rcv_err         = $input->param('error');
my @rcv_err_barcode = $input->param('error_bc');

my $startfrom      = $input->param('startfrom');
my $resultsperpage = $input->param('resultsperpage');
$resultsperpage = 20 unless ($resultsperpage);
$startfrom      = 0  unless ($startfrom);

sub get_value_with_gst_params {
    my $value = shift;
    my $gstrate = shift;
    my $bookseller = shift;
    if ( $bookseller->{listincgst} ) {
        if ( $bookseller->{invoiceincgst} ) {
            return $value;
        } else {
            return $value / ( 1 + $gstrate );
        }
    } else {
        if ( $bookseller->{invoiceincgst} ) {
            return $value * ( 1 + $gstrate );
        } else {
            return $value;
        }
    }
}

sub get_gste {
    my $value = shift;
    my $gstrate = shift;
    my $bookseller = shift;
    if ( $bookseller->{invoiceincgst} ) {
        return $value / ( 1 + $gstrate );
    } else {
        return $value;
    }
}

sub get_gst {
    my $value = shift;
    my $gstrate = shift;
    my $bookseller = shift;
    if ( $bookseller->{invoiceincgst} ) {
        return $value / ( 1 + $gstrate ) * $gstrate;
    } else {
        return $value * ( 1 + $gstrate ) - $value;
    }
}

if($op eq 'new'){
    my ($template, $loggedinuser, $cookie) = get_template_and_user(
        {   template_name   => "acqui/parcel.tmpl",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { acquisition => 'order_receive' },
            debug           => 1,
        }
    );

    my $invoiceinfos = GetInvoice($invoice);
    if($invoiceinfos) {
        $template->param(
            error_existing  => 1,
            invoice         => $invoice,
            supplierid      => $supplierid,
        );
        output_html_with_http_headers $input, $cookie, $template->output;
        exit;
    }
}

if ( $input->param('format') eq "json" ) {
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {   template_name   => "acqui/ajax.tmpl",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { acquisition => 'order_receive' },
            debug           => 1,
        }
    );

    my @datas;
    my $search   = $input->param('search')     || '';
    my $ean      = $input->param('ean')        || '';
    my $supplier = $input->param('supplierid') || '';
    my $basketno = $input->param('basketno')   || '';
    my $orderno  = $input->param('orderno')    || '';

    my $orders = SearchOrder( $orderno, $search, $ean, $supplier, $basketno );
    foreach my $order (@$orders) {
        if ( $order->{quantityreceived} < $order->{quantity} ) {
            my $data = {};
            my $ecost = get_value_with_gst_params( $order->{ecost}, $order->{gstrate}, $bookseller );

            $data->{basketno}     = $order->{basketno};
            $data->{ordernumber}  = $order->{ordernumber};
            $data->{title}        = $order->{title};
            $data->{author}       = $order->{author};
            $data->{isbn}         = $order->{isbn};
            $data->{booksellerid} = $order->{booksellerid};
            $data->{biblionumber} = $order->{biblionumber};
            $data->{freight}      = $order->{freight};
            $data->{quantity}     = $order->{quantity};
            $data->{ecost}        = sprintf( "%.2f", $ecost );
            $data->{ordertotal}   = sprintf( "%.2f", $ecost * $order->{quantity} );
            push @datas, $data;
        }
    }

    my $json_text = to_json( \@datas );
    $template->param( return => $json_text );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

my ( $template, $loggedinuser, $cookie, $staff_flags ) = get_template_and_user(
    {   template_name   => "acqui/parcel.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_receive' },
        debug           => 1,
    }
);

my $action       = $input->param('action');
my $ordernumber  = $input->param('ordernumber');
my $biblionumber = $input->param('biblionumber');

# If canceling an order
if ( $action eq "cancelorder" ) {
    my $confirm = $input->param('confirm');
    if ( $confirm ) {

        # We delete the order
        my $error = DelOrder( $biblionumber, $ordernumber, $input->param('del_biblio') ? 1 : 0 );

        if ( $error ) {
            if ($error->{'delitem'})   { $template->param( error_delitem   => 1 ); }
            if ($error->{'delbiblio'}) { $template->param( error_delbiblio => 1 ); }
        } else {
            $template->param( success_delorder => 1 );
        }

        print $input->redirect( '/cgi-bin/koha/acqui/parcel.pl?supplierid=' . $input->param('supplierid') . '&invoice=' . $input->param('invoice') . '&datereceived=' . $input->param('invoicedatereceived'));
        exit;
    } else {
        $template->param(
            confirm_cancel => "1",
            biblionumber   => $biblionumber,
            ordernumber    => $ordernumber,
            supplierid     => $input->param('supplierid'),
            invoice        => $input->param('invoice'),
            datereceived   => $input->param('invoicedatereceived'),
        );
    }
}

# If receiving error, report the error (coming from finishrecieve.pl(sic)).
if ( scalar(@rcv_err) ) {
    my $cnt = 0;
    my $error_loop;
    for my $err (@rcv_err) {
        push @$error_loop, { "error_$err" => 1, barcode => $rcv_err_barcode[$cnt] };
        $cnt++;
    }
    $template->param(
        receive_error => 1,
        error_loop    => $error_loop,
    );
}

my $cfstr         = "%.2f";                                                             # currency format string -- could get this from currency table.
my @parcelitems   = GetParcel( $supplierid, $invoice, $datereceived->output('iso') );
my $totalprice    = 0;
my $totalfreight  = 0;
my $totalquantity = 0;
my $total;
my $tototal;
my @loop_received = ();
my @book_foot_loop;
my %foot;
my $total_quantity = 0;
my $total_gste = 0;
my $total_gsti = 0;

# Received items
for my $item ( @parcelitems ) {
    $item->{unitprice} = get_value_with_gst_params( $item->{unitprice}, $item->{gstrate}, $bookseller );
    $total = ( $item->{'unitprice'} ) * $item->{'quantityreceived'};    #weird, are the freight fees counted by book? (pierre)
    $item->{'unitprice'} += 0;
    my %line;
    %line          = %{ $item };
    my $ecost = get_value_with_gst_params( $line{ecost}, $line{gstrate}, $bookseller );
    $line{ecost} = sprintf( "%.2f", $ecost );
    $line{invoice} = $invoice;
    $line{total} = sprintf( $cfstr, $total );
    $line{supplierid} = $supplierid;
    $totalprice += $item->{'unitprice'};
    $line{unitprice} = sprintf( $cfstr, $item->{'unitprice'} );
    my $gste = get_gste( $line{total}, $line{gstrate}, $bookseller );
    my $gst = get_gst( $line{total}, $line{gstrate}, $bookseller );
    $foot{$line{gstrate}}{gstrate} = $line{gstrate};
    $foot{$line{gstrate}}{value} += sprintf( "%.2f", $gst );
    $total_quantity += $line{quantity};
    $total_gste += $gste;
    $total_gsti += $gste + $gst;

    my $suggestion   = GetSuggestionInfoFromBiblionumber($line{biblionumber});
    $line{suggestionid}         = $$suggestion{suggestionid};
    $line{surnamesuggestedby}   = $$suggestion{surnamesuggestedby};
    $line{firstnamesuggestedby} = $$suggestion{firstnamesuggestedby};

    $totalfreight = $item->{'freight'};
    $totalquantity += $item->{'quantityreceived'};
    $tototal += $total;

    my $budget = GetBudget( $line{budget_id} );
    $line{budget_name} = $budget->{'budget_name'};

    push @loop_received, \%line;
}

push @book_foot_loop, map {
    $_
} values %foot;

my $pendingorders = GetPendingOrders($supplierid);
my $countpendings = scalar @$pendingorders;

# pending orders totals
my ( $totalPunitprice, $totalPquantity, $totalPecost, $totalPqtyrcvd );
my $ordergrandtotal;
my @loop_orders = ();

for ( my $i = 0 ; $i < $countpendings ; $i++ ) {
    my %line;
    %line = %{ $pendingorders->[$i] };

    my $ecost = get_value_with_gst_params( $line{ecost}, $line{gstrate}, $bookseller );
    $line{unitprice} = get_value_with_gst_params( $line{unitprice}, $line{gstrate}, $bookseller );
    $line{quantity}         += 0;
    $line{quantityreceived} += 0;
    $line{unitprice}        += 0;
    $totalPunitprice        += $line{unitprice};
    $totalPquantity         += $line{quantity};
    $totalPqtyrcvd          += $line{quantityreceived};
    $totalPecost            += $ecost;
    $line{ecost}      = sprintf( "%.2f", $ecost );
    $line{ordertotal} = sprintf( "%.2f", $ecost * $line{quantity} );
    $line{unitprice}  = sprintf( "%.2f", $line{unitprice} );
    $line{invoice}    = $invoice;
    #$line{total}      = $total;
    $line{supplierid} = $supplierid;
    $ordergrandtotal += $ecost * $line{quantity};

    my $suggestion   = GetSuggestionInfoFromBiblionumber($line{biblionumber});
    $line{suggestionid}         = $$suggestion{suggestionid};
    $line{surnamesuggestedby}   = $$suggestion{surnamesuggestedby};
    $line{firstnamesuggestedby} = $$suggestion{firstnamesuggestedby};

    my $budget = GetBudget( $line{budget_id} );
    $line{budget_name} = $budget->{'budget_name'};

    my $basket = GetBasket( $line{'basketno'} );
    my $branch = $line{'branchcode'} || $basket->{'branch'};
    # Check if user has permission to use basket
    unless( $staff_flags->{'superlibrarian'} % 2 == 1 || $template->{param_map}->{'CAN_user_acquisition_order_manage_all'} ) {
        my @basketusers = GetBasketUsers( $line{'basketno'} );
        my $isabasketuser = 0;
        foreach (@basketusers) {
            if($loggedinuser == $_ ){
                $isabasketuser = 1;
                last;
            }
        }
        if($basket->{'authorisedby'} != $loggedinuser
        && $isabasketuser == 0
        && $branch ne C4::Context->userenv->{'branch'}) {
            $line{'basket_lock'} = 1;
        }
    }
    unless( $staff_flags->{'superlibrarian'} % 2 == 1 || $template->{param_map}->{'CAN_user_acquisition_order_receive_all'} ) {
        if($branch ne C4::Context->userenv->{'branch'} ) {
            $line{receive_lock} = 1;
        }
    }
    unless( $staff_flags->{'superlibrarian'} % 2 == 1 || $template->{param_map}->{'CAN_user_acquisition_order_receive_all'} ) {
        if($line{branchcode} && $line{branchcode} ne C4::Context->userenv->{'branch'} ) {
            $line{receive_lock} = 1;
        }
    }
    $line{'receive_lock'} = 1 if($invoiceclosedate);

    push @loop_orders, \%line if ( $i >= $startfrom and $i < $startfrom + $resultsperpage );
}

$freight = $totalfreight unless $freight;

my $count = $countpendings;

if ( $count > $resultsperpage ) {
    my $displaynext = 0;
    my $displayprev = $startfrom;
    if ( ( $count - ( $startfrom + $resultsperpage ) ) > 0 ) {
        $displaynext = 1;
    }

    my @numbers = ();
    for ( my $i = 1 ; $i < $count / $resultsperpage + 1 ; $i++ ) {
        my $highlight = 0;
        ( $startfrom / $resultsperpage == ( $i - 1 ) ) && ( $highlight = 1 );
        push @numbers,
          { number    => $i,
            highlight => $highlight,
            startfrom => ( $i - 1 ) * $resultsperpage
          };
    }

    my $from = $startfrom * $resultsperpage + 1;
    my $to;
    if ( $count < ( ( $startfrom + 1 ) * $resultsperpage ) ) {
        $to = $count;
    } else {
        $to = ( ( $startfrom + 1 ) * $resultsperpage );
    }
    $template->param(
        numbers       => \@numbers,
        displaynext   => $displaynext,
        displayprev   => $displayprev,
        nextstartfrom => ( ( $startfrom + $resultsperpage < $count ) ? $startfrom + $resultsperpage : $count ),
        prevstartfrom => ( ( $startfrom - $resultsperpage > 0 ) ? $startfrom - $resultsperpage : 0 )
    );
}

$tototal = $tototal + $freight;


$template->param(
    invoice               => $invoice,
    datereceived          => $datereceived->output('iso'),
    invoicedatereceived   => $datereceived->output('iso'),
    formatteddatereceived => $datereceived->output(),
    invoiceclosedate      => $invoiceclosedate,
    name                  => $bookseller->{'name'},
    supplierid            => $supplierid,
    freight               => $freight,
    invoice               => $invoice,
    loop_received         => \@loop_received,
    loop_orders           => \@loop_orders,
    book_foot_loop        => \@book_foot_loop,
    totalprice            => sprintf( $cfstr, $totalprice ),
    totalfreight          => $totalfreight,
    totalquantity         => $totalquantity,
    tototal               => sprintf( $cfstr, $tototal ),
    ordergrandtotal       => sprintf( $cfstr, $ordergrandtotal ),
    grandtot              => sprintf( $cfstr, $tototal ), #+ $gstrate ),
    totalPunitprice       => sprintf( "%.2f", $totalPunitprice ),
    totalPquantity        => $totalPquantity,
    totalPqtyrcvd         => $totalPqtyrcvd,
    totalPecost           => sprintf( "%.2f", $totalPecost ),
    resultsperpage        => $resultsperpage,
    total_quantity       => $total_quantity,
    total_gste           => sprintf( "%.2f", $total_gste ),
    total_gsti           => sprintf( "%.2f", $total_gsti ),
);
output_html_with_http_headers $input, $cookie, $template->output;
 
