#!/usr/bin/perl

use Modern::Perl;
use Data::SearchEngine::Query;
use Data::SearchEngine::Solr;
use Getopt::Long;
use C4::Context;

my $debug = $ENV{'DEBUG'};

my $delete = 0;
my $help = 0;
GetOptions(
    'help'   => \$help,
    'delete' => \$delete,
);

if($help) {
    usage();
    exit 0;
}

my $count = 100;

# Get Solr connection
my $solr = Data::SearchEngine::Solr->new(
    url => C4::Context->preference("SolrAPI"),
    options => {
        fl      => "id,recordid",
        sort    => "recordid asc",
    },
);

# Prepare the SQL query
my $dbh = C4::Context->dbh;
my $sql_query = qq{
    SELECT biblionumber
    FROM biblio
    WHERE biblionumber = ?
};
my $sth = $dbh->prepare($sql_query);

# Launch the first search
my $query = Data::SearchEngine::Query->new(
    query   => "recordtype:biblio",
    count   => $count,
    page    => 1,
);
my $results = $solr->search($query);

my $missing = 0;
while (0 < scalar @{$results->items}) {
    foreach(@{$results->items}) {
        # Check if this biblionumber exist in database
        my $recordid = $_->{'values'}->{'recordid'};
        $debug && say "Checking record $recordid";
        $sth->execute($recordid);
        my $res = $sth->fetchrow_arrayref;
        if(not defined $res) {
            $missing += 1;
            print "\nBiblio $recordid is not in database.";
            if($delete) {
                $solr->remove("id:biblio_$recordid", []);
                print " Deleted.";
            }
        }
    }
    $query->{'page'} += 1;
    $results = $solr->search($query);
}
print "\n";
if($missing) {
    if($delete) {
        print "$missing records were deleted from Solr";
    } else {
        print "$missing records refers to inexistant entry in database";
    }
} else {
    print "No inconsistencies found";
}
print "\n";

sub usage {
    print "\n";
    print "check_consistency.pl\n";
    print "This script check if Solr records have a matching entry in database.\n";
    print "It does only check for biblios at the moment.\n";
    print "Usage:\n";
    print "    -h|--help       Show this help message\n";
    print "    -d|--delete     Delete records in Solr that don't match in database\n";
    print "\n";
}
