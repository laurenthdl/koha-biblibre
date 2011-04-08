#!/bin/perl

use Modern::Perl;
use DBI;
use YAML;

use Koha_Synchronize_System::tools::kss;

my $conf                     = Koha_Synchronize_System::tools::kss::get_conf();
my $kss_dir                  = $$conf{path}{kss_dir};
my $kss_home                 = $$conf{path}{kss_server_home};
my $outbox                   = $$conf{path}{client_outbox};
my $inbox                    = $$conf{abspath}{server_inbox};
my $ip_server                = $$conf{cron}{serverhost};
my $remote_dump_filepath     = $$conf{abspath}{server_dump_filepath};
my $local_dump_filepath      = $$conf{path}{client_dump_filepath};
my $scp_cmd                  = $$conf{which_cmd}{scp};

my $username = "kss";
print "\nEnvoi des dumps au serveur\n";
qx{$scp_cmd $outbox/*.tar.gz  $username\@$ip_server:$inbox};

