#!/usr/bin/perl

use CGI;
use C4::Serials::Numberpattern;
use URI::Escape;
use strict;
use warnings;

my $input = new CGI;

my $numberpattern;
foreach (qw/ numberingmethod label1 label2 label3 add1 add2 add3
  every1 every2 every3 setto1 setto2 setto3 whenmorethan1 whenmorethan2
  whenmorethan3 numbering1 numbering2 numbering3 /) {
    $numberpattern->{$_} = $input->param($_);
}
# patternname is label in database
$numberpattern->{'label'} = $input->param('patternname');

my $numberpatternid = AddSubscriptionNumberpattern($numberpattern);

binmode STDOUT, ":utf8";
print $input->header(-type => 'text/plain', -charset => 'UTF-8');
print "{\"numberpatternid\":\"$numberpatternid\"}";
