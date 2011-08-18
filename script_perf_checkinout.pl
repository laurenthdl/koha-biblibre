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
    my @cpan_classes = (
        {
            class => "HTTPD::Bench::ApacheBench",
            cpan => "HTTPD::Bench::ApacheBench"
        }
    );
    for my $class ( @cpan_classes ) {
        eval "require $$class{class}";
        die "$$class{class} not installed \nrun:\ncpan install $$class{cpan}\nto install\n" if $@;
    }
};

use Modern::Perl;
use Log::LogLite;
use Data::Dumper;
use DBI;
use HTTPD::Bench::ApacheBench;
use LWP::UserAgent;
use HTTP::Cookies;
use C4::Auth;
use C4::Circulation;
use C4::Members;


my $logger = Log::LogLite->new( "script_perf_checkinout.log", 7 );
$logger and $logger->template("<date> <message>\n");

my $baseurl     = $ARGV[0] || "http://admin.koha_master.localhost/cgi-bin/koha";
my $max_tries   = 200;
my $concurrency = 1;
my $user        = $ARGV[1] || 'test';
my $password    = $ARGV[2] || 'test';

# Authenticate via our handy dandy RESTful services
# and grab a cookie
my $ua          = LWP::UserAgent->new();
my $cookie_jar  = HTTP::Cookies->new();
my $cookie;
$ua->cookie_jar($cookie_jar);
my $resp = $ua->post( "$baseurl" . "/svc/authentication", { userid => $user, password => $password } );
if ( $resp->is_success ) {
    $cookie_jar->extract_cookies($resp);
    $cookie = $cookie_jar->as_string;
    $logger and $logger->write(" Authentication successful" );
    $logger and $logger->write(" Auth:\n" . $resp->content );
} else {
    $logger and $logger->write( "Authentication failed for user $user and password $password" );
}

# remove some unnecessary garbage from the cookie
$cookie =~ s/ path_spec; discard; version=0//;
$cookie =~ s/Set-Cookie3: //;

my $b = HTTPD::Bench::ApacheBench->new;
$b->concurrency($concurrency);

my $dbh = C4::Context->dbh;

my $MAX_ISSUES = 1;
my $MAX_RETURNS = 1;
my $query = "SELECT borrowernumber FROM borrowers WHERE dateexpiry > NOW() AND debarred IS NULL ORDER BY RAND() LIMIT 1;";
my $sth = $dbh->prepare($query);
$sth->execute();

my $borrowernumbers = $sth->fetchall_arrayref( {} );
my @borrowers = map { GetMemberDetails $$_{borrowernumber}, 0 } @$borrowernumbers;

$query = "SELECT barcode FROM items WHERE onloan IS NULL ORDER BY RAND() LIMIT $MAX_ISSUES;";
$sth = $dbh->prepare($query);
$sth->execute();

my @checkout_pages;
my @checkout_runs;
while (my $barcode = $sth->fetchrow ) {
    my $borrower = _rand( \@borrowers );

    $logger and $logger->write( "Checkout barcode $barcode for borrower " . $$borrower{borrowernumber} );
    my $run = HTTPD::Bench::ApacheBench::Run->new(
        {
            urls => [ $baseurl . "/circ/circulation.pl" ],
            cookies => [$cookie],
        }
    );
    my @postdata = ( "foo=foo&borrowernumber=" . $$borrower{borrowernumber} . "&barcode=$barcode&issueconfirmed=1bar=bar" );
    $run->postdata( \@postdata );

    $b->add_run( $run );

    # send HTTP request sequences to server and time responses
    my $ro = $b->execute;

}
$query = "SELECT it.barcode, b.cardnumber, b.borrowernumber FROM issues iss, borrowers b, items it WHERE iss.borrowernumber=b.borrowernumber AND iss.itemnumber=it.itemnumber ORDER BY RAND() LIMIT $MAX_RETURNS;";
$sth = $dbh->prepare($query);
$sth->execute();
my @checkin_pages;
my @checkin_runs;
while ( my ( $barcode, $cardnumber, $borrowernumber ) = $sth->fetchrow ) {

    $logger and $logger->write( "Checkin barcode $barcode for borrower $borrowernumber (cardnumber=$cardnumber)" );
    my $run = HTTPD::Bench::ApacheBench::Run->new(
        {
            urls => [ $baseurl . "/reserve/renewscript.pl" ],
            cookies => [$cookie],
        }
    );
    my @postdata = ( "foo=foo&borrowernumber=$borrowernumber&cardnumber=$cardnumber&barcodes[]=$barcode&destination=circ&bar=bar" );
    $run->postdata( \@postdata );

    $b->add_run( $run );

    # send HTTP request sequences to server and time responses
    my $ro = $b->execute;

}


sub _rand {
  my ( $arr ) = @_;
  my $rand = rand ( scalar @$arr - 1 );
  return @$arr[$rand];
}


