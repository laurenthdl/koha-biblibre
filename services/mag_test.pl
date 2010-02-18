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
my $config = LoadFile($configfile);
my $socket = new IO::Socket::INET(LocalAddr => $ip,
    				LocalPort => $config->{'port'},
                    Listen  =>1,
				    Proto	 => "tcp"
                	);
die "Could not create socket: $!\n" unless $socket; 
my $newsocket=$socket->accept;
while (<$newsocket>) {
    print "$_ \n"; 
}
close($newsocket);
