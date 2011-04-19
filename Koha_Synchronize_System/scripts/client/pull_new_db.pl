#!/bin/perl

use Koha_Synchronize_System::tools::kss;
use C4::Logguer qw(:DEFAULT $log_kss);

while ( 1 ) {
    eval {
        Koha_Synchronize_System::tools::kss::pull_new_db($log_kss);
    };
    if ( not $@ ) {
        exit 0;
    }
    $log_kss->error("Impossible de récupérer la nouvelle base de données du serveur, on recommence dans 60sec ($@)");
    sleep 60;
}
