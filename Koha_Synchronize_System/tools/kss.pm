package Koha_Synchronize_System::tools::kss;

use Modern::Perl;
use DBI;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;
use DateTime;
use POSIX qw(strftime);
use YAML;
use Digest::MD5;
use Cwd;
use C4::Context;
use Koha_Synchronize_System::tools::mysql;

my $conf                     = get_conf();
my $kss_dir                  = $$conf{path}{kss_dir};
my $db_client                = $$conf{databases_infos}{db_client};
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
my $help                     = "";
my $dump_db_server_dir       = $$conf{path}{backup_server_db};
my $backup_diff_server       = $$conf{path}{backup_server_diff};
my $generate_triggers_path   = $$conf{path}{generate_triggers};
my $generate_procedures_path = $$conf{path}{generate_procedures};

my $kss_infos_table          = $$conf{databases_infos}{kss_infos_table};
my $kss_status_table         = $$conf{databases_infos}{kss_status_table};
my $kss_logs_table           = $$conf{databases_infos}{kss_logs_table};
my $kss_errors_table         = $$conf{databases_infos}{kss_errors_table};
my $kss_statistics_table     = $$conf{databases_infos}{kss_statistics_table};
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

sub get_conf {
    my $koha_dir = C4::Context->config('intranetdir');
    my $kss_dir = "$koha_dir/Koha_Synchronize_System/";
    my $yaml = YAML::LoadFile("$kss_dir/conf/kss.yaml");
    my $conf = {%$yaml};

    my $paths = $$conf{path};
    while ( my ($key, $path) = each %$paths ) {
        if ( $key ne 'kss_root' ) {
            $$conf{path}{$key} = $kss_dir . $$conf{path}{$key};
        }
    }
    $$conf{path}{kss_dir} = $kss_dir;

    return $conf;
}

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

sub get_archives {
    my $conf = get_conf;
    my $dir = $$conf{path}{server_inbox};

    my @files = qx{ls -1 $dir/*.tar.gz};
    return \@files;
}

sub backup_server_db {
    my $log = shift;
    my $conf = get_conf;

    my $user     = $$conf{databases_infos}{user};
    my $passwd   = $$conf{databases_infos}{passwd};
    my $db_server = $$conf{databases_infos}{db_server};
    my $dump_db_server_dir = $$conf{path}{backup_server_db};
    my $mysqldump_cmd = $$conf{which_cmd}{mysqldump};

    my $dump_filename = $dump_db_server_dir . "/" . ( strftime "%Y-%m-%d_%H:%M:%S", localtime );
    $log && $log->info("Dump en cours dans $dump_filename");
    qx{$mysqldump_cmd -u $user -p$passwd $db_server > $dump_filename};
}

sub backup_client_logbin {
    my $log = shift;
    my $conf = get_conf;
    my $service_cmd = $$conf{which_cmd}{service};
    my $hostname_cmd = $$conf{which_cmd}{hostname};
    my $mkdir_cmd = $$conf{which_cmd}{mkdir};
    my $cp_cmd = $$conf{which_cmd}{cp};
    my $rm_cmd = $$conf{which_cmd}{rm};
    my $mv_cmd = $$conf{which_cmd}{mv};
    my $tar_cmd = $$conf{which_cmd}{tar};
    my $outbox = $$conf{path}{client_outbox};
    my $bakdir = $$conf{path}{client_backup};
    my $logdir = $$conf{abspath}{client_logbin};
    
#    eval { qx{$service_cmd mysql stop} };
##    die $@ if $@;
#
#    my $id = strftime "%Y-%m-%d_%H-%M-%S", localtime;
#    my $dirname = $outbox . "/" . $id;
#    
#    eval { qx{$mkdir_cmd $dirname/logbin -p} };
#    die $@ if $@;
#
#    eval { qx{$mkdir_cmd $dirname/ids -p} };
#    die $@ if $@;
#
#    eval { qx{$cp_cmd $logdir/mysql-bin.* $dirname/logbin} };
#    die $@ if $@;
#
#    eval { qx{$rm_cmd -f $logdir/mysql-bin.*} };
#    die $@ if $@;
#
##    eval { qx{$service_cmd mysql start} };
#    die $@ if $@;     

    eval {
        qx{$service_cmd mysql stop};
    };
    if ( $? != 0 ) {
        die "Can't stop mysql";
    }
    
    my $id = strftime "%Y-%m-%d_%H-%M-%S", localtime;
    my $dirname = $outbox . "/" . $id;
    eval {
        qx{$mkdir_cmd $dirname/logbin -p};
        qx{$mkdir_cmd $dirname/ids -p};
    };
    if ( $? != 0 ) {
        die "Can't create directory for backup";
    }
    qx{$cp_cmd $logdir/mysql-bin.* $dirname/logbin};
    qx{$rm_cmd -f $logdir/mysql-bin.*};

    eval {
        qx{$service_cmd mysql start};
    };
    if ( $? != 0 ) {
        die "Can't start mysql";
    }
     
    my $cwd = getcwd;
    eval { qx{$hostname_cmd -f > $dirname/hostname} };
    die $@ if $@;
    
    eval { generate_ids_files("$dirname/ids") };
    die $@ if $@;
    
    eval { chdir $dirname };
    die $@ if $@;
    
    eval { qx{$tar_cmd zcvf $id.tar.gz logbin ids hostname} };
    die $@ if $@;

    eval { qx{$mv_cmd $id.tar.gz $outbox} };
    die $@ if $@;

    chdir $cwd;

    eval { qx{$mv_cmd $dirname $bakdir} };
    die $@ if $@;

}

sub generate_ids_files {
    my $outdir = shift;
    my $conf = get_conf;
    my $scripts_dir = $$conf{path}{client_scripts_ids};
    my $perl_cmd = $$conf{which_cmd}{perl};

    my @scripts = qx{ls -1 $scripts_dir/*.pl};
    for my $script ( @scripts ) {
        chomp $script;
        my $filename = $script;
        $filename =~ s#.*/([^/]*).pl#$1#;
        my $filepath = $outdir . '/' . $filename . '.sql';
        qx{$perl_cmd $script > $filepath};
    }
}

sub diff_files_exists {
    my $dir = shift;
    my $log = shift;

    my @diff_bin = qx{ls -1 $dir};
    if ( scalar( @diff_bin ) > 0 ) {
        $log && $log->info(scalar( @diff_bin) . " fichiers binaires trouvés");
        return 1;
    }

    die "Aucun fichier binaire trouvé dans cette archive, rien ne sert de continuer !";

    return 0;
}

sub insert_new_ids {
    my ($mysql_cmd, $user, $pwd, $db_name, $id_dir, $log) = @_;
    my @dump_id = qx{ls -1 $id_dir};

    my $nb_files = scalar(@dump_id);
    qx{$mysql_cmd -u $user -p$pwd $db_name -e "CALL PROC_UPDATE_STATUS\('Insert new ids \($nb_files files found\)', 0\);"};
    $log && $log->info("$nb_files Fichiers trouvés");
    for my $file ( @dump_id ) {
        chomp $file;
        $log && $log->info("Insertion de $file en cours...");
        qx{$mysql_cmd -u $user -p$pwd $db_name < $id_dir/$file};
    }
    qx{$mysql_cmd -u $user -p$pwd $db_name -e "CALL PROC_UPDATE_STATUS\('Insert new ids \($nb_files files found\)', 1\);"};
}

sub insert_proc_and_triggers {
    my ($user, $pwd, $db_name, $log) = @_;
    my $conf = get_conf();
    eval {
        qx{$$conf{path}{generate_triggers} > /tmp/triggers.sql};
        qx{$$conf{which_cmd}{mysql} -u $user -p$pwd $db_name < /tmp/triggers.sql};
        qx{$$conf{path}{generate_procedures} > /tmp/procedures.sql};
        qx{$$conf{which_cmd}{mysql} -u $user -p$pwd $db_name < /tmp/procedures.sql};
    };

    if ( $@ ) {
        die $@;
    }
}

sub prepare_database {
    my ($mysql_cmd, $user, $pwd, $db_name, $client_hostname, $log) = @_;
    qx{$mysql_cmd -u $user -p$passwd $db_name -e "CALL PROC_KSS_START('$client_hostname');"};
}

sub delete_proc_and_triggers {
    my ($mysql_cmd, $user, $pwd, $db_name, $log) = @_;
    my $conf = get_conf();
    eval {
        qx{$$conf{path}{generate_triggers} -action=drop > /tmp/del_triggers.sql};
        qx{$mysql_cmd -u $user -p$pwd $db_name < /tmp/del_triggers.sql};
        qx{$$conf{path}{generate_procedures} -action=drop > /tmp/del_procedures.sql};
        qx{$mysql_cmd -u $user -p$pwd $db_name < /tmp/del_procedures.sql};
    };

    if ( $@ ) {
        die $@;
    }

}
sub clean_fs {

    my $conf = get_conf();

    qx{rm -f $$conf{path}{diff_logbin_dir}/*};
    qx{rm -f $$conf{path}{diff_logtxt_full_dir}/*};
    qx{rm -f $$conf{path}{diff_logtxt_dir}/*};
    qx{rm -f $$conf{path}{dump_ids}/*};
    qx{rm -f $$conf{path}{server_inbox}/hostname};
    qx{rm -Rf $$conf{path}{server_inbox}/ids};
    qx{rm -Rf $$conf{path}{server_inbox}/logbin};
    qx{mv $$conf{path}{server_inbox}/*.tar.gz $$conf{path}{backup_server_diff}};

}

sub clean {
    my ($mysql_cmd, $user, $pwd, $db_name, $log) = @_;

    $log && $log->info(" - Purge des tables temporaires");
    qx{$mysql_cmd -u $user -p$passwd $db_server -e "CALL PROC_KSS_END();"};

    $log && $log->info(" - Suppression en base des triggers et procédures stockées");
    delete_proc_and_triggers $mysql_cmd, $user, $passwd, $db_server, $log;

}

sub prepare_next_iteration {
    my $log = shift;
    my $dbh = shift || get_dbh;

    $dbh->do("CALL PROC_CREATE_KSS_INFOS()");
}

sub dump_available_db {
    my $log = shift;

    my $conf = get_conf;
    my $outbox   = $$conf{path}{server_outbox};
    my $hostname = $$conf{databases_infos}{hostname};
    my $user     = $$conf{databases_infos}{user};
    my $passwd   = $$conf{databases_infos}{passwd};
    my $db_server = $$conf{databases_infos}{db_server};
    my $remote_dump_filepath = $$conf{abspath}{server_dump_filepath};

    $log && $log->info("=== Dump de la nouvelle base ===");
    my $dump_filepath = $outbox . "/" . strftime ( "%Y-%m-%d_%H:%M:%S", localtime ) . ".sql";
    $log && $log->info("Dump en cours dans $dump_filepath");
    qx{$mysqldump_cmd -u $user -p$passwd $db_server > $dump_filepath};
    $log && $log->info("Copie dans le fichier partagé au client ($remote_dump_filepath)");
    qx{cp $dump_filepath $remote_dump_filepath};
}

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

    my @files = qx{ls -1 $bindir};
    for my $file ( @files ) {
        chomp $file;
        my $bin_filepath = "$bindir\/$file";
        $log && $log->info("--- Traitement du fichier $file ---");
        my $r = qx{$file_cmd $bin_filepath};
        if ( not $r =~ /MySQL replication log/ ) {
            $log && $log->info("Ce fichier n'est pas un fichier de log sql, il ne peut être géré");
            next;
        }
        $dbh->do("CALL PROC_UPDATE_STATUS\('Extract and purge file $file', 0\);");

        open(FILE, $bin_filepath);
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

        my $full_output_filepath = "$fulldir\/$file";
        my $output_filepath = "$txtdir\/$file";
        $log && $log->info("Extraction vers $full_output_filepath");
        qx{$mysqlbinlog_cmd $bin_filepath > $full_output_filepath};
        
        $log && $log->info("Purge vers $output_filepath");
        Koha_Synchronize_System::tools::mysql::purge_mysql_log ($full_output_filepath, $output_filepath);
        $dbh->do("CALL PROC_UPDATE_STATUS\('Extract and purge file $file', 1\);");
    }
    return 0;
}

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

sub get_last_errors {
    my $dbh = shift;
    return _get_last_table($dbh, $kss_errors_table);
}

sub get_last_status {
    my $dbh = shift;
    return _get_last_table($dbh, $kss_status_table);
}


sub _get_last_table {
    my $dbh = shift;
    my $table = shift;

    # Getting last id
    my $tmpres = get_last_log($dbh);
    my $last = $tmpres->{'id'};

    my $query = "SELECT * from $table WHERE kss_id=? ORDER BY id DESC";
    my $sth = $dbh->prepare($query);
    $sth->execute($last);
    return $sth->fetchall_arrayref({});
}


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

sub log_error {
    my $error = shift;
    my $message = shift;
    my $dbh = shift || get_dbh;

    $dbh->do(qq{CALL PROC_ADD_ERROR("} . $dbh->quote($error) . qq{", "} . $dbh->quote($message) . qq{");});

}

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

    my $sep = "/*!*/;";
    my $oldsep = $/;
    $/ = $sep;

   
   $dbh->do("CALL PROC_UPDATE_STATUS('Processing file $file', 0);");

    while ( my $query = <FILE> ) {
        my $r;
        next if length($query) <= 1;
        my @errors;
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
                $query = replace_with_new_id ( $query, $table_name, 'reservenumber', $dbh );
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
        } elsif ( $query =~ /^DELETE\s+FROM\s+(\S+)/ ) {
            $table_name = $1;
            my $level = get_level $1;
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

        $dbh->do($query);

        @errors = $dbh->selectrow_array(qq{SHOW ERRORS $sep});
        @warnings = $dbh->selectrow_array(qq{SHOW WARNINGS $sep});

        if ( @errors ) {
	    $log && $log->error($errors[0] . ':' . $errors[1] . ' => ' . $errors[2]);
            if ( ( $table_name eq 'biblioitems' or $table_name eq 'items' ) and $errors[0] eq 'Error' and $errors[1] eq '1222' ) {
                $log && $log->error("This query was ignored. It try to modify $table_name table");
                $dbh->do("CALL PROC_ADD_ERROR('Unauthorized query', 'A query was ignored. It try to modify $table_name table');");
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
1;
