use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More "no_plan";
use Test::Exception;

my $sel = Test::WWW::Selenium->new( host => "localhost", 
                                    port => 4444, 
                                    browser => "*chrome", 
                                    browser_url => "http://devsolr.biblibre.com/" );
my $expected = '';

# Basic search must return a result in pro

$sel->open_ok("/cgi-bin/koha/catalogue/search.pl");
$sel->type_ok("id=search-form", "*:*");
$sel->click_ok("css=#cat-search-block > input.submit");
$sel->wait_for_page_to_load_ok("30000");

$expected = /réponse\(s\) trouvée\(s\) pour|result\(s\) found for/;
$sel->is_text_present_ok($expected);
