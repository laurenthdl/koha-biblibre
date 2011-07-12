use Modern::Perl;

use C4::Context;

my $dbh = C4::Context->dbh;
use Getopt::Long;
my $version;
my $list;

GetOptions( 
    'm:s' => \$version,
    'l'   => \$list,
);

use Cwd 'abs_path';
use File::Basename;
my $script_path = abs_path($0);
my $script_dir = dirname($script_path);
my $VERSIONS_DIRNAME = 'versions';
my $VERSIONS_PATH = $script_dir . '/' . $VERSIONS_DIRNAME;

if ( $version ) {
    my @files = <$VERSIONS_PATH/$version(.pl)*>;
    if ( scalar @files != 1 ) {
        warn "This version ($version) returned more than one file (or any) corresponding!";
        exit 2;
    }
    print "$_\n" for @files;
}

if ( $list ) {
    opendir DH, $VERSIONS_PATH or die "Cannot open directory ($!)";
    my @versions = readdir DH;
    for my $v ( @versions ) {
        print "$v\n" unless ( ($v eq ".") || ($v eq "..") );
    }
    closedir DH;
}

