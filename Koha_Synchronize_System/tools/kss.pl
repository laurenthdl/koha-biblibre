use Modern::Perl;
use DBI;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;
use DateTime;
use POSIX qw(strftime);
use YAML;

use C4::Logguer qw(:DEFAULT $log_kss);

use Koha_Synchronize_System::tools::kss;

my $log = $log_kss;

my $conf                     = Koha_Synchronize_System::tools::kss::get_conf();
my $kss_dir                  = $$conf{path}{kss_dir};
my $db_server                = $$conf{databases_infos}{db_server};
my $diff_logbin_dir          = $$conf{path}{diff_logbin_dir};
my $diff_logtxt_full_dir     = $$conf{path}{diff_logtxt_full_dir};
my $diff_logtxt_dir          = $$conf{path}{diff_logtxt_dir};
my $mysql_cmd                = $$conf{which_cmd}{mysql};
my $mysqlbinlog_cmd          = $$conf{which_cmd}{mysqlbinlog};
my $mysqldump_cmd            = $$conf{which_cmd}{mysqldump};
my $hostname                 = $$conf{databases_infos}{hostname};
my $user                     = $$conf{databases_infos}{user};
my $passwd                   = $$conf{databases_infos}{passwd};
my $dump_id_dir              = $$conf{path}{dump_ids};
my $dump_db_server_dir       = $$conf{path}{backup_server};

my $kss_infos_table          = $$conf{databases_infos}{kss_infos_table};


$log->info("BEGIN");

eval {

    $log->info("=== Vérification de l'existence d'au moins un fichier de diff binaire ===");
    Koha_Synchronize_System::tools::kss::diff_files_exists $diff_logbin_dir, $log;

    $log->info("=== Sauvegarde de la base du serveur ===");
    my $dump_filename = $dump_db_server_dir . "/" . strftime "%Y-%m-%d_%H:%M:%S", localtime;
    $log->info("=== Dump en cours dans $dump_filename ===");
#    qx{$mysqldump_cmd -u $user -p$passwd $db_server > $dump_filename};

    $log->info("=== Génération et insertion en base des triggers et procédures stockées ===");
    Koha_Synchronize_System::tools::kss::insert_proc_and_triggers $mysql_cmd, $user, $passwd, $db_server, $log;

    $log->info("=== Préparation de la base de données ===");
    Koha_Synchronize_System::tools::kss::prepare_database $mysql_cmd, $user, $passwd, $db_server, $log;

    $log->info("=== Insertion des nouveaux ids remontés par le client ===");
    Koha_Synchronize_System::tools::kss::insert_new_ids $mysql_cmd, $user, $passwd, $db_server, $dump_id_dir, $log;

    $log->info("=== Extraction des fichiers binaires de log sql ===");
    Koha_Synchronize_System::tools::kss::extract_and_purge_mysqllog( $diff_logbin_dir, $diff_logtxt_full_dir, $diff_logtxt_dir, $log );

    my @files = qx{ls -1 $diff_logtxt_dir};
    $log->info("=== Digestion des requêtes ===");
    $log->info(scalar( @files ) . " fichiers trouvés");
    for my $file ( @files ) {
        chomp $file;
        $log && $log->info("Traitement de $file en cours...");
        Koha_Synchronize_System::tools::kss::insert_diff_file ("$diff_logtxt_dir\/$file", undef, $log);
    }


    $log->info("=== Cleaning ... ===");
    Koha_Synchronize_System::tools::kss::clean $mysql_cmd, $user, $passwd, $db_server, $log;

    # À la fin du script :
    #  - insérer les nouveaux id dans kss_infos pour le client
};

if ( $@ ) {

    $log->error($@);
    Koha_Synchronize_System::tools::kss::log_error($@, "Erreur lors de l'exécution ...");
}

$log->info("END");

