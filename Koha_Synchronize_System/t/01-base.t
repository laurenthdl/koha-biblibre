#!/usr/bin/perl

use utf8;
use Modern::Perl;
use Test::More;
use YAML;    
use Test::DBUnit connection_name => 'test';

plan 'no_plan';

my $curdir = "/home/claire/dev/versions/devcg55/Koha_Synchronize_System";
my $conf = YAML::LoadFile("$curdir/conf/kss.yaml");
my $mysql_cmd = $conf->{'datatest'}->{'mysql_cmd'};
my $user = $conf->{'datatest'}->{'user'};
my $passwd = $conf->{'datatest'}->{'passwd'};
my $db_server = $conf->{'datatest'}->{'db_server'};

DBIx::Connection->new(
    name     => 'test',
    dsn      => $db_server,
    username => $user,
    password => $passwd,
);


&setUp;
&processQueries;
is(1,1,'test');

# init bases client + serveur
sub setUp {

    # 1- init (structure, diffs)
    #qx {./init.sh}

    # 2- import procedure.sql
    my $file = "$curdir/tools/procedures.sql";
    #qx{$mysql_cmd -u $user -p$passwd $db_server < $file};

    # 3- import triggers
    #qx{../tools/generate_before_after_sql_script.pl};    

}

sub processQueries {
    my $queriesdir = "$curdir/t/unitdiff";
    my @files = qx{ls -1 $queriesdir};
    for my $file ( @files ) {
      # call insert_diff_file ($file)...
      # dummy try 
      my $filefull = "$queriesdir/$file";
      qx{$mysql_cmd -u $user -p$passwd $db_server < $filefull};
      
    }
    #foreach
      #ajout micro diff client
      #play script
      #verif ajout diff serveur
    #
}


