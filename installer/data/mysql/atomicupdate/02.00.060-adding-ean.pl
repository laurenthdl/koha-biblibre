#!/usr/bin/perl
use C4::Context;
my $dbh= C4::Context->dbh;
$dbh->do("ALTER TABLE `biblioitems` ADD `ean` VARCHAR( 13 ) NULL AFTER issn");
$dbh->do("CREATE INDEX `ean` ON biblioitems (`ean`) ");
$dbh->do("ALTER TABLE `deletedbiblioitems` ADD `ean` VARCHAR( 13 ) NULL AFTER issn");
$dbh->do("CREATE INDEX `ean` ON deletedbiblioitems (`ean`) ");
