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
my $conf = Koha_Synchronize_System::tools::kss::get_conf();
my $curdir = $$conf{path}{kss_dir};
my $mysql_cmd = $conf->{'datatest'}->{'mysql_cmd'};
my $user = $conf->{'datatest'}->{'user'};
my $passwd = $conf->{'datatest'}->{'passwd'};
my $db_server = $conf->{'datatest'}->{'db_server'};
my $hostname = $conf->{'datatest'}->{'hostname'};
my $dump_id_dir = $conf->{'path'}->{'dump_id'};
my $matching_table_prefix = $$conf{databases_infos}{matching_table_prefix};
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
    qx {./init_srv.sh};

    Koha_Synchronize_System::tools::kss::insert_proc_and_triggers $mysql_cmd, $user, $passwd, $db_server; 
    qx{$mysql_cmd -u $user -p$passwd $db_server -e "CALL PROC_CREATE_KSS_INFOS();" } ;
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
        {filename => "borrower-01-insert.sql",              func => "testborrower01insert"},
        {filename => "borrower-02-update.sql",              func => "testborrower02update" },
        {filename => "borrower-03-delete.sql",              func => "testborrower03delete" },
        {filename => "borrower_attributes-01-insert.sql",   func => "testborrower_attributes01insert" },
        {filename => "issue-01-insert.sql",                 func => "testissue01insert" },
        {filename => "issue-02-update.sql",                 func => "testissue02update" },
        {filename => "issue-04-addissue.sql",               func => "testissue04addissue" },
        {filename => "issue-05-return.sql",                 func => "testissue05return" },
        {filename => "issue-06-renewal.sql",                func => "issue06renewal" },
        {filename => "items-02-update.sql",                 func => "testitems02update" },
        {filename => "old_issues-04-newoldissue.sql",       func => "testold_issues04newoldissue" },
        {filename => "reserves-02-update.sql",              func => "testreserves02update" },
#        {filename => "reserves-04-addissue.sql",            func => "testreserves04addissue" },
#    {filename => "reserves-05-holding.sql", func =>            "testreserves05holding" },
        {filename => "statistics-01-insert.sql", func =>           "teststatistics01insert" },

    );
    for my $hash ( @files ) {
        my $file = $$hash{filename};
        my $func = $$hash{func};

        my $filefull = "$queriesdir/$file";
        Koha_Synchronize_System::tools::kss::insert_diff_file ($filefull, $dbh, $log);
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

    my $bn = "52"; my $in = "275";
    my $issuebeforerenew = {borrowernumber => $bn, itemnumber => $in};
    is (&findInData ("issues", $issuebeforerenew), 0 , "issue $in don't exists before issue06");
   
    $in = "153";
    my $itembeforeupdate = {itemnumber => $in, holdingbranch => 'BDM', itemlost => '0', onloan => '2012-04-30', datelastseen => '2011-02-18'};
    is (&findInData ("items", $itembeforeupdate), 1 , "item $in before item02");

    #reserves-04-addissue
    my $reservebeforeupdate = {reservenumber => "1", borrowernumber => "79", priority => "1", biblionumber => "9740"};
    is (&findInData ("reserves", $reservebeforeupdate), 1 , "reserve before reserves-02-update");
    $reservebeforeupdate = {reservenumber => "2", borrowernumber => "23", priority => "2", biblionumber => "9740"};
    is (&findInData ("reserves", $reservebeforeupdate), 1 , "reserve before reserves-02-update");
     

}

sub clean {
    Koha_Synchronize_System::tools::kss::clean $mysql_cmd, $user, $passwd, $db_server, $log;
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
    my $bn = "51";
    my $expected1 = {borrowernumber => $bn, code => "CANTON", attribute => "canton_client"};
    is (&findInData ("borrower_attributes", $expected1), 1 , "update borrower_attributes 100 CANTON");
    my $expected2 = {borrowernumber => $bn, code => "HORAIRES", attribute => "horaires_client"};
    is (&findInData ("borrower_attributes", $expected2), 1 , "update borrower_attributes 100 HORAIRES");
    my $expected3 = {borrowernumber => $bn, code => "TOURNEE", attribute => "tournee_client"};
    is (&findInData ("borrower_attributes", $expected3), 1 , "update borrower_attributes 100 TOURNEE");
}

sub testissue01insert {
    my $bn = "52";
    my $in = "153";
    
    my $expected = {borrowernumber => $bn, itemnumber => $in, issuedate => '2011-03-15', date_due => '2011-03-25', branchcode => 'BDM'};
    is (&findInData ("issues", $expected), 1 , "insert issues $in for borrowers $bn");
    
    $in = "275";
    $expected = {borrowernumber => $bn, itemnumber => $in, issuedate => '2011-03-15', date_due => '2011-03-25', branchcode => 'BDM'};
    is (&findInData ("issues", $expected), 1 , "insert issues $in for borrowers $bn");
}

sub testissue02update {
    my $bn = "52";
    my $in = "275";
    
    my $expected = {borrowernumber => $bn, itemnumber => $in, issuedate => '2011-03-15', date_due => '2011-04-04', branchcode => 'BDM', renewals => '1', lastreneweddate => '2011-03-15'};
    is (&findInData ("issues", $expected), 1 , "update issues $in for borrowers $bn");
}

sub testissue04addissue {
    my $bn = "53";
    my $in = "101";
    
    my $expected = {borrowernumber => $bn, itemnumber => $in, issuedate => '2011-03-11', date_due => '2011-04-01', branchcode => 'BDM'};
    is (&findInData ("issues", $expected), 1, "issue04 insert issues : items $in for borrowers $bn");
    
    $expected = {itemnumber => $in, issues => '2', datelastborrowed => '2011-03-11', onloan => '2011-04-01', holdingbranch => 'BDM', itemlost => '0', datelastseen => '2011-03-11'};
    is (&findInData ("items", $expected), 1, "issue04 update items $in for borrowers $bn");

    $expected = {branch => 'BDM', type => 'issue', value => '0.0000', other => '', itemnumber => $in, itemtype => 'PG', borrowernumber => $bn};
    is (&findInData ("statistics", $expected), 1, "issue04 insert statistics for items $in and borrowers $bn");
}

sub testissue05return {
    my $bn = "53";
    my $in = "101";
    
    # How test UPDATE issues with returndate=now() ? cf gdoc

    my $expected = {borrowernumber => $bn, itemnumber => $in, issuedate => '2011-03-11', date_due => '2011-04-01', branchcode => 'BDM'};
    is (&findInData ("old_issues", $expected), 1, "issue04 insert old_issues : items $in for borrowers $bn");

    $expected = {borrowernumber => $bn, itemnumber => $in};
    is (&findInData ("issues", $expected), 0, "issue05 delete issues : items $in for borrowers $bn");

    $expected = {itemnumber => $in, renewals => '0', datelastseen => '2011-03-11', itemlost => '0'};
    is (&findInData ("issues", $expected), 0, "issue05 delete issues : items $in for borrowers $bn");

    $expected = {branch => 'BDM', type => 'return', value => '0.0000', other => '', itemnumber => $in, borrowernumber => $bn};
    is (&findInData ("statistics", $expected), 1, "issue05 insert statistics for items $in and borrowers $bn");

    $expected = {borrowernumber => "100", itemnumber => '301'};
    is (&findInData ("old_issues", $expected), 0, "old_issues-04 with borrowernumber 100 in 301 doesn't exist yet");
    is (&findInData ("issues", $expected), 1, "old_issues-04 with borrowernumber 100 in 301 exist in issues table");
}

sub issue06renewal {
    my $bn = "54";
    my $in = "102";

    my $expected = {borrowernumber => $bn, itemnumber => $in, date_due => '2011-04-01', renewals => '1', lastreneweddate => '2011-03-11'};
    is (&findInData ("issues", $expected), 1, "issue06 update issues : items $in for borrowers $bn");
}

sub testitems02update {
    my $in = "153";
    my $expected = {itemnumber => $in, issues => '1', datelastborrowed => '2011-03-15', holdingbranch => 'BDM', itemlost => '0', onloan => '2011-03-25', datelastseen => '2011-03-15'};
    is (&findInData ("items", $expected), 1, "item02 update items : items $in ");
}

sub testold_issues04newoldissue {
    my $expected = {borrowernumber => "100", itemnumber => '301'};
    is (&findInData ("old_issues", $expected), 1, "old_issues-04 with borrowernumber 100 in 301 exists");
    is (&findInData ("issues", $expected), 0, "old_issues-04 with borrowernumber 100 in 301 is remove from issues table");
}

sub testreserves02update {
    my $reserveafterupdate = {reservenumber => "1", borrowernumber => "79", priority => "2", biblionumber => "9740"};
    is (&findInData ("reserves", $reserveafterupdate), 1 , "reserve 79 after reserves-02-update");
    $reserveafterupdate = {reservenumber => "2", borrowernumber => "23", priority => "1", biblionumber => "9740"};
    is (&findInData ("reserves", $reserveafterupdate), 1 , "reserve 23 after reserves-02-update");
}

sub testreserves04addissue {}

sub testreserves05holding {}

sub teststatistics01insert {
    my $stat = {branch => "BDM", type => "renew", borrowernumber => "100", itemnumber => "287"};
    is (&findInData ("statistics", $stat), 1 , "add stats statistics-01-insert.sql");
    $stat = {branch => "BDM", type => "issue", borrowernumber => "100", itemnumber => "275"};
    is (&findInData ("statistics", $stat), 1 , "add stats statistics-01-insert.sql");
}

sub findInData {
    my ($table, $data, $out) = @_;
    my $results = C4::SQLHelper::SearchInTable ($table, $data, undef, undef, $out, undef, undef);
    my $size = scalar (@$results);
    return $size;
}
