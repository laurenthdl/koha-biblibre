#!/usr/bin/perl
# small script that deletes biblios which barcodes are in the parameter file.

use strict;

use MARC::File::USMARC;
use MARC::Record;
use MARC::Batch;
use C4::Context;
use C4::Biblio;
use C4::Items;
use Time::HiRes qw(gettimeofday);

use utf8;

use Getopt::Long;

sub DelItemCheck {
    my ( $dbh, $biblionumber, $itemnumber ) = @_;
    my $error;

    # check that there is no issue on this item before deletion.
    my $sth=$dbh->prepare("select * from issues i where i.itemnumber=?");
    $sth->execute($itemnumber);

    my $onloan=$sth->fetchrow;

    $sth->finish();
    if ($onloan){
        $error = "book_on_loan" 
    }else{
        # check it doesnt have a waiting reserve
        $sth=$dbh->prepare("SELECT * FROM reserves WHERE found = 'W' AND itemnumber = ?");
        $sth->execute($itemnumber);
        my $reserve=$sth->fetchrow;
        $sth->finish();
        if ($reserve){
            $error = "book_reserved";
        }else{
            DelItem($dbh, $biblionumber, $itemnumber);
            return 1;
        }
    }
    return $error;
}

my ( $input_file) = ('');
my ($version, $test_parameter,$char_encoding, $annexe, $verbose);
GetOptions(
    'file:s'    => \$input_file,
    'h' => \$version,
    't' => \$test_parameter,
    'v' => \$verbose
);

if ($version || ($input_file eq '')) {
	print <<EOF
Script pour supprimer des notices en serie dans Koha
Parametres :
\th : Cet ecran d'aide
\tfile /chemin/vers/fichier/fichier.codebarres : Le fichier contenant les code-barres a supprimer. Chaque code-barre est sur une ligne differente.
\tt : test mode : Ne fait rien, sauf parser le fichier.
\tv : verbose mode : Affiche tous les codes barre supprimés et les erreurs éventuelles qui ne sont pas importantes
SAMPLE : ./nettoie_bdp.pl -file /home/koha/liste_barcodes.txt
EOF
;#'
die;
}

my $dbh = C4::Context->dbh;
if ($test_parameter) {
	print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}
$|=1; # flushes output

my $starttime = gettimeofday;
open FILE, $input_file || die "erreur : fichier introuvable";

my $i=0;
#1st of all, find barcode MARC tag.
my ($tagfield,$tagsubfield) = &GetMarcFromKohaField("items.itemnumber",'');

my $sth_barcode = $dbh->prepare("SELECT biblionumber,itemnumber 
                                    FROM items 
                                    WHERE barcode=?");

# my $sth = $dbh->prepare("select biblionumber from marc_subfield_table where tag=$tagfield and subfieldcode='$tagsubfield' and subfieldvalue=?");

while ( my $barcode = <FILE> ) {
    # on supprime tout ce qui n'est pas numérique
     $barcode =~ s/\n//g;
     $barcode =~ s/\r//g;
#    $barcode =~ s/\D//g;
#    $barcode=~s/ |\x09//g;
    $i++;
    $sth_barcode->execute($barcode);
    my ($biblionumber,$itemnumber) = $sth_barcode->fetchrow;
    if ($test_parameter) {
        if ($biblionumber) {
                print "suppression du code barre $barcode\n" if $verbose;
        } else {
                print "Probleme avec le code barre $barcode : introuvable dans la base\n" if $verbose;
        }
    } else {
        if ($biblionumber) {
            # suppression exemplaire
            print "suppression du code barre $barcode " if $verbose;
            my $error = &DelItemCheck($dbh,$biblionumber,$itemnumber);
            if($error != 1){
                print "L'exemplaire $itemnumber (notice : $biblionumber) est encore en pret ou en reservation\n";
            }
            # on regarde s'il reste un exemplaire pour cette notice
            my $record = GetMarcBiblio($biblionumber);
            unless ($record->field($tagfield)) {
                print "et suppression notice biblio\n" if $verbose;
                &DelBiblio($biblionumber);
            } else {
                print "et conservation biblio, il reste des exemplaires attaches a biblionumber $biblionumber\n" if $verbose;
            }
        } else {
                print "Probleme avec le code barre $barcode : introuvable dans la base\n" if $verbose;
        }
        print "." if $verbose;
        my $timeneeded = gettimeofday - $starttime;
        print "$i in $timeneeded s\n" unless ($i % 50);
    }
# 	print "B : $barcode";
}
# $dbh->do("unlock tables");
my $timeneeded = gettimeofday - $starttime;
print "$i MARC record done in $timeneeded seconds\n";

