use Modern::Perl;

use C4::Context;
use C4::Update::Database;
use Getopt::Long;


my $version;
my $list;

GetOptions( 
    'm:s' => \$version,
    'l'   => \$list,
);

if ( $version ) {
    my $report = C4::Update::Database::execute_version($version);
    warn Data::Dumper::Dumper $report;
}

if ( $list ) {
    #list_versions_availables();
    #list_versions_already_knows();
}
