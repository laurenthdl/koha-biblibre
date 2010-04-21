#!/usr/bin/perl

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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA



=head1 batchupdateEANs.pl 

    This script batch updates EAN fields

=cut

use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}
use C4::Context;
use MARC::File::XML;
use MARC::Record;
use Getopt::Long;

# Configuration
my $eanfield    = '345';
my $eansubfield = 'b';

my ($verbose, $help) = (0,0);

GetOptions(
    'v'     => \$verbose,
    'h'         => \$help,
    'help'      => \$help,
);


$| = 1;
my $dbh   = C4::Context->dbh;

if($help){
    print qq(
        Option :
            \t-h        show this help
            \t-v        verbose
            \n\n 
    );
    exit;
}

    
my $query_marcxml = "
    SELECT biblioitemnumber,marcxml FROM biblioitems ORDER BY biblioitemnumber
";


my $update_marcxml = "
    UPDATE biblioitems SET marcxml=? WHERE biblioitemnumber = ? 
";
my $sth = $dbh->prepare($query_marcxml);
$sth->execute;

print "Looking for biblioitems with unnormalized EAN (might take a long time)\n";

while (my $data = $sth->fetchrow_arrayref){
    
   my $biblioitemnumber = $data->[0];
    
    # suppression des tirets de l'ean dans la notice
    my $marcxml = $data->[1];
    
    eval{
	my $record = MARC::Record->new_from_xml($marcxml,'UTF-8','UNIMARC');
	my @field = $record->field($eanfield);
	my $flag = 0;
	foreach my $field (@field){
	    my $subfield = $field->subfield($eansubfield);
	    if($subfield){
		my $ean = $subfield;
		if ($subfield =~ /-/) { 
		    print "\nremoving '-' on marcxml for biblioitemnumber $biblioitemnumber";
		    $ean =~ s/-//g;
		    print " ($subfield -> $ean)" if ($verbose);
		    $field->update($eansubfield => $ean);
		    $flag = 1;
		}
	    }
	}
	if($flag){
	    $marcxml = $record->as_xml_record('UNIMARC');
	    # Update
	    print "\nupdating record $biblioitemnumber" if ($verbose);
	    my $sth = $dbh->prepare($update_marcxml);
	    $sth->execute($marcxml,$biblioitemnumber);
	}
    };
    if($@){
	print "\n /!\\ pb getting $biblioitemnumber : $@";
    }
}
