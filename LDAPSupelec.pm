#! /usr/bin/perl
package LDAPSupelec;
use Modern::Perl;
use C4::Members;
use YAML;
use Net::LDAP::LDIF;

# attributs trouvés dans le ldapsearch:
# ldapsearch | perl -F: -wlanE ' END { say for sort keys %a } $F[0] ~~ /^\S/ and $a{$F[0]} = 1' 

our %rapport;
our @ATTRS = qw/
    givenName
    mail
    sn
    supelecBibCaution
    supelecCampusRattachement
    supelecDateEntree
    supelecDatePrevueSortie
    supelecDepartement
    supelecMatriculeEleve
    supelecNiveauScolaire
    supelecPromo
    supelecTypePersonne
    supelecUid
    supelecVoie
    uid
/;

our $VALID_LDAP_ATTRS = [qw/
cn
description
displayName
dn
gidNumber
givenName
homeDirectory
loginShell
mail
objectClass
sn
supelecBibCaution
supelecCampusRattachement
supelecDepartement
supelecEtatDuCompte
supelecMatricule
supelecMatriculeEleve
supelecMembreDe
supelecPromo
supelecTypePersonne
supelecUid
uid
uidNumber
/];

our $supelecTypePersonne =
{ categorycode => 
    {qw/
    personnel	PSUPELEC
    personnel-cdd	PERSLABO
    personnel-ext	PERSLABO
    vacataire	VAC
    eleve	ETU
    eleve_ecp	ETU
    doctorant	DOCTSUP
    doctorant-cdi	DOCTSUP
    doctorant-nonsupelec	DOCTLABO
    post-doctorant	PSUPELEC
    post-doctorant-cdi	PSUPELEC
    post-doctorant-nonsupelec	PERSLABO
    stagiaire	STAGEXT
    stagiaire-cdd	STAGSUP
    mastere	ETU
    master	ETU
    /}
, to_ignore =>
    [qw/
    MISSING
    c3s
    exterieur
    fc
    moniteur
    moodle
    service
    test
    /]
, with_caution => [qw/
    eleve_ecp
    doctorant-nonsupelec
    post-doctorant
    post-doctorant-cdi
    post-doctorant-nonsupelec
    stagiaire
    stagiaire-cdd
    /]
};

our %cardnumber_attribute_for_categorycode = qw/
DOCTLABO	supelecUid
DOCTSUP	supelecMatriculeEleve
ETU	supelecMatriculeEleve
PERSLABO	supelecUid
PSUPELEC	supelecUid
STAGEXT	supelecUid
STAGSUP	supelecUid
VAC	supelecUid
/;

sub set_category_code (_) {
    my $user = shift;
    my $type = $$user{src}{supelecTypePersonne};
    return if $type ~~ $$supelecTypePersonne{to_ignore};

    $$user{column}{categorycode} = $$supelecTypePersonne{categorycode}{$type}
    || do {
	push @{ $rapport{'supelecTypePersonne sans categorycode'}{$type}
	}, $$user{column}{userid};
	'ETU';
    };

}

sub set_cardnumber (_) {
    my $user = shift;
    my $cc = $$user{column}{categorycode}
	or die 'set_category_code must be called before set_cardnumber';

    my $cn_attr = $cardnumber_attribute_for_categorycode{ $cc }
    || do {
	$rapport{'pas de cardnumber attr pour categorycode'}{$cc}++;
	'MISSING';
    };

    my $cn = $$user{src}{$cn_attr}
    || do {
	$rapport{'valeur manquante pour le cardnumber'}{$cc}{$cn_attr}++;
	return;
    };

    for my $v ( $$user{column}{cardnumber} ) {
	$v && $cn ne $v
	    and $rapport{'divergence dans la detection du cardnumber'}{$v}{$cn}++;
	$v = $cn;
    }

}

sub set_branchcode (_) {
    my $user = shift;
    state $branchcode_for = {qw/
	gif BGIF
	Gif BGIF
	metz BMTZ
	Metz BMTZ
	rennes BREN
	Rennes BREN
    /};

    my $campus = $$user{src}{supelecCampusRattachement} or do {
	push @{ $rapport{supelecCampusRattachement}{missing} }
	, $$user{src}{dn};
	return
    };

    $$user{column}{branchcode} = $$branchcode_for{$campus} or do {
	$rapport{supelecCampusRattachement}{'with no branchcode'}{$campus}++;
	return
    };
}

sub set_xattrs (_) {
    state $attr_for_ldap = {qw/
    supelecDateEntree	ENTRE
    supelecDatePrevueSortie	SORTIE
    supelecPromo	PROMO
    supelecNiveauScolaire	NIVSCOl
    supelecVoie	VOIE
    supelecDepartement	SUPDPT
    /};

    my $user = shift;
    while ( my ( $ldap , $attr ) = each %$attr_for_ldap ) {
	if ( my $v = $$user{src}{$ldap} ) {
	    if ( $attr ~~ [qw/ ENTRE SORTIE /]  ) {
		$v =~ s/
		    (?<year>  \d{4} ) 
		    (?<month> \d{2} )
		    (?<day>   \d{2} )
		    .*
		    000000Z
		/$+{year}-$+{month}-$+{day}/x
		    or $rapport{"date pe foireuse"}{$v}++;
	    }
	    $$user{xattr}{$attr} = $v;
	}
    }

} 

sub set_caution_and_debarring (_) {
    my $user = shift;
    my $debarring_date = '9999-12-31';

    if ( my $caution = $$user{src}{supelecBibCaution} ) {
	'N' eq ($$user{xattr}{CAUTION} = $caution)
	    and $$user{column}{debarred} = $debarring_date;
	return
    }

    if ( $$user{src}{supelecTypePersonne} ~~ $$supelecTypePersonne{with_caution} ) {
	for ( $$user{column} ) {
	    $$_{cardnumber} = $$user{src}{supelecUid};
	    $$_{debarred}   = $debarring_date;
	}
    }
}

sub HashLdapEntry(_) {
    my $e = shift;
    $e->isa('Net::LDAP::Entry') or die;
    { dn => $e->dn
    , map {
	    my @v = $e->get_value( $_ );
	    $_ => @v > 1 ? \@v : shift @v;
	} $e->attributes(qw/ nooptions 1 /)
    };
}

sub get_borrower {
    state $today = (map { chomp; $_ } `date +%F`)[0];
    my $ldap_entry = shift;
    my $user = { src => HashLdapEntry( $ldap_entry ) };

    for
    ( [qw/ givenName firstname /]
    , [qw/ sn        surname   /]
    , [qw/ uid       userid    /]
    , [qw/ mail      email     /]
    ) { my ( $from, $to ) = @$_;
	$$user{column}{$to}
	= $$user{src}{$from};
    }

    set_category_code( $user ) or return;
    for ( $$user{column} ) {
	$$_{dateexpiry} = GetExpiryDate
	( $$_{categorycode}
	, $$_{dateenrolled} = $today
	) 
    }

    set_cardnumber( $user );
    set_branchcode( $user )
	or push @{ $rapport{'missing cardnumber'} }, $$user{src}{dn};
    set_xattrs( $user );
    set_caution_and_debarring( $user );
    my @missing_important_informations = grep { not defined $$user{column}{$_} } qw/
	userid cardnumber firstname surname categorycode branchcode
    /;

    if ( @missing_important_informations ) {
	# 0 and 
	say STDERR YAML::Dump(
		{ missing => \@missing_important_informations
		# , src     => $$user{src}
		, column  => $$user{column}
		}
	);
    }

    $user;
}

# unless (caller) {
#     my $ldif = Net::LDAP::LDIF->new( 'out.ldif', qw/ onerror die /);
#     while ( not $ldif->eof ) {
# 	my $e = $ldif->read_entry
# 	    or die $ldif->error . ' at ' . $ldif->error_lines;
# 	get_borrower( $e );
#     }
#     say Dump \%rapport;
# }

1;

