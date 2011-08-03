use Modern::Perl;
use DBI;
use YAML;

use Koha_Synchronize_System::tools::kss;

my $conf                     = Koha_Synchronize_System::tools::kss::get_conf();
my $kss_dir                  = $$conf{path}{kss_dir};
my $db_server                = $$conf{databases_infos}{db_server};
my $mysql_cmd                = $$conf{which_cmd}{mysql};
my $hostname                 = $$conf{databases_infos}{hostname};
my $user                     = $$conf{databases_infos}{user};
my $passwd                   = $$conf{databases_infos}{passwd};
my $dump_id_dir              = $$conf{abspath}{dump_ids};
my $kss_infos_table          = $$conf{databases_infos}{kss_infos_table};
my $matching_table_prefix    = $$conf{databases_infos}{matching_table_prefix};
my $matching_table_ids       = $$conf{databases_infos}{matching_table_ids};
my $max_old_borrowernumber_fieldname = $$conf{databases_infos}{max_borrowers_fieldname};
my $max_old_reservenumber_fieldname = $$conf{databases_infos}{max_reserves_fieldname};
my $kss_home                 = $$conf{abspath}{kss_server_home};
my $diff_logbin_dir          = $$conf{abspath}{diff_logbin_dir};
my $diff_logtxt_full_dir     = $$conf{abspath}{diff_logtxt_full_dir};
my $diff_logtxt_dir          = $$conf{abspath}{diff_logtxt_dir};
my $dump_db_server_dir       = $$conf{abspath}{backup_server_db};
my $backup_server_diff       = $$conf{abspath}{backup_server_diff};
my $inbox                    = $$conf{abspath}{server_inbox};
my $outbox                   = $$conf{abspath}{server_outbox};

if ( $< ne "0" ) {
   print "You must logged in root";
   exit 1
}

my $username = "kss";
print "Création de l'utilisateur $username\n";
my $pwd = crypt("kss", "kss");
eval {
    qx{useradd --home $kss_home --create-home --password $pwd $username};
};
if ( $@ ) {
    print "Can't create user kss";
    exit(1);
}

qx{mkdir -p $inbox};
qx{mkdir -p $outbox};
qx{mkdir -p $diff_logbin_dir};
qx{mkdir -p $diff_logtxt_full_dir};
qx{mkdir -p $diff_logtxt_dir};
qx{mkdir -p $dump_id_dir};
qx{mkdir -p $dump_db_server_dir};
qx{mkdir -p $backup_server_diff};

qx{chown -R $username:$username $inbox};
qx{chown -R $username:$username $outbox};
qx{chown -R $username:$username $dump_id_dir};
qx{chown -R $username:$username $dump_db_server_dir};
qx{chown -R $username:$username $backup_server_diff};

qx{chown -R $username:$username $kss_home};

print "=== Création des cronjobs ===\n";
system( qq{perl $kss_dir/tools/insert_or_update_crontab.pl --host=master} ) == 0 or die "Can't insert crontab";

print "/!\ Changer le mot de passe pour l'utilisateur $username\n";

print "=== Mise à disposition du client de la base de données du serveur ===\n";
print "Sauvegarde de la base du serveur";
Koha_Synchronize_System::tools::kss::backup_server_db;
print "Insertion des procedures\n";
Koha_Synchronize_System::tools::kss::insert_proc_and_triggers $user, $passwd, $db_server;

print "Préparation de la base de données\n";
system( qq{$mysql_cmd -u $user -p$passwd $db_server -e "CALL PROC_INIT_KSS();"} );

print "Préparation prochaine itération\n";
system( qq{$mysql_cmd -u $user -p$passwd $db_server -e "DROP TABLE IF EXISTS $kss_infos_table;"} );
system( qq{$mysql_cmd -u $user -p$passwd $db_server -e "CREATE TABLE IF NOT EXISTS $kss_infos_table ( variable VARCHAR(255), value VARCHAR(255) ) ENGINE=InnoDB DEFAULT CHARSET=utf8; "} );
system( qq{$mysql_cmd -u $user -p$passwd $db_server -e "INSERT INTO $kss_infos_table (variable, value) VALUES ('$max_old_borrowernumber_fieldname', (SELECT GREATEST(IFNULL(MAX(o.borrowernumber), 1), IFNULL(MAX(b.borrowernumber), 1)) + 1 FROM deletedborrowers o, borrowers b));"} );
system( qq{$mysql_cmd -u $user -p$passwd $db_server -e "INSERT INTO $kss_infos_table (variable, value) VALUES ('$max_old_reservenumber_fieldname', (SELECT GREATEST(IFNULL(MAX(o.reservenumber), 1), IFNULL(MAX(r.reservenumber), 1)) + 1 FROM old_reserves o, reserves r));"} );

print "Nettoyage\n";
system( qq{$mysql_cmd -u $user -p$passwd $db_server -e "DROP TABLE IF EXISTS } . $matching_table_prefix . qq{borrowers;"} );
system( qq{$mysql_cmd -u $user -p$passwd $db_server -e "DROP TABLE IF EXISTS } . $matching_table_prefix . qq{reserves;"} );
system( qq{$mysql_cmd -u $user -p$passwd $db_server -e "DROP TABLE IF EXISTS $matching_table_ids;"} );
Koha_Synchronize_System::tools::kss::delete_proc_and_triggers $user, $passwd, $db_server;
system( qq{rm -f /tmp/procedures /tmp/triggers /tmp/del_triggers /tmp/del_procedures} );
print "Dump de la base de données et mise à disposition pour le client\n";
Koha_Synchronize_System::tools::kss::dump_available_db;

qx{chown -R $username:$username $outbox};
print "Terminé\nPensez à installer le script 'service' et configurer le fichier de configuration mysql (my.cnf) afin de logguer les requêtes dans un log binaire\n";

