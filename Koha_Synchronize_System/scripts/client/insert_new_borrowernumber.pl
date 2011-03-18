#!/usr/bin/perl

use Modern::Perl;
use DBI;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

my $database = "koha_devkss_client";
my $hostname = "localhost";
my $user     = "root";
my $passwd   = "root";
my $help     = "";

my $mysqldump_cmd = "/usr/bin/mysqldump";
my $dump_filename = "/tmp/borrowers.sql":

my $kss_infos_table = "kss_infos";
my $max_borrowers_fieldname = "max_old_borrowers";
my $max_issues_fieldname = "max_old_issues";

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

$dbh->do("DROP TABLE IF EXISTS kss_match_borrowers");
$dbh->do("CREATE TABLE kss_match_borrowers(borrowernumber INT(11), cardnumber VARCHAR(16))");
$dbh->do("INSERT INTO kss_match_borrowers(borrowernumber, cardnumber) SELECT borrowernumber, cardnumber FROM borrowers WHERE borrowernumber > (SELECT value FROM $kss_infos_table WHERE variable='$max_borrowers_fieldname')");

qx{$mysqldump_cmd --no-create-db --no-create-info -u $user -p$passwd $database borrowers > $dump_filename};

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
