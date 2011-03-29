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
my $kss_errors_table = $$conf{databases_infos}{kss_errors_table};
my $dbh = DBI->connect("DBI:mysql:dbname=$db_server;host=$hostname;", $user, $passwd); 
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do("set NAMES 'utf8'");
warn "\nINFOS: hostname:$hostname - user:$user - pass:$passwd - db:$db_server";

warn "You must delete manually $kss_errors_table table";

eval {
    &setUp;
    &checkBefore;
    &processQueries;
};
&clean;

# init bases client + serveur
sub setUp {
    # 1- init (structure, diffs)
    #qx{./init.sh};
    qx{./init_srv.sh};

    Koha_Synchronize_System::tools::kss::insert_proc_and_triggers $user, $passwd, $db_server; 
    qx{$mysql_cmd -u $user -p$passwd $db_server -e "CALL PROC_CREATE_KSS_INFOS();" } ;
    Koha_Synchronize_System::tools::kss::prepare_database $mysql_cmd, $user, $passwd, $db_server; 

}

sub processQueries {
    my $queriesdir = "$curdir/t/unitdiff3";

    my @files = (
        {filename => "warnings-01-issue_already_onloan.sql", func => "test_issue_already_onloan"},
        {filename => "warnings-02-issue_returned_twice.sql", func => "test_issue_returned_twice"},
        {filename => "warnings-03-reserve_twice_on_same_itemnumber.sql", func => "test_reserve_twice_on_samedi_itemnumber"},

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
}

sub clean {
    Koha_Synchronize_System::tools::kss::clean $mysql_cmd, $user, $passwd, $db_server, $log;
}

sub test_issue_already_onloan {
    my $expected = { 
        'borrowernumber' => 30,
        'itemnumber' => '130'};
    is (&findInData ("issues", $expected), 1 , "new issues 130 for borrower 30");

    $expected = { 
        'borrowernumber' => 31,
        'itemnumber' => '130'};
    is (&findInData ("issues", $expected), 1 , "new issues 130 for borrower 31");

    $expected = { 
        'error' => 'Issue already onloan',
        'message' => 'Issue 130 is already onloan by another borrower'};
    is (&findInData ($kss_errors_table, $expected), 1 , "new issue 130 raise an error in $kss_errors_table table");
}

sub test_issue_returned_twice {
    my $bn = 32;
    my $in = 131;
    my $expected = {
        borrowernumber => $bn,
        itemnumber => $in
    };
    is (&findInData ("issues", $expected), 0 , "issue 131 is not present in issues table");
    is (&findInData ("old_issues", $expected), 1 , "issue 131 is present in old_issues table");

}

sub test_reserve_twice_on_samedi_itemnumber {
    my $bn = 33;
    my $bibn = 31;
    my $expected = {
        borrowernumber => $bn,
        biblionumber => $bibn,
        priority => 1
    };
    is (&findInData ("reserves", $expected), 1 , "reserve for biblionumber $bibn and borrower $bn is present in reserves table with priority 1");

    $bn = 34;
    $expected = {
        borrowernumber => $bn,
        biblionumber => $bibn,
        priority => 2
    };
    is (&findInData ("reserves", $expected), 1 , "reserve for biblionumber $bibn and borrower $bn is present in reserves table with priority 2");
    $expected = { 
        'error' => 'Reserve already exist',
        'message' => "Reserve for biblionumber=$bibn AND itemnumber=NULL already exist. Set priority to 2"};
    is (&findInData ($kss_errors_table, $expected), 1 , "reserve warning for biblionumber $bibn and borrower $bn is present in reserves table with priority 2");

    $bn = 35;
    $bibn = 9754;
    my $in = 31;
    $expected = {
        borrowernumber => $bn,
        biblionumber => $bibn,
        priority => 1
    };
    is (&findInData ("reserves", $expected), 1 , "reserve for itemnumber $in and borrower $bn is present in reserves table with priority 1");

    $bn = 36;
    $bibn = 9754;
    $in = 31;
    $expected = {
        borrowernumber => $bn,
        biblionumber => $bibn,
        priority => 2
    };
    is (&findInData ("reserves", $expected), 1 , "reserve for itemnumber $in and borrower $bn is present in reserves table with priority 2");

    $expected = { 
        'error' => 'Reserve already exist',
        'message' => "Reserve for biblionumber=$bibn AND itemnumber=$in already exist. Set priority to 2"};
    is (&findInData ($kss_errors_table, $expected), 1 , "reserve warning for biblionumber $bibn and borrower $bn is present in reserves table with priority 2");
}

sub findInData {
    my ($table, $data, $out) = @_;
    my $results = C4::SQLHelper::SearchInTable ($table, $data, undef, undef, $out, undef, undef);
    my $size = scalar (@$results);
    return $size;
}
