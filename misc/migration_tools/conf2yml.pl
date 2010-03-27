#!/usr/bin/perl
use C4::Context;
use YAML;
open FILE, ">koha-conf.yml";
print FILE Dump($C4::Context::context);


