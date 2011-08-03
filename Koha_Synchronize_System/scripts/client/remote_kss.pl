#!/bin/perl

use Modern::Perl;
use DBI;
use YAML;
use Digest::MD5;
use File::Basename;
use Koha_Synchronize_System::tools::kss;
use C4::Logguer qw(:DEFAULT $log_kss);

my $conf = Koha_Synchronize_System::tools::kss::get_conf();
my $log_filepath = $$conf{abspath}{logfile_stderr};
open(STDSTD, ">&1");
open(STDOUT, ">>$log_filepath");
open(STDERR, ">>$log_filepath");

my $log = $log_kss;
my $ip_server                = $$conf{cron}{serverhost};
my $ssh_cmd                  = $$conf{which_cmd}{ssh};
my $username = "kss";
my $args = join(" ", @ARGV);

$log->info("Exécution de kss.pl sur le serveur");
my $command = qq/$$conf{which_cmd}{ssh} $username\@$ip_server 'source .zshrc; perl $$conf{abspath}{server_kss_pl_script} $args'/;
my @result = qx{$command};
print STDSTD @result;
