package Koha_Synchronize_System::tools::kss;

use Modern::Perl;
use DBI;
use Data::Dumper;
use DateTime;
use POSIX qw(strftime);
use YAML;
use Mail::Sendmail;
use Digest::MD5;
use File::Path qw(make_path remove_tree);
use File::Basename;
use C4::Context;
use Koha_Synchronize_System::tools::mysql;

my $conf                     = get_conf();
my $kss_dir                  = $$conf{path}{kss_dir};
my $db_client                = $$conf{databases_infos}{db_client};
my $db_server                = $$conf{databases_infos}{db_server};
my $diff_logbin_dir          = $$conf{abspath}{diff_logbin_dir};
my $diff_logtxt_full_dir     = $$conf{abspath}{diff_logtxt_full_dir};
my $diff_logtxt_dir          = $$conf{abspath}{diff_logtxt_dir};
my $mysql_cmd                = $$conf{which_cmd}{mysql};
my $mysqlbinlog_cmd          = $$conf{which_cmd}{mysqlbinlog};
my $mysqldump_cmd            = $$conf{which_cmd}{mysqldump};
my $hostname                 = $$conf{databases_infos}{hostname};
my $user                     = $$conf{databases_infos}{user};
my $passwd                   = $$conf{databases_infos}{passwd};
my $help                     = "";
my $dump_db_server_dir       = $$conf{abspath}{backup_server_db};
my $backup_diff_server       = $$conf{abspath}{backup_server_diff};
my $generate_triggers_path   = $$conf{path}{generate_triggers};
my $generate_procedures_path = $$conf{path}{generate_procedures};

my $kss_infos_table          = $$conf{databases_infos}{kss_infos_table};
my $kss_status_table         = $$conf{databases_infos}{kss_status_table};
my $kss_logs_table           = $$conf{databases_infos}{kss_logs_table};
my $kss_errors_table         = $$conf{databases_infos}{kss_errors_table};
my $kss_sql_errors_table     = $$conf{databases_infos}{kss_sql_errors_table};
my $kss_statistics_table     = $$conf{databases_infos}{kss_statistics_table};
my $max_borrowers_fieldname  = $$conf{databases_infos}{max_borrowers_fieldname};

my $alertmail                = $$conf{cron}{alertmail};
my $smtpserver               = $$conf{cron}{smtpserver};

# SetLocale and transkation with gettext
use Locale::gettext;
use POSIX;
setlocale(LC_MESSAGES, "fr_FR");

=head2 get_conf

Return hashref contains all data in yaml config file.
All paths in the path section are concatenate with the kss root.
We manipulate absolute path.

=cut
sub get_conf {
    my $koha_dir = C4::Context->config('intranetdir');
    my $kss_dir = "$koha_dir/Koha_Synchronize_System/";
    my $yaml = YAML::LoadFile("$kss_dir/conf/kss.yaml");
    my $conf = {%$yaml};

    my $paths = $$conf{path};
    while ( my ($key, $path) = each %$paths ) {
        $$conf{path}{$key} = $kss_dir . $$conf{path}{$key};
    }
    $$conf{path}{kss_dir} = $kss_dir;
    $$conf{path}{koha_dir} = $koha_dir;

    return $conf;
}

=head2 get_dbh
Returns a database handler with informations in config file.
Argument must be 'server' or 'client'. By default, returns a handler to server
=cut
sub get_dbh {
    my $host = shift || 'server';

    my $conf = get_conf();
    my $db_server = $$conf{databases_infos}{db_server};
    my $db_client = $$conf{databases_infos}{db_client};
    my $hostname = $$conf{databases_infos}{hostname};
    my $user = $$conf{databases_infos}{user};
    my $passwd = $$conf{databases_infos}{passwd};
    
    my $dbh;
    if ( $host eq 'server' ) {
        $dbh = DBI->connect( "DBI:mysql:dbname=$db_server;host=$hostname;", $user, $passwd ) or die $DBI::errstr;
    } elsif ( $host eq 'client' ) {
        $dbh = DBI->connect( "DBI:mysql:dbname=$db_server;host=$hostname;", $user, $passwd ) or die $DBI::errstr;
    }

    $dbh->{'mysql_enable_utf8'} = 1;
    $dbh->do("set NAMES 'utf8'");

    return $dbh;

}


#+--------------------------------------+
#|          Server functions            +
#+--------------------------------------+

=head2 get_archives
Returns arrayref of tar.gz files.
We search in path:server_inbox section
=cut
sub get_archives {
    my $conf = get_conf;
    my $dir = $$conf{abspath}{server_inbox};

    my @files = <$dir/*.tar.gz>;
    return \@files;
}

=head2 backup_server_db
Dumps the current DB
=cut
sub backup_server_db {
    my $log = shift;
    my $conf = get_conf;

    my $user     = $$conf{databases_infos}{user};
    my $passwd   = $$conf{databases_infos}{passwd};
    my $db_server = $$conf{databases_infos}{db_server};
    my $dump_db_server_dir = $$conf{abspath}{backup_server_db};
    my $mysqldump_cmd = $$conf{which_cmd}{mysqldump};

    my $dump_filename = $dump_db_server_dir . "/" . ( strftime "%Y-%m-%d_%H:%M:%S", localtime );
    $log && $log->info("Dump en cours dans $dump_filename");

    system( qq{$mysqldump_cmd -u $user -p$passwd $db_server > $dump_filename} ) == 0 or die $?;
}

=head2 diff_files_exists
Returns 1 if exists at least 1 binary log file else 0
=cut
sub diff_files_exists {
    my $dir = shift;
    my $log = shift;

    my @diff_bin = <$dir/*>;
    if ( scalar( @diff_bin ) > 0 ) {
        $log && $log->info(scalar( @diff_bin) . " fichiers binaires trouvés");
        return 1;
    }

    die "Aucun fichier binaire trouvé dans cette archive, rien ne sert de continuer !";

    return 0;
}

=head2 insert_new_ids
Insert each sql dump file presents in $id_dir.
=cut
sub insert_new_ids {
    my ($user, $pwd, $db_name, $id_dir, $log) = @_;
    my @dump_id = <$id_dir/*>;

    my $conf = get_conf();
    my $mysql_cmd = $$conf{which_cmd}{mysql};

    my $nb_files = scalar(@dump_id);
    system( qq{$mysql_cmd -u $user -p$pwd $db_name -e "CALL PROC_UPDATE_STATUS\('Insert new ids \($nb_files files found\)', 0\);"} ) == 0 or ($log && $log->warning("Can't call PROC_UPDATE_STATUS ($?)"));
    $log && $log->info("$nb_files Fichiers trouvés");

    for my $file ( @dump_id ) {
        chomp $file;
        $log && $log->info("Insertion de $file en cours...");
        system( qq{$mysql_cmd -u $user -p$pwd $db_name < $file} ) == 0 or die "Can't Insert file $file in $db_name DB ($?)";
    }

    system( qq{$mysql_cmd -u $user -p$pwd $db_name -e "CALL PROC_UPDATE_STATUS\('Insert new ids \($nb_files files found\)', 1\);"} ) == 0 or ($log && $log->warning("Can't call PROC_UPDATE_STATUS ($?)"));
}

=head2 insert_proc_and_triggers
Inserts All procedures and triggers in server database.
Call me before kss
=cut
sub insert_proc_and_triggers {
    my ($user, $pwd, $db_name, $log) = @_;
    my $conf = get_conf();
    eval {
        system( qq{$$conf{path}{generate_triggers} > /tmp/triggers.sql} ) == 0 or die "Can't generate triggers ($?)";
        system( qq{$$conf{which_cmd}{mysql} -u $user -p$pwd $db_name < /tmp/triggers.sql} ) == 0 or die "Can't insert triggers ($?)";
        system( qq{$$conf{path}{generate_procedures} > /tmp/procedures.sql} ) == 0 or die "Can't generate procedures ($?)";
        system( qq{$$conf{which_cmd}{mysql} -u $user -p$pwd $db_name < /tmp/procedures.sql} ) == 0 or die "Can't insert procedures ($?)";
    };

    if ( $@ ) {
        die "Can't generate triggers or procedures ($@)";
    }
}

=head2 prepare_database
Call PROC_KSS_START procedure.
It initializes tables and logs.
=cut
sub prepare_database {
    my ($user, $pwd, $db_name, $client_hostname, $log) = @_;

    my $conf = get_conf();
    my $mysql_cmd = $$conf{which_cmd}{mysql};
    system( qq{$mysql_cmd -u $user -p$passwd $db_name -e "CALL PROC_KSS_START('$client_hostname');"} ) == 0 or die "Can't call PROC_KSS_START procedure ($?)";
}

=head2 insert_proc_and_triggers
Drop All procedures and triggers in server database
=cut
sub delete_proc_and_triggers {
    my ($user, $pwd, $db_name, $log) = @_;
    my $conf = get_conf();
    eval {
        system( qq{$$conf{path}{generate_triggers} -action=drop> /tmp/del_triggers.sql} ) == 0 or die "Can't generate drop triggers ($?)";
        system( qq{$$conf{which_cmd}{mysql} -u $user -p$pwd $db_name < /tmp/del_triggers.sql} ) == 0 or die "Can't drop triggers in DB ($?)";
        system( qq{$$conf{path}{generate_procedures} -action=drop> /tmp/del_procedures.sql} ) == 0 or die "Can't generate drop procedures ($?)";
        system( qq{$$conf{which_cmd}{mysql} -u $user -p$pwd $db_name < /tmp/del_procedures.sql} ) == 0 or die "Can't drop procedures in DB ($?)";
    };

    if ( $@ ) {
        die "Can't delete triggers or procedures ($@)";
    }
}

=head2 clean_fs
Delete all temporary files.
Call me when tar.gz processing is done
=cut
sub clean_fs {

    my $conf = get_conf();

    qx{rm -f $$conf{abspath}{diff_logbin_dir}/*};
    qx{rm -f $$conf{abspath}{diff_logtxt_full_dir}/*};
    qx{rm -f $$conf{abspath}{diff_logtxt_dir}/*};
    qx{rm -f $$conf{abspath}{dump_ids}/*};
    qx{rm -f $$conf{abspath}{server_inbox}/hostname};
    qx{rm -Rf $$conf{abspath}{server_inbox}/ids};
    qx{rm -Rf $$conf{abspath}{server_inbox}/logbin};
    qx{mv $$conf{abspath}{server_inbox}/*.tar.gz $$conf{abspath}{backup_server_diff}};

}

=head2 clean
Call PROC_KSS_END procedure.
Drop all temporary tables.
Call me after kss.
=cut
sub clean {
    my ($user, $pwd, $db_name, $log) = @_;

    my $conf = get_conf();
    my $mysql_cmd = $$conf{which_cmd}{mysql};
    $log && $log->info(" - Purge des tables temporaires");
    system( qq{$mysql_cmd -u $user -p$passwd $db_server -e "CALL PROC_KSS_END();"} ) == 0 or die "Can't call PROC_KSS_END ($?)";

    $log && $log->info(" - Suppression en base des triggers et procédures stockées");
    delete_proc_and_triggers $user, $passwd, $db_server, $log;

}

=head2 prepare_next_iteration
Call PROC_CREATE_KSS_INFOS procedure.
Get greatest borrowernumber and reservenumber. Its insert in kss_infos table.
=cut
sub prepare_next_iteration {
    my $log = shift;
    my $dbh = shift || get_dbh;

    $dbh->do("CALL PROC_CREATE_KSS_INFOS()");
}

=head2 dump_available_db
Dump new database and make it available in inbox for client.
=cut
sub dump_available_db {
    my $log = shift;

    my $conf = get_conf;
    my $outbox   = $$conf{abspath}{server_outbox};
    my $hostname = $$conf{databases_infos}{hostname};
    my $user     = $$conf{databases_infos}{user};
    my $passwd   = $$conf{databases_infos}{passwd};
    my $db_server = $$conf{databases_infos}{db_server};
    my $remote_dump_filepath = $$conf{abspath}{server_dump_filepath};

    $log && $log->info("=== Dump de la nouvelle base ===");
    my $dump_filepath = $outbox . "/" . strftime ( "%Y-%m-%d_%H:%M:%S", localtime ) . ".sql";
    $log && $log->info("Dump en cours dans $dump_filepath");
    system( qq{$mysqldump_cmd -u $user -p$passwd $db_server > $dump_filepath} ) == 0 or die "Can't dump '$db_server' DB($?)";
    $log && $log->info("Copie dans le fichier partagé au client ($remote_dump_filepath)");
    system( qq{cp $dump_filepath $remote_dump_filepath} ) == 0 or die "Can't copy dump file";
}


=head2 extract_and_purge_mysqllog
Extract mysql binary log files with mysqllogbin command and purge.
At end, we have sql files contains only queries we want.
=cut
sub extract_and_purge_mysqllog {
    my $bindir  = shift;
    my $fulldir = shift;
    my $txtdir  = shift;
    my $log     = shift;
    my $dbh = shift || get_dbh('server');

    if ( not -d $bindir ) {
        die "Le répertoire des logs binaires mysql ($bindir) n'existe pas !";
    }
    
    my $conf = get_conf();
    my $file_cmd             = $$conf{which_cmd}{file};

    my @files = <$bindir/*>;
    for my $file ( @files ) {
        chomp $file;
	my $filename = basename($file);
        $log && $log->info("--- Traitement du fichier $file ---");
        my $r = qx{$file_cmd $file};
        if ( not $r =~ /MySQL replication log/ ) {
            $log && $log->info("Ce fichier n'est pas un fichier de log sql, il ne peut être géré ($r)");
            next;
        }
        $dbh->do("CALL PROC_UPDATE_STATUS\('Extract and purge file $file', 0\);");

        open(FILE, $file);
        my $ctx = Digest::MD5->new;
        $ctx->addfile(*FILE);
        my $md5 = $ctx->hexdigest;
        close(FILE);

        $dbh->do("CALL PROC_ADD_MD5\('$md5', \@already_exists\);");
        my @already_exists = $dbh->selectrow_array("SELECT \@already_exists;");
        if ( $already_exists[0] ) {
            $log && $log->warning("This file already added !");
            log_error("This file already added !", "Le Fichier binaire de log $file a déjà été inséré lors d'une précédente mise à jour");
	    next;
        }

        my $full_output_filepath = "$fulldir\/$filename";
        my $output_filepath = "$txtdir\/$filename";
        $log && $log->info("Extraction vers $full_output_filepath");
        system( qq{$mysqlbinlog_cmd $file > $full_output_filepath} ) == 0 or die "Can't extract mysql logbin with mysqlbinlog command ($?)";
        
        $log && $log->info("Purge vers $output_filepath");
        Koha_Synchronize_System::tools::mysql::purge_mysql_log ($full_output_filepath, $output_filepath);
        $dbh->do("CALL PROC_UPDATE_STATUS\('Extract and purge file $file', 1\);");
    }
    return 0;
}

=head2 get_level
Get table name level.
Proccess is different fonctions of level.
=cut
sub get_level {
    my $table_name = shift;

    my @tables_level1 = ('borrowers', 'deletedborrowers', 'items');
    my @tables_level2 = ('issues', 'old_issues', 'statistics', 'reserves', 'old_reserves', 'action_logs', 'borrower_attributes');

    if ( grep { $_ eq $table_name } @tables_level1 ) {
        return 1;
    }

    if ( grep { $_ eq $table_name } @tables_level2 ) {
        return 2;
    }

}

=head2 replace_with_new_id
Replace in a sql query old primary key with the new one.
$string is a sql query
=cut
sub replace_with_new_id {
    my $string = shift;
    my $table_name = shift;
    my $field = shift;
    my $dbh = shift;

    if ( $string =~ /$field\s*=\s*\'{0,1}([^']*)\'{0,1}/ ) {
        $dbh->do("CALL PROC_GET_NEW_ID (\"$table_name.$field\", $1, \@new_id);");
        my @value = $dbh->selectrow_array("SELECT \@new_id;");

        my $new_id = $value[0];

        # ex:
        # borrowernumber= 42
        # borrowernumber ='42'
        $string =~ s/$field\s*=\s*\'{0,1}([^']*)\'{0,1}/$field = '$new_id'/;
    }

    return $string;
}

=head2 log_error
log an error in kss errors table.
$error and $message are string
=cut
sub log_error {
    my $error = shift;
    my $message = shift;
    my $dbh = shift || get_dbh;

    $dbh->do(qq{CALL PROC_ADD_ERROR("} . $dbh->quote($error) . qq{", "} . $dbh->quote($message) . qq{");});

}

=head2 insert_diff_file
Insert a sql file which contains queries executed on client.
$file must be a filepath
=cut
sub insert_diff_file {
    my $file = shift;
    my $dbh = shift;
    my $log = shift;
    chomp $file;

    if (not $dbh) {
        $dbh = DBI->connect( "DBI:mysql:dbname=$db_server;host=$hostname;", $user, $passwd ) or die $DBI::errstr;
        $dbh->{'mysql_enable_utf8'} = 1;
        $dbh->do("set NAMES 'utf8'");
    }

    open( FILE, $file ) or die "Le fichier $file ne peut être lu";

    # Separator
    my $sep = "/*!*/;";
    my $oldsep = $/;
    $/ = $sep;

    $dbh->do("CALL PROC_UPDATE_STATUS('Processing file $file', 0);");

    # For each query
    while ( my $query = <FILE> ) {
        my $r;
        next if length($query) <= 1; # It's not a valid query
        my @errors;
        my @warnings;
        my $table_name;
        $query =~ s/^\n//; # First character is a \n
        if ( $query =~ /^INSERT INTO (\S+)/ ) { # INSERT QUERY
            $table_name = $1;
            my $level = get_level $table_name;
            if ( $level == 1 ) {
                # Nothing todo
            } elsif ( $level == 2 ) {
                # For INSERT old_issues SELECT * FROM issues WHERE borrowernumber=xxx [...] format
                $query = replace_with_new_id ( $query, $table_name, 'borrowernumber', $dbh );
                $query = replace_with_new_id ( $query, $table_name, 'reservenumber', $dbh );
            }
        } elsif ( $query =~ /^UPDATE (\S+)/ ) { # UPDATE QUERY
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
        } elsif ( $query =~ /^DELETE\s+FROM\s+(\S+)/ ) { # DELETE QUERY
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


        } else {
            $log && $log->warning("This query is not parsed : ###$query###");
            next;
        }

        $log && $log->info( $query );

        $dbh->do($query); # Execute the query

        @errors = $dbh->selectrow_array(qq{SHOW ERRORS $sep}); # Get errors
        @warnings = $dbh->selectrow_array(qq{SHOW WARNINGS $sep}); # Get warnings

        if ( @errors ) { # Catch specifics errors
            $log && $log->error($errors[0] . ':' . $errors[1] . ' => ' . $errors[2]);
            if ( ( $table_name eq 'biblioitems' or $table_name eq 'items' ) and $errors[0] eq 'Error' and $errors[1] eq '1222' ) {
                $log && $log->error("This query was ignored. It tries to modify $table_name table");
                $dbh->do("CALL PROC_ADD_ERROR('Unauthorized query', 'A query was ignored. It try to modify $table_name table');");
            } elsif ( ( $table_name eq 'issues' ) and $errors[0] eq 'Error' and $errors[1] eq '1452' and $errors[2] =~ /`issues_ibfk_2`/ ) {
                $log && $log->error("This query tries to update a record with a item wich doesn't exist");
                $dbh->do("CALL PROC_ADD_ERROR('Item missing', 'A quer¼y tries to update a record with an item wich doesn\\'t exist');");
            } else {
                $dbh->do("CALL PROC_ADD_SQL_ERROR(\"" . $errors[0] . ":" . $errors[1] . " => " . $errors[2] . "\", " . $dbh->quote($query) . ");");
            }
        } elsif ( @warnings ) {
            if ( $warnings[0] ne 'Note' ) {
                    $log && $log->warning($warnings[0] . ':' . $warnings[1] . ' => ' . $warnings[2]);
                    $dbh->do("CALL PROC_ADD_SQL_ERROR(\"" . $warnings[0] . ":" . $warnings[1] . " => " . $warnings[2] . "\", " . $dbh->quote($query) . ");");
            }
        } else {
            $log && $log->info(" <<< OK >>>")
        }
    }

    close( FILE );

    $dbh->do("CALL PROC_UPDATE_STATUS('Processing file $file', 1);");

    $/ = $oldsep;
}

#+--------------------------------------+
#|          Client functions            +
#+--------------------------------------+

=head2 backup_client_logbin
Create a new tar.gz file with binary mysql log (in /var/log/mysql), hostname and idsD
=cut
sub backup_client_logbin {
    my $log = shift;

    my $conf = get_conf;
    my $service_cmd = $$conf{which_cmd}{service};
    my $hostname_cmd = $$conf{which_cmd}{hostname};
    my $ls_cmd = $$conf{which_cmd}{ls};
    my $cp_cmd = $$conf{which_cmd}{cp};
    my $rm_cmd = $$conf{which_cmd}{rm};
    my $mv_cmd = $$conf{which_cmd}{mv};
    my $chown_cmd = $$conf{which_cmd}{chown};
    my $tar_cmd = $$conf{which_cmd}{tar};
    my $outbox = $$conf{abspath}{client_outbox};
    my $bakdir = $$conf{abspath}{client_backup};
    my $logdir = $$conf{abspath}{client_logbin};
    
    # Generate a filename
    my $filename = strftime "%Y-%m-%d_%H-%M-%S", localtime;
    my $dirname = $outbox . "/" . $filename;

    # Generate ids files
    eval { generate_ids_files("$dirname/ids") };
    die $@ if $@;
    
    # Stop mysql
    system( qq{$service_cmd mysql stop} ) == 0 or die "Can't stop mysql ! ($?)";
    
    # Make directory logbin and ids
    eval {
        make_path "$dirname/logbin";
        make_path "$dirname/ids";
    };
    die "Can't create directory for backup ($@)" if $@;

    # Move binaries
    my @binfiles = qx{sudo $ls_cmd -1 $logdir | grep mysql-bin};
    for my $binfile ( @binfiles ) {
        chomp $binfile;
        qx{sudo $mv_cmd $logdir/$binfile $dirname/logbin/};
    }
    qx{sudo $chown_cmd kss:kss $dirname/logbin -R};

    # Start mysql
    system( qq{$service_cmd mysql start} ) == 0 or die "Can't start mysql ! ($?)";

    # Get hostname
    system( qq{$hostname_cmd -f > $dirname/hostname} ) == 0 or ($log && $log->warning("Can't get hostname from file ($?)"));
    
    # Create archive
    system( qq{cd $dirname; $tar_cmd zcvf $filename.tar.gz logbin ids hostname} ) == 0 or die "Can't create archive ($?)";

    # Move archive to outbox dir
    system( qq{cd $dirname; $mv_cmd $filename.tar.gz $outbox} ) == 0 or die "Can't move archive to outbox ($?)";

    # Move directory to backup dir
    system( qq{$mv_cmd $dirname $bakdir} ) == 0 or die "Can't move directory $dirname to backup dir $bakdir ($?)";

}

=head2 pull_new_db
Get and insert new db from server
=cut
sub pull_new_db {
    my $log = shift;

    my $conf = get_conf;
    my $ssh_cmd                 = $$conf{which_cmd}{ssh};
    my $scp_cmd                 = $$conf{which_cmd}{scp};
    my $mysql_cmd               = $$conf{which_cmd}{mysql};
    my $ip_server               = $$conf{cron}{serverhost};
    my $kss_pl_script           = $$conf{abspath}{server_kss_pl_script};
    my $remote_dump_filepath    = $$conf{abspath}{server_dump_filepath};
    my $local_dump_filepath     = $$conf{abspath}{client_dump_filepath};
    my $username = "kss";

    # If kss.pl is running, we can't continue
    $log && $log->info( "Vérification de la disponibilité d'un nouveau dump" );
    my $status = qx{$ssh_cmd $username\@$ip_server "source .zshrc; perl $kss_pl_script --status"} or die "Can't connect to the server ($?)";
    if ( not $status =~ /is not running/ ){
        $log && $log->error("Le serveur est toujours en cours d'exécution, impossible de récupérer le dump actuellement");
        return 1;
    }

    # Get remote dump
    $log && $log->info( "Récupération du dump distant" );
    system( qq{$scp_cmd $username\@$ip_server:$remote_dump_filepath $local_dump_filepath} ) == 0 or die "Can't get new db from server ($?)";

    # Insert dump
    $log && $log->info( "Insertion dans la base de données locale" );
    system( qq{$mysql_cmd -u $user -p$passwd $db_client < $local_dump_filepath} ) == 0 or die "Can't insert new dump ($?)";
    $log && $log->info( "Suppression des logs binaires (générés par l'insertion)" );
    system( qq{$mysql_cmd -u $user -p$passwd $db_client -e "RESET MASTER;"} ) == 0 or die "Can't delete binaries logs inserted during insertion of dump ($?)";

}

=head2 generate_ids_files
Generate ids files.
Execute .pl in scripts client directory to generate sql files.
=cut
sub generate_ids_files {
    my $outdir = shift;
    my $conf = get_conf;
    my $scripts_dir = $$conf{path}{client_scripts_ids};
    my $perl_cmd = $$conf{which_cmd}{perl};

    qx{mkdir -p $outdir};
    my @scripts = <$scripts_dir/*.pl>;
    for my $script ( @scripts ) {
        chomp $script;
        my $filename = $script;
        $filename =~ s#.*/([^/]*).pl#$1#;
        my $filepath = $outdir . '/' . $filename . '.sql';
        system( qq{$perl_cmd $script > $filepath} ) == 0 or die "Can't gererate file $filepath ($?)";
    }
}


=head2 get_last_log

Return last log (optionally for a given hostname)

Example:

=over

$VAR1 = {
          'end_time' => '2011-04-01 15:52:10',
          'status' => 'End !',
          'progress' => '0',
          'start_time' => '2011-04-01 15:52:02',
          'hostname' => 'ns39793.ovh.net',
          'id' => '9'
        };

=cut
sub get_last_log {
    my $dbh = shift;
    my $hostname = shift;

    my $query = "SELECT * from $kss_logs_table";
    $query .= " WHERE hostname=?" if ($hostname); 
    $query .= " ORDER BY id DESC LIMIT 1";
    my $sth = $dbh->prepare($query);
    ($hostname) ? $sth->execute($hostname) : $sth->execute;
    return $sth->fetchrow_hashref;
}

# Return last execution ids for each client
sub get_last_ids {
    my $dbh = shift;
    my $query = "SELECT MAX(id), hostname from $kss_logs_table GROUP BY hostname ORDER BY hostname";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    return $sth->fetchall_arrayref();
}

=head2 get_last_errors

Returns last errors recorded in kss_error table. During process, some functionnal errors can occurs. (optionally for a given hostname)
=over
Sample record:

 {
    'error' => 'Item already onloan',
    'kss_id' => '9',
    'id' => '24',
    'message' => 'Item 179 is already onloan by another borrower'
  },

=cut
sub get_last_errors {
    my $dbh = shift;
    my $hostname = shift;
    return _get_last_table($dbh, $kss_errors_table, $hostname);
}


=head2 get_last_status

Returns last logs recorded in kss_logs table / last status (optionally for a given hostname)

Status are:
- Cleaning...
- Creating kss_infos table...
- Processing file [...]
- Extract and purge file [...]
- Insert new ids ([...] files found)

=over
Sample record:

{
  'end_time' => '2011-04-01 15:52:10',
  'status' => 'End !',
  'progress' => '0',
  'start_time' => '2011-04-01 15:52:02',
  'hostname' => 'ns39793.ovh.net',
  'id' => '9'
}
=cut
sub get_last_status {
    my $dbh = shift;
    my $hostname = shift;
    return _get_last_table($dbh, $kss_status_table, $hostname);
}

# Return last errors (optionally for a given hostname)
sub get_last_sql_errors {
    my $dbh = shift;
    my $hostname = shift;
    return _get_last_table($dbh, $kss_sql_errors_table, $hostname);
}


=head2 _get_last_table

Return last all last data from a given table (optionally for a given hostname)

=cut
sub _get_last_table {
    my $dbh = shift;
    my $table = shift;
    my $hostname = shift;

    # Getting last id
    my $tmpres = get_last_log($dbh, $hostname);
    my $last = $tmpres->{'id'};

    my $query = "SELECT * from $table WHERE kss_id=? ORDER BY id DESC";
    my $sth = $dbh->prepare($query);
    $sth->execute($last);
    return $sth->fetchall_arrayref({});
}

# Returns last statistics for a given host : number of issues, returns and reserves 
sub get_stats_by_host {
    my $dbh = shift;
    my $host = shift;

    my $results;

    # Getting last id for a given hostname
    my $tmpres = get_last_log($dbh, $host);
    my $last = $tmpres->{'id'};

    for (qw(issue return reserve)) {
	my $query = "SELECT COUNT(*) from $kss_statistics_table WHERE variable=? and kss_id=?";
	my $sth = $dbh->prepare($query);
	$sth->execute($_, $last);
	my $count = $sth->fetchrow_arrayref;
	$results->{$_} = $count->[0];
    }
    return $results;
}

# Returns detailled statistics for a given host : number of issues by itemtype and section
sub get_stats_details {
    my $dbh = shift;
    my $hostname = shift;
    my $doctyperesults;
    my $locationresults;

    # Getting last id for a given hostname
    my $tmpres = get_last_log($dbh, $hostname);
    my $last = $tmpres->{'id'};

    # Getting itemnumbers from the last execution
    my $query = "SELECT itemnumber from $kss_statistics_table WHERE variable=? AND kss_id=?";
    my $sth = $dbh->prepare($query);
    $sth->execute('issue', $last);
    my @items;
    while (my $res = $sth->fetchrow_array()) {
	push @items, $res;
    }
    my $items_str = join(',', @items);
    warn $items_str;

    # Getting by ccode
    #FIXME: Shouldn't be hardcoded
    my $ccodes = C4::Koha::GetAuthorisedValues('CCODE');
    foreach (@$ccodes) {
	my $ccode = $_->{'authorised_value'};
	my $query = "SELECT ccode AS doctype, count(itemnumber) AS value from items where ccode=? AND itemnumber IN ($items_str) HAVING COUNT(itemnumber) > 0";
	my $sth = $dbh->prepare($query);
	$sth->execute($ccode);
	my $result = $sth->fetchrow_hashref();
	push @$doctyperesults, $result if ($result);
	
	
    }
    # Getting by location
    #FIXME: Todo
    return ($doctyperesults,$locationresults);
}

# Return last statistics for all hosts
sub get_stats {
    my $dbh = shift;

    my $results;

    # Getting last ids for each client
    my $ids = get_last_ids($dbh);
    foreach (@{$ids}) {
        $results->{$_->[1]} = get_stats_by_host($dbh, $_->[1]);
    }
    return $results;

}


sub send_alert_mail {

    my $d = Locale::gettext->domain('messages');
    $d->dir("$kss_dir/locale/");

    my $dbh     = C4::Context->dbh;

    my $last_log_result = Koha_Synchronize_System::tools::kss::get_last_log($dbh);
    my $last_errors_result = Koha_Synchronize_System::tools::kss::get_last_errors($dbh);
    my $last_sql_errors_result = Koha_Synchronize_System::tools::kss::get_last_sql_errors($dbh);
    my $stats = Koha_Synchronize_System::tools::kss::get_stats($dbh);

    my $title = $d->get("TITLE_START")." ";
    $title .= $$last_log_result{'status'} eq "End !" ? $d->get("TITLE_MIDDLE")." $$last_log_result{'end_time'}" : $d->get("TITLE_END");
    my $content;
    $content .= "\n".$d->get("SUMMARY_H2")."\n";
    $content .= scalar(@$last_errors_result)." ".$d->get("ERRORS")." - " . scalar(@$last_sql_errors_result) . " ".$d->get("SQL_ERRORS");
    $content .= "\n".$d->get("STATS_H2")."\n";
    foreach (keys %{$stats}) {
        $content .= "- $_: ".$$stats{$_}{reserve}." ".$d->get("RESERVES")." ".$$stats{$_}{return}." ".$d->get("RETURNS")." ".$$stats{$_}{issue}." ".$d->get("ISSUES")." ".$d->get("END_STATS")."\n";
    }

    if (scalar($last_errors_result) != 0) {
        $content .= "\n".$d->get("ERRORS_H2")."\n";
        foreach (@$last_errors_result) {
           $content .= "$$_{'error'} - $$_{'message'}\n";
        }
    }

    if (scalar($last_sql_errors_result) != 0) {
        $content .= "\n";
        foreach (@$last_sql_errors_result) {
           $content .= "$$_{'error'}\n";
        }
    }

    my %mail    = (
          To             => $alertmail,
          From           => $alertmail,
          Subject        => $title,
          Message        => $content,
          smtp           => $smtpserver,
          'Content-Type' => 'text/plain; charset="utf8"',
    );

    sendmail(%mail) or die $Mail::Sendmail::error;

    print "OK. Log says:\n", $Mail::Sendmail::log;

}

1;
