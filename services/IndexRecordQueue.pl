#!/usr/bin/perl -w

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


BEGIN{
    my @classes = (
        {
            class => "App::Daemon",
            package => "libapp-daemon-perl"
        },
        {
            class => "File::Tail",
            package => "libfile-tail-perl"
        },
        {
            class => "Time::Progress",
            package => "libtime-progress-perl"
        },
        {
            class => "Log::LogLite",
            package => "liblog-loglite-perl"
        },
        {
            class => "Modern::Perl",
            package => "libmodern-perl-perl"
        }
    );

    for my $class ( @classes ) {
        eval "require $$class{class}";
        die "$$class{class} not installed \nrun:\nsudo apt-get install $$class{package} \nor:\ncpan install $$class{class}\nto install\n" if $@;
    }
};

use Modern::Perl;

use App::Daemon qw( daemonize );
use Data::Dumper;
use Fcntl qw(:flock SEEK_END);
use File::Tail;
use List::MoreUtils qw(uniq);
use Log::LogLite;
use Pod::Usage;
use Tie::File;
use Time::Progress;
use threads;

$App::Daemon::logfile = "/tmp/IndexRecordQueue.log";
$App::Daemon::pidfile = "/tmp/IndexRecordQueue.pid";

my $logger = Log::LogLite->new( $App::Daemon::logfile, 7 );

$| = 1;

# Defaults values
our $DEFAULT_MAX_RECORDS = 5;
our $DEFAULT_MAX_DELTA   = 30;
our $MAX_INTERVAL        = 1;
my $filepath = '/tmp/records.txt';
my $max_records;
my $max_delta;

if ( grep /-h/, @ARGV ) {pod2usage(1);} # Display full usage

# Get options
my %opts = ();
for my $opt (qw(-a -f -mr -ms)) {
    my $v = App::Daemon::find_option( $opt, 1 );
    $opts{ $opt } = $v if defined $v;
}

$filepath    = $opts{"-f"}  if defined $opts{"-f"};

$max_records = get_opt( $opts{"-mr"} ) || $DEFAULT_MAX_RECORDS;
$max_delta   = get_opt( $opts{"-ms"} ) || $DEFAULT_MAX_DELTA;

# If we want add records, we don't want to daemonize
if ( $opts{"-a"} ) {
    add( $opts{"-a"}, $filepath );
} else {
    daemonize();
}

# If we want status or add records, we want not require C4::Search
if ( not $opts{"-a"} and not grep /status/, @ARGV ) {
    require C4::Search;
    C4::Search->import(qw/IndexRecord/);
}

# Process previous records (ie. records already present in file)
process_previous_records( $filepath );

my %records;

# No wait because we want check on delay
my $file = File::Tail->new( name => $filepath, max_interval => $MAX_INTERVAL, nowait => 1 );

# Main loop
my $continue = 1; # We always continue
my $thread;
my $timer;
my $mr;
my $ms;
while ( $continue and defined( my $line = $file->read ) ) {
    # If we get a line, we build the corresponding record and add to the records array.
    if ( $line ) {
        chomp $line;
        my $record = build_record( $line );
        append( \%records, $record );

        # Initialize timer if not exists (ie. Is the first record for this recordtype)
        $$timer{ $$record{ recordtype } } = new Time::Progress
            if not defined $$timer{ $$record{ recordtype } };

        # Set value for max_records for this recordtype
        $$mr{ $$record{ recordtype } } or
            $$mr{ $$record{ recordtype } } = ref( $max_records ) eq 'HASH'
                ? $$max_records{ $$record{ recordtype } } || $DEFAULT_MAX_RECORDS
                : $max_records;

        # Set value for max_delta for this recordtype
        $$ms{ $$record{ recordtype } } or
            $$ms{ $$record{ recordtype } } = ref( $max_delta ) eq 'HASH'
                ? $$max_delta{ $$record{ recordtype } } || $DEFAULT_MAX_DELTA
                : $max_delta;

    }

    # If already exists records
    while ( my ( $recordtype, $recordids ) = each %records ) {
        next if scalar( @$recordids ) == 0; # In fact, there is no records

        # If one condition is true
        # - We have max records for this recordtype
        # - These records are waiting for enough
        if ( scalar( @$recordids ) >= $$mr { $recordtype }
                or int( $$timer{ $recordtype }->elapsed ) >= $$ms{ $recordtype } ) {
            # Lock file
            open my $fh, "+<", $filepath or die "Can't open $filepath: $!";
            lock_file( $fh );
            # Index records
            index_records( $recordtype, $recordids );
            # Remove theses records from file
            remove_indexed_records( $recordtype, $recordids, $fh );
            # Remove recordids for this recordtype
            $records{$recordtype} = [];
            # Unlock
            unlock( $fh );
            close $fh;
            # Réinitialize timer
            $$timer{ $recordtype } = undef;
        }
    }

    # We sleep. File::Tail no sleep with nowait = 1
    sleep $MAX_INTERVAL;
}

=head2 remove_indexed_records
Rewrite file without indexed records.
=cut
sub remove_indexed_records {
    my ( $recordtype, $recordids, $fh ) = @_;
    tie my @lines, 'Tie::File', $fh;
    for my $line ( @lines ) {
        $line =~ s/^$recordtype.*\K $_// for @$recordids;
        $line =~ s/^$recordtype$//;
    }
    @lines = grep {!/^$/} @lines;
    untie @lines;
}

=head2 append
Append a record into a hash containing all records.
Each recordids appears just one time.
=cut
sub append {
    my ( $records, $record ) = @_;

    my $recordtype = $$record{recordtype};
    my $recordids = $$record{recordids};
    $$records{ $recordtype } = () if not defined $$records{ $recordtype };
    push @{ $$records{ $recordtype } }, @$recordids;
    @{ $$records{ $recordtype } } = uniq @{ $$records{ $recordtype } };
}

=head2 process_previous_records

=cut
sub process_previous_records {
    my ( $filepath ) = @_;
    # We open a $fh for reading
    # and a $fh_lock for locking
    open my $fh, "<", $filepath or die "Can't open $filepath: $!";
    open my $fh_lock, ">>", $filepath or die "Can't open $filepath: $!";
    lock_file( $fh_lock );
    my %previous_records;
    # Get existing records in file
    while ( my $line = <$fh> ) {
        my $record = build_record( $line );
        next if not defined $record;
        append( \%previous_records, $record );
    }
    truncate $fh_lock, 0; # Truncate all the file
    unlock( $fh_lock ); # Release the lock
    close $fh;
    close $fh_lock;
    # Index previous records
    while ( my ( $recordtype, $recordids ) = each %previous_records ) {
        index_records( $recordtype, $recordids );
    }
}

=head2 index_records
Create a new thread for indexation if not already exists.
If exists, we sleep for 10''
=cut
sub index_records {
    my ( $recordtype, $recordids ) = @_;
    say "Indexing !";

    # Wait if precedent thread already running
    while ( defined $thread and $thread->is_running() ) {
        say "Precedent thread is already running, I'm going to sleep for 10''";
        sleep 10;
    }

    # Launch indexation in a thread
    $thread = threads->new(\&launch_indexation, $recordtype, $recordids);
}

=head2 launch_indexation
Launching indexation to call C4::Search::IndexRecord;
=cut
sub launch_indexation {
    my ( $recordtype, $recordids ) = @_;
    C4::Search::IndexRecord( $recordtype, $recordids );
}

=head2 lock_file
Put a lock on a filehandler
=cut
sub lock_file {
    my ($fh) = @_;
    flock($fh, LOCK_EX) or die "Cannot lock $filepath - $!\n";

    # and, in case someone appended while we were waiting...
    seek($fh, 0, SEEK_END) or die "Cannot seek - $!\n";
}

=head2 unlock
Release the lock on a filehandler
=cut
sub unlock {
    my ($fh) = @_;
    flock($fh, LOCK_UN) or die "Cannot unlock $filepath - $!\n";
}

=head2 buld_record
Building a record from a line
input must be "biblio 1 2 3" and we return a hash : 
{ recordtype => "biblio", recordids => [1, 2, 3] }
=cut
sub build_record {
    my ( $line ) = @_;
    chomp $line;
    my @values = split ' ', $line;
    return undef if scalar( @values ) <= 1;
    my @recordids = @values[1 .. scalar(@values)-1];
    return {
        recordtype => $values[0],
        recordids  => \@recordids
    };
}

=head2 add
Add a line into a file after have put a lock.
=cut
sub add {
    my ( $line, $filepath ) = @_;
    open my $fh, ">>", $filepath or die "Can' open $filepath: $!";
    lock_file( $fh );
    print $fh "$line\n";
    unlock( $fh );
    close $fh;
    exit;
}

=head2 get_opt
return values for -mr and -ms options
We can have :
 * -mr 5                      # Set to 5
 * -mr "authority:4;biblio:5" # Set to { authority => 4, biblio => 5 }
 * nothing                    # Set to undef
=cut
sub get_opt {
    my ( $opt ) = @_;
    my $max;
    if ( defined $opt and $opt =~ /^\d+$/ ) {
        $max = $opt;
    } elsif ( defined $opt ) {
        my @val = split ';', $opt;
        for my $v1 ( @val ) {
            my @vv = split ':', $v1;
            $$max{$vv[0]} = $vv[1];
        }
    } else {
        return undef;
    }
    return $max;
}

1;

__END__

=head1 NAME

IndexRecordQueue - Daemon for a management of an index queue

=head1 SYNOPSIS

./IndexRecordQueue [start|stop|status] [options]

Options:

-h  : help message

-a  : Add new line in file.

-f  : Set a filepath for manage records.

-mr : Max records in queue.

-ms : Max seconds before indexation.

=head1 OPTIONS

=over 8

=item B<-h>

Print a brief help message and exits.

=item B<-a>

Add new line in file (ex. "biblio 1 2 3" for pushing in queue an indexation of biblios with biblionumber = 1, 2 and 3).

=item B<-f>

Set a filepath for manage records (default is /tmp/records.txt. /tmp is not a good idea)

=item B<-mr>

Max records in queue. You can specify a specific max records before indexation.
              -mr 5  Index each type when we have 5 differents records for a recordtype
              -mr "authority:4;biblio:5" Index authorities when there is 4 authority id. The same with 5 biblios id

=item B<-ms>

Max seconds before indexation. Syntax : see -mr option.

=back

=head1 DESCRIPTION

B<IndexRecordQueue> is a daemon for an index queue management.

=cut
