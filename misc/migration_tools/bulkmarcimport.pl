#!/usr/bin/perl
# Import an iso2709 file into Koha 3

use strict;
use warnings;

#use diagnostics;
BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

# Koha modules used
use MARC::File::USMARC;
use MARC::File::XML;
use MARC::Record;
use MARC::Batch;
use MARC::Charset;

use C4::Context;
use C4::Biblio;
use C4::Koha;
use C4::Debug;
use C4::Charset;
use C4::Items;
use YAML;
use Unicode::Normalize;
use Time::HiRes qw(gettimeofday);
use Getopt::Long;
use IO::File;
use Pod::Usage;

use open qw( :std :utf8 );
binmode( STDOUT, ":utf8" );

my ( $input_marc_file, $number, $offset ) = ( '', 0, 0 );
my ( $version, $delete, $skip_marc8_conversion, $char_encoding, $verbose, $commit, $fk_off, $format, $biblios, $authorities, $keepids, $match, $isbn_check, $logfile, $yamlfile );
my ( $sourcetag, $sourcesubfield, $idmapfl );
my ( $insert, $filters, $update, $all, $test_parameter );

$| = 1;

GetOptions(
    'commit:f'      => \$commit,
    'file:s'        => \$input_marc_file,
    'n:f'           => \$number,
    'o|offset:f'    => \$offset,
    'h'             => \$version,
    'd'             => \$delete,
    't|test'        => \$test_parameter,
    's'             => \$skip_marc8_conversion,
    'c:s'           => \$char_encoding,
    'v:s'           => \$verbose,
    'fk'            => \$fk_off,
    'm:s'           => \$format,
    'l:s'           => \$logfile,
    'k|keepids:s'   => \$keepids,
    'b|biblios'     => \$biblios,
    'a|authorities' => \$authorities,
    'filter=s@'     => \$filters,
    'insert'        => \$insert,
    'update'        => \$update,
    'all'           => \$all,
    'match=s@'      => \$match,
    'i|isbn'        => \$isbn_check,
    'x:s'           => \$sourcetag,
    'y:s'           => \$sourcesubfield,
    'idmap:s'       => \$idmapfl,
    'yaml:s'        => \$yamlfile,
);
$biblios ||= !$authorities;
$insert  ||= !$update;

if ($all) {
    $insert = 1;
    $update = 1;
}

if ( $version || ( $input_marc_file eq '' ) ) {
    print <<EOF
Small script to import bibliographic records into Koha.

Parameters:
  h      this version/help screen
  file   /path/to/file/to/dump: the file to import
  v      verbose mode. 1 means "some infos", 2 means "MARC dumping"
  fk     Turn off foreign key checks during import.
  n      the number of records to import. If missing, all the file is imported
  o      file offset before importing, ie number of records to skip.
  commit the number of records to wait before performing a 'commit' operation
  l file logs actions done for each record and their status into file
  t      test mode: parses the file, saying what he would do, but doing nothing.
  s      skip automatic conversion of MARC-8 to UTF-8.  This option is 
         provided for debugging.
  c      the characteristic MARC flavour. At the moment, only MARC21 and 
         UNIMARC are supported. MARC21 by default.
  d      delete EVERYTHING related to biblio in koha-DB before import. Tables:
         biblio, biblioitems, titems
  m      format, MARCXML or ISO2709 (defaults to ISO2709)
  yaml file  format a yaml file with ids
  keepids field store ids in field (usefull for authorities, where 001 contains the authid for Koha, that can contain a very valuable info for authorities coming from LOC or BNF. useless for biblios probably)
  x      source bib tag for reporting the source bib number
  y      source subfield for reporting the source bib number
  idmap  file for the koha bib and source id
  keepids store ids in 009 (usefull for authorities, where 001 contains the authid for Koha, that can contain a very valuable info for authorities coming from LOC or BNF. useless for biblios probably)
  b|biblios type of import : bibliographic records
  a|authorities type of import : authority records
  match  matchindex,fieldtomatch matchpoint to use to deduplicate
          fieldtomatch can be either 001 to 999 
                       or field and list of subfields as such 100abcde
  test   if set, test mode only, donot add anything in database
  insert if set, only insert when possible
  update if set, only updates (any biblio should have a matching record)
  all    if set, do whatever is required
  i|isbn if set, a search will be done on isbn, and, if the same isbn is found, the biblio is not added. It's another
         method to deduplicate. 
         match & i can be both set.
IMPORTANT: don't use this script before you've entered and checked your MARC 
           parameters tables twice (or more!). Otherwise, the import won't work 
           correctly and you will get invalid data.

SAMPLE: 
  \$ export KOHA_CONF=/etc/koha.conf
  \$ perl misc/migration_tools/bulkmarcimport.pl -d -commit 1000 \\
    -file /home/jmf/koha.mrc -n 3000
EOF
;#'
      exit;
}

if ( defined $idmapfl ) {
    open( IDMAP, ">$idmapfl" ) or die "cannot open $idmapfl \n";
}

if ( ( not defined $sourcesubfield ) && ( not defined $sourcetag ) ) {
    $sourcetag      = "910";
    $sourcesubfield = "a";
}

my $dbh = C4::Context->dbh;

# save the CataloguingLog property : we don't want to log a bulkmarcimport. It will slow the import &
# will create problems in the action_logs table, that can't handle more than 1 entry per second per user.
my $CataloguingLog = C4::Context->preference('CataloguingLog');
$dbh->do("UPDATE systempreferences SET value=0 WHERE variable='CataloguingLog'");

if ($fk_off) {
    $dbh->do("SET FOREIGN_KEY_CHECKS = 0");
}

if ($delete) {
    if ($biblios) {
        print "deleting biblios\n";
        $dbh->do("truncate biblio");
        $dbh->do("truncate biblioitems");
        $dbh->do("truncate items");
    } else {
        print "deleting authorities\n";
        $dbh->do("truncate auth_header");
    }
    $dbh->do("truncate zebraqueue");
}

if ($test_parameter) {
    print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}

my $marcFlavour = C4::Context->preference('marcflavour') || 'MARC21';

print "Characteristic MARC flavour: $marcFlavour\n" if $verbose;
my $starttime = gettimeofday;
my $batch;
my $fh = IO::File->new($input_marc_file);    # don't let MARC::Batch open the file, as it applies the ':utf8' IO layer
if ( defined $format && $format =~ /XML/i ) {

    # ugly hack follows -- MARC::File::XML, when used by MARC::Batch,
    # appears to try to convert incoming XML records from MARC-8
    # to UTF-8.  Setting the BinaryEncoding key turns that off
    # TODO: see what happens to ISO-8859-1 XML files.
    # TODO: determine if MARC::Batch can be fixed to handle
    #       XML records properly -- it probably should be
    #       be using a proper push or pull XML parser to
    #       extract the records, not using regexes to look
    #       for <record>.*</record>.
    $MARC::File::XML::_load_args{BinaryEncoding} = 'utf-8';
    my $recordformat = ( $marcFlavour eq "MARC21" ? "USMARC" : uc($marcFlavour) );

    #UNIMARC Authorities have a different way to manage encoding than UNIMARC biblios.
    $recordformat = $recordformat . "AUTH" if ( $authorities and $marcFlavour ne "MARC21" );
    $MARC::File::XML::_load_args{RecordFormat} = $recordformat;
    $batch = MARC::Batch->new( 'XML', $fh );
} else {
    $batch = MARC::Batch->new( 'USMARC', $fh );
}
$batch->warnings_off();
$batch->strict_off();
my $i = 0;
my $commitnum = $commit ? $commit : 50;
my $yamlhash;

# Skip file offset
if ($offset) {
    print "Skipping file offset: $offset records\n";
    $batch->next() while ( $offset-- );
}

my ( $tagid, $subfieldid );
if ($authorities) {
    $tagid = '001';
} else {
    ( $tagid, $subfieldid ) = GetMarcFromKohaField( "biblio.biblionumber", '' );
    $tagid ||= "001";
}

# the SQL query to search on isbn
my $sth_isbn = $dbh->prepare("SELECT biblionumber,biblioitemnumber FROM biblioitems WHERE isbn=?");

$dbh->{AutoCommit} = 0;
my $loghandle;
if ($logfile) {
    $loghandle = IO::File->new( $logfile, "w" );
    print $loghandle "id;operation;status\n";
}
RECORD: while () {
    my $record;

    # get records
    eval { $record = $batch->next() };
    if ($@) {
        print "Bad MARC record: skipped\n";

        # FIXME - because MARC::Batch->next() combines grabbing the next
        # blob and parsing it into one operation, a correctable condition
        # such as a MARC-8 record claiming that it's UTF-8 can't be recovered
        # from because we don't have access to the original blob.  Note
        # that the staging import can deal with this condition (via
        # C4::Charset::MarcToUTF8Record) because it doesn't use MARC::Batch.
        next;
    }

    # skip if we get an empty record (that is MARC valid, but will result in AddBiblio failure
    last unless ($record);
    $i++;
    print ".";
    print "\r$i" unless $i % 100;

    # transcode the record to UTF8 if needed & applicable.
    if ( $record->encoding() eq 'MARC-8' and not $skip_marc8_conversion ) {

        # FIXME update condition
        my ( $guessed_charset, $charset_errors );
        ( $record, $guessed_charset, $charset_errors ) = MarcToUTF8Record( $record, $marcFlavour . ( ( $authorities and $marcFlavour ne "MARC21" ) ? 'AUTH' : '' ) );
        if ( $guessed_charset eq 'failed' ) {
            warn "ERROR: failed to perform character conversion for record $i\n";
            next RECORD;
        }
    }
    SetUTF8Flag($record);
    my $isbn;

    # remove trailing - in isbn (only for biblios, of course)
    if ($biblios) {
        if ( $marcFlavour eq 'UNIMARC' ) {
            if ( my $f010 = $record->field('010') ) {
                if ( $f010->subfield('a') ) {
                    $isbn = $f010->subfield('a');
                    $isbn =~ s/-//g;
                    $f010->update( 'a' => $isbn );
                }
            }
        } else {
            if ( my $f020 = $record->field('020') ) {
                $isbn = $f020->subfield('a');
                $isbn =~ s/-//g;
                $f020->update( 'a' => $isbn );
            }
        }
    }
    my $id;

    # search for duplicates (based on Local-number)
    my $originalid;
    $originalid = GetRecordId( $record, $tagid, $subfieldid );
    if ($match) {
        require C4::Search;
        my $query = build_query( $match, $record );
        my $server = ( $authorities ? 'authorityserver' : 'biblioserver' );
        $debug && warn $query;
        my ( $error, $results, $totalhits ) = C4::Search::SimpleSearch( $query, 0, 3, [$server] );
        die "unable to search the database for duplicates : $error" if ( defined $error );
        $debug && warn "$query $server : $totalhits";
        if ( $results && scalar(@$results) == 1 ) {
            my $marcrecord = MARC::File::USMARC::decode( $results->[0] );
            SetUTF8Flag($marcrecord);
            $id = GetRecordId( $marcrecord, $tagid, $subfieldid );
            if ( $authorities && $marcFlavour ) {

                #Skip if authority in database is the same as the on in database
                if ( $marcrecord->field('005')->data >= $record->field('005')->data ) {
                    if ($yamlfile) {
                        $yamlhash->{$originalid}->{'authid'} = $id;

                        # On récupère tous les souschamps des champs vedettes d'autorités
                        my @subfields;
                        foreach my $field ( $marcrecord->field("2..") ) {
                            push @subfields, map { ( $_->[0] =~ /[a-z]/ ? $_->[1] : () ) } $field->subfields();
                        }
                        $yamlhash->{$originalid}->{'subfields'} = \@subfields;
                    }
                    next;
                }
            }
        } elsif ( $results && scalar(@$results) > 1 ) {
            $debug && warn "more than one match for $query";
        } else {
            $debug && warn "nomatch for $query";
        }
    }
    if ($keepids) {
        if ($originalid) {
            my $storeidfield;
            if ( length($keepids) == 3 ) {
                $storeidfield = MARC::Field->new( $keepids, $originalid );
            } else {
                $storeidfield = MARC::Field->new( substr( $keepids, 0, 3 ), "", "", substr( $keepids, 3, 1 ), $originalid );
            }
            $record->insert_fields_ordered($storeidfield);
            $record->delete_field( $record->field($tagid) );
        }
    }
    foreach my $stringfilter (@$filters) {
        if ( length($stringfilter) == 3 ) {
            foreach my $field ( $record->field($stringfilter) ) {
                $record->delete_field($field);
                $debug && warn "removed : ", $field->as_string;
            }
        } else {
            my ( $removetag, $removesubfield, $removematch ) = ( $1, $2, $3 )
              if $stringfilter =~ /([0-9]{3})([a-z0-9])(.*)/;
            if ( ( $removetag > "010" ) && $removesubfield ) {
                foreach my $field ( $record->field($removetag) ) {
                    $field->delete_subfield( code => "$removesubfield", match => $removematch );
                    $debug && warn "Potentially removed : ", $field->subfield($removesubfield);
                }
            }
        }
    }
    if ($authorities) {
        use C4::AuthoritiesMarc;
        my $authtypecode = GuessAuthTypeCode($record);
        my $authid = ( $id ? $id : GuessAuthId($record) );
        if ( $authid && GetAuthority($authid) && $update ) {
            ## Authority has an id and is in database : Replace
            ( !$test_parameter ) and eval { ($authid) = ModAuthority( $authid, $record, $authtypecode ) };
            if ($@) {
                warn "Problem with authority $authid Cannot Modify";
                printlog( { id => $originalid || $id || $authid, op => "edit", status => "ERROR" } ) if ($logfile);
            } else {
                printlog( { id => $originalid || $id || $authid, op => "edit", status => "ok" } ) if ($logfile);
            }
        } elsif ( defined $authid ) {
            ## An authid is defined but no authority in database : add
            ( !$test_parameter ) and eval { ($authid) = AddAuthority( $record, $authid, $authtypecode ) };
            if ($@) {
                warn "Problem with authority $authid Cannot Add " . $@;
                printlog( { id => $originalid || $id || $authid, op => "insert", status => "ERROR" } ) if ($logfile);
            } else {
                printlog( { id => $originalid || $id || $authid, op => "insert", status => "ok" } ) if ($logfile);
            }
        } else {
            ## True insert in database
            ( !$test_parameter ) and eval { ($authid) = AddAuthority( $record, "", $authtypecode ) };
            if ($@) {
                warn "Problem with authority $authid Cannot Add" . $@;
                printlog( { id => $originalid || $id || $authid, op => "insert", status => "ERROR" } ) if ($logfile);
            } else {
                printlog( { id => $originalid || $id || $authid, op => "insert", status => "ok" } ) if ($logfile);
            }
        }
        if ($yamlfile) {
            $yamlhash->{$originalid}->{'authid'} = $authid;
            my @subfields;
            foreach my $field ( $record->field("2..") ) {
                push @subfields, map { ( $_->[0] =~ /[a-z]/ ? $_->[1] : () ) } $field->subfields();
            }
            $yamlhash->{$originalid}->{'subfields'} = \@subfields;
        }
    } else {
        my ( $biblionumber, $biblioitemnumber, $itemnumbers_ref, $errors_ref );
        $biblionumber = $id;

        # check for duplicate, based on ISBN (skip it if we already have found a duplicate with match parameter
        if ( !$biblionumber && $isbn_check && $isbn ) {

            #         warn "search ISBN : $isbn";
            $sth_isbn->execute($isbn);
            ( $biblionumber, $biblioitemnumber ) = $sth_isbn->fetchrow;
        }
        if ( defined $idmapfl ) {
            if ( $sourcetag < "010" ) {
                if ( $record->field($sourcetag) ) {
                    my $source = $record->field($sourcetag)->data();
                    printf( IDMAP "%s|%s\n", $source, $biblionumber );
                }
            } else {
                my $source = $record->subfield( $sourcetag, $sourcesubfield );
                printf( IDMAP "%s|%s\n", $source, $biblionumber );
            }
        }

        # create biblio, unless we already have it ( either match or isbn )
        if ($biblionumber) {
            eval { $biblioitemnumber = GetBiblioData($biblionumber)->{biblioitemnumber}; };
            if ($update) {
                ( !$test_parameter ) and eval { ( $biblionumber, $biblioitemnumber ) = ModBiblio( $record, $biblionumber, GetFrameworkcode($biblionumber) ) };
                if ($@) {
                    warn "ERROR: Edit biblio $biblionumber failed: $@\n";
                    printlog( { id => $id || $originalid || $biblionumber, op => "update", status => "ERROR" } ) if ($logfile);
                    next RECORD;
                } else {
                    printlog( { id => $id || $originalid || $biblionumber, op => "update", status => "ok" } ) if ($logfile);
                }
            } else {
                printlog( { id => $id || $originalid || $biblionumber, op => "insert", status => "warning : already in database" } ) if ($logfile);
            }
        } else {
            if ($insert) {
                ( !$test_parameter ) and eval { ( $biblionumber, $biblioitemnumber ) = AddBiblio( $record, '', { defer_marc_save => 1 } ) };
                if ($@) {
                    warn "ERROR: Adding biblio $biblionumber failed: $@\n";
                    printlog( { id => $id || $originalid || $biblionumber, op => "insert", status => "ERROR" } ) if ($logfile);
                    next RECORD;
                } else {
                    printlog( { id => $id || $originalid || $biblionumber, op => "insert", status => "ok" } ) if ($logfile);
                }
            } else {
                printlog( { id => $id || $originalid || $biblionumber, op => "update", status => "warning : not in database" } ) if ($logfile);
            }
        }
        ( !$test_parameter ) and eval { ( $itemnumbers_ref, $errors_ref ) = AddItemBatchFromMarc( $record, $biblionumber, $biblioitemnumber, '' ); };
        if ($@) {
            warn "ERROR: Adding items to bib $biblionumber failed: $@\n";
            printlog( { id => $id || $originalid || $biblionumber, op => "insertitem", status => "ERROR" } ) if ($logfile);

            # if we failed because of an exception, assume that
            # the MARC columns in biblioitems were not set.
            ModBiblioMarc( $record, $biblionumber, '' );
            next RECORD;
        } else {
            printlog( { id => $id || $originalid || $biblionumber, op => "insertitem", status => "ok" } ) if ($logfile);
        }
        if ( $#{$errors_ref} > -1 ) {
            report_item_errors( $biblionumber, $errors_ref );
        }
        $yamlhash->{$originalid} = $biblionumber if ($yamlfile);
    }
    $dbh->commit() if ( 0 == $i % $commitnum );
    last if $i == $number;
}
$dbh->commit();

if ($fk_off) {
    $dbh->do("SET FOREIGN_KEY_CHECKS = 1");
}

# restore CataloguingLog
$dbh->do("UPDATE systempreferences SET value=$CataloguingLog WHERE variable='CataloguingLog'");

my $timeneeded = gettimeofday - $starttime;
print "\n$i MARC records done in $timeneeded seconds\n";
if ($logfile) {
    print $loghandle "file : $input_marc_file\n";
    print $loghandle "$i MARC records done in $timeneeded seconds\n";
    $loghandle->close;
}
if ($yamlfile) {
    open YAML, "> $yamlfile" or die "cannot open $yamlfile \n";
    print YAML Dump($yamlhash);
}
exit 0;

sub GetRecordId {
    my $marcrecord = shift;
    my $tag        = shift;
    my $subfield   = shift;
    my $id;
    if ( $tag lt "010" ) {
        return $marcrecord->field($tag)->data() if $marcrecord->field($tag);
    } elsif ($subfield) {
        if ( $marcrecord->field($tag) ) {
            return $marcrecord->subfield( $tag, $subfield );
        }
    }
    return $id;
}

sub build_query {
    my $match  = shift;
    my $record = shift;
    my @searchstrings;
    foreach my $matchingpoint (@$match) {
        my $string = build_simplequery( $matchingpoint, $record );
        push @searchstrings, $string if ( length($string) > 0 );
    }
    return join( " and ", @searchstrings );
}

sub build_simplequery {
    my $element = shift;
    my $record  = shift;
    my ( $index, $recorddata ) = split /,/, $element;
    my ( $tag, $subfields ) = ( $1, $2 ) if ( $recorddata =~ /(\d{3})(.*)/ );
    my @searchstrings;
    foreach my $field ( $record->field($tag) ) {
        if ( length( $field->as_string("$subfields") ) > 0 ) {
            push @searchstrings, "$index,wrdl=\"" . $field->as_string("$subfields") . "\"";
        }
    }
    return join( " and ", @searchstrings );
}

sub report_item_errors {
    my $biblionumber = shift;
    my $errors_ref   = shift;

    foreach my $error ( @{$errors_ref} ) {
        my $msg        = "Item not added (bib $biblionumber, item tag #$error->{'item_sequence'}, barcode $error->{'item_barcode'}): ";
        my $error_code = $error->{'error_code'};
        $error_code =~ s/_/ /g;
        $msg .= "$error_code $error->{'error_information'}";
        print $msg, "\n";
    }
}

sub printlog {
    my $logelements = shift;
    print $loghandle join( ";", map { defined $_ ? $_ : "" } @$logelements{qw<id op status>} ), "\n";
}

=head1 NAME

bulkmarcimport.pl - Import bibliographic/authority records into Koha

=head1 USAGE

 $ export KOHA_CONF=/etc/koha.conf
 $ perl misc/migration_tools/bulkmarcimport.pl -d -commit 1000 \\
    -file /home/jmf/koha.mrc -n 3000

=head1 WARNING

Don't use this script before you've entered and checked your MARC parameters
tables twice (or more!). Otherwise, the import won't work correctly and you
will get invalid data.

=head1 DESCRIPTION

=over

=item  B<-h>

This version/help screen

=item B<-b, -biblios>

Type of import: bibliographic records

=item B<-a, -authorities>

Type of import: authority records

=item B<-file>=I<FILE>

The I<FILE> to import

=item  B<-v>

Verbose mode. 1 means "some infos", 2 means "MARC dumping"

=item B<-fk>

Turn off foreign key checks during import.

=item B<-n>=I<NUMBER>

The I<NUMBER> of records to import. If missing, all the file is imported

=item B<-o, -offset>=I<NUMBER>

File offset before importing, ie I<NUMBER> of records to skip.

=item B<-commit>=I<NUMBER>

The I<NUMBER> of records to wait before performing a 'commit' operation

=item B<-l>

File logs actions done for each record and their status into file

=item B<-t>

Test mode: parses the file, saying what he would do, but doing nothing.

=item B<-s>

Skip automatic conversion of MARC-8 to UTF-8.  This option is provided for
debugging.

=item B<-c>=I<CHARACTERISTIC>

The I<CHARACTERISTIC> MARC flavour. At the moment, only I<MARC21> and
I<UNIMARC> are supported. MARC21 by default.

=item B<-d>

Delete EVERYTHING related to biblio in koha-DB before import. Tables: biblio,
biblioitems, items

=item B<-m>=I<FORMAT>

Input file I<FORMAT>: I<MARCXML> or I<ISO2709> (defaults to ISO2709)

=item B<-k, -keepids>=<FIELD>

Field store ids in I<FIELD> (usefull for authorities, where 001 contains the
authid for Koha, that can contain a very valuable info for authorities coming
from LOC or BNF. useless for biblios probably)

=item B<-match>=<FIELD>

I<FIELD> matchindex,fieldtomatch matchpoint to use to deduplicate fieldtomatch
can be either 001 to 999 or field and list of subfields as such 100abcde

=item B<-i,-isbn>

If set, a search will be done on isbn, and, if the same isbn is found, the
biblio is not added. It's another method to deduplicate.  B<-match> & B<-isbn>
can be both set.

=item B<-x>=I<TAG>

Source bib I<TAG> for reporting the source bib number

=item B<-y>=I<SUBFIELD>

Source I<SUBFIELD> for reporting the source bib number

=item B<-idmap>=I<FILE>

I<FILE> for the koha bib and source id

=item B<-keepids>

Store ids in 009 (usefull for authorities, where 001 contains the authid for
Koha, that can contain a very valuable info for authorities coming from LOC or
BNF. useless for biblios probably)

=back

=cut

