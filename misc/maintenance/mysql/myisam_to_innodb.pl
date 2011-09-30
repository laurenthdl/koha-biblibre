#!/usr/bin/perl
use strict;
use warnings;
use DBI;
my $debug=$ENV{DEBUG};
my $db_user=$ARGV[0] || '';
my $db_passwd=$ARGV[1] || ''
my $db_name = $ARGV[2] || '';

my $db=DBI->connect("DBI:mysql:mysql", $db_user, $db_passwd);
unless($db_name) {
    my $dbquery=$db->prepare(qq{show databases});
    $dbquery->execute;
    while (my $dbname=$dbquery->fetchrow){
        next unless $dbname=~/^koha/;
        $debug && warn $dbname;
        $db->do("use $dbname");
        my $tablequery=$db->prepare(qq{show tables});
        $tablequery->execute;
        while (my $tablename=$tablequery->fetchrow){
           $debug && warn "     $tablename"; 
           if ($tablename=~/sessions|zebraqueue|temp_upg_biblioitems|pending_offline_operations/)
           {
                $db->do(qq{ALTER TABLE $tablename engine=myisam});
           }
           else {
                $db->do(qq{ALTER TABLE $tablename engine=innodb});
           }
        }
    }
} else {
    $debug && warn $db_name;
    $db->do("use $db_name") or die "Invalid database name";
    my $tablequery = $db->prepare(qq{show tables});
    $tablequery->execute;
    while (my $tablename=$tablequery->fetchrow){
       $debug && warn "     $tablename";
       if ($tablename=~/sessions|zebraqueue|temp_upg_biblioitems|pending_offline_operations/)
       {
            $db->do(qq{ALTER TABLE $tablename engine=myisam});
       }
       else {
            $db->do(qq{ALTER TABLE $tablename engine=innodb});
       }
    }
}
