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
my $dump_id_dir              = $$conf{path}{dump_ids};
my $kss_infos_table          = $$conf{databases_infos}{kss_infos_table};
my $kss_home                 = $$conf{path}{kss_server_home};
my $diff_logbin_dir          = $$conf{path}{diff_logbin_dir};
my $diff_logtxt_full_dir     = $$conf{path}{diff_logtxt_full_dir};
my $diff_logtxt_dir          = $$conf{path}{diff_logtxt_dir};
my $dump_db_server_dir       = $$conf{path}{backup_server_db};
my $backup_server_diff       = $$conf{path}{backup_server_diff};
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

qx{chown -R $username:$username $kss_home};

print "=== Création des cronjobs ===\n";
system( qq{perl $kss_dir/tools/insert_or_update_crontab.pl --host=master} ) == 0 or die "Can't insert crontab";

print "/!\ Changer le mot de passe pour l'utilisateur $username\n";

print "=== Mise à disposition du client de la base de données du serveur ===\n";
print "Insertion des procedures\n";
Koha_Synchronize_System::tools::kss::insert_proc_and_triggers $user, $passwd, $db_server;
print "Préparation prochaine itération\n";
Koha_Synchronize_System::tools::kss::prepare_next_iteration;
print "Nettoyage\n";
Koha_Synchronize_System::tools::kss::clean $user, $passwd, $db_server;

