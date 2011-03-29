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

plan 'no_plan';

my $conf = Koha_Synchronize_System::tools::kss::get_conf();
my $user = $conf->{'datatest'}->{'user'};
my $passwd = $conf->{'datatest'}->{'passwd'};
my $db_server = $conf->{'datatest'}->{'db_server'};
my $hostname = $conf->{'datatest'}->{'hostname'};
my $statistics_table = $$conf{databases_infos}{kss_statistics_table};
my $mysql_cmd = $$conf{which_cmd}{mysql};
my $dbh = DBI->connect("DBI:mysql:dbname=$db_server;host=$hostname;", $user, $passwd); 
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do("set NAMES 'utf8'");

&setUp;
&processQueries;
&clean;

sub setUp {
    #qx{./init.sh};
    qx{./init_srv.sh};

    Koha_Synchronize_System::tools::kss::insert_proc_and_triggers $user, $passwd, $db_server;
    qx{$mysql_cmd -u $user -p$passwd $db_server -e "CALL PROC_CREATE_KSS_INFOS();" } ;
    Koha_Synchronize_System::tools::kss::prepare_database $mysql_cmd, $user, $passwd, $db_server; 
}

sub processQueries {
    $dbh->do("INSERT INTO issues 
                        (borrowernumber, itemnumber,issuedate, date_due, branchcode)
                    VALUES ('52','153','2011-03-15','2011-03-25','BDM')
    ");

    $dbh->do("INSERT INTO issues 
                        (borrowernumber, itemnumber,issuedate, date_due, branchcode)
                    VALUES ('52','275','2011-03-15','2011-03-25','BDM')
    ");

    $dbh->do("INSERT INTO old_issues SELECT * FROM issues 
                                      WHERE borrowernumber = '52'
                                      AND itemnumber = '153'
    ");

    $dbh->do("INSERT INTO reserves (borrowernumber,biblionumber,reservedate,branchcode,constrainttype, priority,reservenotes,itemnumber,found,waitingdate,expirationdate) VALUES ('50','1234','2011-03-24','BDM','a', '1','',NULL,NULL,NULL,NULL)
    ");

    $dbh->do("INSERT INTO reserves (borrowernumber,biblionumber,reservedate,branchcode,constrainttype, priority,reservenotes,itemnumber,found,waitingdate,expirationdate) VALUES ('53','124','2011-03-24','BDM','a', '1','',NULL,NULL,NULL,NULL)
    ");

    my $data = {itemnumber => '153', variable => 'issue'};
    warn $statistics_table;
    is (&findInData ($statistics_table, $data), 1 , "issue stat for 153");
    is (&findInData ($statistics_table, {itemnumber => '275', variable => 'issue'}), 1 , "issue stat for 275");
    is (&findInData ($statistics_table, {itemnumber => '153', variable => 'return'}), 1 , "return stat for 153");
    is (&findInData ($statistics_table, {biblionumber => '1234', variable => 'reserve'}), 1 , "reserve stat for 1234");
    is (&findInData ($statistics_table, {biblionumber => '124', variable => 'reserve'}), 1 , "reserve stat for 124");
}

sub clean {
    Koha_Synchronize_System::tools::kss::clean $mysql_cmd, $user, $passwd, $db_server;
}

sub findInData {
    my ($table, $data, $out) = @_;
    my $results = C4::SQLHelper::SearchInTable ($table, $data, undef, undef, $out, undef, undef);
    my $size = scalar (@$results);
    return $size;
}
