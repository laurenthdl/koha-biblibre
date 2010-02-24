#!/usr/bin/perl

use CGI;
use YAML qw/LoadFile/;
use IO::Socket::INET;
use Socket qw(:DEFAULT :crlf);
use FindBin qw/$Bin/;
use warnings;
use strict;
warn $Bin;
my $configfile=$ENV{CONFIG_MAGNETISE}||qq($Bin/etc/magnetise.yaml);
my $cgi    = CGI->new;
my $ip     = $cgi->param('ip');
my $op     = $cgi->param('op');
my $config = LoadFile($configfile);
my $socket = new IO::Socket::INET(PeerAddr => $ip,
    				PeerPort => $config->{'port'},
				    Proto	 => "tcp"
                	);
die "Could not create socket: $!\n" unless $socket; 
while (<$socket>) {
    print $_ "\n"; 
}
close($socket);
