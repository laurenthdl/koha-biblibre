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
    my @files = <$VERSIONS_PATH/$version*>;
    if ( scalar @files != 1 ) {
        warn "This version ($version) returned more than one file (or any) corresponding!";
        exit 2;
    }
    my @file_infos = fileparse($files[0], qr/\.[^.]*/);
    my $extension = $file_infos[2];
    given ( $extension ) {
        when ( /.sql/ ) {

        }
        when ( /.pl/ ) {

        }
        default {
            warn "This extension ($extension) is not take into account (only .pl or .sql)";
        }
    }
}

if ( $list ) {
    opendir DH, $VERSIONS_PATH or die "Cannot open directory ($!)";
    my @versions = readdir DH;
    for my $v ( @versions ) {
        print "$v\n" unless ( ($v eq ".") || ($v eq "..") );
    }
    closedir DH;
}

