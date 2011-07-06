#!/usr/bin/perl
# Small script that checks that each biblio in the DB is properly indexed

use strict;

use warnings;

BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

# Koha modules used
use MARC::Record;
use C4::Context;
use C4::Search;
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ( $input_marc_file, $number ) = ( '', 0 );
my ( $version, $confirm, $zebraqueue, $silent );
GetOptions(
    'c' => \$confirm,
    'h' => \$version,
    'z' => \$zebraqueue,
    's' => \$silent
);

if ( $version || ( !$confirm ) ) {
    print <<EOF
This script takes all biblios and check they are indexed in zebra using biblionumber search.

parameters:
\th this help screen
\tc confirm (without this parameter, you get the help screen
\tz insert a signal in zebraqueue to force indexing of non indexed biblios
\ts silent throw no warnings except for non indexed records. Otherwise throw a warn every 1000 biblios to show progress

Syntax:
\t./batchCheckNonIndexedBiblios.pl -h (or without arguments => shows this screen)
\t./batchCheckNonIndexedBiblios.pl -c (c like confirm => check all records (may be long)
\t-t => test only, change nothing in DB
EOF
      ;
    exit;
}

my $dbh       = C4::Context->dbh;
my $i         = 0;
my $starttime = time();

$|         = 1;              # flushes output
$starttime = gettimeofday;

my $sth = $dbh->prepare("SELECT biblionumber FROM biblio");
my $sth_insert = $dbh->prepare("INSERT INTO zebraqueue (biblio_auth_number,operation,server,done) VALUES (?,'specialUpdate','biblioserver',0)");
$sth->execute;
my ($nbhits);
while ( my ($biblionumber) = $sth->fetchrow ) {
    (undef,undef,$nbhits) = SimpleSearch("Local-number=$biblionumber");
    print "biblionumber $biblionumber not indexed\n" unless $nbhits;
    $sth_insert->execute($biblionumber) if $zebraqueue and !$nbhits;
    $i++;
    print "$i done\n" unless $i % 1000;
}

