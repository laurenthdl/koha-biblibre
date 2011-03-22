#!/usr/bin/perl

use utf8;
use Modern::Perl;
use Test::More;
use YAML;    
use DBI;
use C4::Context;
use C4::SQLHelper;
use Koha_Synchronize_System::tools::kss;

plan 'no_plan';

my $koha_dir = C4::Context->config('intranetdir');
my $curdir = "$koha_dir/Koha_Synchronize_System/";

my $conf = YAML::LoadFile("$curdir/conf/kss.yaml");
my $mysql_cmd = $conf->{'datatest'}->{'mysql_cmd'};
my $user = $conf->{'datatest'}->{'user'};
my $passwd = $conf->{'datatest'}->{'passwd'};
my $db_server = $conf->{'datatest'}->{'db_server'};
my $hostname = $conf->{'datatest'}->{'hostname'};
my $dump_id_dir = $curdir . $conf->{'datas_path'}->{'dump_id'};
my $dbh = DBI->connect("DBI:mysql:dbname=$db_server;host=$hostname;", $user, $passwd); 

warn "\nINFOS: hostname:$hostname - user:$user - pass:$passwd - db:$db_server";

&setUp;
&checkBefore;
&processQueries;

# init bases client + serveur
sub setUp {
    warn ">>>init";
    # 1- init (structure, diffs)
    #qx {./init.sh};

    warn ">>>other";
    Koha_Synchronize_System::tools::kss::insert_proc_and_triggers $mysql_cmd, $user, $passwd, $db_server; 
    warn ">>>other2";
    qx{$mysql_cmd -u $user -p$passwd $db_server -e "CALL PROC_INIT_KSS_INFOS();" } ;
    warn ">>>other3";
    Koha_Synchronize_System::tools::kss::prepare_database $mysql_cmd, $user, $passwd, $db_server; 
    warn ">>>other4";
    Koha_Synchronize_System::tools::kss::insert_new_ids $mysql_cmd, $user, $passwd, $db_server, $dump_id_dir; 
}

#table-01 = simple insert
#table-02 = simple update
#table-03 = simple delete
# > 04 = more complex scenarii "addissue" "return"...
sub processQueries {
    my $queriesdir = "$curdir/t/unitdiff";
    my @files = qx{ls -1 $queriesdir};
    for my $file ( @files ) {
        chomp $file;

        #?!?
        #qx{../scripts/client/insert_new_borrowernumber.pl};
        #my $borrfile = "$curdir/tools/procedures.sql";
        #qx{$mysql_cmd -u $user -p$passwd $db_server < $$conf{datas_path}{dump_borrowers_filename}  };

        my $filefull = "$queriesdir/$file";
        warn "file:$filefull";
        qx{$mysql_cmd -u $user -p$passwd $db_server < $filefull};

        Koha_Synchronize_System::tools::kss::insert_diff_file ($filefull);

        given ($file) {
          when ("borrower-01-insert.sql")            { &testborrower01insert }
#          when ("borrower-02-update.sql")            { &testborrower02update }
#          when ("borrower-03-delete.sql")            { &testborrower03delete }
#          when ("borrower_attributes-01-insert.sql") { &testborrower_attributes01insert }
#          when ("issue-01-insert.sql")               { &testissue01insert }
#          when ("issue-02-update.sql")               { &testissue02update }
#          when ("issue-03-delete.sql")               { &testissue03delete }
#          when ("issue-04-addissue.sql")             { &testissue04addissue }
#          when ("issue-05-return.sql")               { &testissue05return }
#          when ("issue-06-renewal.sql")              { &issue06renewal }
#          when ("items-02-update.sql")               { &testitems02update }
#          when ("old_issues-04-newoldissue.sql")     { &testold_issues04newoldissue }
#          when ("reserves-04-addissue.sql")          { &testreserves04addissue }
#          when ("reserves-05-holding.sql")           { &testreserves05holding }
#          when ("statistics-01-insert.sql")          { &teststatistics01insert }
          default                                    { warn 'default case'; &testdefault }
        }
        last;

    }
}

sub checkBefore {
    my $oldborrower =  { 'borrowernumber' => "86"
      , 'cardnumber' => "1000955"
      , 'surname' => "ABAINVILLE(Mairie)"
      , 'dateexpiry' => "2017-01-15"
      , 'password' => "kDPg4wXyR8DDyA0MeEjIsw"
    };
    is (&findInData ("borrowers", $oldborrower), 1, 'borrower 86 modified by testborrower02update');
    
}

sub testdefault {
    is (&findInData ("borrowers", { 'cardnumber' => "10000267", 'surname' => "COLLIN" }), 1 , "default exists");
    is (&findInData ("borrowers", { 'cardnumber' => "424242", 'surname' => "John Carmack" }) ,0, "default exists");
}

sub testborrower01insert {
    my $expected = { 
      'cardnumber' => "42424242", 
      'surname' => "John Carmack", 
      'branchcode' => 'BDM'};
    is (&findInData ("borrowers", $expected), 1 , "new borrower John Carmack");
}

sub testborrower02update {
    my $expected = { 
      'borrowernumber' => "86"
      , 'cardnumber' => "1000955"
      , 'password' => "ZAZZPmpdgdmbT19nxSYXeA" #3rd query
      , 'dateexpiry' => "2012-03-12" # 2nd query
      , 'surname' => "modif client sur état précédent"}; # 1st query
    is (&findInData ("borrowers", $expected), 1 , "update borrower 86");
    
}

sub testborrower03delete {}
sub testborrower_attributes01insert {
    my $bn = "100";
    my $expected1 = {borrowernumber => $bn, code => "CANTON", attribute => "canton_client"};
    is (&findInData ("borrower_attributes", $expected1), 1 , "update borrower_attributes 100 CANTON");
    my $expected2 = {borrowernumber => $bn, code => "HORAIRES", attribute => "horaires_client"};
    is (&findInData ("borrowers_attributes", $expected2), 1 , "update borrower_attributes 100 HORAIRES");
    my $expected3 = {borrowernumber => $bn, code => "TOURNEE", attribute => "tournee_client"};
    is (&findInData ("borrowers_attributes", $expected3), 1 , "update borrower_attributes 100 TOURNEE");
}
sub testissue01insert {}
sub testissue02update {}
sub testissue03delete {}
sub testissue04addissue {}
sub testissue05return {}
sub issue06renewal {}
sub testitems02update {}
sub testold_issues04newoldissue {}
sub testreserves04addissue {}
sub testreserves05holding {}
sub teststatistics01insert {}

sub findInData {
    my ($table, $data, $out) = @_;
    my $results = C4::SQLHelper::SearchInTable ($table, $data, undef, undef, $out, undef, undef);
    my $size = scalar (@$results);
    return $size;
}
