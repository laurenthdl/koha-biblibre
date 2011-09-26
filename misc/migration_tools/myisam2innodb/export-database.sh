SHELL=/bin/sh
MAILTO=xxx@xxx.com

echo "Début de l'export des tables de la base de donnees koha a `date`"

        TODAY=`date +%Y-%m-%d`
        mkdir /data/backups/koha_database/$TODAY

        for table in `mysql koha -u consult -pkoha -N -e "SHOW tables"`
        do
                mysqldump koha -u consult -pkoha $table | gzip -v > /data/backups/koha_database/$TODAY/$table-`date +%Y-%m-%d`.gz
        done
        
echo ""         
echo "  Début de suppression des fichiers de plus de 15 jours"
        rm -Rf `find /data/backups/koha_database/* -type d -mtime +15`
echo "  Fin de suppression des fichiers de plus de 15 jours"
echo ""

echo "Fin de l'export des tables de la base de donnees koha a `date`"
