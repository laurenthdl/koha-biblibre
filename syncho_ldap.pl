#! /usr/bin/perl
# vim: sw=4 ai
use Modern::Perl;
use Net::LDAP;
use Net::LDAP::LDIF;
use C4::Auth_with_ldap;
use LDAPTransform;
my $ldap = C4::Auth_with_ldap->cnx;
my $out = Net::LDAP::LDIF->new(qw/ out.ldif w onerror die /);

my $config = C4::Context->config("ldapserver")
    or die qq[No "ldapserver" in server from KOHA_CONF: $ENV{KOHA_CONF}];

for my $site ( @{ $$config{branch} } ) {
warn $$site{dn};
    my $m = $ldap->search
    ( base     => $$site{dn}
    , filter   => '(&(uid=*))'
    , attrs    => \@LDAPTransform::ATTRS
    , callback => sub {
	    my ( $m, $e ) = @_;
	    $e or return;
	    $e->dump;
	    my $b = LDAPTransform::get_borrower($e) or return;
	     say YAML::Dump(
	         { c => $$b{column}
	         , x => $$b{xattr}
	         }
	     );
	    C4::Auth_with_ldap::accept_borrower( $b );
	    $LDAPSupelec::rapport{ $$site{dn} }++;
	    $m->shift_entry;
	}
    );
}

#say YAML::Dump(\%LDAPSupelec::rapport);
