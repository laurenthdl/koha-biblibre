#!/bin/bash

USER="test";
PWD="test";
DATABASE_SERVER="koha_devkss_server";
DATABASE_CLIENT="koha_devkss_client";
STRUCTURE_AND_DATA_FILE="data/structure_and_data_init.sql";
SPECIFICS_TABLES_DIR="data/tables";
DIFF_SERVER_DIR="data/server";
DIFF_CLIENT_DIR="data/client";
SCRIPT_CLIENT_DIR="scripts/client";
DATA_CLIENT_IDS="data/client/ids";

echo "Insert specifics tables...";
for file in $SPECIFICS_TABLES_DIR/*.sql; do
    echo " - $file";
    if [ -f $file ];then
        mysql -u $USER -p$PWD $DATABASE_SERVER < $file;
    fi
done

echo "Insert diff in server database...";
for file in $DIFF_SERVER_DIR/*.sql; do
    echo " - $file";
    if [ -f $file ];then
        mysql -u $USER -p$PWD $DATABASE_SERVER < $file;
    fi
done
