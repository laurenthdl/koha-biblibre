#! /usr/bin/perl
# vim: sw=4 ai
use Modern::Perl;
use Net::LDAP;
use Net::LDAP::LDIF;
use C4::Auth_with_ldap;
use LDAPSupelec;
my $ldap = C4::Auth_with_ldap->cnx;
my $out = Net::LDAP::LDIF->new(qw/ out.ldif w onerror die /);

my $config = C4::Context->config("ldapserver")
    or die qq[No "ldapserver" in server from KOHA_CONF: $ENV{KOHA_CONF}];

for my $site ( @{ $$config{branch} } ) {
    my $m = $ldap->search
    ( base     => $$site{dn}
    , filter   => '(&(objectClass=supelecPerson)(uid=*))'
    # , filter   => 'uid=missoffe'
    # , filter   => 'supelecMatriculeEleve=13262'
    , attrs    => \@LDAPSupelec::ATTRS
    , callback => sub {
	    my ( $m, $e ) = @_;
	    $e or return;
	    # $e->dump;
	    my $b = LDAPSupelec::get_borrower($e) or return;
	    # $e->dump;
	    say YAML::Dump(
	        { c => $$b{column}
	        , x => $$b{xattr}
	        }
	    );
	    # C4::Auth_with_ldap::accept_borrower( $b );
	    # $LDAPSupelec::rapport{ $$site{dn} }++;
	    # $m->shift_entry;
    }
);
    $m->code and die $m->error;
}

say YAML::Dump(\%LDAPSupelec::rapport);
