#!/bin/perl

use Koha_Synchronize_System::tools::kss;

while ( 1 ) {
    eval {
        Koha_Synchronize_System::tools::kss::pull_new_db;
    };
    if ( not $@ ) {
        exit 0;
    }
    sleep 60;
}
