#!/bin/bash

USER="test";
PWD="test";
DATABASE_INIT="koha_devkss";
DATABASE_SERVER="koha_devkss_server";
DATABASE_CLIENT="koha_devkss_client";
STRUCTURE_AND_DATA_FILE="data/structure_and_data_init.sql";
SPECIFICS_TABLES_DIR="data/tables";
DIFF_SERVER_DIR="data/server";
DIFF_CLIENT_DIR="data/client";

echo "DROP/CREATE databases in progress...";
mysql -u $USER -p$PWD < data/create_database.sql;

echo "creation init database in progress...";
mysql -u $USER -p$PWD $DATABASE_INIT < $STRUCTURE_AND_DATA_FILE;

echo "creation server database in progress...";
mysql -u $USER -p$PWD $DATABASE_SERVER < $STRUCTURE_AND_DATA_FILE;

echo "creation client database in progress...";
mysql -u $USER -p$PWD $DATABASE_CLIENT < $STRUCTURE_AND_DATA_FILE;

echo "Insert specifics tables...";
for file in $SPECIFICS_TABLES_DIR/*.sql; do
    echo " - $file";
    if [ -f $file ];then
        mysql -u $USER -p$PWD $DATABASE_INIT < $file;
        mysql -u $USER -p$PWD $DATABASE_SERVER < $file;
        mysql -u $USER -p$PWD $DATABASE_CLIENT < $file;
echo "l";
    fi
done

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

