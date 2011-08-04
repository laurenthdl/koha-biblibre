#!/usr/bin/perl

# This script takes every biblio record in the database,
# looks for a value beginning with $find in $fieldtag$$subfieldtag
# and strips $find from this value.
# This was originally made for the file upload plugin, but might
# be used for other purposes.

use strict;

use Getopt::Long;
use C4::Context;
use C4::Biblio;

my $debug = 0;

# Which field are we processing?
my $fieldtag = "857";
my $subfieldtag = "u";

# Whichi beginning pattern are we looking to delete?
my $find = "http://myurl.tld/";
my $length = length($find);
my $pattern = qr|^$find|;

print "Field $fieldtag\$$subfieldtag\n";

# Getting db connection
my $dbh = C4::Context->dbh;

# Getting max bibnumber
my $query = "SELECT MAX(biblionumber) from biblio";
my $sth = $dbh->prepare($query);
$sth->execute();
my $bibliocount = $sth->fetchrow;

warn "unable to get biblio count" and exit -1 unless $bibliocount;

print "Biblio count : $bibliocount\n";

# Foreach each biblio
foreach (1..$bibliocount) {
    my $found = 0;
    my $record = GetMarcBiblio($_);
    $debug and warn "unable to get marc for record $_" unless $record;
    next unless $record;
    foreach my $field ($record->field($fieldtag)) {
	my $newfield = $field->clone();
	my $subfield = $newfield->subfield($subfieldtag);
	if ($subfield and $subfield =~ $pattern) {
	    my $newsubfield = substr $subfield, $length;
	    $newsubfield =~ s/\s+$//;
	    $newfield->update($subfieldtag, $newsubfield);
	    $field->replace_with($newfield);
	    $found = 1;
	}
    }
    print "processing $_\n" if ($found == 1);
    ModBiblioMarc($record, $_, GetFrameworkCode($_)) if ($found == 1);
}
