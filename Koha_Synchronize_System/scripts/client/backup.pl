#!/bin/perl

use C4::Logguer qw(:DEFAULT $log_kss);
use Koha_Synchronize_System::tools::kss;

Koha_Synchronize_System::tools::kss::backup_client_logbin $log_kss;
