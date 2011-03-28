#!/usr/bin/perl

use Modern::Perl;
use DBI;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;
use YAML;

use Koha_Synchronize_System::tools::kss;

my $conf = Koha_Synchronize_System::tools::kss::get_conf();

my $database = $$conf{databases_infos}{db_client};
my $hostname = $$conf{databases_infos}{hostname};
my $user     = $$conf{databases_infos}{user};
my $passwd   = $$conf{databases_infos}{passwd};
my $help     = "";

my $mysqldump_cmd = $$conf{which_cmd}{mysqldump};
my $dump_filename = $$conf{path}{dump_ids} . '/borrowers.sql';

my $kss_infos_table = $$conf{databases_infos}{kss_infos_table};
my $max_borrowers_fieldname = $$conf{databases_infos}{max_borrowers_fieldname};
my $max_issues_fieldname = $$conf{databases_infos}{max_issues_fieldname};
my $matching_table_prefix = $$conf{databases_infos}{matching_table_prefix};

GetOptions(
    'help|?'       => \$help,
    'database=s'   => \$database,
    'hostname=s'   => \$hostname,
    'user=s'       => \$user,
    'passwd=s'     => \$passwd,
) or pod2usage(2);

pod2usage(1) if $help;

my $dbh = DBI->connect( "DBI:mysql:dbname=$database;host=$hostname;", $user, $passwd ) or die $DBI::errstr;
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do("set NAMES 'utf8'");

my $borrowers_matching = $matching_table_prefix . 'borrowers';

$dbh->do("DROP TABLE IF EXISTS $borrowers_matching");
$dbh->do("CREATE TABLE $borrowers_matching (borrowernumber INT(11), cardnumber VARCHAR(16)) ENGINE=InnoDB DEFAULT CHARSET=utf8");
$dbh->do("INSERT INTO $borrowers_matching (borrowernumber, cardnumber) SELECT borrowernumber, cardnumber FROM borrowers WHERE borrowernumber > (SELECT value FROM $kss_infos_table WHERE variable='$max_borrowers_fieldname')");
$dbh->do("INSERT INTO $borrowers_matching (borrowernumber, cardnumber) SELECT borrowernumber, cardnumber FROM deletedborrowers WHERE borrowernumber > (SELECT value FROM $kss_infos_table WHERE variable='$max_borrowers_fieldname')");

qx{$mysqldump_cmd -u $user -p$passwd $database $borrowers_matching > $dump_filename};

__END__

=head1 NAME

insert_new_borrowernumber - insert last borrowernumber in kss_infos table


=head1 SYNOPSIS

insert_new_borrowernumber.pl [options]

Options:

-help brief : help message

-database   : set a database name

-hostname   : set a hostname

-user       : set a user

-passwd     : set a passwd

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-database>

Set a database name for mysql connexion

=item B<-hostname>

Set a hostname for mysql connexion

=item B<-user>

Set a user for mysql connexion

=item B<-passwd>

Set a password for mysql connexion

=item B<-passwd>

Set list of fields separated by a coma

=back

=head1 DESCRIPTION

B<insert_new_borrowernumber> insert last borrowernumber in kss_infos table

=cut
