#!/bin/sh
#./tmpl_process3.pl install -r -s po/prog_opac_fr_FR.po -i ../../koha-tmpl/opac-tmpl/prog/en -o ../../koha-tmpl/opac-tmpl/prog/fr

#./tmpl_process3.pl install -r -s po/prog_opac_zh_TW.po -i ../../koha-tmpl/opac-tmpl/prog/en -o ../../koha-tmpl/opac-tmpl/prog/zh-TW
#./tmpl_process3.pl install -r -s po/default_intranet_zh_TW.po -i ../../koha-tmpl/intranet-tmpl/default/en -o ../../koha-tmpl/intranet-tmpl/default/zh-TW

# ./tmpl_process3.pl install -r -s po/css_opac_es_AR.po -i ../../koha-tmpl/opac-tmpl/css/zh_TW -o ../../koha-tmpl/opac-tmpl/css/es_AR
#./tmpl_process3.pl install -r -s po/default_intranet_es_AR.po -i ../../koha-tmpl/intranet-tmpl/default/en -o ../../koha-tmpl/intranet-tmpl/default/es
./tmpl_process3.pl install -r -s po/fr-FR-i-staff-t-prog-v-3000000.po -i ../../koha-tmpl/intranet-tmpl/prog/en -o ../../koha-tmpl/intranet-tmpl/prog/fr-FR
./tmpl_process3.pl install -r -s po/fr-FR-i-opac-t-prog-v-3000000.po -i ../../koha-tmpl/opac-tmpl/prog/en -o ../../koha-tmpl/opac-tmpl/prog/fr-FR

