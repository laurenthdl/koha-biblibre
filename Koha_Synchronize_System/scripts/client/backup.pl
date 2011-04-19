#!/bin/perl

use C4::Logguer qw(:DEFAULT $log_kss);
use Koha_Synchronize_System::tools::kss;

my $conf = Koha_Synchronize_System::tools::kss::get_conf();
my $log_filepath = $$conf{abspath}{logfile_stderr};
open(STDOUT, ">>$log_filepath");
open(STDERR, ">>$log_filepath");

Koha_Synchronize_System::tools::kss::backup_client_logbin $log_kss;
