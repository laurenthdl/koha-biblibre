package C4::Update::Database;

use Modern::Perl;

use C4::Context;
use C4::Config::File::YAML;

use File::Basename;
use Digest::MD5;
use List::MoreUtils qw/uniq/;

my $config = C4::Config::File::YAML->new( C4::Context->config("installdir") . qq{/etc/update/database/config.yaml} );
my $VERSIONS_PATH = C4::Context->config('intranetdir') . '/' . $config->{versions_dir};

my $version;
my $list;

my $dbh = C4::Context->dbh;

sub execute_version {
    my ( $version ) = @_;
    my $report;
    my @files = <$VERSIONS_PATH/$version*>;
    if ( scalar @files != 1 ) {
        $$report{$version} = "This version ($version) returned more than one file (or any) corresponding!";
        return $report;
    }
    my @file_infos = fileparse( $files[0], qr/\.[^.]*/ );
    my $extension = $file_infos[2];

    my $filename = $version . $extension;
    my $filepath = $VERSIONS_PATH . '/' . $filename;
    open(FILE, $filepath);
    my $ctx = Digest::MD5->new;
    $ctx->addfile(*FILE);
    my $md5 = $ctx->hexdigest;
    close(FILE);

    my $r = md5_already_exists( $md5 ); # FIXME with grep
    for my $r ( @{ md5_already_exists( $md5 ) } ) {
        $$report{$version} = "This file ( $filename ) still already execute in version " . $$r{version} . " : same md5 (" . $$r{md5} . ")";
        return $report;
    }
    given ( $extension ) {
        when ( /.sql/ ) {
            my $queries = get_queries ( $filepath );
            my $errors = execute ( $queries );
            $$report{$version} = -s $errors ? $errors : "OK";
            set_infos ( $version, $queries, $errors, $md5 );
        }
        when ( /.pl/ ) {
            $$report{$version} = ".pl files is not yet supported";

        }
        default {
            $$report{$version} = "This extension ($extension) is not take into account (only .pl or .sql)";
        }
    }
    return $report;
}

sub list_versions_availables {
    my @versions;
    opendir DH, $VERSIONS_PATH or die "Cannot open directory ($!)";
    my @files = grep { !/^\.\.?$/ and /^.*\.(sql|pl)$/ } readdir DH;
    for my $f ( @files ) {
        my @file_infos = fileparse( $f, qr/\.[^.]*/ );
        push @versions, $file_infos[0];
    }
    @versions = uniq @versions;
    closedir DH;
    return \@versions;
}

sub list_versions_already_knows {
    my $query = qq/ SELECT version, comment, status FROM updatedb_report /;
    my $sth = $dbh->prepare( $query );
    $sth->execute;
    my $versions = $sth->fetchall_arrayref( {} );
    map {
        my $version = $_;
        my @comments = split '\\\n', $$_{comment};
        push @{ $$version{comments} }, { comment => $_ } for @comments;
        delete $$version{comment};
    } @$versions;
    $sth->finish;
    for my $version ( @$versions ) {
        $query = qq/ SELECT query FROM updatedb_query WHERE version = ? /;
        $sth = $dbh->prepare( $query );
        $sth->execute( $$version{version} );
        $$version{queries} = $sth->fetchall_arrayref( {} );
        $sth->finish;
        $query = qq/ SELECT error FROM updatedb_error WHERE version = ? /;
        $sth = $dbh->prepare( $query );
        $sth->execute( $$version{version} );
        $$version{errors} = $sth->fetchall_arrayref( {} );
        $sth->finish;
    }
    return $versions;
}

sub execute {
    my ( $queries ) = @_;
    my @errors;
    for my $query ( @{$$queries{queries}} ) {
        eval {
            check_coherency( $query );
        };
        if ( $@ ) {
            push @errors, $@;
        } else {
            eval {
                $dbh->do( $query );
            };
            push @errors, get_error();
        }
    }
    return \@errors;
}

sub get_tables_name {
    my $sth = $dbh->prepare("SHOW TABLES");
    $sth->execute();
    my @tables;
    while ( my ( $table ) = $sth->fetchrow_array ) {
        push @tables, $table;
    }
    return \@tables;
}
my $tables;
sub check_coherency {
    my ( $query ) = @_;
    $tables = get_tables_name() if not $tables;

    given ( $query ) {
        when ( /CREATE TABLE(?:.*?)? `?(\w+)`?/ ) {
            my $table_name = $1;
            if ( grep { /$table_name/ } @$tables ) {
                die "ERROR Table $table_name already exists";
            }
        }

        when ( /ALTER TABLE *`?(\w+)`? *ADD *(?:COLUMN)? `?(\w+)`?/ ) {
            my $table_name = $1;
            my $column_name = $2;
            next if $column_name =~ /(UNIQUE|CONSTRAINT|INDEX|KEY|FOREIGN)/;
            if ( not grep { /$table_name/ } @$tables ) {
                return "ERROR Table $table_name does not exist";
            } else {
                my $sth = $dbh->prepare( "DESC $table_name $column_name" );
                my $rv = $sth->execute;
                if ( $rv > 0 ) {
                    die "ERROR Field $table_name.$column_name already exists";
                }
            }
        }

        when ( /INSERT INTO `?(\w+)`?.*?VALUES *\((.*?)\)/ ) {
            my $table_name = $1;
            my @values = split /,/, $2;
            s/^ *'// foreach @values;
            s/' *$// foreach @values;
            given ( $table_name ) {
                when ( /systempreferences/ ) {
                    my $syspref = $values[0];
                    my $sth = $dbh->prepare( "SELECT COUNT(*) FROM systempreferences WHERE variable = ?" );
                    $sth->execute( $syspref );
                    if ( ( my $count = $sth->fetchrow_array ) > 0 ) {
                        die "ERROR Syspref $syspref already exists";
                    }
                }

                when ( /permissions/){
                    my $module_bit = $values[0];
                    my $code = $values[1];
                    my $sth = $dbh->prepare( "SELECT COUNT(*) FROM permissions WHERE module_bit = ? AND code = ?" );
                    $sth->execute($module_bit, $code);
                    if ( ( my $count = $sth->fetchrow_array ) > 0 ) {
                        die "ERROR Permission $code already exists";
                    }
                }
            }
        }
    }
    return 1;
}

sub get_error {
    my @errors = $dbh->selectrow_array(qq{SHOW ERRORS}); # Get errors
    my @warnings = $dbh->selectrow_array(qq{SHOW WARNINGS}); # Get warnings
    if ( @errors ) { # Catch specifics errors
        return qq{$errors[0] : $errors[1] => $errors[2]};
    } elsif ( @warnings ) {
        return qq{$warnings[0] : $warnings[1] => $warnings[2]}
            if $warnings[0] ne 'Note';
    }
    return;
}

sub get_queries {
    my ( $filename ) = @_;
    open my $fh, "<", $filename;
    my @queries;
    my @comments;
    my $delimiter = $/;
    my $old_delimiter;
    while ( <$fh> ) {
        my $line = $_;
        chomp $line;
        $line =~ s/^\s*//;
        if ( $line =~ s/^--(.*)$// ) {
            warn "comment=$1";
            push @comments, $1;
            next;
        }
        if ( $line =~ /^delimiter (.*)$/i ) {
            warn "delimiter=$1";
            $delimiter = $1;
            $/ = $delimiter;
            next;
        }
        warn "query=$line";
        $line =~ s/$delimiter//;
        push @queries, $line if not $line =~ /^\s*$/; # Push if query is not empty
    }
    $/ = $old_delimiter;
    close $fh;

    return { queries => \@queries, comments => \@comments };
}

sub md5_already_exists {
    my ( $md5 ) = @_;
    my $query = qq/SELECT version, md5 FROM updatedb_report WHERE md5 = ?/;
    my $sth = $dbh->prepare( $query );
    $sth->execute( $md5 );
    my @r;
    while ( my ( $version, $md5 ) = $sth->fetchrow ) {
        push @r, { version => $version, md5 => $md5 };
    }
    $sth->finish;
    return \@r;
}

sub set_infos {
    my ( $version, $queries, $errors, $md5 ) = @_;
    #SetVersion($DBversion) if not -s $errors;
    for my $query ( @{ $$queries{queries} } ) {
        my $sth = $dbh->prepare("INSERT INTO updatedb_query(version, query) VALUES (?, ?)");
        $sth->execute( $version, $query );
        $sth->finish;
    }
    for my $error ( @$errors ) {
        my $sth = $dbh->prepare("INSERT INTO updatedb_error(version, error) VALUES (?, ?)");
        $sth->execute( $version, $error );
    }
    my $sth = $dbh->prepare("INSERT INTO updatedb_report(version, md5, comment, status) VALUES (?, ?, ?, ?)");
    $sth->execute(
        $version,
        $md5,
        join ('\n', @{ $$queries{comments} }),
        ( @$errors > 0 ) ? 0 : 1
    );
}

=item TransformToNum

  Transform the Koha version from a 4 parts string
  to a number, with just 1 .

=cut

sub TransformToNum {
    my $version = shift;

    # remove the 3 last . to have a Perl number
    $version =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
    return $version;
}

sub SetVersion {
    my $kohaversion = TransformToNum(shift);
    if ( C4::Context->preference('Version') ) {
        my $finish = $dbh->prepare("UPDATE systempreferences SET value=? WHERE variable='Version'");
        $finish->execute($kohaversion);
    } else {
        my $finish = $dbh->prepare(
"INSERT IGNORE INTO systempreferences (variable,value,explanation) values ('Version',?,'The Koha database version. WARNING: Do not change this value manually, it is maintained by the webinstaller')"
        );
        $finish->execute($kohaversion);
    }
}

1;
