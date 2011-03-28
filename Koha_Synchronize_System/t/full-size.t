use Modern::Perl;
use DBI;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;
use DateTime;
use POSIX qw(strftime);
use YAML;

use Koha_Synchronize_System::tools::kss;

qx{./init.sh};

qx{perl ../tools/kss.pl}
