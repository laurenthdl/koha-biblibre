#! /usr/bin/perl
use strict;
use warnings;
use C4::Context;
my $dbh=C4::Context->dbh;
$dbh->do("ALTER TABLE issuingrules ADD COLUMN `allowonshelfholds` TINYINT(1) NOT NULL DEFAULT '0';");

my $sth = $dbh->prepare( "SELECT value from systempreferences where variable = 'AllowOnShelfHolds';" ); 
$sth->execute();
my $data = $sth->fetchrow_hashref();

my $updsth = $dbh->prepare("UPDATE issuingrules SET allowonshelfholds = ?");
$updsth->execute($data->{value});

$dbh->do("DELETE FROM systempreferences where variable = 'AllowOnShelfHolds';");
print "Upgrade done (Migrating AllowOnShelfHold to smart-rules)\n";
