#!/usr/bin/perl
# small script that import an iso2709 file into koha 2.0

# MAX BIBLIONUMBER : 3597 avant moulinette;
# delete from marc_subfield_table where bibid > (select bibid from marc_biblio where biblionumber=3597);
# delete from marc_word where bibid > (select bibid from marc_biblio where biblionumber=3597);
# delete from marc_biblio where biblionumber > 3597;
# delete from biblio where biblionumber >3597;
# delete from biblioitems where biblionumber >3597;
# delete from items where biblionumber >3597;
# delete from bibliosubject where biblionumber >3597;
# delete from additionalauthors where biblionumber >3597;

use strict;

use MARC::File::USMARC;
use Date::Calc;
use MARC::Record;
use MARC::Batch;
use C4::Context;
use C4::Biblio;
use C4::Items;
use C4::Charset;
use Time::HiRes qw(gettimeofday);
use IO::File;

use Getopt::Long;
my ( $input_marc_file) = ('');
my ($version, $test_parameter,$char_encoding, $annexe,$batch,$replace, $verbose);
GetOptions(
    'file:s'    => \$input_marc_file,
    'h' => \$version,
    't' => \$test_parameter,
    'c:s' => \$char_encoding,
    's:s' => \$annexe,
    'b' => \$batch,
    'r' => \$replace,
    'v' => \$verbose,
);

if ($version || ($input_marc_file eq '') || !$annexe) {
    print <<EOF
Script pour importer un fichier iso2709 dans Koha.
Paramètres :
\th : Cet écran d'aide
\tfile /chemin/vers/fichier/fichier.iso2709 : Le fichier à importer
\tt : test mode : Ne fait rien, sauf parser le fichier.
\tc : L'encodage des caractères. UNIMARC (valeur par défaut) ou MARC21
\ts : le site auquel ces notices sont prétées.
\tv : mode verbeux, affichant un maximum d'informations
EXEMPLE : ./import.pl -file /home/koha/bdp83-janvier.iso2709 -s VID

Valeurs possibles pour le site destinataire : 
\tBDP        | 
\tCAYLUS     | 
\tCAZALS     | 
\tFENEYROLS  | 
\tLAGUEPIE   | 
\tLOZE       | 
\tPARISOT    | 
\tPUYLAGARDE | 
\tQRGA       | 
\tST PROJET  | 
\tSTANTNV    | 
\tVAREN      | 
\tVERF/SEYE  | 


EOF
;#'/
die;
}

print "Analyse du fichier...\n";
my $fh = IO::File->new($input_marc_file); # don't let MARC::Batch open the file, as it applies the ':utf8' IO layer
my $batch = MARC::Batch->new( 'USMARC', $fh );

my $i=0;
while ( my $record = $batch->next() ) {
    $i++;
}

my $dbh = C4::Context->dbh;
if ($test_parameter) {
    print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}
$|=1; # flushes output

$char_encoding = 'UNIMARC' unless ($char_encoding);
my $starttime = gettimeofday;

my $fh = IO::File->new($input_marc_file); # don't let MARC::Batch open the file, as it applies the ':utf8' IO layer
my $batch = MARC::Batch->new( 'USMARC', $fh );
$batch->warnings_off();
$batch->strict_off();
my $i=0;
# Ou sont les exemplaires coté Koha ? (normalement 995)

my ($tagfield,$tagsubfield) = &GetMarcFromKohaField("items.itemnumber",'');

while ( my $record = $batch->next() ) {
# warn "AVANT :".$record->as_formatted;
    $i++;
    print "." if $verbose;
    my $isbn; # on met l'isbn de coté pour chercher si la notice existe déjà dans le catalogue
                # et ne créer que l'exemplaire le cas échéant
    my $timeneeded = gettimeofday - $starttime;
    print "$i in $timeneeded s\n" unless ($i % 50);
    #now, parse the record, extract the item fields, and store them in somewhere else.

    ## create an empty record object to populate
    my $newRecord = MARC::Record->new();

    # on affiche l'enregistrement s'il n'y a pas d'exemplaire
    #print $record->as_formatted unless $record->field("995");
    
    my $cote =$record->subfield("995",'k');
    #### detection du type de document ####
	my $itemtype = "LIVR";
	my $cote  = $record->subfield("995","k");
    print "================\n";
    print "title : ". $record->subfield('200','a');
    print "\ncote : $cote\n";
    my @subjectfields=$record->field('606');
    foreach my $field (@subjectfields) {
	$itemtype="CD" if $field->subfield('x')=~/Disques compacts/;
	last if $itemtype eq "CD";
    }
    $itemtype = "CD" if (
			($itemtype eq "CD") 
			and $cote =~ /^\d{3}(\.\d{1,3})? \w{2,4}$|^\d\s+\w{2,4}/
			);
    $itemtype = "CDR" if $cote =~ /^C /;
    $itemtype = "DVD" if $cote =~ /^D/;
    
    print "type de document : $itemtype\n";

    my $f200 = $record->field("200");
    $f200->add_subfields('b' => $itemtype);

    # go through each field in the existing record
    foreach my $oldField ( $record->fields() ) {
        # les champs qu'on ignore...
        next if $oldField->tag() eq '345';
        # on ignore le 001, c'est essentiel vu qu'on va mettre le biblionumber dedans ensuite !!!
        next if $oldField->tag() eq '001';
        
        # just reproduce tags < 010 in our new record
        if ( $oldField->tag() < 10 ) {
            $newRecord->append_fields( $oldField );
            next();
        }

        # store our new subfield data in this list
        my @newSubfields = ();
    
        # go through each subfield code/data pair
        foreach my $pair ( $oldField->subfields() ) { 
            $pair->[1] =~ s/\<//g;
            $pair->[1] =~ s/\>//g;
            # supprimer les - dans l'ISBN
            if ($oldField->tag() eq '010' && $pair->[0] eq 'a') {
                $pair->[1] =~ s/-//g;
                $isbn = $pair->[1];
            }
            # supprimer les () dans le titre
            if ($oldField->tag() eq '200' && $pair->[0] eq 'a') {
# 			warn "==>".$pair->[1];
                $pair->[1] =~ s/\x88//g;
                $pair->[1] =~ s/\x89//g;
            }
            # on ignore le 995$o (notforloan dans Koha)
            push( @newSubfields, $pair->[0], $pair->[1]) unless ($oldField->tag() eq 995 and $pair->[0] eq 'o');
        }
        # Ajouter le nouveau champ dans le MARC::Record, en déplaçant le 330 en 300 (indexation libre)
        my $newField;
        if ($oldField->tag() eq 330) {
            $newField = MARC::Field->new(
                300,
                $oldField->indicator(1),
                $oldField->indicator(2),
                @newSubfields
            );
        } elsif ($oldField->tag() eq 606) {
            $newField = MARC::Field->new(
                610,
                $oldField->indicator(1),
                $oldField->indicator(2),
                @newSubfields
            );
        } else {
            $newField = MARC::Field->new(
                $oldField->tag(),
                $oldField->indicator(1),
                $oldField->indicator(2),
                @newSubfields
            );
        }
        $newRecord->append_fields( $newField );
    }

    # on extrait les exemplaires...
    # print $newRecord->as_formatted."\n";
    my @fields = $newRecord->field($tagfield);
    my @items;
    my $nbitems=0;
    foreach my $field (@fields) {
        $newRecord->delete_field($field);
        my $item = MARC::Record->new();
        # on calcule la localisation...
        my $localisation='';
        $localisation = "Doc adultes"       if $cote =~ /^(\d{3}|B )/;
        $localisation = "BDA"               if $cote =~ /^BDA \w{3}/; # BD Ado
        $localisation = "BDX"               if $cote =~ /^X \w{3}/; # BD Adulte
        $localisation = "BD"                if $cote =~ /^BD \w{3}/; # BD enfant
        $localisation = "Doc jeunesse"      if $cote =~ /^J/;
        $localisation = "Espace enfant"     if $cote =~ /^(I|A|LEJ) /;
        $localisation = "Espace multimédia" if $cote =~ /^(C|E) /;
        $localisation = "Fiction jeunesse"     if $cote =~ /^(Ea|Ra) /;
        $localisation = "Espace local"     if $cote =~ /^FL /;
        $localisation = "Littérature adulte"     if $cote =~ /^(R|RP|Rt|LEA) /;
        
        $localisation = "Espace audiovisuel" if $itemtype =~ /CD|DVD/;
        
        print "localisation : $localisation\n";

        ###### Modification du public ########
        my $public = "a"; #adulte
        $public = "j" if $field->subfield("k") =~ /^(VJ|DJ|E|A|C|J)/;

        my $newField=MARC::Field->new('995','','','b' => "$annexe",
                                'c' => "$annexe",
                                'e' => "$localisation",
                                'f' => $field->subfield('f')."",
                                'k' => $field->subfield('k')."",
                                'm' => join('',Date::Calc::Today()),
                                'o' => 0,
                                'q' => $public?$public:($field->subfield('q')?$field->subfield('q'):'u'),
                                'u' => $field->subfield('u')."",
                                );
        $item->append_fields($newField);
        push @items,$item;
        $nbitems++;
#         print "ITEM : ".$item->as_formatted."\n";
    }
    # now, create biblio and items
    my $sth_barcode=$dbh->prepare("SELECT barcode FROM items WHERE barcode=?");
    my $sth_isbn = $dbh->prepare("SELECT biblionumber FROM biblioitems WHERE isbn=?");
    my ($guessed_charset, $charset_errors);
    ($newRecord, $guessed_charset, $charset_errors) = MarcToUTF8Record($newRecord, 'UNIMARC');
    my $frameworkcode='';
    
    my ($biblionumber,$biblioitemnumber);
    if ($replace) {
        for (my $i=0;$i<$nbitems;$i++) {
            my $itemfield = $items[$i];
            # remplacement de l'exemplaire. On cherche le biblionumber et l'itemnumber
            my $sth_itemnumber= $dbh->prepare("SELECT biblionumber,itemnumber,holdingbranch FROM items WHERE barcode=?");
            $sth_itemnumber->execute($itemfield->subfield('995','f'));
            my ($holdingbranch,$itemnumber);
            ($biblionumber,$itemnumber,$holdingbranch) = $sth_itemnumber->fetchrow;
            if ($itemnumber) {
#                 warn "ModItemFromMarc $biblionumber,$itemnumber,".$itemfield->subfield('995','f')." / ".$itemfield->as_formatted;
                ModItemFromMarc($itemfield,$biblionumber,$itemnumber);
            } else {
                print "code à barre ".$itemfield->subfield('995','f')." introuvable\n" if $verbose;
            }
        }
    } else {
        # création normale
        # on regarde si l'isbn existe déjà dans la base
        if ($isbn) {
            $sth_isbn->execute($isbn);
            ($biblionumber) = $sth_isbn->fetchrow;
        }
        # on crée la notice si elle n'existe pas déjà
        unless ($biblionumber) {
    #         warn "NR ($nbitems) : ".$newRecord->as_formatted;
            unless ($test_parameter) {
    #             print "AddBiblio fait\n";
                ($biblionumber,$biblioitemnumber) = AddBiblio($newRecord,$frameworkcode) if $nbitems>0;
            }
        } else {
            print "ISBN trouvé pour $isbn\n" if $verbose;
        }
        # on ajoute les exemplaires
        for (my $i=0;$i<$nbitems;$i++) {
            my $itemfield = $items[$i];
            # vérifions que le code-barre n'existe pas déjà...
            $sth_barcode->execute($itemfield->subfield('995','f'));
            my ($barcode) = $sth_barcode->fetchrow;
            if ($barcode) {
                print "Le code-barre $barcode est déjà dans la base, ligne non intégrée\n";
            } else {
                print "code-barre à intégrer : ".$itemfield->subfield('995','f')."\n" if $verbose or $test_parameter;
                unless ($test_parameter) {
                    AddItemFromMarc($itemfield,$biblionumber);
                }
            }
        }
    }
}
# $dbh->do("unlock tables");
my $timeneeded = gettimeofday - $starttime;
print "$i MARC record done in $timeneeded seconds\n";
