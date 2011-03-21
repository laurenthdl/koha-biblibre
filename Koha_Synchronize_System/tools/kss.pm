#!/usr/bin/perl

package Koha_Synchronize_System::tools::kss;

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

my $log                   = $log_kss;

my $koha_dir = C4::Context->config('intranetdir');

my $kss_dir = "$koha_dir/Koha_Synchronize_System/";

my $conf                     = YAML::LoadFile("$kss_dir/conf/kss.yaml");
my $db_client                = $$conf{databases_infos}{db_client};
my $db_server                = $$conf{databases_infos}{db_server};
my $diff_logbin_dir          = $$conf{mysql_log}{diff_logbin_dir};
my $diff_logtxt_full_dir     = $$conf{mysql_log}{diff_logtxt_full_dir};
my $diff_logtxt_dir          = $$conf{mysql_log}{diff_logtxt_dir};
my $mysql_cmd                = $$conf{which_cmd}{mysql};
my $mysqlbinlog_cmd          = $$conf{which_cmd}{mysqlbinlog};
my $mysqldump_cmd            = $$conf{which_cmd}{mysqldump};
my $hostname                 = $$conf{databases_infos}{hostname};
my $user                     = $$conf{databases_infos}{user};
my $passwd                   = $$conf{databases_infos}{passwd};
my $help                     = "";
my $dump_id_dir              = $$conf{datas_path}{dump_id};
my $dump_db_server_dir       = $$conf{datas_path}{backup_server};

my $generate_triggers_path   = $kss_dir . $$conf{tools_path}{generate_triggers};
my $generate_procedures_path = $kss_dir . $$conf{tools_path}{generate_procedures};

my $kss_infos_table          = $$conf{databases_infos}{kss_infos_table};
my $max_borrowers_fieldname  = $$conf{databases_infos}{max_borrowers_fieldname};

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

sub diff_files_exists {
    my $dir = shift;
    my $log = shift;

    my @diff_bin = qx{ls -1 $dir};
    if ( scalar( @diff_bin ) > 0 ) {
        $log && $log->info(scalar( @diff_bin) . " fichiers binaires trouvés");
        return 1;
    }

    $log && $log->info("Aucun fichier binaire trouvé, rien ne sert de continuer !");
    die "Aucun fichier binaire trouvé, rien ne sert de continuer !";

    return 0;
}

sub insert_new_ids {
    my ($mysql_cmd, $user, $pwd, $db_name, $id_dir, $log) = @_;
    my @dump_id = qx{ls -1 $id_dir};

    $log && $log->info(scalar(@dump_id) . " Fichiers trouvés");
    for my $file ( @dump_id ) {
        $log && $log->info("Insertion de $file en cours...");
        qx{$mysql_cmd -u $user -p$pwd $db_name < $file};
    }
}

sub insert_proc_and_triggers {
    my ($mysql_cmd, $user, $pwd, $db_name, $log) = @_;
    eval {
        qx{$generate_triggers_path > /tmp/triggers.sql};
        qx{$mysql_cmd -u $user -p$pwd $db_name < /tmp/triggers.sql};
        qx{$generate_procedures_path > /tmp/procedures.sql};
        qx{$mysql_cmd -u $user -p$pwd $db_name < /tmp/procedures.sql};
    };

    if ( $@ ) {
        die $@;
    }
}

sub delete_proc_and_triggers {
    my ($mysql_cmd, $user, $pwd, $db_name, $log) = @_;
    eval {
        qx{$generate_triggers_path > /tmp/del_triggers.sql};
        qx{$mysql_cmd -u $user -p$pwd $db_name < /tmp/del_triggers.sql};
        qx{$generate_procedures_path > /tmp/del_procedures.sql};
        qx{$mysql_cmd -u $user -p$pwd $db_name < /tmp/del_procedures.sql};
    };

    if ( $@ ) {
        die $@;
    }

}

eval {

    $log->info("=== Vérification de l'existence d'au moins un fichier de diff binaire ===");
    diff_files_exists $diff_logbin_dir, $log;

    $log->info("=== Sauvegarde de la base du serveur ===");
    my $dump_filename = $dump_db_server_dir . "/" . strftime "%Y-%m-%d_%H:%M:%S", localtime;
    $log->info("=== Dump en cours dans $dump_filename ===");
#    qx{$mysqldump_cmd -u $user -p$passwd $db_server > $dump_filename};

    $log->info("=== Génération et insertion en base des triggers et procédures stockées ===");
    insert_proc_and_triggers $mysql_cmd, $user, $passwd, $db_server, $log;

    $log->info("=== Préparation de la base de données ===");
    qx{$mysql_cmd -u $user -p$passwd $db_server -e "CALL PROC_INIT_KSS();"};

    $log->info("=== Insertion des nouveaux ids remontés par le client ===");
    insert_new_ids $mysql_cmd, $user, $passwd, $db_server, $dump_id_dir, $log;

    $log->info("=== Extraction des fichiers binaires de log sql ===");
    extract_and_purge_mysqllog( $diff_logbin_dir, $diff_logtxt_full_dir, $diff_logtxt_dir, $log );

    my @files = qx{ls -1 $diff_logtxt_dir};
    $log->info("=== Digestion des requêtes ===");
    $log->info(scalar( @files ) . " fichiers trouvés");
    for my $file ( @files ) {
        $log && $log->info("Traitement de $file en cours...");
        insert_diff_file ("$diff_logtxt_dir\/$file", $log);
    }

    $log->info("=== Purge des tables temporaires ===");
    qx{$mysql_cmd -u $user -p$passwd $db_server -e "CALL PROC_END_KSS();"};

    $log->info("=== Suppression en base des triggers et procédures stockées ===");
    delete_proc_and_triggers $mysql_cmd, $user, $passwd, $db_server, $log;

    # À la fin du script :
    #  - insérer les nouveaux id dans kss_infos pour le client
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


    #$dbh->do(qq{DELIMITER $sep});
    while ( my $query = <FILE> ) {
        my $r;
        my @warnings;
        my $table_name;
        $query =~ s/^\n//; # 1er caractère est un retour chariot
        if ( $query =~ /^INSERT INTO (\S+)/ ) {
            $table_name = $1;
            my $level = get_level $table_name;
            if ( $level == 1 ) {
                # Nothing todo
            } elsif ( $level == 2 ) {
                # For INSERT old_issues SELECT * FROM issues WHERE borrowernumber=xxx [...] format
                $query = replace_with_new_id ( $query, $table_name, 'borrowernumber', $dbh );
            }
        } elsif ( $query =~ /^UPDATE (\S+)/ ) {
            $table_name = $1;
            my $level = get_level $table_name;
            if ( $level == 1 ) {
                if ( $table_name eq 'borrowers' ) {
                    $query = replace_with_new_id ( $query, $table_name, 'borrowernumber', $dbh );
                    $query = replace_with_new_id ( $query, $table_name, 'reservenumber', $dbh );
                }
            } elsif ( $level == 2 ) {
                $query = replace_with_new_id ( $query, $table_name, 'borrowernumber', $dbh );
                $query = replace_with_new_id ( $query, $table_name, 'reservenumber', $dbh );
            }
        } elsif ( $query =~ /^DELETE FROM (\S+)/ ) {
            $table_name = $1;
            my $level = get_level $1;
            if ( $level == 1 ) {
                # Nothing todo
            } elsif ( $level == 2 ) {
                $query = replace_with_new_id ( $query, $table_name, 'borrowernumber', $dbh );
                $query = replace_with_new_id ( $query, $table_name, 'reservenumber', $dbh );
            }

        } else {
            $log->warning("This query is not parsed : ###$query###");
        }
        $log && $log->info( $query );

        $dbh->do($query);

        @warnings = $dbh->selectrow_array(qq{show warnings $sep});

        if ( @warnings ) {
            $log && $log->error($warnings[0] . ':' . $warnings[1] . ' => ' . $warnings[2]);
        } else {
            $log && $log->info(" <<< OK >>>")
        }
    }

    close( FILE );
}

$log->info("END");

