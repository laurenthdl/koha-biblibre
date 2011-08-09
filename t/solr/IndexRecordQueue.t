#!/usr/bin/perl

use utf8;
use Modern::Perl;
use Test::More;

my $tests;
plan tests => $tests;

my $expected;
my $got;
my $data_filepath = '/tmp/records.txt';
my $scriptpath = "/home/jonathan/workspace/versions/koha_master/services/IndexRecordQueue.pl";
my $content;

sub get_data_content {
    open my $fh, "<", $data_filepath;
    my $content;
    while (<$fh>){ chomp $_; $content .= $_; }
    close $fh;
    return $content // "";
}

BEGIN { $tests += 1 }
use_ok('C4::Search');

BEGIN { $tests += 2 }
my $status = qx#$scriptpath status#;
$got = $status =~ /No pidfile found/ or $status =~ /Running: *no/ == 1 ? 1 : 0;
is ( $got, 0, "Check if service is running" );
is ( length(get_data_content), 0, "Check if data_file is empty" );

BEGIN { $tests += 1 }
my @biblionumbers = qw/1 2 3/;
C4::Search::IndexRecord( "biblio", \@biblionumbers );
$content = get_data_content;
is ( $content, "biblio 1 2 3" );

