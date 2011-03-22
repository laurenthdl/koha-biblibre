#!/usr/bin/perl

use utf8;
use Modern::Perl;
use Test::More;
use YAML;    
use DBI;
use C4::Context;
use C4::SQLHelper;
use Koha_Synchronize_System::tools::kss;
use C4::Logguer qw(:DEFAULT $log_kss);

my $log = $log_kss;

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
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do("set NAMES 'utf8'");
warn "\nINFOS: hostname:$hostname - user:$user - pass:$passwd - db:$db_server";

&setUp;
&checkBefore;
&processQueries;
&clean;

# init bases client + serveur
sub setUp {
    # 1- init (structure, diffs)
    #qx {./init.sh};

    Koha_Synchronize_System::tools::kss::insert_proc_and_triggers $mysql_cmd, $user, $passwd, $db_server; 
    qx{$mysql_cmd -u $user -p$passwd $db_server -e "CALL PROC_INIT_KSS_INFOS();" } ;
    Koha_Synchronize_System::tools::kss::prepare_database $mysql_cmd, $user, $passwd, $db_server; 
    Koha_Synchronize_System::tools::kss::insert_new_ids $mysql_cmd, $user, $passwd, $db_server, $dump_id_dir, $log;
}

#table-01 = simple insert
#table-02 = simple update
#table-03 = simple delete
# > 04 = more complex scenarii "addissue" "return"...
sub processQueries {
    my $queriesdir = "$curdir/t/unitdiff";

    my @files = (
        {filename => "borrower-01-insert.sql",  func =>            "testborrower01insert"},
    {filename => "borrower-02-update.sql", func =>             "testborrower02update" },
    {filename => "borrower-03-delete.sql", func =>             "testborrower03delete" },
#    {filename => "borrower_attributes-01-insert.sql", func =>  "testborrower_attributes01insert" },
#    {filename => "issue-01-insert.sql", func =>                "testissue01insert" },
#    {filename => "issue-02-update.sql", func =>                "testissue02update" },
#    {filename => "issue-03-delete.sql", func =>                "testissue03delete" },
#    {filename => "issue-04-addissue.sql", func =>              "testissue04addissue" },
#    {filename => "issue-05-return.sql", func =>                "testissue05return" },
#    {filename => "issue-06-renewal.sql", func =>               "issue06renewal" },
#    {filename => "items-02-update.sql", func =>                "testitems02update" },
#    {filename => "old_issues-04-newoldissue.sql", func =>      "testold_issues04newoldissue" },
#    {filename => "reserves-04-addissue.sql", func =>           "testreserves04addissue" },
#    {filename => "reserves-05-holding.sql", func =>            "testreserves05holding" },
#    {filename => "statistics-01-insert.sql", func =>           "teststatistics01insert" },

    );
    for my $hash ( @files ) {
        my $file = $$hash{filename};
        my $func = $$hash{func};

        my $filefull = "$queriesdir/$file";
        Koha_Synchronize_System::tools::kss::insert_diff_file ($filefull, $dbh);
        no strict "refs";
        &{ $func }

    }
}

sub checkBefore {
    my $oldborrower =  { 'borrowernumber' => "86"
      , 'cardnumber' => "10000955"
      , 'surname' => "ABAINVILLE (Mairie)"
      , 'dateexpiry' => "2017-01-15"
      , 'password' => "kDPg4wXyR8DDyA0MeEjIsw"
    };
    is (&findInData ("borrowers", $oldborrower), 1, 'borrower 86 modified by testborrower02update');

    $oldborrower = { 'borrowernumber' => '50'};
    is (&findInData ("borrowers", $oldborrower), 1, 'borrower 50 deleted by testborrower03delete');


    
}

sub clean {
    qx{$mysql_cmd -u $user -p$passwd $db_server -e "CALL PROC_END_KSS();"};
    Koha_Synchronize_System::tools::kss::delete_proc_and_triggers $mysql_cmd, $user, $passwd, $db_server, $log;
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
  $log->info("INSERT");
    is (&findInData ("borrowers", $expected), 1 , "new borrower John Carmack");
}

sub testborrower02update {
    my $expected = { 
      'borrowernumber' => "86"
      , 'cardnumber' => "10000955"
      , 'password' => "ZAZZPmpdgdmbT19nxSYXeA" #3rd query
      , 'dateexpiry' => "2012-03-12" # 2nd query
      , 'surname' => "modif client sur état précédent"}; # 1st query
    is (&findInData ("borrowers", $expected), 1 , "update borrower 86");
}

sub testborrower03delete {
    my $selected = { 
      'borrowernumber' => "50"
    };
    is (&findInData ("borrowers", $selected), 0 , "delete borrower 50");
}

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
