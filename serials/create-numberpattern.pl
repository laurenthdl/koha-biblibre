#!/usr/bin/perl

use CGI;
use C4::Serials::Numberpattern;
use URI::Escape;
use strict;
use warnings;

my $input = new CGI;

my $patternname = $input->param('patternname');
my $numberingmethod = $input->param('numberingmethod');
my $label1 = $input->param('label1');
my $label2 = $input->param('label2');
my $label3 = $input->param('label3');
my $add1 = $input->param('add1');
my $add2 = $input->param('add2');
my $add3 = $input->param('add3');
my $every1 = $input->param('every1');
my $every2 = $input->param('every2');
my $every3 = $input->param('every3');
my $setto1 = $input->param('setto1');
my $setto2 = $input->param('setto2');
my $setto3 = $input->param('setto3');
my $whenmorethan1 = $input->param('whenmorethan1');
my $whenmorethan2 = $input->param('whenmorethan2');
my $whenmorethan3 = $input->param('whenmorethan3');
my $numbering1 = $input->param('numbering1');
my $numbering2 = $input->param('numbering2');
my $numbering3 = $input->param('numbering3');

my $numberpatternid = AddNumberpattern($patternname, $numberingmethod,
    $label1, $label2, $label3, $add1, $add2, $add3,
    $every1, $every2, $every3, $setto1, $setto2, $setto3,
    $whenmorethan1, $whenmorethan2, $whenmorethan3,
    $numbering1, $numbering2, $numbering3);

binmode STDOUT, ":utf8";
print $input->header(-type => 'text/plain', -charset => 'UTF-8');
print "{\"numberpatternid\":\"$numberpatternid\"}";
