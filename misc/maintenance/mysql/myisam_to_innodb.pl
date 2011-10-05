#!/usr/bin/perl
use strict;
use warnings;
use Modern::Perl;
use Getopt::Long;

my $usage = <<EOF;
myisam_to_innodb.pl - Change SQL engine to InnoDB

Options:
    --help|-h       Print this help message
    --verbose|-v    Print the name of table being processed
    --user|-u       Username for database connection
    --pass|-p       Password for database connection
    --db-name|-d    Name of database to modify (optional, modify all databases
                    whose name starts with "koha" if omitted)
    --context|-c    Use C4::Context to retrieve a database handler. In this
                    case, --user, --pass and --db-name options are simply
                    ignored
EOF

my $help = 0;
my $verbose = 0;
my $use_context = 0;

my ($db_user, $db_passwd, $db_name);

GetOptions(
    "user=s"    => \$db_user,
    "pass=s"    => \$db_passwd,
    "db-name=s" => \$db_name,
    "context"   => \$use_context,
    "help"      => \$help,
    "verbose"   => \$verbose,
) or die $usage;

if($help) {
    print $usage;
    exit 0;
}

my $dbh;
if($use_context) {
    require C4::Context;
    import C4::Context;
    $dbh = C4::Context->dbh;
} else {
    require DBI;
    import DBI;
    $db_name //= '';
    $dbh = DBI->connect("DBI:mysql:$db_name", $db_user, $db_passwd);
}
$dbh or die "Can't connect to database";

unless($use_context or $db_name) {
    # Modify all databases whose name starts with 'koha'
    my $dbquery = $dbh->prepare(qq{show databases});
    $dbquery->execute;
    while (my $dbname = $dbquery->fetchrow){
        next unless $dbname =~ /^koha/;
        $verbose and say "Database $dbname";
        $dbh->do("use $dbname");
        my $tablequery = $dbh->prepare(qq{show tables});
        $tablequery->execute;
        while (my $tablename = $tablequery->fetchrow){
           $verbose and say "\t$tablename";
           if ($tablename =~ /sessions|zebraqueue|temp_upg_biblioitems|pending_offline_operations/)
           {
                $dbh->do(qq{ALTER TABLE $tablename engine=myisam});
           }
           else {
                $dbh->do(qq{ALTER TABLE $tablename engine=innodb});
           }
        }
    }
} else {
    my $tablequery = $dbh->prepare(qq{show tables});
    $tablequery->execute;
    while (my $tablename = $tablequery->fetchrow){
       $verbose and say "\t$tablename";
       if ($tablename =~ /sessions|zebraqueue|temp_upg_biblioitems|pending_offline_operations/)
       {
            $dbh->do(qq{ALTER TABLE $tablename engine=myisam});
       }
       else {
            $dbh->do(qq{ALTER TABLE $tablename engine=innodb});
       }
    }
}
