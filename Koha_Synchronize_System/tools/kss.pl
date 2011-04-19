#!/usr/bin/perl

use Modern::Perl;
use DBI;
use Data::Dumper;
use Getopt::Long;
use Fcntl qw(:flock);
use YAML;

use C4::Logguer qw(:DEFAULT $log_kss);

use Koha_Synchronize_System::tools::kss;

my $status = "";
my $help = "";
GetOptions(
        'status'   => \$status,
    );

if ( $status ) {
    $status = get_status();
    if ( $status ) {
        print "$0 is running";
        exit 1;
    }

    print "$0 is not running";
    exit 0
}

my $log = $log_kss;

if ( get_status() ) {
    $log->error( "$0 is already running. Exiting.\n");
    exit(1);
}

my $conf                     = Koha_Synchronize_System::tools::kss::get_conf();
my $db_server                = $$conf{databases_infos}{db_server};
my $diff_logbin_dir          = $$conf{abspath}{diff_logbin_dir};
my $diff_logtxt_full_dir     = $$conf{abspath}{diff_logtxt_full_dir};
my $diff_logtxt_dir          = $$conf{abspath}{diff_logtxt_dir};
my $mv_cmd                   = $$conf{which_cmd}{mv};
my $tar_cmd                  = $$conf{which_cmd}{tar};
my $hostname                 = $$conf{databases_infos}{hostname};
my $user                     = $$conf{databases_infos}{user};
my $passwd                   = $$conf{databases_infos}{passwd};
my $dump_id_dir              = $$conf{abspath}{dump_ids};
my $kss_infos_table          = $$conf{databases_infos}{kss_infos_table};
my $inbox                    = $$conf{abspath}{server_inbox};
my $outbox                   = $$conf{abspath}{server_outbox};
my $backup_server_db_dir     = $$conf{abspath}{backup_server_db};
my $backup_server_diff_dir   = $$conf{abspath}{backup_server_diff};
my $backup_delay_db          = $$conf{backup_delay}{server_db};
my $backup_delay_diff        = $$conf{backup_delay}{server_diff};

$log->info("BEGIN");

my $log_filepath = $$conf{abspath}{logfile_stderr};
open(STDOUT, ">>$log_filepath");
open(STDERR, ">>$log_filepath");

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
        system( qq{ $tar_cmd zxvf $archive -C $inbox } ) == 0 or die qq{Can't extract archive $archive in $inbox dir ($?)};

        $log->info(" - Déplacement des fichiers...");

        my @logbin = <$inbox/logbin/*>;
        if ( scalar( @logbin ) == 0 ) {
            $log->info("Pas de fichier binaire dans cette archive, next !");
            next;
        }
        system( qq{$mv_cmd $inbox/ids/*.sql $dump_id_dir/} ) == 0 or die qq{Can't mv $inbox/ids/*.sql to $dump_id_dir/ ($?)};
        system( qq{$mv_cmd $inbox/logbin/* $diff_logbin_dir/} ) == 0 or die qq{Can't mv $inbox/logbin/* to $diff_logbin_dir/ ($?)};

        open HN, "$inbox/hostname";
        my $client_hostname = <HN>;
        close HN;
    	chomp $client_hostname;

        next if not Koha_Synchronize_System::tools::kss::diff_files_exists $diff_logbin_dir, $log;

        $log->info("== Préparation de la base de données ==");
        Koha_Synchronize_System::tools::kss::prepare_database $user, $passwd, $db_server, $client_hostname, $log;

        $log->info("== Insertion des nouveaux ids remontés par le client ==");
        Koha_Synchronize_System::tools::kss::insert_new_ids $user, $passwd, $db_server, $dump_id_dir, $log;

        $log->info("== Extraction des fichiers binaires de log sql ==");
        Koha_Synchronize_System::tools::kss::extract_and_purge_mysqllog( $diff_logbin_dir, $diff_logtxt_full_dir, $diff_logtxt_dir, $log );

        my @files = <$diff_logtxt_dir/*>;
        $log->info("== Digestion des requêtes ==");
        $log->info(scalar( @files ) . " fichiers trouvés");
        for my $file ( @files ) {
            chomp $file;
            $log && $log->info("Traitement de $file en cours...");
            Koha_Synchronize_System::tools::kss::insert_diff_file ($file, undef, $log);
        }

        $log->info("== Suppression des fichiers utilisés ==");
        Koha_Synchronize_System::tools::kss::clean_fs;
    }

    $log && $log->info("=== Préparation pour la prochaine itération ===");
    Koha_Synchronize_System::tools::kss::prepare_next_iteration $log;

    $log->info("=== Cleaning ... ===");
    Koha_Synchronize_System::tools::kss::clean $user, $passwd, $db_server, $log;

    $log->info("=== Mise à disposition du client de la nouvelle base de données ===");
    Koha_Synchronize_System::tools::kss::dump_available_db $log;

    $log->info("=== Suppression des anciens fichiers de sauvegarde ===");
    system( qq{find $backup_server_diff_dir -maxdepth 1 -mtime +$backup_delay_diff -name '*.tar.gz' -delete} ) == 0 or die "Can't delete old backup diff ($!)";
    system( qq{find $backup_server_db_dir -maxdepth 1 -mtime +$backup_delay_db -exec rm -R {} \\;} ) == 0 or die "Can't delete old backup db ($!)";
};

if ( $@ ) {

    $log->error("An error occured, try to clean...");
    $log->error($@);
    Koha_Synchronize_System::tools::kss::log_error($@, "Erreur lors de l'exécution ...");
    Koha_Synchronize_System::tools::kss::clean_fs;
    Koha_Synchronize_System::tools::kss::clean $user, $passwd, $db_server, $log;

}

$log->info("END");

sub get_status {
    unless ( flock(DATA, LOCK_EX|LOCK_NB) ) {
        return 1;
    }
    return 0;
}

__DATA__
DO NOT REMOVE THIS DATA SECTION.
USED BY LOCK SYSTEM.
