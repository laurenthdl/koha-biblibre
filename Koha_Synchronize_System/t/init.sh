#!/bin/bash

USER="root";
PWD="root";
DATABASE_SERVER="koha_devkss_server";
DATABASE_CLIENT="koha_devkss_client";
STRUCTURE_AND_DATA_FILE="data/structure_and_data_init.sql";
SPECIFICS_TABLES_DIR="data/tables";
DIFF_SERVER_DIR="diff/server";
DIFF_CLIENT_DIR="diff/client";
SCRIPT_CLIENT_DIR="scripts/client";
DATA_CLIENT_IDS="data/client/ids";

echo "DROP/CREATE databases in progress...";
mysql -u $USER -p$PWD < data/create_database.sql;

echo "creation server database in progress...";
mysql -u $USER -p$PWD $DATABASE_SERVER < $STRUCTURE_AND_DATA_FILE;

echo "creation client database in progress...";
mysql -u $USER -p$PWD $DATABASE_CLIENT < $STRUCTURE_AND_DATA_FILE;

echo "Insert specifics tables...";
for file in $SPECIFICS_TABLES_DIR/*.sql; do
    echo " - $file";
    if [ -f $file ];then
        mysql -u $USER -p$PWD $DATABASE_SERVER < $file;
        mysql -u $USER -p$PWD $DATABASE_CLIENT < $file;
    fi
done

mysql -u $USER -p$PWD $DATABASE_CLIENT -e "CREATE TABLE kss_infos (variable varchar(255), value varchar(255))";
mysql -u $USER -p$PWD $DATABASE_CLIENT -e "INSERT INTO kss_infos (variable, value) VALUES ('max_old_borrowernumber', (SELECT MAX(borrowernumber) FROM borrowers))";
mysql -u $USER -p$PWD $DATABASE_CLIENT -e "INSERT INTO kss_infos (variable, value) VALUES ('max_old_reservenumber', (SELECT MAX(reservenumber) FROM reserves))";

echo "Insert diff in server database...";
for file in $DIFF_SERVER_DIR/*.sql; do
    echo " - $file";
    if [ -f $file ];then
        mysql -u $USER -p$PWD $DATABASE_SERVER < $file;
    fi
done

echo "Insert diff in client database...";
for file in $DIFF_CLIENT_DIR/*.sql; do
    echo " - $file";
    if [ -f $file ];then
        mysql -u $USER -p$PWD $DATABASE_CLIENT < $file;
    fi
done

echo "Insert temp table in client database...";
for file in $SCRIPT_CLIENT_DIR/*.pl; do
    echo " - $file";
    if [ -f $file ];then
        name=`echo $file | sed "s/.*\/\([^/]*\).pl/\1/"`;
        perl $file > $DATA_CLIENT_IDS/$name;
    fi
done
