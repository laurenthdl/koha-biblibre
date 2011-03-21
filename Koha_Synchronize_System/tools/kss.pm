#!/usr/bin/perl

package Koha_Synchronize_System::kss;

use Modern::Perl;
use DBI;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;
use DateTime;
use POSIX qw(strftime);
use YAML;

use C4::Logguer qw(:DEFAULT $log_kss);

use Koha_Synchronize_System::tools::mysql;

my $koha_dir = C4::Context->config('intranetdir');

my $kss_dir = "$koha_dir/Koha_Synchronize_System";

my $conf = YAML::LoadFile("$kss_dir/conf/kss.yaml");
my $db_client             = $$conf{databases_infos}{db_client};
my $db_server             = $$conf{databases_infos}{db_server};
my $diff_logbin_dir       = $$conf{mysql_log}{diff_logbin_dir};
my $diff_logtxt_full_dir  = $$conf{mysql_log}{diff_logtxt_full_dir};
my $diff_logtxt_dir       = $$conf{mysql_log}{diff_logtxt_dir};
my $mysql_cmd             = $$conf{databases_infos}{mysql};
my $mysqlbinlog_cmd       = $$conf{databases_infos}{mysqlbinlog};
my $mysqldump_cmd         = $$conf{databases_infos}{mysqldump};
my $hostname              = $$conf{databases_infos}{hostname};
my $user                  = $$conf{databases_infos}{user};
my $passwd                = $$conf{databases_infos}{passwd};
my $help                  = "";
my $log = $log_kss;
my $dump_id_dir           = $$conf{datas_path}{dump_id};
my $dump_db_server_dir    = $$conf{datas_path}{backup_server};

my $kss_infos_table = $$conf{databases_infos}{kss_infos_table};
my $max_borrowers_fieldname = $$conf{databases_infos}{max_borrowers_fieldname};

GetOptions(
    'help|?'       => \$help,
    'db_client=s'  => \$db_client,
    'db_server=s'  => \$db_server,
    'hostname=s'   => \$hostname,
    'user=s'       => \$user,
    'passwd=s'     => \$passwd,
) or pod2usage(2);

pod2usage(1) if $help;

$log->info("BEGIN");

eval {

    $log->info("=== Vérification de l'existence d'au moins un fichier de diff binaire ===");
    my @diff_bin = qx{ls -1 $diff_logbin_dir};
    if ( scalar( @diff_bin ) > 0 ) {
        $log_info(scalar( @diff_bin) . " fichiers binaires trouvés");
    } else {
        $log_info("Aucun fichier binaire trouvé, rien ne sert de continuer !");
        die "Aucun fichier binaire trouvé, rien ne sert de continuer !";
    }

    $log->info("=== Sauvegarde de la base du serveur ===");
    my $dump_filename = $dump_db_server_dir . "/" . strftime "%Y-%m-%d_%H:%M:%S", localtime;
    $log->info("=== Dump en cours dans $dump_filename ===");
    qx{$mysqldump_cmd -u $user -p$passwd $db_server > $dump_filename};

    $log->info("=== Récupération des nouveaux ids remontés par le client ===");
    my @dump_id = qx{ls -1 $dump_id_dir};
    for my $file ( @dump_id ) {
        $log->info("$file trouvé, insertion en cours...");
        qx{$mysql_cmd -u $user, -p$passwd $db_server < $file};
    }

    $log->info("=== Extraction des fichiers binaires de log sql ===");
    extract_and_purge_mysqllog( $diff_logbin_dir, $diff_logtxt_full_dir, $diff_logtxt_dir, $log );

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

sub replace_with_new_id {
    my $string = shift;
    my $table_name = shift;
    my $field = shift;
    my $dbh = shift;

    if ( $string =~ /$field\s*=\s*\'{0,1}([^']*)\'{0,1}/ ) {
        $dbh->do("CALL PROC_GET_NEW_ID (\"$table_name.$field\", $1, \@new_id);");
        my @value = $dbh->selectrow_array("SELECT \@new_id;");

        my $new_id = $value[0];

        $string =~ s/$field\s*=\s*\'{0,1}([^']*)\'{0,1}/$field = '$new_id'/;
    }

    return $string;
}

sub insert_diff_file {
    my $file = shift;
    my $log = shift;
    chomp $file;

    my $dbh = DBI->connect( "DBI:mysql:dbname=$db_server;host=$hostname;", $user, $passwd ) or die $DBI::errstr;
    $dbh->{'mysql_enable_utf8'} = 1;
    $dbh->do("set NAMES 'utf8'");

    open( FILE, $file ) or die "Le fichier $file ne peut être lu";

    my $sep = "/*!*/;";
    $/ = $sep;


    while ( my $query = <FILE> ) {
        my $r;
        my $table_name;
        $query =~ s/^\n//; # 1er caractère est un retour chariot
        if ( $query =~ /^INSERT INTO (\S+)/ ) {
            # Nothing todo
        } elsif ( $query =~ /^UPDATE (\S+)/ ) {
            $table_name = $1;
            my $level = get_level $table_name;
            if ( $level == 1 ) {
                if ( $table_name eq 'borrowers' ) {
                    $query = replace_with_new_id ( $query, $table_name, 'borrowernumber', $dbh );
                }
            } elsif ( $level == 2 ) {
                $query = replace_with_new_id ( $query, $table_name, 'borrowernumber', $dbh );
            }
        } elsif ( $query =~ /^DELETE FROM (\S+)/ ) {
            $table_name = $1;
            my $level = get_level $1;
            if ( $level == 1 ) {
                # Nothing todo
            } elsif ( $level == 2 ) {
                $query = replace_with_new_id ( $query, $table_name, 'borrowernumber', $dbh );
                $r = $query;
            }

        } else {
            $log->warning("This query is not parsed : ###$query###");
        }
        $log && $log->info( $r );
    }

    close( FILE );
}

$log->info("END");

