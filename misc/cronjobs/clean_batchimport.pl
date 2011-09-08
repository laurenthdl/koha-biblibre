#! /usr/bin/perl
use 5.10.0;
use utf8;
use strict;
use warnings;
use C4::Context;
use Getopt::Long;
use Data::Dumper;
use open qw/ :std :utf8 /;

#initialisation des variables
my %opt;
#GetOptions
GetOptions( \%opt, qw< status:s duration:s laps:s > );
my $status=$opt{"status"};
if ($status and (($status eq "cleaned") or ($status eq "imported"))){}
else
{
	die "status must be cleaned or imported, you must call this like this : ./clean_batchimport.pl -status cleaned -duration 1 -laps MONTH";
}
my $duration=$opt{"duration"};
if ($duration and $duration=~/^\d*$/){}
else
{
	die "duration must be an integer, you must call this like this : ./clean_batchimport.pl -status cleaned -duration 1 -laps MONTH";
}
my $laps=$opt{"laps"};
if ($laps and (($laps eq "MINUTE") or ($laps eq "HOUR") or ($laps eq "DAY") or ($laps eq "WEEK") or ($laps eq "MONTH") or ($laps eq "QUARTER") or ($laps eq "YEAR"))){}
else
{
	die "laps must be an MINUTE, HOUR, DAY, WEEK, MONTH, QUARTER, YEAR ... you must call this like this : ./clean_batchimport.pl -status cleaned -duration 1 -laps MONTH";
}

#dbh
my $dbh = C4::Context->dbh;
my $query = "DELETE import_batches,import_records,import_biblios,import_items,import_record_matches FROM import_batches LEFT JOIN import_records ON import_batches.import_batch_id = import_records.import_batch_id LEFT JOIN import_biblios ON import_biblios.import_record_id = import_records.import_record_id LEFT JOIN import_items ON import_items.import_record_id = import_records.import_record_id LEFT JOIN import_record_matches ON import_record_matches.import_record_id = import_records.import_record_id WHERE import_batches.import_status=? AND import_batches.upload_timestamp <= DATE_SUB(NOW(), INTERVAL ".$duration." ".$laps.")";
my $sth = $dbh->prepare($query);
my $res = $sth->execute($status);
