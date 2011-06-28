# A very simple script wich write logs in a good way and launch complete reindexation without reset

#!/bin/bash

LOGFILE_BIB=/home/koha/var/log/`date +%F`_rebuildbiblio.log
LOGFILE_AUTH=/home/koha/var/log/`date +%F`_rebuildauthor.log

/usr/bin/time ./src/misc/migration_tools/rebuild_solr.pl -t biblio &> $LOGFILE_BIB
/usr/bin/time ./src/misc/migration_tools/rebuild_solr.pl -t authority &> $LOGFILE_AUTH
