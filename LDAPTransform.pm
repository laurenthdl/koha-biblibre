#! /usr/bin/perl
package LDAPTransform;
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
    uid
    homeDirectory
    departmentNumber
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
uid
/];

our $typePersonne =
{ categorycode => 
    {qw/
    master	ETU
    /}
, to_ignore =>
    [qw/
    missing
    c3s
    exterieur
    fc
    moniteur
    moodle
    service
    test
    /]
#, with_caution => [qw/
#    eleve_ecp
#    doctorant-nonsupelec
#    post-doctorant
#    post-doctorant-cdi
#    post-doctorant-nonsupelec
#    stagiaire
#    stagiaire-cdd
#    /]
};

sub set_category_code (_) {
    my $user = shift;

    $$user{column}{categorycode} = 'ADULT';

}

sub set_cardnumber (_) {
    my $user = shift;
    $$user{column}{cardnumber} = $$user{src}{uid};
}

sub set_branchcode (_) {
    my $user = shift;

    $$user{column}{branchcode} = 'BIBA';
}

sub set_xattrs (_) {
    state $attr_for_ldap = {qw/
    departmentNumber	DPT
    homeDirectory	HOME_DIR
    /};

    my $user = shift;
    while ( my ( $ldap , $attr ) = each %$attr_for_ldap ) {
	if ( my $v = $$user{src}{$ldap} ) {
	    $$user{xattr}{$attr} = $v;
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
    set_branchcode( $user );
    set_xattrs( $user );

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

1;

