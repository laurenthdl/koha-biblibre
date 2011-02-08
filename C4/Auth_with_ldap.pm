package C4::Auth_with_ldap;
# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Digest::MD5 qw(md5_base64);
use C4::Debug;
use C4::Context;
use C4::Members qw/ GetMember AddMember changepassword /;
use C4::Members::Attributes qw/ SetBorrowerAttributes /;
use C4::Members::AttributeTypes;
use C4::Utils qw( :all );
use List::MoreUtils qw( any );
use Net::LDAP;
use Net::LDAP::Filter;
use parent 'Exporter';
require YAML;

our $VERSION = 3.10;                 # set the version for version checking
our @ISA     = qw(Exporter);
our @EXPORT  = qw( checkpw_ldap );

# return the ref of the subroutine
sub load_subroutine {
    require Package::Stash;
    my ( $module, $sub ) = @_;
    my $stash = Package::Stash->new($module);
    unless ( %{ $stash->namespace } ) {
	eval "require $module";
	$@ and die $@;
    }
    $stash->get_package_symbol('&'.$sub);
}

# Redefine checkpw_ldap:
# connect to LDAP (named or anonymous)
# ~ retrieves $userid from KOHA_CONF mapping
# ~ then compares $password with userPassword
# ~ then gets the LDAP entry
# ~ and calls the memberadd if necessary

sub ldapserver_error ($) {
    return sprintf( 'No ldapserver "%s" defined in KOHA_CONF: ' . $ENV{KOHA_CONF}, shift );
}

# constants 
sub DEBUG         { 0 }
sub LDAP_CANTBIND { 'LDAP_CANTBIND' }

sub debug_msg { DEBUG and say STDERR @_ }
sub logger { say STDERR YAML::Dump @_ }

use vars qw($mapping @ldaphosts $base $ldapname $ldappassword);
my $context  = C4::Context->new()                or die 'C4::Context->new failed';
my $ldap     = C4::Context->config("ldapserver") or die 'No "ldapserver" in server hash from KOHA_CONF: ' . $ENV{KOHA_CONF};

my ( $prefhost, $base ) = ('')x2;

unless ( $$ldap{authmethod} ) {
    say STDERR "deprecated ldap configuration, see documentation";
    $base = $$ldap{base} or die ldapserver_error('base');
    $prefhost = $$ldap{hostname} or die ldapserver_error('hostname');
}

$ldapname     = $ldap->{user};
$ldappassword = $ldap->{pass};
our %mapping = %{ $ldap->{mapping} || {} };    # FIXME dpavlin -- don't die because of || (); from 6eaf8511c70eb82d797c941ef528f4310a15e9f9
my @mapkeys = keys %mapping;
$debug and print STDERR "Got ", scalar(@mapkeys), " ldap mapkeys (  total  ): ", join ' ', @mapkeys, "\n";
@mapkeys = grep { defined $mapping{$_}->{is} } @mapkeys;
$debug and print STDERR "Got ", scalar(@mapkeys), " ldap mapkeys (populated): ", join ' ', @mapkeys, "\n";

my %config = (
    anonymous => ( $ldapname and $ldappassword ) ? 0 : 1,
    replicate => defined( $ldap->{replicate} ) ? $ldap->{replicate} : 1,    #    add from LDAP to Koha database for new user
    update    => defined( $ldap->{update} )    ? $ldap->{update}    : 1,    # update from LDAP to Koha database for existing user
);

sub description ($) {
    my $result = shift or return undef;
    return "LDAP error #" . $result->code . ": " . $result->error_name . "\n" . "# " . $result->error_text . "\n";
}

sub search_method {
    my $db        = shift                                        or return;
    my $userid    = shift                                        or return;
    my $uid_field = $mapping{userid}->{is}                       or die ldapserver_error("mapping for 'userid'");
    my $filter    = Net::LDAP::Filter->new("$uid_field=$userid") or die "Failed to create new Net::LDAP::Filter";
    my $res = ( $config{anonymous} ) ? $db->bind : $db->bind( $ldapname, password => $ldappassword );
    if ( $res->code ) {    # connection refused
        warn "LDAP bind failed as ldapuser " . ( $ldapname || '[ANONYMOUS]' ) . ": " . description($res);
        return 0;
    }
    my $search = $db->search(
        base   => $base,
        filter => $filter,

        # attrs => ['*'],
    ) or die "LDAP search failed to return object.";
    my $count = $search->count;
    if ( $search->code > 0 ) {
        warn sprintf( "LDAP Auth rejected : %s gets %d hits\n", $filter->as_string, $count ) . description($search);
        return 0;
    }
    if ( $count != 1 ) {
        warn sprintf( "LDAP Auth rejected : %s gets %d his\n", $filter->as_string, $count );
        return 0;
    }
    return $search;
}

# $cnx is an Net::LDAP object that dies when error occurs
# $search_params are params for the search method (default base is the one set in the config)

# TODO:
# this function name suck: find something more generic around koha manager auth and anonymous one

sub _anon_search {

    my ( $cnx, $search ) = @_;

    my $entry;
    for my $branch ( @{ $$ldap{branch} } ) {
	debug_msg "search $$search{filter} at $$branch{dn}";

	my $branch_search = { %$search, base => $$branch{dn}, search => "ObjectClass=*" };
	$entry = eval {
	    $cnx
	    ->search( %$branch_search )
	    ->shift_entry
	};

	if ( $entry ) {
	    debug_msg "found ", $entry->dn;
	    return { entry => $entry, branch => $branch }
	}
	elsif ( $@  ) { return { qw/ error UNKNOWN msg /, $@ }        } 
	else { DEBUG and logger { "failed search" => $branch_search } }
    }
}

sub set_xattr {
    my ( $id, $borrower ) = @_;
    if ( my $x = $$borrower{xattr} ) {
#SetBorrowerAttributes is not managing when being sent an Array ref
	my $attrs = [ map
                    {
                        my $key=$_;
                        if (ref ($$x{$key}) eq "ARRAY"){
                            foreach my $value (@{$$x{$key}}){
                                +{ code => $key, value => $value }
                            }
                        }
                        else {
                            +{ code => $key, value => $$x{$key} }
                        }
                    }
                    , keys %$x ];
	DEBUG and logger { "creating $id" => $attrs };
	SetBorrowerAttributes( $id, $attrs );
    }
}

# sub raising_error (&) {
#     my ( $block ) = @_;
#     my $RaiseError;
#     my $dbh = C4::Context->dbh;
#     $RaiseError = $$dbh{RaiseError};
#     $$dbh{RaiseError} = 1;
#     eval { $block->() };
#     $$dbh{RaiseError} = $RaiseError;
# }

sub accept_borrower {
    my ($borrower,$userid) = @_;
    for ( $$borrower{column}{userid} ) {
	$userid ||= $_ or die;
	unless ( $_ ) {
	    $_ = $userid;
	    next;
	}
	unless ( $userid ~~ $_ ) {
	    warn "userid $_ don't match authentication credential $userid";
	    return 0;
	}
    }

    my $id = ( GetMember( userid => $userid ) || {} )->{borrowernumber}
	or debug_msg "$userid is newcommer";

    my $newcommer = not defined $id;

    # for ($$ldap{dry_run}) {
    #     if ( $_ && not /no/) {
    #         DEBUG and logger
    #         { ( $newcommer ? 'newcommer' : 'existing_user' )
    #         , { map { $_, $$borrower{$_} } qw/ column xattr / }
    #         };
    #         return 0;
    #     }
    # }

    if ( $newcommer ) {
	return 0 unless $config{update};
	DEBUG and logger { Member => $$borrower{column} };
	$id = AddMember( %{ $$borrower{column} } ) or return 0;
	# raising_error { AddMember( %{ $$borrower{column} } ) };
	# if ( $@ || not defined $id ) {
	#     DEBUG and logger { $@, $$borrower{column} };
	#     return 0;
	# }
    } else {
	if ( $config{replicate} ) {
	    my $cardnumber = update_local
	    ( $userid, $$borrower{column}{password}, $id, $$borrower{column} ); 
	    if ( my $old_cardnumber = $$borrower{column}{cardnumber} ) {
		if ( $cardnumber ne $cardnumber ) {
		    warn "update_local returned cardnumber '$cardnumber' instead of '$old_cardnumber'";
		    return 0;
		}
	    }
	}
    }

    if ( $newcommer || $config{update} ) {
	DEBUG and logger { "changing attrs for $id" => $$borrower{xattr} };
	set_xattr $id,$borrower;
    }

    return 1
}

sub cnx {
	state $cnx = Net::LDAP->new( $$ldap{uri}, qw/ onerror die / ) or do {
	    warn "ldap error: $!";
	};
    # bind MUST success
    my $msg = eval { $cnx->bind ( $$ldap{manager}, password => $$ldap{password} ) };
    debug_msg "ldap $_:", $msg->$_ for qw/ error code /;
    if ( $@ ) { return {qw/ error LDAP_CANTBIND msg /, $@} };
	$cnx;
}



sub checkpw_ldap {
    my ( $dbh, $userid, $password ) = @_;
    my @hosts = split( ',', $prefhost );
    my $db = Net::LDAP->new( \@hosts );
    my $to_borrower = {};

    my $uattr
    =  $$ldap{userid_from} 
    || $$ldap{mapping}{userid}{is}
	or die "userid mapping not set";

    # $userldapentry is a crappy global value user at bottom
    # of this fonction to build the koha user 
    my $userldapentry;

    if ( $$ldap{authmethod} ) {

	# TODO: do this test sooner ? 
	for ( $$ldap{branch} ) {
	    $_ or die "no branch, no auth";
	    ref $_ ~~ 'HASH' and $_ = [$_];
	}

	# This code is an attempt to introduce a new codebase that can be hookable
	# and can mangage more cases than the old way

	# if the filter isn't set, userid mapping is used
	$$ldap{filter} ||= "$uattr=%s";

	my $cnx = cnx or return 0;

	# login can be either ...
	my $login = do {

	    # An Active Directory principal_name. Just replace the %s by the userid
	    # well ... don't try if not AD
	    if ( $$ldap{authmethod} ~~ [qw/ principal_name principalname principalName /] ) {
		sprintf( $$ldap{principal_name}, $userid )
	    }

	    # for other LDAP implementation, the standard way is to
	    # A) Bind with the manager account and search for the DN of the user entry
	    # B) Bind with the user DN and password.
	    # Auth is completed if bind success.
	    # so in this code;
	    # - i fill $userldapentry for later use
	    # - i return the DN

	    elsif ( $$ldap{authmethod} ~~ [qw/ searchdn searchDn search_dn /] ) {

		$to_borrower = _anon_search
		( $cnx
		, { filter => sprintf( $$ldap{filter}, $userid ) }
		) or do {
		    debug_msg "no answer from ldap";
		    return 0;
		};

		if ( $$to_borrower{error} ) {
		    say STDERR $$to_borrower{msg};
		    return 0;
		} 

		# TODO:
		# here comes the branch by branch mapping
		# $$result{branch}{mapping} 

		$userldapentry = $$to_borrower{entry} or do {
		    debug_msg "no entry returned? weird ...";
		};

		# login is the dn of the entry
		if ( $userldapentry ) { $userldapentry->dn }
		else {
		    say STDERR "can't authenticate $userid";
		    return 0;
		}
	    } else {
		say STDERR "$$ldap{authmethod} authmethod is invalid,"
		, "please check your ldap configuration in $ENV{KOHA_CONF}"
		;
		return 0;
	    }
	};

	eval { $cnx->bind( $login, password => $password ) };
	if ( $@ ) {
	    say STDERR "ldap bind with $login failed: $@";
	    return 0;
	}
	debug_msg "congrats, you're one of us";
    } else {
	# This is the old stuff: 
	#
	#$debug and $db->debug(5);
	if ( $ldap->{auth_by_bind} ) {
	    my $principal_name = $ldap->{principal_name};
	    if ( $principal_name and $principal_name =~ /\%/ ) {
		$principal_name = sprintf( $principal_name, $userid );
	    } else {
		$principal_name = $userid;
	    }
	    my $res = $db->bind( $principal_name, password => $password );
	    if ( $res->code ) {
		$debug and warn "LDAP bind failed as kohauser $principal_name: " . description($res);
		return 0;
	    }

	    # FIXME dpavlin -- we really need $userldapentry leater on even if using auth_by_bind!
	    my $search = search_method( $db, $userid ) or return 0;    # warnings are in the sub
	    $userldapentry = $search->shift_entry;

	} else {
	    # i wish this would NEVER EVER BE !
	    say STDERR "deprecated kludge: use authmethod search_dn instead";
	    my $search = search_method( $db, $userid ) or return 0;    # warnings are in the sub
	    $userldapentry = $search->shift_entry;
	    my $cmpmesg = $db->compare( $userldapentry, attr => 'userpassword', value => $password );
	    if ( $cmpmesg->code != 6 ) {
		warn "LDAP Auth rejected : invalid password for user '$userid'. " . description($cmpmesg);
		return 0;
	    }
	}
    }

    if ( my $t = $$ldap{transformation} ) {
	$$t{subroutine} ||= 'get_borrower';
	my $get_borrower = load_subroutine ( @$t{qw/ module subroutine /} );
	unless ( $get_borrower ) {
	    warn "no get_borrower $$t{subroutine} subroutine in $$t{module}";
	    return 0;
	}
	debug_msg  "$$t{subroutine} subroutine loaded from $$t{module}";
	if ( my $b = $get_borrower->( $$to_borrower{entry} ) ) {
	    return accept_borrower $b,$userid;
	}
	else { return 0 }
    }

    # To get here, LDAP has accepted our user's login attempt.
    # But we still have work to do.  See perldoc below for detailed breakdown.

    my %borrower;
    my ( $borrowernumber, $cardnumber, $local_userid, $savedpw ) = exists_local($userid);

    if (  ( $borrowernumber and $config{update} )
        or ( !$borrowernumber and $config{replicate} ) ) {
        %borrower = ldap_entry_2_hash( $userldapentry, $userid );
        $debug and print STDERR "checkpw_ldap received \%borrower w/ " . keys(%borrower), " keys: ", join( ' ', keys %borrower ), "\n";
    }

    if ($borrowernumber) {
        if ( $config{update} ) {    # A1, B1
            my $c2 = &update_local( $local_userid, $password, $borrowernumber, \%borrower ) || '';
            ( $cardnumber eq $c2 ) or warn "update_local returned cardnumber '$c2' instead of '$cardnumber'";
        } else {                    # C1, D1
                                    # maybe update just the password?
            return ( 1, $cardnumber );    # FIXME dpavlin -- don't destroy ExtendedPatronAttributes
        }
    } elsif ( $config{replicate} ) {    # A2, C2
	debug_msg "$borrower{userid} # = $borrowernumber";
        AddMember(%borrower);
	# $borrowernumber = eval { AddMember(%borrower) };
	# if ( $@ || not defined $borrowernumber ) {
	#     die logger { $@ => \%borrower };
	#     if (DEBUG) { logger { $@ => \%borrower } }
	#     else { say STDERR "ldap account $borrower{userid} can't be replicated in koha" }
	#     return 0;
	# }
    } else {
        return 0;                       # B2, D2
    }
    if ( C4::Context->preference('ExtendedPatronAttributes') && $borrowernumber && ( $config{update} || $config{replicate} ) ) {
        my @types      = C4::Members::AttributeTypes::GetAttributeTypes();
        my @attributes = grep {
            my $key = $_;
            any { $_ eq $key } @types;
        } keys %borrower;
        my $extended_patron_attributes = map { { code => $_, value => $borrower{$_} } } @attributes;
        $extended_patron_attributes = [] unless $extended_patron_attributes;
        my @errors;

        #Check before add
        for ( my $i ; $i < scalar(@$extended_patron_attributes) - 1 ; $i++ ) {
            my $attr = $extended_patron_attributes->[$i];
            unless ( C4::Members::Attributes::CheckUniqueness( $attr->{code}, $attr->{value}, $borrowernumber ) ) {
                unshift @errors, $i;
                warn "ERROR_extended_unique_id_failed $attr->{code} $attr->{value}";
            }
        }

        #Removing erroneous attributes
        foreach my $index (@errors) {
            @$extended_patron_attributes = splice( @$extended_patron_attributes, $index, 1 );
        }
        C4::Members::Attributes::SetBorrowerAttributes( $borrowernumber, $extended_patron_attributes );
    }
    return ( 1, $cardnumber );
}

# Pass LDAP entry object and local cardnumber (userid).
# Returns borrower hash.
# Edit KOHA_CONF so $memberhash{'xxx'} fits your ldap structure.
# Ensure that mandatory fields are correctly filled!
#
sub ldap_entry_2_hash ($$) {
    my $userldapentry = shift;
    my %borrower = ( cardnumber => shift );
    my %memberhash;
    $userldapentry->exists('uid');    # This is bad, but required!  By side-effect, this initializes the attrs hash.
    if ($debug) {
        print STDERR "\nkeys(\%\$userldapentry) = " . join( ', ', keys %$userldapentry ), "\n", $userldapentry->dump();
        foreach ( keys %$userldapentry ) {
            print STDERR "\n\nLDAP key: $_\t", sprintf( '(%s)', ref $userldapentry->{$_} ), "\n";
            hashdump( "LDAP key: ", $userldapentry->{$_} );
        }
    }
    my $x = $userldapentry->{attrs} or return undef;
    foreach ( keys %$x ) {
        $memberhash{$_} = join ' ', @{ $x->{$_} };
        $debug and print STDERR sprintf( "building \$memberhash{%s} = ", $_, join( ' ', @{ $x->{$_} } ) ), "\n";
    }
    $debug and print STDERR "Finsihed \%memberhash has ", scalar( keys %memberhash ), " keys\n", "Referencing \%mapping with ", scalar( keys %mapping ), " keys\n";
    foreach my $key ( keys %mapping ) {
        my $data = $memberhash{ $mapping{$key}->{is} };
        $debug and printf STDERR "mapping %20s ==> %-20s (%s)\n", $key, $mapping{$key}->{is}, $data;
        unless ( defined $data ) {
            $data = $mapping{$key}->{content} || '';    # default or failsafe ''
        }
        $borrower{$key} = ( $data ne '' ) ? $data : ' ';
    }
    $borrower{initials} = $memberhash{initials}
      || ( substr( $borrower{'firstname'}, 0, 1 ) . substr( $borrower{'surname'}, 0, 1 ) . " " );
    return %borrower;
}

sub exists_local($) {
    my $arg    = shift;
    my $dbh    = C4::Context->dbh;
    my $select = "SELECT borrowernumber,cardnumber,userid,password FROM borrowers ";

    my $sth = $dbh->prepare("$select WHERE userid=?");    # was cardnumber=?
    $sth->execute($arg);
    $debug and printf STDERR "Userid '$arg' exists_local? %s\n", $sth->rows;
    ( $sth->rows == 1 ) and return $sth->fetchrow;

    $sth = $dbh->prepare("$select WHERE cardnumber=?");
    $sth->execute($arg);
    $debug and printf STDERR "Cardnumber '$arg' exists_local? %s\n", $sth->rows;
    ( $sth->rows == 1 ) and return $sth->fetchrow;
    return 0;
}

sub _do_changepassword {
    my ( $userid, $borrowerid, $digest ) = @_;
    $debug and print STDERR "changing local password for borrowernumber=$borrowerid to '$digest'\n";
    changepassword( $userid, $borrowerid, $digest );

    # Confirm changes
    my $sth = C4::Context->dbh->prepare("SELECT password,cardnumber FROM borrowers WHERE borrowernumber=? ");
    $sth->execute($borrowerid);
    if ( $sth->rows ) {
        my ( $md5password, $cardnum ) = $sth->fetchrow;
        ( $digest eq $md5password ) and return $cardnum;
        warn "Password mismatch after update to cardnumber=$cardnum (borrowernumber=$borrowerid)";
        return undef;
    }
    die "Unexpected error after password update to userid/borrowernumber: $userid / $borrowerid.";
}

sub update_local($$$$) {
    my $userid     = shift             or return undef;
    my $digest     = md5_base64(shift) or return undef;
    my $borrowerid = shift             or return undef;
    my $borrower   = shift             or return undef;
    my @keys       = keys %$borrower;
    my $dbh        = C4::Context->dbh;
    my $query = "UPDATE  borrowers\nSET     " . join( ',', map { "$_=?" } @keys ) . "\nWHERE   borrowernumber=? ";
    my $sth = $dbh->prepare($query);
    if ($debug) {
        print STDERR $query, "\n", join "\n", map { "$_ = '" . $borrower->{$_} . "'" } @keys;
        print STDERR "\nuserid = $userid\n";
    }
    $sth->execute( ( ( map { $borrower->{$_} } @keys ), $borrowerid ) );

    # MODIFY PASSWORD/LOGIN
    _do_changepassword( $userid, $borrowerid, $digest );
}

1;
__END__

=head1 NAME

C4::Auth - Authenticates Koha users

=head1 SYNOPSIS

  use C4::Auth_with_ldap;

=head1 LDAP Configuration

    This module is specific to LDAP authentification. It requires Net::LDAP package and one or more
	working LDAP servers.
	To use it :
	   * Modify ldapserver element in KOHA_CONF
	   * Establish field mapping in <mapping> element.

	For example, if your user records are stored according to the inetOrgPerson schema, RFC#2798,
	the username would match the "uid" field, and the password should match the "userpassword" field.

	Make sure that ALL required fields are populated by your LDAP database (and mapped in KOHA_CONF).  
	What are the required fields?  Well, in mysql you can check the database table "borrowers" like this:

	mysql> show COLUMNS from borrowers;
		+------------------+--------------+------+-----+---------+----------------+
		| Field            | Type         | Null | Key | Default | Extra          |
		+------------------+--------------+------+-----+---------+----------------+
		| borrowernumber   | int(11)      | NO   | PRI | NULL    | auto_increment | 
		| cardnumber       | varchar(16)  | YES  | UNI | NULL    |                | 
		| surname          | mediumtext   | NO   |     |         |                | 
		| firstname        | text         | YES  |     | NULL    |                | 
		| title            | mediumtext   | YES  |     | NULL    |                | 
		| othernames       | mediumtext   | YES  |     | NULL    |                | 
		| initials         | text         | YES  |     | NULL    |                | 
		| streetnumber     | varchar(10)  | YES  |     | NULL    |                | 
		| streettype       | varchar(50)  | YES  |     | NULL    |                | 
		| address          | mediumtext   | NO   |     |         |                | 
		| address2         | text         | YES  |     | NULL    |                | 
		| city             | mediumtext   | NO   |     |         |                | 
		| zipcode          | varchar(25)  | YES  |     | NULL    |                | 
		| email            | mediumtext   | YES  |     | NULL    |                | 
		| phone            | text         | YES  |     | NULL    |                | 
		| mobile           | varchar(50)  | YES  |     | NULL    |                | 
		| fax              | mediumtext   | YES  |     | NULL    |                | 
		| emailpro         | text         | YES  |     | NULL    |                | 
		| phonepro         | text         | YES  |     | NULL    |                | 
		| B_streetnumber   | varchar(10)  | YES  |     | NULL    |                | 
		| B_streettype     | varchar(50)  | YES  |     | NULL    |                | 
		| B_address        | varchar(100) | YES  |     | NULL    |                | 
		| B_city           | mediumtext   | YES  |     | NULL    |                | 
		| B_zipcode        | varchar(25)  | YES  |     | NULL    |                | 
		| B_email          | text         | YES  |     | NULL    |                | 
		| B_phone          | mediumtext   | YES  |     | NULL    |                | 
		| dateofbirth      | date         | YES  |     | NULL    |                | 
		| branchcode       | varchar(10)  | NO   | MUL |         |                | 
		| categorycode     | varchar(10)  | NO   | MUL |         |                | 
		| dateenrolled     | date         | YES  |     | NULL    |                | 
		| dateexpiry       | date         | YES  |     | NULL    |                | 
		| gonenoaddress    | tinyint(1)   | YES  |     | NULL    |                | 
		| lost             | tinyint(1)   | YES  |     | NULL    |                | 
		| debarred         | tinyint(1)   | YES  |     | NULL    |                | 
		| contactname      | mediumtext   | YES  |     | NULL    |                | 
		| contactfirstname | text         | YES  |     | NULL    |                | 
		| contacttitle     | text         | YES  |     | NULL    |                | 
		| guarantorid      | int(11)      | YES  |     | NULL    |                | 
		| borrowernotes    | mediumtext   | YES  |     | NULL    |                | 
		| relationship     | varchar(100) | YES  |     | NULL    |                | 
		| ethnicity        | varchar(50)  | YES  |     | NULL    |                | 
		| ethnotes         | varchar(255) | YES  |     | NULL    |                | 
		| sex              | varchar(1)   | YES  |     | NULL    |                | 
		| password         | varchar(30)  | YES  |     | NULL    |                | 
		| flags            | int(11)      | YES  |     | NULL    |                | 
		| userid           | varchar(30)  | YES  | MUL | NULL    |                |  # UNIQUE in next release.
		| opacnote         | mediumtext   | YES  |     | NULL    |                | 
		| contactnote      | varchar(255) | YES  |     | NULL    |                | 
		| sort1            | varchar(80)  | YES  |     | NULL    |                | 
		| sort2            | varchar(80)  | YES  |     | NULL    |                | 
		+------------------+--------------+------+-----+---------+----------------+
		50 rows in set (0.01 sec)
	
		Where Null="NO", the field is required.

=head1 KOHA_CONF and field mapping

Example XML stanza for LDAP configuration in KOHA_CONF.

 <config>
  ...
  <useldapserver>1</useldapserver>
  <!-- LDAP SERVER (optional) -->
  <ldapserver id="ldapserver">
    <hostname>localhost</hostname>
    <base>dc=metavore,dc=com</base>
    <user>cn=Manager,dc=metavore,dc=com</user>             <!-- DN, if not anonymous -->
    <pass>metavore</pass>          <!-- password, if not anonymous -->
    <replicate>1</replicate>       <!-- add new users from LDAP to Koha database -->
    <update>1</update>             <!-- update existing users in Koha database -->
    <auth_by_bind>0</auth_by_bind> <!-- set to 1 to authenticate by binding instead of
                                        password comparison, e.g., to use Active Directory -->
    <principal_name>%s@my_domain.com</principal_name>
                                   <!-- optional, for auth_by_bind: a printf format to make userPrincipalName from koha userid -->
    <mapping>                  <!-- match koha SQL field names to your LDAP record field names -->
      <firstname    is="givenname"      ></firstname>
      <surname      is="sn"             ></surname>
      <address      is="postaladdress"  ></address>
      <city         is="l"              >Athens, OH</city>
      <zipcode      is="postalcode"     ></zipcode>
      <branchcode   is="branch"         >MAIN</branchcode>
      <userid       is="uid"            ></userid>
      <password     is="userpassword"   ></password>
      <email        is="mail"           ></email>
      <categorycode is="employeetype"   >PT</categorycode>
      <phone        is="telephonenumber"></phone>
    </mapping> 
  </ldapserver> 
 </config>

The <mapping> subelements establish the relationship between mysql fields and LDAP attributes. The element name
is the column in mysql, with the "is" characteristic set to the LDAP attribute name.  Optionally, any content
between the element tags is taken as the default value.  In this example, the default categorycode is "PT" (for
patron).  

=head1 CONFIGURATION

Once a user has been accepted by the LDAP server, there are several possibilities for how Koha will behave, depending on 
your configuration and the presence of a matching Koha user in your local DB:

                         LOCAL_USER
 OPTION UPDATE REPLICATE  EXISTS?  RESULT
   A1      1       1        1      OK : We're updating them anyway.
   A2      1       1        0      OK : We're adding them anyway.
   B1      1       0        1      OK : We update them.
   B2      1       0        0     FAIL: We cannot add new user.
   C1      0       1        1      OK : We do nothing.  (maybe should update password?)
   C2      0       1        0      OK : We add the new user.
   D1      0       0        1      OK : We do nothing.  (maybe should update password?)
   D2      0       0        0     FAIL: We cannot add new user.

Note: failure here just means that Koha will fallback to checking the local DB.  That is, a given user could login with
their LDAP password OR their local one.  If this is a problem, then you should enable update and supply a mapping for 
password.  Then the local value will be updated at successful LDAP login and the passwords will be synced.

If you choose NOT to update local users, the borrowers table will not be affected at all.
Note that this means that patron passwords may appear to change if LDAP is ever disabled, because
the local table never contained the LDAP values.  

=head2 auth_by_bind

Binds as the user instead of retrieving their record.  Recommended if update disabled.

=head2 principal_name

Provides an optional sprintf-style format for manipulating the userid before the bind.
Even though the userPrincipalName is one intended target, any uniquely identifying
attribute that the server allows to be used for binding could be used.

Currently, principal_name only operates when auth_by_bind is enabled.

=head2 Active Directory 

The auth_by_bind and principal_name settings are recommended for Active Directory.

Under default Active Directory rules, we cannot determine the distinguishedName attribute from the Koha userid as reliably as
we would typically under openldap.  Instead of:

    distinguishedName: CN=barnes.7,DC=my_company,DC=com

We might get:

    distinguishedName: CN=Barnes\, Jim,OU=Test Accounts,OU=User Accounts,DC=my_company,DC=com

Matching that would require us to know more info about the account (firstname, surname) and to include punctuation and whitespace
in Koha userids.  But the userPrincipalName should be consistent, something like:

    userPrincipalName: barnes.7@my_company.com

Therefore it is often easier to bind to Active Directory with userPrincipalName, effectively the
canonical email address for that user, or what it would be if email were enabled for them.  If Koha userid values 
will match the username portion of the userPrincipalName, and the domain suffix is the same for all users, then use principal_name
like this:
    <principal_name>%s@core.my_company.com</principal_name>

The user of the previous example, barnes.7, would then attempt to bind as:
    barnes.7@core.my_company.com

=head1 SEE ALSO

CGI(3)

Net::LDAP()

XML::Simple()

Digest::MD5(3)

sprintf()

=cut

# For reference, here's an important difference in the data structure we rely on.
# ========================================
# Using attrs instead of {asn}->attributes
# ========================================
#
# 	LDAP key: ->{             cn} = ARRAY w/ 3 members.
# 	LDAP key: ->{             cn}->{           sss} = sss
# 	LDAP key: ->{             cn}->{   Steve Smith} = Steve Smith
# 	LDAP key: ->{             cn}->{Steve S. Smith} = Steve S. Smith
#
# 	LDAP key: ->{      givenname} = ARRAY w/ 1 members.
# 	LDAP key: ->{      givenname}->{Steve} = Steve
#
