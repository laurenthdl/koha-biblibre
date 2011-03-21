#!/usr/bin/perl

use utf8;
use Modern::Perl;
use Test::More;
use YAML;    
use Test::DBUnit connection_name => 'test';
use Test::DBUnit::Generator;
use DBI;
use C4::Context;

plan 'no_plan';

my $koha_dir = C4::Context->config('intranetdir');
my $curdir = "$koha_dir/Koha_Synchronize_System";

my $conf = YAML::LoadFile("$curdir/conf/kss.yaml");
my $mysql_cmd = $conf->{'datatest'}->{'mysql_cmd'};
my $user = $conf->{'datatest'}->{'user'};
my $passwd = $conf->{'datatest'}->{'passwd'};
my $db_server = $conf->{'datatest'}->{'db_server'};
my $hostname = $conf->{'datatest'}->{'hostname'};
my $dsn = "DBI:mysql:dbname=$db_server;host=$hostname;";

my $connection = DBIx::Connection->new(
    name     => 'test',
    dsn      => $dsn,
    username => $user,
    password => $passwd,
);

my $dbh = DBI->connect("DBI:mysql:dbname=$db_server;host=$hostname;", $user, $passwd); 
add_test_connection('test', dbh => $dbh);

my $generator = Test::DBUnit::Generator->new(
  connection      => $connection,
  datasets => {
      borrowers => 'SELECT * FROM borrowers',
});
my @initdataset = $generator->dataset;

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

        my @expectedarr = (borrowers => [cardnumber => "4200000000001", surname => "John Carmack" ]);
        push @initdataset, @expectedarr ;
        #warn Data::Dumper::Dumper (@initdataset);
        expected_dataset_ok (
          borrowers => @initdataset,
       );
    }
}


