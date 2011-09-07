#!/usr/bin/perl

BEGIN{
    my @classes = (
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
use Log::LogLite;
use Data::Dumper;
use DBI;
use C4::Search;

$| = 1;

my $logger = Log::LogLite->new( "script_perf_idx.log", 7 );
$logger and $logger->template("<date> <message>\n");

my $dbh = C4::Context->dbh;

my $NB_BIBLIOS  = 100;
my $SQL_LIMIT   = 10000;

my $query = "SELECT biblionumber FROM biblio LIMIT $SQL_LIMIT;";
my $sth = $dbh->prepare($query);
$sth->execute();

my @biblionumbers = map { shift @$_ } @{ $sth->fetchall_arrayref };
@biblionumbers = get_random_elements( \@biblionumbers, $NB_BIBLIOS );

my $p = new Time::Progress;
$logger and $logger->write("START");
#for my $bn ( @biblionumbers ) {
#    $logger and $logger->write($bn);
#    AddToIndexQueue( "biblio", $bn );
#}

for ( 1 .. 25 ) {
    my $bn = shift @biblionumbers;    
    $logger and $logger->write($bn);
    AddToIndexQueue( "biblio", [$bn] );
    $bn = shift @biblionumbers;    
    $logger and $logger->write($bn);
    AddToIndexQueue( "biblio", [$bn] );
    $bn = shift @biblionumbers;    
    $logger and $logger->write($bn);
    AddToIndexQueue( "biblio", [$bn] );
    $bn = shift @biblionumbers;    
    $logger and $logger->write($bn);
    AddToIndexQueue( "biblio", [$bn] );
    sleep 4;
}

$logger and $logger->write("Elapsed for $NB_BIBLIOS biblios : " . $p->elapsed_str);
$logger and $logger->write("STOP");

sub get_random_elements {
    my $arr = shift;
    my $nb_elt = shift || 1;
    $nb_elt = $nb_elt > scalar(@$arr) ? scalar($arr) : $nb_elt;
    my @r = sort { int(rand $arr) - int($arr / 2) } @$arr;
    return @r[0 .. $nb_elt-1] if $nb_elt <= scalar(@$arr);
    return @r;
}

