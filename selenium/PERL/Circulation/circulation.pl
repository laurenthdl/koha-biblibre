use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More "no_plan";
use Test::Exception;
use DBI;
my $dbh=DBI->connect( "DBI:mysql:dbname=$ARGV[0];host=$ARGV[1];port=$ARGV[2]", $ARGV[3], $ARGV[4] ) or die $DBI::errstr;
my $sel = Test::WWW::Selenium->new( host => "localhost", 
                                    port => 4444, 
                                    browser => "*chrome", 
                                    browser_url => "http://devlimoges.biblibre.com/" );

$sel->open_ok("/cgi-bin/koha/circ/circulation.pl");
$sel->type_ok("userid", "mybiblibre");
$sel->type_ok("password", "monbiblibre");
$sel->click_ok("submit");
$sel->wait_for_page_to_load_ok("30000");
$sel->type_ok("findborrower", "Aaron Ann");
$sel->click_ok("ysearchsubmit");
$sel->wait_for_page_to_load_ok("30000");
my $barcodes=$dbh->selectall_arrayref("select barcode from items where homebranch='CENTRE' AND holdingbranch=('CENTRE') AND onloan IS NULL LIMIT 300",{});
use Data::Dumper;
warn Data::Dumper::Dumper($barcodes);
for my $item (@$barcodes){
    $sel->type_ok("barcode", $item->[0]);
    $sel->click_ok("//input[\@value='Check Out']");
    $sel->wait_for_page_to_load_ok("30000");
}
$sel->click_ok("link=Check In");
my $first=1;
for my $item (@$barcodes){
    if ($first){
        $sel->type_ok("ret_barcode", $item->[0]);
        $sel->click_ok("//div[\@id='checkin_search']/form/input[2]");
        $sel->wait_for_page_to_load_ok("30000");
        $first=0
    } else {
        $sel->type_ok("barcode", $item->{barcode});
        $sel->click_ok("//div[\@id='yui-main']/div[2]/form/div/fieldset/input[2]");
    }
}
