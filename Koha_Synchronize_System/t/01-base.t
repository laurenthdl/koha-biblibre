#!/usr/bin/perl

use utf8;
use Modern::Perl;
use Test::More;
use YAML;    
use DBI;
use C4::Context;
use C4::SQLHelper;
use Switch;
use Koha_Synchronize_System::tools::kss;


plan 'no_plan';

my $koha_dir = C4::Context->config('intranetdir');
my $curdir = "$koha_dir/Koha_Synchronize_System";

my $conf = YAML::LoadFile("$curdir/conf/kss.yaml");
my $mysql_cmd = $conf->{'datatest'}->{'mysql_cmd'};
my $user = $conf->{'datatest'}->{'user'};
my $passwd = $conf->{'datatest'}->{'passwd'};
my $db_server = $conf->{'datatest'}->{'db_server'};
my $hostname = $conf->{'datatest'}->{'hostname'};
my $dbh = DBI->connect("DBI:mysql:dbname=$db_server;host=$hostname;", $user, $passwd); 

warn "\nINFOS: hostname:$hostname - user:$user - pass:$passwd - db:$db_server";

&setUp;
&processQueries;

# init bases client + serveur
sub setUp {

    # 1- init (structure, diffs)
    qx {./init.sh};

    # 2- import procedure.sql
    qx{../tools/generate_procedures.pl}; 
    my $procfile = "$curdir/tools/procedures.sql";
    qx{$mysql_cmd -u $user -p$passwd $db_server < $procfile};

    # 3- import triggers
    qx{../tools/generate_triggers.pl}; 
    my $trigfile = "$curdir/tools/triggers.sql";
    qx{$mysql_cmd -u $user -p$passwd $db_server < $trigfile};

}

#table-01 = simple insert
#table-02 = simple update
#table-03 = simple delete
# > 04 = scenarii "addissue" "return"...
sub processQueries {
    my $queriesdir = "$curdir/t/unitdiff";
    my @files = qx{ls -1 $queriesdir};
    for my $file ( @files ) {

        #?!?
        #qx{../scripts/client/insert_new_borrowernumber.pl};
        #my $borrfile = "$curdir/tools/procedures.sql";
        #qx{$mysql_cmd -u $user -p$passwd $db_server < $$conf{datas_path}{dump_borrowers_filename}  };

        my $filefull = "$queriesdir/$file";
        warn "file:$filefull";
        qx{$mysql_cmd -u $user -p$passwd $db_server < $filefull};

        Koha_Synchronize_System::tools::kss::insert_diff_file ($filefull);

        switch ($file) {
          case "01-insertborrower.sql" { &testinsertborrower01 }
          else                         { warn 'default case'; &testdefault}
        }
    }
}

sub testdefault {
    is (&findInData ("borrowers", { 'cardnumber' => "10000267", 'surname' => "COLLIN" }), 1 , "test1");
    is (&findInData ("borrowers", { 'cardnumber' => "424242", 'surname' => "John Carmack" }) ,0, "test3");
}

sub testinsertborrower01 {
warn "test";
}

sub findInData {
    my ($table, $data, $out) = @_;
    my $results = C4::SQLHelper::SearchInTable ($table, $data, undef, undef, $out, undef, undef);
    my $size = scalar (@$results);
    return $size;
}
