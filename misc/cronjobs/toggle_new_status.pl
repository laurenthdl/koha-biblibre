#!/usr/bin/perl

use strict;

use Getopt::Long;
use YAML;
use C4::Context;
use C4::Items qw/ModItem ModItemFromMarc/;
use C4::Biblio;

# Getting options
my $ccode;
my $specific;
my $mapping;
my $result           = GetOptions(
    'ccode'        => \$ccode,
    'specific'     => \$specific,
    'mapping'      => \$mapping,
);

if (not $ccode and not $specific and not $mapping) {
    print_usage();
    exit 0;
}

# Getting db connection
my $dbh = C4::Context->dbh;

# Load yaml file
my ($conf, $rules, $mappingrules);
eval { ($conf,  $rules, $mappingrules) = YAML::LoadFile('toggle_new_status.yaml') };
if ($@) {
    print "Unable to load yaml file : $@";
    exit -1;
}

# Getting specific new tag
my ($nfield, $nsubfield) = split(/\$/, $conf->{'new_status_tag'});
print "\nspecific new tag: $nfield\$$nsubfield";

# Getting items.itype tag
my ($ifield, $isubfield)  = GetMarcFromKohaField('items.itype', '');
print "\nitems.itype tag: $ifield\$$isubfield";

# Getting items.new tag
my ($newfield, $newsubfield)  = GetMarcFromKohaField('items.new', '');
print "\nitems.new tag: $newfield\$$newsubfield";


# Querying based on rules
if ($ccode or $specific) {
foreach my $rule (@$rules) {
    print "\nFirst set of rules: --ccode and/or --specific";
    print "\nrule: ccode " . $rule->{'ccode'} . " / duration : " . $rule->{'duration'} . "\n";

    my $query = "select biblionumber, itemnumber from items where ccode=? ";
    $query .= "and itype=? " if ($ccode);
    $query .= "and TO_DAYS(NOW()) - TO_DAYS(dateaccessioned) >= ?"; 
    my $sth = $dbh->prepare($query);
    ($ccode) ? $sth->execute($rule->{'ccode'},  $conf->{'itype_new_value'}, $rule->{'duration'}) : $sth->execute($rule->{'ccode'}, $rule->{'duration'});

    while (my $rs = $sth->fetchrow_hashref) {

	my $biblionumber = $rs->{biblionumber};
	my $itemnumber = $rs->{itemnumber};
	my $itemrec = C4::Items::GetMarcItem($biblionumber, $itemnumber);
	#FIXME : Too generic
	my $item = $itemrec->field(995);

	if ($item) {
	    # Removes new status 
	    if ($specific) {
		if ($item->subfield($nsubfield) eq $conf->{'new_status_value'}) {
		   print "Processing item $itemnumber: ";
		   print "removing $nfield\$$nsubfield from item\n";
		   $item->delete_subfield($nsubfield);
		   ModItem({}, $biblionumber, $itemnumber, C4::Context->dbh, GetFrameworkCode($biblionumber), $item);
		}
	    }

	    # Changing itype to ccode
	    if ($ccode) {
	        print "Processing item $itemnumber: ";
		print "updating itype to value " . $rule->{'dest_ccode'} . "\n";
		ModItem({ itype => $rule->{'dest_ccode'} }, $biblionumber, $itemnumber);
	    }
	} else {
	    print "Error: can't get item $itemnumber";
	}
    }
}
}

if ($mapping) {

    foreach my $rule (@$mappingrules) {
	print "\nSecond set of rules: --mapping";
	print "\nrule: " . $conf->{'mapping_rules_index'} . " " . $rule->{'index'} . " / duration : " . $rule->{'duration'} . "\n";

     my $query = "select biblionumber, itemnumber from items where " .  $conf->{'mapping_rules_index'} . "=? ";
	$query .= "and TO_DAYS(NOW()) - TO_DAYS(dateaccessioned) >= ? "; 
	$query .= "and items.new=1";
	my $sth = $dbh->prepare($query);
	$sth->execute($rule->{'index'},  $rule->{'duration'});

	while (my $rs = $sth->fetchrow_hashref) {
	    my $biblionumber = $rs->{biblionumber};
	    my $itemnumber = $rs->{itemnumber};
	    my $itemrec = C4::Items::GetMarcItem($biblionumber, $itemnumber);
	    my $item = $itemrec->field($newfield);

	    if ($item) {
		# Removes new status 
		if ($item->subfield($newsubfield)) {
		   print "Processing item $itemnumber: ";
		   print "removing $newfield\$$newsubfield from item\n";
		   $item->delete_subfield($newsubfield);
		   ModItem({new => undef}, $biblionumber, $itemnumber, C4::Context->dbh, GetFrameworkCode($biblionumber), $item);
		}
	    } else {
		print "Error: can't get item $itemnumber";
	    }
	}
    }
}

print "done\n";

sub print_usage {
    print <<_USAGE_;
$0: toggle recent acquisitions status

Use this script to delete "new" status for items.

Parameters (at least one):
    --ccode : replace the "new" itype to a ccode (specified in the config file)

    --specific : removes the subfield that contains the "new" status

    --mapping : use the "items.new" mapping 

_USAGE_
}
