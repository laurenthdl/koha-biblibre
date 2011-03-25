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


$log->info("BEGIN");

eval {

    $log->info("=== Vérification de l'existence d'au moins un fichier de diff binaire ===");
#    diff_files_exists $diff_logbin_dir, $log;

    $log->info("=== Sauvegarde de la base du serveur ===");
    my $dump_filename = $dump_db_server_dir . "/" . strftime "%Y-%m-%d_%H:%M:%S", localtime;
    $log->info("=== Dump en cours dans $dump_filename ===");
#    qx{$mysqldump_cmd -u $user -p$passwd $db_server > $dump_filename};

    $log->info("=== Génération et insertion en base des triggers et procédures stockées ===");
    insert_proc_and_triggers $mysql_cmd, $user, $passwd, $db_server, $log;

    $log->info("=== Préparation de la base de données ===");
    prepare_database $mysql_cmd, $user, $passwd, $db_server, $log;

    $log->info("=== Insertion des nouveaux ids remontés par le client ===");
    insert_new_ids $mysql_cmd, $user, $passwd, $db_server, $dump_id_dir, $log;

    $log->info("=== Extraction des fichiers binaires de log sql ===");
    extract_and_purge_mysqllog( $diff_logbin_dir, $diff_logtxt_full_dir, $diff_logtxt_dir, $log );

    my @files = qx{ls -1 $diff_logtxt_dir};
    $log->info("=== Digestion des requêtes ===");
    $log->info(scalar( @files ) . " fichiers trouvés");
    for my $file ( @files ) {
        chomp $file;
        $log && $log->info("Traitement de $file en cours...");
        insert_diff_file ("$diff_logtxt_dir\/$file", $log);
    }


    $log->info("=== Cleaning ... ===");
    clean $mysql_cmd, $user, $passwd, $db_server, $log;

    # À la fin du script :
    #  - insérer les nouveaux id dans kss_infos pour le client
};

if ( $@ ) {

    $log->error($@);
    Koha_Synchronize_System::tools::kss::log_error($@, "Erreur lors de l'exécution ...");
}

$log->info("END");

