#!/usr/bin/perl

use Modern::Perl;
use DBI;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;
use Fcntl qw(:flock);
use YAML;

use C4::Logguer qw(:DEFAULT $log_kss);

use Koha_Synchronize_System::tools::kss;

my $host;
my $help;
GetOptions(
        'help' => \$help,
        'host=s'   => \$host,
    ) or pod2usage(2);

pod2usage(1) if $help;

if (not defined $host) {
    print "<= host param is mandatory =>\n\n";
    pod2usage(1);
}

if ( $< ne "0" ) {
   print "You must logged in root";
   exit 1
}

my $conf = Koha_Synchronize_System::tools::kss::get_conf();
my $koha_dir = $$conf{path}{koha_dir};
my $kss_dir = $$conf{path}{kss_dir};
my $koha_conf = $$conf{cron}{koha_conf};
given ( $host ) {
    when ( "master" ) {
        my $jobtime = $$conf{cron}{jobtime_server_digest};
        open my $file, ">", "/etc/cron.d/kss" or die $!;
        print $file <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
PERL5LIB=$koha_dir
KOHA_CONF=$koha_conf
$jobtime kss perl $kss_dir/tools/kss.pl
EOF

    };
    when ( "slave" ) {
        my $jobtime_push = $$conf{conf}{jobtime_client_push};
        my $jobtime_pull = $$conf{conf}{jobtime_client_pull};
        open my $file, ">", "/etc/cron.d/kss" or die $!;
        print $file <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
PERL5LIB=$koha_dir
KOHA_CONF=$koha_conf
$jobtime_push kss perl $kss_dir/scripts/send_backups.pl
$jobtime_pull kss perl $kss_dir/scripts/pull_db.pl
EOF
    };
    default {
        print "$host is not a valid host type\n";
        pod2usage(1);
    };
}

__END__

=head1 NAME

insert_crontab - Insert job in crontab for kss

=head1 SYNOPSIS

insert_crontab.pl [options]

Options:

-help brief : help message

-host   : set a type of host

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-host>

Host must be master or slave.
It's type of host where we are.

=back

=head1 DESCRIPTION

B<insert_crontab> insert job in crontab for kss

=cut
