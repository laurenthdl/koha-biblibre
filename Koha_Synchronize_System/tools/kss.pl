#!/usr/bin/perl

use Modern::Perl;
use DBI;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;
use DateTime;
use POSIX qw(strftime);

use C4::Logguer qw(:DEFAULT $log_kss);

use Koha_Synchronize_System::tools::mysql;

my $db_client             = "koha_devkss_client";
my $db_server             = "koha_devkss_server";
my $db_merge              = "koha_devkss_merge";
my $diff_logbin_dir       = "../data/client/logbin";
my $diff_logtxt_full_dir  = "../data/client/logtxt_full";
my $diff_logtxt_dir       = "../data/client/logtxt";
my $mysql_cmd             = "/usr/bin/mysql";
my $mysqlbinlog_cmd       = "/usr/bin/mysqlbinlog";
my $mysqldump_cmd         = "/usr/bin/mysqldump";
my $hostname              = "localhost";
my $user                  = "root";
my $passwd                = "root";
my $help                  = "";
my $log = $log_kss;
my $dump_id_dir           = "../data/client/dump_id";
my $dump_db_server_dir    = "../data/server/bak";

my $kss_infos_table = "kss_infos";
my $max_borrowers_fieldname = "max_old_borrowers";

GetOptions(
    'help|?'       => \$help,
    'db_client=s'  => \$db_client,
    'db_server=s'  => \$db_server,
    'db_merge=s'   => \$db_merge,
    'hostname=s'   => \$hostname,
    'user=s'       => \$user,
    'passwd=s'     => \$passwd,
) or pod2usage(2);

pod2usage(1) if $help;

$log->info("BEGIN");

eval {

#    $log->info("=== Vérification de l'existence d'au moins un fichier de diff binaire ===");
#    my @diff_bin = qx{ls -1 $diff_logbin_dir};
#    if ( scalar( @diff_bin ) > 0 ) {
#        $log_info(scalar( @diff_bin) . " fichiers binaires trouvés");
#    } else {
#        $log_info("Aucun fichier binaire trouvé, rien ne sert de continuer !");
#        die "Aucun fichier binaire trouvé, rien ne sert de continuer !";
#    } 
#
#    $log->info("=== Sauvegarde de la base du serveur ===");
#    my $dump_filename = $dump_db_server_dir . "/" . strftime "%Y-%m-%d_%H:%M:%S", localtime;
#    $log->info("=== Dump en cours dans $dump_filename ===");
#    qx{$mysqldump_cmd -u $user -p$passwd $db_server > $dump_filename};
#
#    $log->info("=== Récupération des nouveaux ids remontés par le client ===");
#    my @dump_id = qx{ls -1 $dump_id_dir};
#    for my $file ( @dump_id ) {
#        $log->info("$file trouvé, insertion en cours...");
#        qx{$mysql_cmd -u $user, -p$passwd $db_server < $file};
#    }
#
#    $log->info("=== Extraction des fichiers binaires de log sql ===");
#    extract_and_purge_mysqllog( $diff_logbin_dir, $diff_logtxt_full_dir, $diff_logtxt_dir, $log );
#    
    my @files = qx{ls -1 $diff_logtxt_dir};
    $log->info("=== Digestion des requêtes ===");
    $log->info(scalar( @files ) . " fichiers trouvés");
    for my $file ( @files ) {
        insert_diff_file ("$diff_logtxt_dir\/$file", $log);
    }

    # À la fin du script, penser à insérer les nouveaux id dans kss_infos pour le client
};

if ( $@ ) {
    $log->error($@);
}

sub extract_and_purge_mysqllog {
    my $bindir  = shift;
    my $fulldir = shift;
    my $txtdir  = shift;
    my $log     = shift;

    if ( not -d $bindir ) {
        die "Le répertoire des logs binaires mysql ($bindir) n'existe pas !";
    }
    
    my @files = qx{ls -1 $bindir};
    for my $file ( @files ) {
        chomp $file;
        $log && $log->info("--- Traitement du fichier $file ---");
        my $bin_filepath = "$bindir\/$file";
        my $full_output_filepath = "$fulldir\/$file";
        my $output_filepath = "$txtdir\/$file";
        $log && $log->info("Extraction vers $full_output_filepath");
        qx{$mysqlbinlog_cmd $bin_filepath > $full_output_filepath};
        
        $log && $log->info("Purge vers $output_filepath");
        Koha_Synchronize_System::tools::mysql::purge_mysql_log ($full_output_filepath, $output_filepath);
    }
    return 0;
}

sub get_level {
    my $table_name = shift;

    my @tables_level1 = ('borrowers', 'items');
    my @tables_level2 = ('issues', 'old_issues', 'statistics', 'reserves', 'old_reserves', 'action_logs', 'borrower_attributes');

    if ( grep { $_ eq $table_name } @tables_level1 ) {
        return 1;
    }

    if ( grep { $_ eq $table_name } @tables_level2 ) {
        return 2;
    }

}

sub insert_diff_file {
    my $file = shift;
    my $log = shift;
    chomp $file;

    open( FILE, $file ) or die "Le fichier $file ne peut être lu";

    my $sep = "/*!*/;";
    $/ = $sep;


    while ( my $query = <FILE> ) {
        $query =~ s/^\n//; # 1er caractère est un retour chariot
        if ( $query =~ /^INSERT INTO (\S+)/ ) {
            my $level = get_level $1;
        } elsif ( $query =~ /^UPDATE (\S+)/ ) {
            my $level = get_level $1;
        } elsif ( $query =~ /^DELETE FROM (\S+)/ ) {
            my $level = get_level $1;
        } else {
            $log->warning("This query is not parsed : ###$query###");
        }
    }

    close( FILE );
}

$log->info("END");

