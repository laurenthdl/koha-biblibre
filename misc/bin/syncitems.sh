#!/bin/bash
test1=`/bin/ps -ef|/bin/grep -c "sync_items_in_marc_bib"`;
if [ $test1 -lt 2 ];
        then
        /usr/bin/perl /home/koha/src/misc/maintenance/sync_items_in_marc_bib.pl --items --run-update --where "items.timestamp >= DATE_SUB(NOW(), INTERVAL  5 MINUTE)"  &>/home/koha/logs_syncitem
fi
