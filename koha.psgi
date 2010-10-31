#!/usr/bin/perl
use Plack::Builder;
use Plack::App::CGIBin;
use Plack::Middleware::Debug;
use Plack::Middleware::Debug::MemLeak;
use lib("/home/koha/Code/wip_master/");
use DBI;
use C4::Context;
use C4::Languages;
use C4::Members;
use C4::Dates;
use C4::Boolean;
use C4::Letters;
use C4::Koha;
use C4::XSLT;
use C4::Branch;
use C4::Category;

my $app=Plack::App::CGIBin->new(root => "/home/koha/Code/wip_master");

  builder {
      enable 'Debug',  panels =>
                [ qw(Environment Response Timer Memory MemLeak),
                            [ 'DBITrace', level => 1 ]
                                      ];
                                      ;
      enable 'StackTrace';
      mount "/cgi-bin/koha/" => $app;
  };


