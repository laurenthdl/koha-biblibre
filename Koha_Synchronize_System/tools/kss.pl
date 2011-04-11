use Modern::Perl;
use DBI;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;
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
my $mv_cmd                   = $$conf{which_cmd}{mv};
my $tar_cmd                  = $$conf{which_cmd}{tar};
my $hostname                 = $$conf{databases_infos}{hostname};
my $user                     = $$conf{databases_infos}{user};
my $passwd                   = $$conf{databases_infos}{passwd};
my $dump_id_dir              = $$conf{path}{dump_ids};
my $kss_infos_table          = $$conf{databases_infos}{kss_infos_table};
my $inbox                    = $$conf{path}{server_inbox};
my $outbox                   = $$conf{path}{server_outbox};


$log->info("BEGIN");

eval {

    $log->info("=== Récupération des archives remontées par le client ===");
    my $tar_gz_files = Koha_Synchronize_System::tools::kss::get_archives ;

    if ( scalar ( @$tar_gz_files ) == 0 ) {
        $log->error("Aucune archive n'a été trouvé, le serveur ne sera pas modifié.");
        exit(1);
    }

    $log->info("=== Sauvegarde de la base du serveur ===");
    Koha_Synchronize_System::tools::kss::backup_server_db $log;

    $log->info("=== Génération et insertion en base des triggers et procédures stockées ===");
    Koha_Synchronize_System::tools::kss::insert_proc_and_triggers $user, $passwd, $db_server, $log;

    for my $archive ( @$tar_gz_files ) {
        chomp $archive;
        $log->info("=== Gestion de l'archive $archive ===");
        $log->info(" - Extraction...");
        print "$tar_cmd zxvf $archive -C $inbox";
        eval { qx{ $tar_cmd zxvf $archive -C $inbox } };
        die $@ if $@;

        $log->info(" - Déplacement des fichiers...");
        my $cmd = "$mv_cmd $inbox/ids/*.sql $dump_id_dir/";
        my @r = qx{$cmd};
        $cmd = "$mv_cmd $inbox/logbin/* $diff_logbin_dir/";
        @r = qx{$cmd};

        $cmd = "cat $inbox/hostname";
        @r = qx{$cmd};
        my $client_hostname = $r[0];
    	chomp $client_hostname;

        Koha_Synchronize_System::tools::kss::diff_files_exists $diff_logbin_dir, $log;

        $log->info("== Préparation de la base de données ==");
        Koha_Synchronize_System::tools::kss::prepare_database $mysql_cmd, $user, $passwd, $db_server, $client_hostname, $log;

        $log->info("== Insertion des nouveaux ids remontés par le client ==");
        Koha_Synchronize_System::tools::kss::insert_new_ids $mysql_cmd, $user, $passwd, $db_server, $dump_id_dir, $log;

        $log->info("== Extraction des fichiers binaires de log sql ==");
        Koha_Synchronize_System::tools::kss::extract_and_purge_mysqllog( $diff_logbin_dir, $diff_logtxt_full_dir, $diff_logtxt_dir, $log );

        my @files = qx{ls -1 $diff_logtxt_dir};
        $log->info("== Digestion des requêtes ==");
        $log->info(scalar( @files ) . " fichiers trouvés");
        for my $file ( @files ) {
            chomp $file;
            $log && $log->info("Traitement de $file en cours...");
	    Koha_Synchronize_System::tools::kss::insert_diff_file ("$diff_logtxt_dir\/$file", undef, $log);
        }

        $log->info("== Suppression des fichiers utilisés ==");
        Koha_Synchronize_System::tools::kss::clean_fs;
    }

    $log && $log->info("=== Préparation pour la prochaine itération ===");
    Koha_Synchronize_System::tools::kss::prepare_next_iteration $log;

    $log->info("=== Cleaning ... ===");
    Koha_Synchronize_System::tools::kss::clean $mysql_cmd, $user, $passwd, $db_server, $log;

    $log->info("=== Mise à disposition du client de la nouvelle base de données ===");
    Koha_Synchronize_System::tools::kss::dump_available_db $log;


};

if ( $@ ) {

    $log->error($@);
    Koha_Synchronize_System::tools::kss::log_error($@, "Erreur lors de l'exécution ...");

}

$log->info("END");

