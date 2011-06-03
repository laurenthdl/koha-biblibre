package C4::Serials::PredictiveModel;

use Modern::Perl;
use C4::Serials;

use vars qw(@ISA @EXPORT);
BEGIN {
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(ComputePredictiveModel);
}

sub ComputePredictiveModel {
    my ($freqid, $numpatternid, $lastvalue1, $lastvalue2, $lastvalue3) = @_;
    return undef unless ($freqid && $numpatternid);

    my $frequency = C4::Serials::GetSubscriptionFrequency($freqid);
    my $numberpattern = C4::Serials::GetSubscriptionNumberpattern($numpatternid);
    if(!defined $frequency || !defined $numberpattern) {
        return undef;
    }

    undef $lastvalue1 if (defined $lastvalue1 && $lastvalue1 eq '');
    undef $lastvalue2 if (defined $lastvalue2 && $lastvalue2 eq '');
    undef $lastvalue3 if (defined $lastvalue3 && $lastvalue3 eq '');

    my %predictivemodel;
    foreach ( qw(numberingmethod
                 add1 every1 whenmorethan1 setto1 numbering1 innerloop1
                 add2 every2 whenmorethan2 setto2 numbering2 innerloop2
                 add3 every3 whenmorethan3 setto3 numbering3 innerloop3) ) {
        $predictivemodel{$_} = $numberpattern->{$_} if(defined $numberpattern->{$_});
    }
    my %p = %{ \%predictivemodel };

    $p{'add3'} //= 1;
    $p{'setto3'} //= 1;
    $p{'numbering3'} //= '';
    $p{'lastvalue3'} = $lastvalue3 // 1;
    $p{'whenmorethan3'} //= 99999;
    $p{'every3'} //= 1;
    $p{'innerloop3'} //= 0;
    if($numberpattern->{'numberingmethod'} =~ /{Z}/) {
        $numberpattern->{'basedon3'} //= '';
        if($numberpattern->{'basedon3'} eq 'frequency') {
            $p{'whenmorethan3'} = $frequency->{'expectedissuesayear'};
        } elsif($numberpattern->{'basedon3'} eq 'dow') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon3'} eq 'dom') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon3'} eq 'doy') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon3'} eq 'week') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon3'} eq 'month') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon3'} eq 'year') {
            # TODO Get publication date
        }

        foreach ( qw(add3 every3 whenmorethan3 setto3 numbering3 innerloop3 lastvalue3) ) {
            $predictivemodel{$_} = $p{$_};
        }
    }

    $p{'add2'} //= 1;
    $p{'setto2'} //= 1;
    $p{'numbering2'} //= '';
    $p{'lastvalue2'} = $lastvalue2 // 1;
    $p{'whenmorethan2'} //= 99999;
    $p{'every2'} //= 1;
    $p{'innerloop2'} //= 0;
    if($numberpattern->{'numberingmethod'} =~ /{Y}/) {
        $numberpattern->{'basedon2'} //= '';
        if($numberpattern->{'basedon2'} eq 'value3') {
            $p{'every2'} = ($p{'whenmorethan3'} + $p{'add3'} - $p{'setto3'}) * $p{'every3'} / $p{'add3'};
            $p{'innerloop2'} = ($p{'lastvalue3'} - $p{'setto3'}) * $p{'every3'} / $p{'add3'} + $p{'innerloop3'};
        } elsif($numberpattern->{'basedon2'} eq 'frequency') {
            $p{'whenmorethan2'} = $frequency->{'expectedissuesayear'};
        } elsif($numberpattern->{'basedon2'} eq 'dow') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon2'} eq 'dom') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon2'} eq 'doy') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon2'} eq 'week') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon2'} eq 'month') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon2'} eq 'year') {
            # TODO Get publication date
        }
        foreach ( qw(add2 every2 whenmorethan2 setto2 numbering2 innerloop2 lastvalue2) ) {
            $predictivemodel{$_} = $p{$_};
        }
    }

    $p{'add1'} //= 1;
    $p{'setto1'} //= 1;
    $p{'numbering1'} //= '';
    $p{'lastvalue1'} = $lastvalue1 // 1;
    $p{'whenmorethan1'} //= 99999;
    $p{'every1'} //= 1;
    $p{'innerloop1'} //= 0;
    if($numberpattern->{'numberingmethod'} =~ /{X}/) {
        $numberpattern->{'basedon1'} //= '';
        if($numberpattern->{'basedon1'} eq 'value2') {
            $p{'every1'} = ($p{'whenmorethan2'} + $p{'add2'} - $p{'setto2'}) * $p{'every2'} / $p{'add2'};
            $p{'innerloop1'} = ($p{'lastvalue2'} - $p{'setto2'}) * $p{'every2'} / $p{'add2'} + $p{'innerloop2'};
        } elsif($numberpattern->{'basedon1'} eq 'value3') {
            $p{'every1'} = ($p{'whenmorethan3'} + $p{'add3'} - $p{'setto3'}) * $p{'every3'} / $p{'add3'};
            $p{'innerloop1'} = ($p{'lastvalue3'} - $p{'setto3'}) * $p{'every3'} / $p{'add3'} + $p{'innerloop3'};
        } elsif($numberpattern->{'basedon1'} eq 'frequency') {
            $p{'whenmorethan1'} = $frequency->{'expectedissuesayear'};
        } elsif($numberpattern->{'basedon1'} eq 'dow') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon1'} eq 'dom') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon1'} eq 'doy') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon1'} eq 'week') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon1'} eq 'month') {
            # TODO Get publication date
        } elsif($numberpattern->{'basedon1'} eq 'year') {
            # TODO Get publication date
        }
        if($numberpattern->{'whenmorethan1basedonfrequency'}) {
            $p{'whenmorethan1'} = $frequency->{'expectedissuesayear'}
        }
        if($numberpattern->{'every1basedonfrequency'}) {
            $p{'every1'} = $frequency->{'expectedissuesayear'}
        }
        foreach ( qw(add1 every1 whenmorethan1 setto1 numbering1 innerloop1 lastvalue1) ) {
            $predictivemodel{$_} = $p{$_};
        }
    }
    return \%predictivemodel;
}

1;
