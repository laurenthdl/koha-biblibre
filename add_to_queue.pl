#!/usr/bin/perl

use Modern::Perl;

use C4::Search::Engine::Solr;

C4::Search::Engine::Solr::AddRecordToIndexRecordQueue "biblio", "1 2 3";
