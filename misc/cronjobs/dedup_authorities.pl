#!/usr/bin/perl
use Modern::Perl;
use C4::Context;
use C4::AuthoritiesMarc;
use C4::Search::Query;
use C4::Search;
use C4::Charset;
use C4::Debug;

use Getopt::Long;
use YAML;
use diagnostics;

my @matchstrings;
my ($verbose,$all,$help,$wherestring,$test);
my $result = GetOptions ("match=s"   => \@matchstrings      # string
                         , "verbose"  => \$verbose
                         , "all|a"  => \$all
                         , "test|t"  => \$test
                         , "help|h"   => \$help
                         , "where=s"   => \$wherestring
                        );  # flag

if ( $help || ! (@ARGV || $all)) {
    print_usage();
    exit 0;
}

my $dbh=C4::Context->dbh;
my $merge;
my $authtypes_ref=$dbh->selectcol_arrayref( qq{SELECT authtypecode, auth_tag_to_report FROM auth_types }, { Columns=>[1,2] });
my %authtypes=@$authtypes_ref;
my @authtypecodes= @ARGV ;
@authtypecodes = keys %authtypes unless(@authtypecodes);
unless (@matchstrings){
    @matchstrings=(qq{at/152b##auth-ppn/009});
#    @matchstrings=(qq{at/152b##he-main/2..a##he/2..bxyzt##ppn/009});
    #@matchstrings=(qq{authtype/152b##he-main,ext/2..a##he,ext/2..bxyz});
    #@matchstrings=(qq{sn,ne,st-numeric/001##authtype/152b##he-main,ext/2..a##he,ext/2..bxyz});
}

my @attempts=prepare_matchstrings(@matchstrings);

for my $authtypecode (@authtypecodes){
    $debug and warn $authtypecode;
    my @sqlparams;
    my $strselect= qq{SELECT authid, NULL FROM auth_header where authtypecode=?};
    push @sqlparams,$authtypecode;
    if ($wherestring){
        $strselect.=" and $wherestring";
    }
    my $auth_ref=$dbh->selectcol_arrayref( $strselect, { Columns=>[1,2] },@sqlparams);
    my $auth_tag=$authtypes{$authtypecode};
    my %authorities=@$auth_ref if ($auth_ref);
AUTH:    foreach my $authid (keys %authorities){
        #authority was marked as duplicate
        next if $authorities{$authid};
        my $authrecord=GetAuthority($authid);
        # next if cannot take authority
	    next unless $authrecord;
        SetUTF8Flag($authrecord);
        my $success;
ATTEMPT:        for my $attempt (@attempts) {
	    my $query=_build_query($authrecord,$attempt);
            warn _build_query($authrecord,$attempt);
	    next ATTEMPT unless $query=~/(he|ppn)=/;
            my $results=eval{SimpleSearch(C4::Search::Query->normalSearch($query))};
            if ($@ || !$results){
                warn $auth_tag;
                warn $@;
                next;
            }
            $debug and warn YAML::Dump($results);
            next if (!$results or scalar(@{$results->{items}})<1);
RECORD:     foreach my $rawrecord (@{$results->{items}}){
    		next if $authid eq $rawrecord->{values}->{recordid};
                my $marc=GetAuthority($rawrecord->{values}->{recordid}); 
                $debug and warn YAML::Dump($rawrecord);
                if ($marc->field('001') and ($marc->field('001')->data ne $authid)){ #This Part should always be true
                    SetUTF8Flag($marc);
                    my $localauthid=$marc->field('001')->data;
                    my $certainty=1;
                    my $choice=undef;
                    my $next=0;
                    if ($marc->field($auth_tag) and ! ($authrecord->field($auth_tag))){
                            $debug && warn "certainty 0 ",$marc->field($auth_tag)->as_string," ",$authrecord->field($auth_tag)->as_string;
                            $certainty=0;
                            $next=1;
                    }
                    elsif ($authrecord->field($auth_tag) && ! ($marc->field($auth_tag))){
                            $debug && warn "certainty 0 ",$marc->field($auth_tag)->as_string," ",$authrecord->field($auth_tag)->as_string;
                            $certainty=0;
                            $next=1;
                    }
                    for my $subfield qw(a b c d e f g i h x y z t){
                        if (compare_arrays([ trim($marc->subfield($auth_tag,$subfield))],[trim($authrecord->subfield($auth_tag,$subfield))])){
                            $debug && warn "certainty 1 ",$marc->subfield($auth_tag,$subfield)," ",$authrecord->subfield($auth_tag,$subfield);
                            $certainty=(1 and $certainty);
                        }
                        else {
                            $debug && warn "certainty 0 ",$marc->subfield($auth_tag,$subfield)," ",$authrecord->subfield($auth_tag,$subfield);
                            $certainty=0;
                            $next=1;
                        }
                        $next and next RECORD;
                    }
                    $choice=(CountUsage($authid)>CountUsage($localauthid));
                    $debug and warn $certainty;
                    if ($certainty){
                            $authorities{$localauthid}=1;
                            $merge++;
                            $verbose and print "$authid;".$authrecord->as_usmarc.";$localauthid;".$marc->as_usmarc.";$choice;merged\n";
			    unless ($test){
				if ($choice){
				    merge($authid,$authrecord,$localauthid,$marc);
				}
				else {
				    merge($localauthid,$marc,$authid,$authrecord);
				}
			    }
                     }
                }
            }
        }
        $authorities{$authid}=1;
    }
}
$verbose and print "$merge autorités fusionnées";
exit 1;

sub compare_arrays{
    my ($arrayref1,$arrayref2)=@_;
    return 0 if scalar(@$arrayref1)!=scalar(@$arrayref2);
    my $compare=1;
    for (my $i=0;$i<scalar(@$arrayref1);$i++){
        $compare = $compare and ($arrayref1->[$i] eq $arrayref2->[$i]); 
    }
    return $compare;
}

sub prepare_matchstrings {
    my @structure;
    for my $matchstring (@_) {
        my @andstrings      = split /##/,$matchstring;
        my @matchelements = map {
                                my $hash;
                                @$hash{qw(index subfieldtag)}=split '/', $_; 
                                @$hash{qw(tag subfields)}=($1,[ split (//, $2) ]) if $$hash{subfieldtag}=~m/([0-9\.]{3})(.*)/;
                                delete $$hash{subfieldtag};
                                $hash
                                } @andstrings;
        push @structure , \@matchelements;
    }
    return @structure;
}

#trims the spaces before and after a string
#and normalize the number of spaces inside
sub trim{
    map{
       my $value=$_;
       $value=~s/\s+$//g;
       $value=~s/^\s+//g;
       $value=~s/\s+/ /g;
       $value;
    }@_
}

sub prepare_strings{
    my $authrecord=shift;
    my $attempt=shift;
    my @stringstosearch;
    for my $field ($authrecord->field($attempt->{tag})){
        if ($attempt->{tag} le '009'){
            if ($field->data()){
                push @stringstosearch, trim($field->data());
            }
        }
        else {
            if ($attempt->{subfields}){
                for my $subfield (@{$attempt->{subfields}}){
                    push @stringstosearch, trim($field->subfield($subfield));
                }
            }
            else {
                push @stringstosearch,  trim($field->as_string());
            }

        }
    }
    return map {
                ( $_
                ?  qq<$$attempt{'index'}=\"$_\"> 
                : () )
            }@stringstosearch;
}

sub _build_query{
    my $authrecord=shift;
    my $attempt=shift;
    if ($attempt){
        my @strings_elements=map{
                                prepare_strings($authrecord,$_);
                            }@$attempt;
        $debug and warn join " and ",@strings_elements;
        return join " and ",@strings_elements;
    }
}

#=head2 SimpleSearch
#
#( $error, $results, $total_hits ) = SimpleSearch( $query, $offset, $max_results, [@servers] );
#
#This function provides a simple search API on the bibliographic catalog
#
#=over 2
#
#=item C<input arg:>
#
#    * $query can be a simple keyword or a complete CCL query
#    * @servers is optional. Defaults to biblioserver as found in koha-conf.xml
#    * $offset - If present, represents the number of records at the beggining to omit. Defaults to 0
#    * $max_results - if present, determines the maximum number of records to fetch. undef is All. defaults to undef.
#
#
#=item C<Output:>
#
#    * $error is a empty unless an error is detected
#    * \@results is an array of records.
#    * $total_hits is the number of hits that would have been returned with no limit
#
#=item C<usage in the script:>
#
#=back
#
#my ( $error, $marcresults, $total_hits ) = SimpleSearch($query);
#
#if (defined $error) {
#    $template->param(query_error => $error);
#    warn "error: ".$error;
#    output_html_with_http_headers $input, $cookie, $template->output;
#    exit;
#}
#
#my $hits = scalar @$marcresults;
#my @results;
#
#for my $i (0..$hits) {
#    my %resultsloop;
#    my $marcrecord = MARC::File::USMARC::decode($marcresults->[$i]);
#    my $biblio = TransformMarcToKoha(C4::Context->dbh,$marcrecord,'');
#
#    #build the hash for the template.
#    $resultsloop{title}           = $biblio->{'title'};
#    $resultsloop{subtitle}        = $biblio->{'subtitle'};
#    $resultsloop{biblionumber}    = $biblio->{'biblionumber'};
#    $resultsloop{author}          = $biblio->{'author'};
#    $resultsloop{publishercode}   = $biblio->{'publishercode'};
#    $resultsloop{publicationyear} = $biblio->{'publicationyear'};
#
#    push @results, \%resultsloop;
#}
#
#$template->param(result=>\@results);
#
#=cut
#
#sub SimpleSearch {
#    my ( $query, $offset, $max_results, $servers ) = @_;
#
#        # FIXME hardcoded value. See catalog/search.pl & opac-search.pl too.
#        my @servers = defined($servers) ? @$servers : ("biblioserver");
#        my @results;
#        my @zoom_queries;
#        my @tmpresults;
#        my @zconns;
#        my $total_hits;
#        return ( "No query entered", undef, undef ) unless $query;
#
#        # Initialize & Search Zebra
#        for ( my $i = 0 ; $i < @servers ; $i++ ) {
#            eval {
#                $zconns[$i] = C4::Context->Zconn( $servers[$i], 1 );
#                $zoom_queries[$i] = new ZOOM::Query::CCL2RPN( $query, $zconns[$i] );
#                $tmpresults[$i] = $zconns[$i]->search( $zoom_queries[$i] );
#
#                # error handling
#                my $error = $zconns[$i]->errmsg() . " (" . $zconns[$i]->errcode() . ") " . $zconns[$i]->addinfo() . " " . $zconns[$i]->diagset();
#
#                return ( $error, undef, undef ) if $zconns[$i]->errcode();
#            };
#            if ($@) {
#
#                # caught a ZOOM::Exception
#		#my $error = $@->message() . " (" . $@->code() . ") " . $@->addinfo() . " " . $@->diagset();
#                my $error = $@;
#                warn $error;
#                return ( $error, undef, undef );
#            }
#        }
#        while ( ( my $i = ZOOM::event( \@zconns ) ) != 0 ) {
#            my $event = $zconns[ $i - 1 ]->last_event();
#            if ( $event == ZOOM::Event::ZEND ) {
#
#                my $first_record = defined($offset) ? $offset + 1 : 1;
#                my $hits = $tmpresults[ $i - 1 ]->size();
#                $total_hits += $hits;
#                my $last_record = $hits;
#                if ( defined $max_results && $offset + $max_results < $hits ) {
#                    $last_record = $offset + $max_results;
#                }
#
#                for my $j ( $first_record .. $last_record ) {
#                    my $record = $tmpresults[ $i - 1 ]->record( $j - 1 )->raw();    # 0 indexed
#                    push @results, $record;
#                }
#            }
#        }
#
#        foreach my $result (@tmpresults) {
#            $result->destroy();
#        }
#        foreach my $zoom_query (@zoom_queries) {
#            $zoom_query->destroy();
#        }
#
#        return ( undef, \@results, $total_hits );
#}
#
sub print_usage {
    print <<_USAGE_;
$0: deduplicate authorities

Use this batch job to remove duplicate authorities

Parameters:
    --match  <matchstring>  matchstring  
                            is composed of : index1/tagsubfield1[##index2/tagsubfield2]
                            the matching will be done with an AND between all elements of ONE matchstring
                            tagsubfield can be 123a or 123abc or 123

                            If multiple match parameters are sent, then it will try to match in the order it is provided to the script.

    --where sqlstring       limit the deduplication to SOME authorities only
    --verbose               display logs
    --all                   deduplicate all authority type

    --help or -h            show this message.

Other paramters :
   Authtypecode to deduplicate authorities on  
exemple:
    $0 --match ident/009 --match he-main,ext/200a##he,ext/200bxz NC
    
Note : If launched with DEBUG=1 it will print more messages
_USAGE_
}
