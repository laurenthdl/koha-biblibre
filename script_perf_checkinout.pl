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

$| = 1;

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

my $MAX_BORROWERS = 20;
my $MAX_ISSUES    = 2;
my $MAX_RETURNS   = 2;
my $SQL_LIMIT     = 100;

my $query = "SELECT borrowernumber FROM borrowers WHERE dateexpiry > NOW() AND debarred IS NULL LIMIT $SQL_LIMIT;";
my $sth = $dbh->prepare($query);
$sth->execute();

my @borrowernumbers = map { shift @$_ } @{ $sth->fetchall_arrayref };
@borrowernumbers = get_random_elements( \@borrowernumbers, $MAX_BORROWERS );
my @borrowers = map { GetMemberDetails $_, 0 } @borrowernumbers;
$query = "SELECT barcode FROM items WHERE onloan IS NULL LIMIT $SQL_LIMIT;";
$sth = $dbh->prepare($query);
$sth->execute();
my @barcodes = map { shift @$_ } @{ $sth->fetchall_arrayref };
my @barcodes4issues = get_random_elements( \@barcodes, $MAX_ISSUES );
my @checkout_pages;
my @checkout_runs;

for my $barcode ( @barcodes4issues ) {
    my $borrower = _rand( \@borrowers );

    my $run = HTTPD::Bench::ApacheBench::Run->new(
        {
            urls => [ $baseurl . "/circ/circulation.pl" ],
            cookies => [$cookie],
            user_message => "du blalbal",
        }
    );
    # postdata method is very stupid ? Without "foo" and "bar", data are truncated (or prefixed with \r) !?
    my @postdata = ( "foo=foo&borrowernumber=" . $$borrower{borrowernumber} . "&barcode=$barcode&issueconfirmed=1bar=bar" );
    $run->postdata( \@postdata );

    $$run{user_message} = "Checkout barcode $barcode for borrower " . $$borrower{borrowernumber};

    $b->add_run( $run );

}

# send HTTP request sequences to server and time responses
my $ro = $b->execute;
$logger and $logger->write( report_regress ( $ro, $b ) );

$query = <<EOQ;
SELECT it.barcode, b.cardnumber, b.borrowernumber
FROM issues iss, borrowers b, items it
WHERE iss.borrowernumber=b.borrowernumber
    AND iss.itemnumber=it.itemnumber
LIMIT $SQL_LIMIT;
EOQ
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
    # postdata method is very stupid ? Without "foo" and "bar", data are truncated (or prefixed with \r) !?
    my @postdata = ( "foo=foo&borrowernumber=$borrowernumber&cardnumber=$cardnumber&barcodes[]=$barcode&destination=circ&bar=bar" );
    $run->postdata( \@postdata );

    $b->add_run( $run );

}

# send HTTP request sequences to server and time responses
my $ro = $b->execute;
$logger and $logger->write( report_regress ( $ro, $b ) );

sub _rand {
  my ( $arr ) = @_;
  my $rand = int( rand ( scalar @$arr - 1 ) );
  return @$arr[$rand];
}

sub get_random_elements {
    my $arr = shift;
    my $nb_elt = shift || 1;
    $nb_elt = $nb_elt > scalar(@$arr) ? scalar($arr) : $nb_elt;
    my @r = sort { int(rand $arr) - int($arr / 2) } @$arr;
    return @r[0 .. $nb_elt-1] if $nb_elt <= scalar(@$arr);
    return @r;
}

sub report_regress {
    my ( $regress, $bench ) = @_;
    my $s = "\n";
    for my $runnumber ( grep { /run/ } keys %{$regress->{regression}} ) {
        $runnumber =~ s/run(\d+)/$1/;
        my $run = $$regress{regression}{"run$runnumber"}[0];
        $s .= ">>> $$bench{runs}[$runnumber]->{user_message}";
        $s .= "\tresponse times (in ms) for run $runnumber : $$run{total_response_time}";
        $s .= $$run{good}[0] == 0 ? "[KO]" : "[OK]";
        $s .= "\n";
    }
    return $s;
}
