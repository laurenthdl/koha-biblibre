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
    #qx{./init.sh};
    qx{./init_srv.sh};

    Koha_Synchronize_System::tools::kss::insert_proc_and_triggers $mysql_cmd, $user, $passwd, $db_server; 
    qx{$mysql_cmd -u $user -p$passwd $db_server -e "CALL PROC_INIT_KSS_INFOS();" } ;
    Koha_Synchronize_System::tools::kss::prepare_database $mysql_cmd, $user, $passwd, $db_server; 

    # Not possible in test, it's too late......
    #Koha_Synchronize_System::tools::kss::insert_new_ids $mysql_cmd, $user, $passwd, $db_server, $dump_id_dir, $log;

    my $insert = qq{INSERT INTO } . $matching_table_prefix . qq{borrowers(borrowernumber, cardnumber) VALUES ('100', "42424242");};
    qx{$mysql_cmd -u $user -p$passwd $db_server -e '$insert'} ;

    $insert = qq{INSERT INTO } . $matching_table_prefix . qq{borrowers(borrowernumber, cardnumber) VALUES ('101', "01010101");};
$log->info($insert);
    qx{$mysql_cmd -u $user -p$passwd $db_server -e '$insert'} ;

    #$insert = "INSERT INTO " . $matching_table_prefix . "reserves(reservenumber, borrowernumber, biblionumber, reservedate) SELECT reservenumber, borrowernumber, biblionumber, reservedate FROM reserves WHERE reservenumber > 99;";
    #qx{$mysql_cmd -u $user -p$passwd $db_server -e $insert} ;

}

#table-01 = simple insert
#table-02 = simple update
#table-03 = simple delete
# > 04 = more complex scenarii "addissue" "return"...
sub processQueries {
    my $queriesdir = "$curdir/t/unitdiff2";

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
        Koha_Synchronize_System::tools::kss::insert_diff_file ($filefull, $dbh, $log);
        no strict "refs";
        &{ $func };
    }
}

sub checkBefore {
    my $lastborrower = {borrowernumber => 101};
    my $nextborrower = {borrowernumber => 102};
    is (&findInData ("borrowers", $lastborrower), 1, 'borrower 101 is present (inserted by server)');
    is (&findInData ("borrowers", $nextborrower), 0, 'borrower 102 is next borrower (== borrower 100 for client)');
}

sub clean {
    qx{$mysql_cmd -u $user -p$passwd $db_server -e "CALL PROC_END_KSS();"};
    Koha_Synchronize_System::tools::kss::delete_proc_and_triggers $mysql_cmd, $user, $passwd, $db_server, $log;
}

sub testborrower01insert {
    my $expected = { 
        'borrowernumber' => 102,
        'cardnumber' => "42424242", 
        'surname' => "John Carmack", 
        'branchcode' => 'BDM'};
    is (&findInData ("borrowers", $expected), 1 , "new borrower John Carmack (100/102)");
}

sub testborrower02update {
    my $expected = { 
      'borrowernumber' => "102"
      , 'cardnumber' => "42424242"
      , 'password' => "forty2pwd" #3rd query
      , 'dateexpiry' => "2012-03-31" # 2nd query
      , 'surname' => "John Karmacoma"}; # 1st query
    is (&findInData ("borrowers", $expected), 1 , "update borrower 100/102");
}

sub testborrower03delete {
    my $deleted = { 
      'borrowernumber' => "103"
    };
    is (&findInData ("borrowers", $deleted), 0 , "delete borrower 101/103 (created into)");
    is (&findInData ("deletedborrowers", $deleted), 1 , "delete borrower 101/103 add in deletedborrowers");
    my $previous = { borrowernumber => 101, surname => 'Linus' };
    is (&findInData ("borrowers", $previous), 1 , "delete verif existence borrowernumber created on server 101");
}

sub testborrower_attributes01insert {
    my $bn = "102";
    my $expected = {borrowernumber => $bn, code => "CANTON", attribute => "canton_client"};
    is (&findInData ("borrower_attributes", $expected), 1 , "update borrower_attributes 100/102 CANTON");
    $expected = {borrowernumber => $bn, code => "HORAIRES", attribute => "horaires_client"};
    is (&findInData ("borrower_attributes", $expected), 1 , "update borrower_attributes 100/102 HORAIRES");
    $expected = {borrowernumber => $bn, code => "TOURNEE", attribute => "tournee_client"};
    is (&findInData ("borrower_attributes", $expected), 1 , "update borrower_attributes 100/102 TOURNEE");
}

sub testissue01insert {
    my $old_bn = "100";
    my $bn = "102";
    my $in = "153";
    
    my $expected = {borrowernumber => $bn, itemnumber => $in, issuedate => '2011-03-15', date_due => '2011-03-25', branchcode => 'BDM'};
    is (&findInData ("issues", $expected), 1 , "insert issues $in for borrowers $old_bn / $bn");
    
    $in = "275";
    $expected = {borrowernumber => $bn, itemnumber => $in, issuedate => '2011-03-15', date_due => '2011-03-25', branchcode => 'BDM'};
    is (&findInData ("issues", $expected), 1 , "insert issues $in for borrowers $old_bn / $bn");
}

sub testissue02update {
    my $old_bn = "100";
    my $bn = "102";
    my $in = "275";
    
    my $expected = {borrowernumber => $bn, itemnumber => $in, issuedate => '2011-03-15', date_due => '2011-04-04', branchcode => 'BDM', renewals => '1', lastreneweddate => '2011-03-15'};
    is (&findInData ("issues", $expected), 1 , "update issues $in for borrowers $bn");
}

sub testissue04addissue {
    my $old_bn = "100";
    my $bn = "102";
    my $in = "101";
    
    my $expected = {borrowernumber => $bn, itemnumber => $in, issuedate => '2011-03-11', date_due => '2011-04-01', branchcode => 'BDM'};
    is (&findInData ("issues", $expected), 1, "issue04 insert issues : items $in for borrowers $bn");
    
    $expected = {itemnumber => $in, issues => '2', datelastborrowed => '2011-03-11', onloan => '2011-04-01', holdingbranch => 'BDM', itemlost => '0', datelastseen => '2011-03-11'};
    is (&findInData ("items", $expected), 1, "issue04 update items $in for borrowers $bn");

    $expected = {branch => 'BDM', type => 'issue', value => '0.0000', other => '', itemnumber => $in, itemtype => 'PG', borrowernumber => $bn};
    is (&findInData ("statistics", $expected), 1, "issue04 insert statistics for items $in and borrowers $bn");
}

sub testissue05return {
    my $old_bn = "100";
    my $bn = "102";
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
}

sub issue06renewal {
    my $old_bn = "100";
    my $bn = "102";
    my $in = "122";

    my $expected = {borrowernumber => $bn, itemnumber => $in, date_due => '2011-04-01', renewals => '1', lastreneweddate => '2011-03-11'};
    is (&findInData ("issues", $expected), 1, "issue06 update issues : items $in for borrowers $bn");
}

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
