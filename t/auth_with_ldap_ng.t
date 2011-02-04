#! /usr/bin/perl
use Modern::Perl;
# use Test::More 'no_plan';
# use Devel::SimpleTrace;
use C4::Auth_with_ldap;

my $dbh = C4::Context->dbh;
C4::Auth_with_ldap::checkpw_ldap($dbh, qw/ toto tata /);
C4::Auth_with_ldap::checkpw_ldap($dbh, qw/ lefaucheur_lau Koha01Supelec2011 /);

# filter="(&amp;(objectClass=supelecPerson)(uid=%s))"
