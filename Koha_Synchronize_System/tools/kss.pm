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
my $kss_sql_errors_table     = $$conf{databases_infos}{kss_sql_errors_table};
my $kss_statistics_table     = $$conf{databases_infos}{kss_statistics_table};
my $max_borrowers_fieldname  = $$conf{databases_infos}{max_borrowers_fieldname};

my $alertmail                = $$conf{cron}{alertmail};
my $smtpserver               = $$conf{cron}{smtpserver};

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
    $$conf{path}{koha_dir} = $koha_dir;

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

    my @files = <$dir/*.tar.gz>;
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

    system( qq{$mysqldump_cmd -u $user -p$passwd $db_server > $dump_filename} ) == 0 or die $!;
}

sub backup_client_logbin {
    my $log = shift;
    my $conf = get_conf;
    my $service_cmd = $$conf{which_cmd}{service};
    my $hostname_cmd = $$conf{which_cmd}{hostname};
    my $cp_cmd = $$conf{which_cmd}{cp};
    my $rm_cmd = $$conf{which_cmd}{rm};
    my $mv_cmd = $$conf{which_cmd}{mv};
    my $tar_cmd = $$conf{which_cmd}{tar};
    my $outbox = $$conf{path}{client_outbox};
    my $bakdir = $$conf{path}{client_backup};
    my $logdir = $$conf{abspath}{client_logbin};
    
    my $filename = strftime "%Y-%m-%d_%H-%M-%S", localtime;
    my $dirname = $outbox . "/" . $filename;
    eval { generate_ids_files("$dirname/ids") };
    die $@ if $@;
    
    system( qq{$service_cmd mysql stop} ) == 0 or die "Can't stop mysql ! ($!)";
    
    eval {
        make_path "$dirname/logbin";
        make_path "$dirname/ids";
    };
    die "Can't create directory for backup ($@)" if $@;

    eval {
        qx{$cp_cmd $logdir/mysql-bin.* $dirname/logbin};
        qx{$rm_cmd -f $logdir/mysql-bin.*};
    };
    die "Can't move mysql-bin ($@)" if $@;

    system( qq{$service_cmd mysql start} ) == 0 or die "Can't start mysql ! ($!)";
     
    system( qq{$hostname_cmd -f > $dirname/hostname} ) == 0 or ($log && $log->warning("Can't get hostname from file ($!)"));
    
    system( qq{cd $dirname; $tar_cmd zcvf $filename.tar.gz logbin ids hostname} ) == 0 or die "Cant' extract archive ($!)";

    system( qq{cd $dirname; $mv_cmd $filename.tar.gz $outbox} ) == 0 or die "Can't move archive to outbox ($!)";

    system( qq{$mv_cmd $dirname $bakdir} ) == 0 or die "Can't move directory $dirname to backup dir $bakdir ($!)";

}

sub pull_new_db {
    my $log = shift;
    my $conf = get_conf;
    my $ssh_cmd                 = $$conf{which_cmd}{ssh};
    my $scp_cmd                 = $$conf{which_cmd}{scp};
    my $mysql_cmd               = $$conf{which_cmd}{mysql};
    my $ip_server               = $$conf{cron}{serverhost};
    my $kss_dir                 = $$conf{path}{kss_dir};
    my $remote_dump_filepath    = $$conf{abspath}{server_dump_filepath};
    my $local_dump_filepath     = $$conf{path}{client_dump_filepath};
    my $username = "kss";

    $log && $log->info(" Vérification de la disponibilité d'un nouveau dump" );
    my $status = qx{$ssh_cmd $username\@$ip_server perl $kss_dir/tools/kss.pl --status} or die "Can't connect to the server ($!)";
    if ( $status == 1 ){
        $log && $log->error("Le serveur est toujours en cours d'exécution, impossible de récupérer le dump actuellement");
        return 1;
    }
    $log && $log->info( "Récupération du dump distant" );
    system( qq{$scp_cmd $username\@$ip_server:$remote_dump_filepath $local_dump_filepath} ) == 0 or die "Can't get new db from server ($!)";

    $log && $log->info( "Insertion dans la base de données locale" );
    system( qq{$mysql_cmd -u $user -p$passwd $db_client < $local_dump_filepath} ) == 0 or die "Can't insert new dump ($!)";
}
sub generate_ids_files {
    my $outdir = shift;
    my $conf = get_conf;
    my $scripts_dir = $$conf{path}{client_scripts_ids};
    my $perl_cmd = $$conf{which_cmd}{perl};

    my @scripts = <$scripts_dir/*.pl>;
    for my $script ( @scripts ) {
        chomp $script;
        my $filename = $script;
        $filename =~ s#.*/([^/]*).pl#$1#;
        my $filepath = $outdir . '/' . $filename . '.sql';
        system( qq{$perl_cmd $script > $filepath} ) == 0 or die "Can't gererate file $filepath ($!)";
    }
}

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

sub insert_new_ids {
    my ($user, $pwd, $db_name, $id_dir, $log) = @_;
    my @dump_id = <$id_dir/*>;

    my $conf = get_conf();
    my $mysql_cmd = $$conf{which_cmd}{mysql};

    my $nb_files = scalar(@dump_id);
    system( qq{$mysql_cmd -u $user -p$pwd $db_name -e "CALL PROC_UPDATE_STATUS\('Insert new ids \($nb_files files found\)', 0\);"} ) == 0 or ($log && $log->warning("Can't call PROC_UPDATE_STATUS ($!)"));
    $log && $log->info("$nb_files Fichiers trouvés");

    for my $file ( @dump_id ) {
        chomp $file;
        $log && $log->info("Insertion de $file en cours...");
        system( qq{$mysql_cmd -u $user -p$pwd $db_name < $id_dir/$file} ) == 0 or die "Can't Insert file $id_dir/$file in $db_name DB ($!)";
    }

    system( qq{$mysql_cmd -u $user -p$pwd $db_name -e "CALL PROC_UPDATE_STATUS\('Insert new ids \($nb_files files found\)', 1\);"} ) == 0 or ($log && $log->warning("Can't call PROC_UPDATE_STATUS ($!)"));
}

sub insert_proc_and_triggers {
    my ($user, $pwd, $db_name, $log) = @_;
    my $conf = get_conf();
    eval {
        system( qq{$$conf{path}{generate_triggers} > /tmp/triggers.sql} ) or die $!;
        system( qq{$$conf{which_cmd}{mysql} -u $user -p$pwd $db_name < /tmp/triggers.sql} ) == 0 or die $!;
        system( qq{$$conf{path}{generate_procedures} > /tmp/procedures.sql} ) == 0 or die $!;
        system( qq{$$conf{which_cmd}{mysql} -u $user -p$pwd $db_name < /tmp/procedures.sql} ) == 0 or die $!;
    };

    if ( $@ ) {
        die "Can't generate triggers or procedures ($@)";
    }
}

sub prepare_database {
    my ($user, $pwd, $db_name, $client_hostname, $log) = @_;

    my $conf = get_conf();
    my $mysql_cmd = $$conf{which_cmd}{mysql};
    system( qq{$mysql_cmd -u $user -p$passwd $db_name -e "CALL PROC_KSS_START('$client_hostname');"} ) == 0 or die "Can't call PROC_KSS_START procedure ($!)";
}

sub delete_proc_and_triggers {
    my ($user, $pwd, $db_name, $log) = @_;
    my $conf = get_conf();
    eval {
        system( qq{$$conf{path}{generate_triggers} -action=drop> /tmp/del_triggers.sql} ) or die $!;
        system( qq{$$conf{which_cmd}{mysql} -u $user -p$pwd $db_name < /tmp/del_triggers.sql} ) == 0 or die $!;
        system( qq{$$conf{path}{generate_procedures} -action=drop> /tmp/del_procedures.sql} ) == 0 or die $!;
        system( qq{$$conf{which_cmd}{mysql} -u $user -p$pwd $db_name < /tmp/del_procedures.sql} ) == 0 or die $!;
    };

    if ( $@ ) {
        die "Can't delete triggers or procedures ($@)";
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
    my ($user, $pwd, $db_name, $log) = @_;

    my $conf = get_conf();
    my $mysql_cmd = $$conf{which_cmd}{mysql};
    $log && $log->info(" - Purge des tables temporaires");
    system( qq{$mysql_cmd -u $user -p$passwd $db_server -e "CALL PROC_KSS_END();"} ) == 0 or die "Can't call PROC_KSS_END ($!)";

    $log && $log->info(" - Suppression en base des triggers et procédures stockées");
    delete_proc_and_triggers $user, $passwd, $db_server, $log;

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
    system( qq{$mysqldump_cmd -u $user -p$passwd $db_server > $dump_filepath} ) == 0 or die "Can't dump '$db_server' DB($!)";
    $log && $log->info("Copie dans le fichier partagé au client ($remote_dump_filepath)");
    system( qq{cp $dump_filepath $remote_dump_filepath} ) == 0 or die "Can't copy dump file";
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

    my @files = <$bindir/*>;
    for my $file ( @files ) {
        chomp $file;
        my $bin_filepath = "$bindir\/$file";
        $log && $log->info("--- Traitement du fichier $file ---");
        my $r = system( qq{$file_cmd $bin_filepath} );
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
        system( qq{$mysqlbinlog_cmd $bin_filepath > $full_output_filepath} ) == 0 or die "Can't extract mysql logbin with mysqlbinlog command ($!)";
        
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

sub send_alert_mail {

    my $dbh     = C4::Context->dbh;

    my $last_log_result = Koha_Synchronize_System::tools::kss::get_last_log($dbh);
    my $last_errors_result = Koha_Synchronize_System::tools::kss::get_last_errors($dbh);
    my $last_sql_errors_result = Koha_Synchronize_System::tools::kss::get_last_sql_errors($dbh);
    my $stats = Koha_Synchronize_System::tools::kss::get_stats($dbh);

    my $title   = "Koha Synchronize System: Last synchronization ".($$last_log_result{'status'} eq "End !" ? "ends at $$last_log_result{'end_time'}" : "does not finished");
    my $content;
    $content .= "\nSummary for the last synchronization:\n";
    $content .= scalar(@$last_errors_result) . " errors - " . scalar(@$last_sql_errors_result) . " sql errors";
    $content .= "\nStats:\n";
    foreach (keys %{$stats}) {
        $content .= "- $_: $$stats{$_}{reserve} reserve(s) $$stats{$_}{return} return(s) $$stats{$_}{issue} issue(s) processed\n";
    }

    if (scalar($last_errors_result) != 0) {
        $content .= "\nErrors to process:\n";
        foreach (@$last_errors_result) {
           $content .= "$$_{'error'} - $$_{'message'}\n";
        }
    }

    if (scalar($last_sql_errors_result) != 0) {
        $content .= "\nSql Errors to process:\n";
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
