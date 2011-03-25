#!/usr/bin/perl

package Koha_Synchronize_System::tools::mysql;

use Modern::Perl;
use DBI;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

my $database = "koha_devcg55";
my $hostname = "localhost";
my $user     = "root";
my $passwd   = "root";
my $help     = "";
my $action;
my $fieldnames;
my $filename;

sub launch {
    GetOptions(
        'help|?'       => \$help,
        'database=s'   => \$database,
        'hostname=s'   => \$hostname,
        'user=s'       => \$user,
        'passwd=s'     => \$passwd,
        'action=s'     => \$action,
        'fieldnames=s' => \$fieldnames,
        'filename=s'   => \$filename,
    ) or pod2usage(2);

    pod2usage(1) if $help;

    if (not defined $action) {
        print "\n\t\t <= Action param is mandatory =>\n\n";
        pod2usage(1);
    }

    my $dbh = DBI->connect( "DBI:mysql:dbname=$database;host=$hostname;", $user, $passwd ) or die $DBI::errstr;
    $dbh->{'mysql_enable_utf8'} = 1;
    $dbh->do("set NAMES 'utf8'");

    my $tables = $dbh->selectall_arrayref("SHOW tables;");

    my %table_fields = (
        'borrowers', 'borrowernumber',
        'items'   , 'itemnumber',
        'reserves', 'reservenumber'
    );

    given ( $action ) {
        when ( 'show-references' ) {
            show_references( $tables, \%table_fields, $dbh );
        }
        
        when ( 'show-fields' ) {
            show_fields( $tables, $fieldnames, $dbh );
        }
        
        when ( 'purge-mysql-log' ) {
            purge_mysql_log( $filename );
        }

        default {
            print "$action is not a correct action";
            pod2usage( 1 );
        }
    }
}


sub show_references {
    my $tables = shift;
    my $table_field = shift;
    my $dbh = shift;
    while ( my ($t, $f) = each %$table_field ) {
        print "\n===== $t.$f REFERENCED BY : =====\n";
        for my $table ( @$tables ) {
            my $creations = $dbh->selectall_arrayref("SHOW CREATE TABLE @$table[0];");
            for my $creation ( @$creations ) {
                if ( @$creation[1] =~ /CONSTRAINT .* FOREIGN KEY \(\`([^\`]*)\`\) REFERENCES \`$t\` \(\`$f\`\)/ ) {
                    print "- $1 \tin @$table[0]\n";
                }
            }
        }
    }
}

sub show_fields {
    my $tables = shift;
    my $fieldnames = shift;
    my $dbh = shift;
    if ( not defined $fieldnames ) {
        print "\n\t\t <= fieldname param is mandatory with -showfields =>\n\n";
        pod2usage(1);
    }
    my $field;
    my $type;
    my $key;
    my @fieldnames = split ',', $fieldnames;
    for my $fieldname ( @fieldnames ) {
        print "\n===== $fieldname PRESENT IN TABLES : =====\n";
        for my $table ( @$tables ) {
            my $creations = $dbh->selectall_arrayref("SHOW COLUMNS FROM @$table[0];");
            for my $creation ( @$creations ) {
                $field = @$creation[0];
                if ( $field eq $fieldname ) {
                    $type = @$creation[1];
                    $key = @$creation[3];
                    print "- @$table[0] ($type, $key)\n";
                }
            }
        }
    }
}

sub purge_mysql_log {
    my $input_filename = shift;
    my $output_filename = shift || "STDOUT";
    chomp $input_filename;

    if ( `file $input_filename` =~ "MySQL replication log" ) {
        die "You must call mysqlbinlog and call this script with a txt file" if caller;
        print "\n\t\t <= You must call mysqlbinlog and call this script with a txt file =>\n\n";
        pod2usage(1);
    }

    my $sep = "/*!*/;";
    open(FILE, $input_filename) or die "Le fichier $input_filename n'existe pas";
    open(OUTPUT, ">$output_filename") or die "Impossible d'écrire dans $output_filename";

    my $old_sep1 = $/;
    my $old_sep2 = $\;
    $/ = $sep;
    $\ = $sep;

    my @tables     = ('borrowers', 'items', 'issues', 'old_issues', 'statistics', 'reserves', 'old_reserves', 'action_logs', 'borrower_attributes');
    my @operations = ('INSERT INTO', 'UPDATE', 'DELETE FROM');

    while ( my $line = <FILE> ) {
        for my $op (@operations){
            for my $table (@tables) {
                if ( $line =~ /$op $table( |\n)/ ) {
                    print OUTPUT substr($line, 0, length($line) - length($/));
                }
            }
        }
    }

    close(FILE);
    close(OUTPUT);

    $/ = $old_sep1;
    $\ = $old_sep2;
    
}

launch unless caller;

__END__

=head1 NAME

mysql-tools - Tools for mysql

=head1 SYNOPSIS

mysql-tools [options]

Options:

-help brief : help message

-database   : set a database name

-hostname   : set a hostname

-user       : set a user

-passwd     : set a passwd

-action     : execute action

-fieldnames : list of filenames (separated by coma)

-filename   : filename

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

=item B<-filename>

Set a filename for purge mysql log

=item B<-action>

Execute an action for this script
action must be : 
   show-references : Show references for fields specified in this script
   show-field      : Show field with name given to -fieldnames param
   purge-mysql-log : Display mysql log without useless lines

=back

=head1 DESCRIPTION

B<mysql-tools> is a collection of tools for mysql

=cut
