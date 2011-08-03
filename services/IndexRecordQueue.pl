#!/usr/bin/perl -w

use Modern::Perl;
use Time::Progress;
use Fcntl qw(:flock SEEK_END);
use Tie::File;
#eval "require(App::Daemon)";
#die "App::Daemon not installed \nrun:\nsudo apt-get install libproc-daemon-perl\nor:\ncpan install Proc::Daemon\nto install\n" if $@;
use App::Daemon qw( daemonize );
use List::MoreUtils qw(uniq);
daemonize();

use threads;

use C4::Search;

use Data::Dumper;

$| = 1;

# 
my $filepath = '/tmp/records.txt';
my $max_records = 5;
my $max_delta = 10; # in seconds

my @records = get_records( $filepath ); # Get old records which have not been processed
my $records;

my $continue = 1;
my $thread;
while ( $continue ) {
    my $line = <STDIN>;
    chomp($line);
    my ( $recordtype, $recordids ) = build_record( $line );
    $$records{ $recordtype } = () if not defined $$records{ $recordtype };
    push @{ $$records{ $recordtype } }, @$recordids;
    @{ $$records{ $recordtype } } = uniq @{ $$records{ $recordtype } };
    if ( scalar( @{ $$records{$recordtype} } ) >= $max_records ) {

        say "Indexing !";

        # Delete entries in file
        open my $fh, ">", $filepath or die "Can't open $filepath: $!";
        lock_file( $fh );
        truncate $fh, tell $fh; # useless ?
        #tie my @lines, 'Tie::File', $filepath;
        #splice (@lines, 0, scalar( @{ $$records{$recordtype} } ));
        #untie @lines;
        unlock( $fh );
        close $fh;

        my @records_to_index = @{ $$records{ $recordtype } };;
        @{ $$records{ $recordtype } } = ();

        # Wait if precedent thread already running
        sleep 10 if defined $thread and $thread->is_running();

        # Launch indexation in a thread
        $thread = threads->new(\&launch_indexation, $recordtype, \@records_to_index);
    }
}

sub launch_indexation {
    my ( $recordtype, $recordids ) = @_;
    C4::Search::IndexRecord( $recordtype, $recordids );
}

sub lock_file {
    my ($fh) = @_;
    flock($fh, LOCK_EX) or die "Cannot lock $filepath - $!\n";

    # and, in case someone appended while we were waiting...
    seek($fh, 0, SEEK_END) or die "Cannot seek - $!\n";
}

sub unlock {
    my ($fh) = @_;
    flock($fh, LOCK_UN) or die "Cannot unlock $filepath - $!\n";
}

close (STDOUT);

sub get_records {
    my ( $filepath ) = @_;
    open my $fh, "<", $filepath;
    my @records;
    while ( my $line = <$fh> ) {
        chomp $line;
        my $record = build_record( $line );
        push @records, $record if defined $record;
    }
    close $fh;
    return @records;
}

sub build_record {
    my ( $line ) = @_;
    chomp $line;
    my @values = split ' ', $line;
    return undef if scalar( @values ) <= 2;
    my @recordids = @values[1 .. scalar(@values)-1];
    return ( $values[0], \@recordids );

}

1;
