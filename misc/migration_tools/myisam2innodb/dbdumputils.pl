#!/usr/bin/perl

use Modern::Perl;
use Getopt::Long;
use Data::Dumper;
use POSIX qw(strftime);

my ( $dumpdir, $savedir, $schema, $db, $user, $pass, $import, $export, $dump, $reset, $create, $want_help );
GetOptions(
    'dd:s' => \$dumpdir,
    'sd:s' => \$savedir,
    's|schema:s' => \$schema,
    'db:s' => \$db,
    'u:s' => \$user,
    'p:s' => \$pass,
    'i|import' => \$import,
    'e|export' => \$export,
    'd|dump' => \$dump,
    'r|reset' => \$reset,
    'c|create' => \$create,
    'h|help' => \$want_help,
);

&import_db($dumpdir,$db, $user, $pass) if ($dumpdir && $import);
&export_data($savedir, $db, $user, $pass) if ($savedir && $export);
&import_newdata($savedir,$db, $schema, $user, $pass) if ($savedir && $import && $schema);

&print_help if ($want_help);
&dump_db($db, $user, $pass, $savedir) if ($dump && $savedir);
&drop_db($db, $user,$pass) if ($reset && $user && $pass);
&create_db($db, $user, $pass) if ($create);

sub dump_db {
    my ($db,$user,$pass,$savedir) = @_;
    my $today = strftime "%F", localtime;
    print "mysqldump -u $user -p $db | gzip -v > $savedir/$today-$db.sql.gz\n";
    eval {
        qx{ mysqldump -u $user -p$pass $db | gzip -v > $savedir/$today-$db.sql.gz };
    };
    if ($@) {
        warn $@;
    } else {
        print "Database $db dumped in $savedir/$today-$db.sql.gz\n";
    }
}

sub drop_db {
    my ($db,$user,$pass) = @_;
    print "mysql -u $user -p -N -e \"DROP database $db\"\n";
    qx{ mysql -u $user -p$pass -N -e "DROP database $db" } ;
}

sub create_db {
    my ($db, $user, $pass) = @_;
    print "mysql -u $user -p -N -e \"CREATE DATABASE $db CHARACTER SET utf8 COLLATE utf8_bin;\"\n";
    qx{ mysql -u $user -p$pass -N -e "CREATE DATABASE $db CHARACTER SET utf8 COLLATE utf8_bin;" };
}

sub import_db {
    my ($dir,$db, $user, $pass) = @_;
    eval {
        my @files = <$dir/*.gz>;
        for my $dump ( @files ) {
            chomp $dump;
            print "$dump importing...\n";
            system( qq{gunzip < $dump | mysql -u $user -p$pass $db} );
        }
    };
    if ($@) {
        warn "ERROR: an error occured during import_db $dir in $db";
        warn $@;
    }
}

sub import_newdata {
    my ($savedir, $db, $schema, $user, $pass) = @_;
    eval {
        print "mysql -u $user -p $db < $schema - in progress...";
        system ( qq{ mysql -u $user -p$pass $db < $schema } );
        &import_db($savedir, $db, $user, $pass);
    };
    if ($@) {
        warn "ERROR: an error occured during import_newdata $savedir and $schema in $db";
        warn $@;
    }
}

sub export_data {
    my ($savedir, $db, $user, $pass) = @_;
    eval {
        my @tables = qx{ mysql $db -u $user -p$pass -N -e "SHOW tables" } ;
        my $today = strftime "%F", localtime;
        for my $table (@tables) {
            chomp $table;
            print "$table exporting...\n";
            system (qq{ mysqldump $db -c -t -u $user -p$pass $table | gzip -v > $savedir/$table-$today.gz });
        }
    };
    if ($@) {
        warn "ERROR: an error occured during export_data $savedir in $db";
        warn $@;
    }
}

sub print_help {
    print <<_USAGE_;
$0: database tools ex: rewrite a new database in a new format
    -dd <dump_dir>           directory where tables.sql.gz are contained (with -i)
    -sd <save_dir>           directory to save files (with -e)
    -s <schema>              database schema to import (with -i)
    -db <database_name>      database name to use with all options
    -u <sgbd_user>
    -p <sgbd_pass>
    -i or --import           option provides import (new data or current dumps)
    -e or --export           option provides export (export data)
    -d or --dump             option dumps all the database
    -r or --reset            use it carefully! drop database
    -c or create             option creates an empty database
    --help or -h             show this message.
_USAGE_
}

=head1 NAME

dbdumputils.pl - this script manipulates dumps and data used to migrate a database from myisam to innodb (for example)

=head1 SYNOPSIS

1/ Imports install data in a local database:
perl dbdumputils.pl --import -dd /.../snapshots -u <user> -p <pass> -db <database_to_write>

2/ Export data from this database
perl dbdumputils.pl --export -sd /.../snapshots/newdata -u <user> -p <pass> -db <database_to_read>

3/ Import a schema and data previously exported
perl dbdumputils.pl --import -sd /.../snapshots/newdata -u <user> -p <password> -db <db_to_write> -s /.../structure.sql

General tools:
- Dump database:     perl dbdumputils.pl --dump -u <user> -p<pass> -db <database> -sd /data/dumps
- Create database:   perl dbdumputils.pl --create -u <user> -p<pass> -db <database>
- Drop /!\ database: perl dbdumputils.pl --reset -u <user> -p<pass> -db <database>

=head1 DESCRIPTION

&import_db($dumpdir,$db, $user, $pass) if ($dumpdir && $import);
&export_data($savedir, $db, $user, $pass) if ($savedir && $export);
&import_newdata($savedir,$db, $schema, $user, $pass) if ($savedir && $import && $schema);

&print_help if ($want_help);
&dump_db($db, $user, $pass, $savedir) if ($dump && $savedir);
&drop_db($db, $user,$pass) if ($reset && user && pass);
&create_db($db, $user, $pass) if ($create);


=head2 import_db( $dumpdir,$db, $user, $pass )

Used to import tables snaphsots into db_curtmp
perl dbdumputils.pl -i -dd /.../snapshots -u test -p test -db db_curtmp

Parameters are:

=over 4

=item $dumpdir
where you finds table.sql.gz files.
=item $db
which database where script will write
=item $user
database user who have rights to write
=item $pass
database password

=back

=head2 export_data($savedir, $db, $user, $pass)

Used to export only tables data int snapshots/newdata directory.
perl dbdumputils.pl -e -sd /.../snapshots/newdata -u test -p test -db db_curtmp

Parameters are:

=over 4

=item $savedir
where script save table.sql.gz files.
=item $db
which database where script will read
=item $user
database user
=item $pass
database password

=back

=head2 import_newdata($savedir,$db, $schema, $user, $pass)

Used to import a sql schema into db.
perl dbdumputils.pl -i -sd /.../snapshots/newdata -u test -p test -db db_newtmp -s /.../structure.sql

Parameters are:

=over 4

=item $savedir
where script will read table.sql.gz files to import its in database
=item $db
which database where script will write $savedir/$table.gz table files
=item $schema
sql schema which contains "create table" wich will be written in database
=item $user
database user who have rights to write into db
=item $pass
database password

=back

=head1 AUTHOR

Claire Hernandez <claire.hernandez@biblibre.com>

=cut
