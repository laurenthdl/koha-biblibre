#!/bin/sh

CURDATA=/data/wip/curdata_myisam/
NEWDATA=/data/wip/newdata_innodb/
CURDB=temp_curprod_mrl
NEWDB=temp_newprod_lim
USER=koha
PASS=test

# Dumps tables from koha_mrlimoges in curdata_myisam (manuel)
#./sauvegarde.sh

#echo "\n>>>Create work databases"
#perl dbdumputils.pl --create -u $USER -p $PASS -db $CURDB
#perl dbdumputils.pl --create -u $USER -p $PASS -db $NEWDB
# en remplacement, commandes manuelles (root)
#mysql> CREATE DATABASE temp_curprod_mrl CHARACTER SET utf8 COLLATE utf8_bin;
#mysql> CREATE DATABASE temp_newprod_mrl CHARACTER SET utf8 COLLATE utf8_bin;
#mysql> grant all privileges on temp_curprod_mrl.* to koha@'localhost' identified by 'test';
#mysql> grant all privileges on temp_newprod_mrl.* to koha@'localhost' identified by 'test';

echo "\n>>>Imports install data in a local database"
perl dbdumputils.pl --import -dd $CURDATA -u $USER -p $PASS -db $CURDB

echo "\n>>>Export data from this database"
perl dbdumputils.pl --export -sd $NEWDATA -u $USER -p $PASS -db $CURDB

echo "\n>>>Import a schema and data previously exported"
perl dbdumputils.pl --import -sd $NEWDATA -u $USER -p $PASS -db $NEWDB -s kohastructure.sql

echo "\n>>>Dump all the new database"
perl dbdumputils.pl --dump -u $USER -p $PASS -db $NEWDB -sd dumps
