#!/usr/bin/perl

use strict;

use Getopt::Long;
use YAML;
use C4::Context;
use C4::Items qw/ModItem/;
use C4::Biblio;

# Getting options
my $ccode;
my $specific;
my $result           = GetOptions(
    'ccode'        => \$ccode,
    'specific'     => \$specific,
);

if (not $ccode and not $specific) {
    print_usage();
    exit 0;
}

# Getting db connection
my $dbh = C4::Context->dbh;

# Load yaml file
my ($conf, $rules);
eval { ($conf,  $rules) = YAML::LoadFile('toggle_new_status.yaml') };
if ($@) {
    print "Unable to load yaml file : $@";
    exit -1;
}

# Getting new tag
my ($nfield, $nsubfield) = split(/\$/, $conf->{'new_status_tag'});

# Getting itype tag
my ($ifield, $isubfield)  = GetMarcFromKohaField('items.itype', '');


# Querying based on rules
foreach my $rule (@$rules) {
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
print "done\n";

sub print_usage {
    print <<_USAGE_;
$0: toggle recent acquisitions status

Use this script to delete "new" status for items.

Parameters (at least one):
    --ccode : replace the "new" itype to a ccode (specified in the config file)

    --specific : removes the subfield that contains the "new" status

_USAGE_
}
