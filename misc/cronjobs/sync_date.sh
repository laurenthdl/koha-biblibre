#!/bin/bash

export KOHA_CONF=/home/koha/etc/koha-conf.xml;export PERL5LIB=/home/koha/src/;
#Adding 099$c and $d where there is none
perl /home/koha/src/misc/maintenance/UNIMARC_sync_date_created_with_marc_biblio.pl --run --where  "Extractvalue(marcxml,'count(//datafield[@tag=\"099\"]/subfield[@code=\"c\" or @code=\"d\"])')=0";
#updating 099$c and $d where they are not synched
perl /home/koha/src/misc/maintenance/UNIMARC_sync_date_created_with_marc_biblio.pl --run --where  "Extractvalue(marcxml,'//datafield[@tag=\"099\"]/subfield[@code=\"c\"]')<>biblio.datecreated";
perl /home/koha/src/misc/maintenance/UNIMARC_sync_date_created_with_marc_biblio.pl --run --where  "Extractvalue(marcxml,'//datafield[@tag=\"099\"]/subfield[@code=\"d\"]')<>biblio.timestamp";
#One can even use LIMIT parameter in order to test
#perl /home/koha/src/misc/maintenance/UNIMARC_sync_date_created_with_marc_biblio.pl --run --where  "Extractvalue(marcxml,'//datafield[@tag=\"099\"]
