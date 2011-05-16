#!/bin/zsh

STRUCTURE_AND_DATA_FILE="data/structure_and_data_init.sql";
SPECIFICS_TABLES_DIR="data/tables";

echo "u devkss_client"
u devkss_client
echo "structure"
m < $STRUCTURE_AND_DATA_FILE
echo "table 1"
m < $SPECIFICS_TABLES_DIR/01-biblio.sql
echo "table 2"
m < $SPECIFICS_TABLES_DIR/02-biblioitems.sql
echo "table 3"
m < $SPECIFICS_TABLES_DIR/03-borrowers.sql
echo "table 4"
m < $SPECIFICS_TABLES_DIR/04-borrower_attributes.sql
echo "table 5"
m < $SPECIFICS_TABLES_DIR/05-items.sql

echo "u devkss_server"
u devkss_server
echo "structure"
m < $STRUCTURE_AND_DATA_FILE
echo "table 1"
m < $SPECIFICS_TABLES_DIR/01-biblio.sql
echo "table 2"
m < $SPECIFICS_TABLES_DIR/02-biblioitems.sql
echo "table 3"
m < $SPECIFICS_TABLES_DIR/03-borrowers.sql
echo "table 4"
m < $SPECIFICS_TABLES_DIR/04-borrower_attributes.sql
echo "table 5"
m < $SPECIFICS_TABLES_DIR/05-items.sql
