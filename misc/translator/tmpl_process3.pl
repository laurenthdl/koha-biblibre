#!/usr/bin/perl
# This file is part of Koha
# Parts copyright 2003-2004 Paul Poulain
# Parts copyright 2003-2004 Jerome Vizcaino
# Parts copyright 2004 Ambrose Li

=head1 NAME

tmpl_process3.pl - Alternative version of tmpl_process.pl
using gettext-compatible translation files

=cut

use strict;

#use warnings; FIXME - Bug 2505
use Getopt::Long;
use Locale::PO;
use File::Temp qw( :POSIX );
use TmplTokenizer;
use VerboseWarnings qw( :warn :die );

###############################################################################

use vars qw( @in_files $in_dir $str_file $out_dir $quiet );
use vars qw( @excludes $exclude_regex );
use vars qw( $recursive_p );
use vars qw( $pedantic_p );
use vars qw( $href );
use vars qw( $type );    # file extension (DOS form without the dot) to match
use vars qw( $charset_in $charset_out );

###############################################################################

sub find_translation ($) {
    my ($s) = @_;
    my $key = $s;
    if ( $s =~ /\S/s ) {
        $key = TmplTokenizer::string_canon($key);
        $key = TmplTokenizer::charset_convert( $key, $charset_in, $charset_out );
        $key = TmplTokenizer::quote_po($key);
    }
    return
         defined $href->{$key}
      && !$href->{$key}->fuzzy
      && length Locale::PO->dequote( $href->{$key}->msgstr ) ? Locale::PO->dequote( $href->{$key}->msgstr ) : $s;
}

sub text_replace_tag ($$) {
    my ( $t, $attr ) = @_;
    my $it;

    # value [tag=input], meta
    my $tag = lc($1) if $t =~ /^<(\S+)/s;
    my $translated_p = 0;
    for my $a ( 'alt', 'content', 'title', 'value', 'label' ) {
        if ( $attr->{$a} ) {
            next if $a eq 'label'   && $tag ne 'optgroup';
            next if $a eq 'content' && $tag ne 'meta';
            next
              if $a eq 'value'
                  && ( $tag ne 'input'
                      || ( ref $attr->{'type'} && $attr->{'type'}->[1] =~ /^(?:checkbox|hidden|radio|text)$/ ) );    # FIXME
            my ( $key, $val, $val_orig, $order ) = @{ $attr->{$a} };                                                 #FIXME
            if ( $val =~ /\S/s ) {
                my $s = find_translation($val);
                if ( $attr->{$a}->[1] ne $s ) {                                                                      #FIXME
                    $attr->{$a}->[1] = $s;                                                                           # FIXME
                    $attr->{$a}->[2] = ( $s =~ /"/s ) ? "'$s'" : "\"$s\"";                                           #FIXME
                    $translated_p    = 1;
                }
            }
        }
    }
    if ($translated_p) {
        $it = "<$tag" . join(
            '',
            map {
                sprintf( ' %s=%s', $_, $attr->{$_}->[2] )                                                            #FIXME
              } sort {
                $attr->{$a}->[3] <=> $attr->{$b}->[3]                                                                #FIXME
              } keys %$attr
        ) . '>';
    } else {
        $it = $t;
    }
    return $it;
}

sub text_replace (**) {
    my ( $h, $output ) = @_;
    for ( ; ; ) {
        my $s = TmplTokenizer::next_token $h;
        last unless defined $s;
        my ( $kind, $t, $attr ) = ( $s->type, $s->string, $s->attributes );
        if ( $kind eq TmplTokenType::TEXT ) {
            print $output find_translation($t);
        } elsif ( $kind eq TmplTokenType::TEXT_PARAMETRIZED ) {
            my $fmt = find_translation( $s->form );
            print $output TmplTokenizer::parametrize(
                $fmt, 1, $s,
                sub {
                    $_ = $_[0];
                    my ( $kind, $t, $attr ) = ( $_->type, $_->string, $_->attributes );
                    $kind == TmplTokenType::TAG && %$attr ? text_replace_tag( $t, $attr ) : $t;
                }
            );
        } elsif ( $kind eq TmplTokenType::TAG && %$attr ) {
            print $output text_replace_tag( $t, $attr );
        } elsif ( $s->has_js_data ) {
            for my $t ( @{ $s->js_data } ) {

                # FIXME for this whole block
                if ( $t->[0] ) {
                    printf $output "%s%s%s", $t->[2], find_translation $t->[3], $t->[2];
                } else {
                    print $output $t->[1];
                }
            }
        } elsif ( defined $t ) {
            print $output $t;
        }
    }
}

sub listfiles ($$$) {
    my ( $dir, $type, $action ) = @_;
    my @it = ();
    if ( opendir( DIR, $dir ) ) {
        my @dirent = readdir DIR;    # because DIR is shared when recursing
        closedir DIR;
        for my $dirent (@dirent) {
            my $path = "$dir/$dirent";
            if (   $dirent =~ /^\./
                || $dirent eq 'CVS'
                || $dirent eq 'RCS'
                || ( defined $exclude_regex && $dirent =~ /^(?:$exclude_regex)$/ ) ) {
                ;
            } elsif ( -f $path ) {
                push @it, $path if ( !defined $type || $dirent =~ /\.(?:$type)$/ ) || $action eq 'install';
            } elsif ( -d $path && $recursive_p ) {
                push @it, listfiles( $path, $type, $action );
            }
        }
    } else {
        warn_normal "$dir: $!", undef;
    }
    return @it;
}

###############################################################################

sub mkdir_recursive ($) {
    my ($dir) = @_;
    local ( $`, $&, $', $1 );
    $dir = $` if $dir ne /^\/+$/ && $dir =~ /\/+$/;
    my ( $prefix, $basename ) = ( $dir =~ /\/([^\/]+)$/s ) ? ( $`, $1 ) : ( '.', $dir );
    mkdir_recursive($prefix) if $prefix ne '.' && !-d $prefix;
    if ( !-d $dir ) {
        print STDERR "Making directory $dir..." unless $quiet;

        # creates with rwxrwxr-x permissions
        mkdir( $dir, 0775 ) || warn_normal "$dir: $!", undef;
    }
}

###############################################################################

sub usage ($) {
    my ($exitcode) = @_;
    my $h = $exitcode ? *STDERR : *STDOUT;
    print $h <<EOF;
Usage: $0 create [OPTION]
  or:  $0 update [OPTION]
  or:  $0 install [OPTION]
  or:  $0 --help
Create or update PO files from templates, or install translated templates.

  -i, --input=SOURCE          Get or update strings from SOURCE file.
                              SOURCE is a directory if -r is also specified.
  -o, --outputdir=DIRECTORY   Install translation(s) to specified DIRECTORY
      --pedantic-warnings     Issue warnings even for detected problems
                              which are likely to be harmless
  -r, --recursive             SOURCE in the -i option is a directory
  -s, --str-file=FILE         Specify FILE as the translation (po) file
                              for input (install) or output (create, update)
  -x, --exclude=REGEXP        Exclude files matching the given REGEXP
      --help                  Display this help and exit
  -q, --quiet                 no output to screen (except for errors)

The -o option is ignored for the "create" and "update" actions.
Try `perldoc $0 for perhaps more information.
EOF
    exit($exitcode);
}    #`

###############################################################################

sub usage_error (;$) {
    for my $msg ( split( /\n/, $_[0] ) ) {
        print STDERR "$msg\n";
    }
    print STDERR "Try `$0 --help for more information.\n";
    exit(-1);
}

###############################################################################

GetOptions(
    'input|i=s'                  => \@in_files,
    'outputdir|o=s'              => \$out_dir,
    'recursive|r'                => \$recursive_p,
    'str-file|s=s'               => \$str_file,
    'exclude|x=s'                => \@excludes,
    'quiet|q'                    => \$quiet,
    'pedantic-warnings|pedantic' => sub { $pedantic_p = 1 },
    'help'                       => \&usage,
) || usage_error;

VerboseWarnings::set_application_name $0;
VerboseWarnings::set_pedantic_mode $pedantic_p;

# keep the buggy Locale::PO quiet if it says stupid things
$SIG{__WARN__} = sub {
    my ($s) = @_;
    print STDERR $s unless $s =~ /^Strange line in [^:]+: #~/s;
};

my $action = shift or usage_error('You must specify an ACTION.');
usage_error('You must at least specify input and string list filenames.')
  if !@in_files || !defined $str_file;

# Type match defaults to *.tmpl plus *.inc if not specified
$type = "tmpl|inc|xsl" if !defined($type);

# Check the inputs for being files or directories
for my $input (@in_files) {
    usage_error( "$input: Input must be a file or directory.\n" . "(Symbolic links are not supported at the moment)" )
      unless -d $input || -f $input;
}

# Generates the global exclude regular expression
$exclude_regex = '(?:' . join( '|', @excludes ) . ')' if @excludes;

# Generate the list of input files if a directory is specified
if ( -d $in_files[0] ) {
    die "If you specify a directory as input, you must specify only it.\n"
      if @in_files > 1;

    # input is a directory, generates list of files to process
    $in_dir = $in_files[0];
    $in_dir =~ s/\/$//;    # strips the trailing / if any
    @in_files = listfiles( $in_dir, $type, $action );
} else {
    for my $input (@in_files) {
        die "You cannot specify input files and directories at the same time.\n"
          unless -f $input;
    }
}

# restores the string list from file
$href = Locale::PO->load_file_ashash($str_file);

# guess the charsets. HTML::Templates defaults to iso-8859-1
if ( defined $href ) {
    die "$str_file: PO file is corrupted, or not a PO file\n" unless defined $href->{'""'};
    $charset_out = TmplTokenizer::charset_canon $2 if $href->{'""'}->msgstr =~ /\bcharset=(["']?)([^;\s"'\\]+)\1/;
    $charset_in = $charset_out;
    warn "Charset in/out: " . $charset_out;

    #     for my $msgid (keys %$href) {
    #   if ($msgid =~ /\bcharset=(["']?)([^;\s"'\\]+)\1/) {
    #       my $candidate = TmplTokenizer::charset_canon $2;
    #       die "Conflicting charsets in msgid: $charset_in vs $candidate => $msgid\n"
    #           if defined $charset_in && $charset_in ne $candidate;
    #       $charset_in = $candidate;
    #   }
    #     }
}

# set our charset in to UTF-8
if ( !defined $charset_in ) {
    $charset_in = TmplTokenizer::charset_canon 'UTF-8';
    warn "Warning: Can't determine original templates' charset, defaulting to $charset_in\n";
}

# set our charset out to UTF-8
if ( !defined $charset_out ) {
    $charset_out = TmplTokenizer::charset_canon 'UTF-8';
    warn "Warning: Charset Out defaulting to $charset_out\n";
}
my $xgettext = './xgettext.pl';    # actual text extractor script
my $st;

if ( $action eq 'create' ) {

    # updates the list. As the list is empty, every entry will be added
    if ( !-s $str_file ) {
        warn "Removing empty file $str_file\n";
        unlink $str_file || die "$str_file: $!\n";
    }
    die "$str_file: Output file already exists\n" if -f $str_file;
    my ( $tmph1, $tmpfile1 ) = tmpnam();
    my ( $tmph2, $tmpfile2 ) = tmpnam();
    close $tmph2;    # We just want a name
                     # Generate the temporary file that acts as <MODULE>/POTFILES.in
    for my $input (@in_files) {
        print $tmph1 "$input\n";
    }
    close $tmph1;
    warn "I $charset_in O $charset_out";

    # Generate the specified po file ($str_file)
    $st =
      system( $xgettext, '-s', '-f', $tmpfile1, '-o', $tmpfile2, ( defined $charset_in ? ( '-I', $charset_in ) : () ), ( defined $charset_out ? ( '-O', $charset_out ) : () ) );

    # Run msgmerge so that the pot file looks like a real pot file
    # We need to help msgmerge a bit by pre-creating a dummy po file that has
    # the headers and the "" msgid & msgstr. It will fill in the rest.
    if ( $st == 0 ) {

        # Merge the temporary "pot file" with the specified po file ($str_file)
        # FIXME: msgmerge(1) is a Unix dependency
        # FIXME: need to check the return value
        unless ( -f $str_file ) {
            local ( *INPUT, *OUTPUT );
            open( INPUT,  "<$tmpfile2" );
            open( OUTPUT, ">$str_file" );
            while (<INPUT>) {
                print OUTPUT;
                last if /^\n/s;
            }
            close INPUT;
            close OUTPUT;
        }
        $st = system( 'msgmerge', '-U', '-s', $str_file, $tmpfile2 );
    } else {
        error_normal "Text extraction failed: $xgettext: $!\n", undef;
        error_additional "Will not run msgmerge\n",             undef;
    }

    #   unlink $tmpfile1 || warn_normal "$tmpfile1: unlink failed: $!\n", undef;
    #   unlink $tmpfile2 || warn_normal "$tmpfile2: unlink failed: $!\n", undef;

} elsif ( $action eq 'update' ) {
    my ( $tmph1, $tmpfile1 ) = tmpnam();
    my ( $tmph2, $tmpfile2 ) = tmpnam();
    close $tmph2;    # We just want a name
                     # Generate the temporary file that acts as <MODULE>/POTFILES.in
    for my $input (@in_files) {
        print $tmph1 "$input\n";
    }
    close $tmph1;

    # Generate the temporary file that acts as <MODULE>/<LANG>.pot
    $st = system( $xgettext, '-s', '-f', $tmpfile1, '-o', $tmpfile2, '--po-mode',
        ( defined $charset_in  ? ( '-I', $charset_in )  : () ),
        ( defined $charset_out ? ( '-O', $charset_out ) : () )
    );
    if ( $st == 0 ) {

        # Merge the temporary "pot file" with the specified po file ($str_file)
        # FIXME: msgmerge(1) is a Unix dependency
        # FIXME: need to check the return value
        $st = system( 'msgmerge', '-U', '-s', $str_file, $tmpfile2 );
    } else {
        error_normal "Text extraction failed: $xgettext: $!\n", undef;
        error_additional "Will not run msgmerge\n",             undef;
    }

    #   unlink $tmpfile1 || warn_normal "$tmpfile1: unlink failed: $!\n", undef;
    #   unlink $tmpfile2 || warn_normal "$tmpfile2: unlink failed: $!\n", undef;

} elsif ( $action eq 'install' ) {
    if ( !defined($out_dir) ) {
        usage_error("You must specify an output directory when using the install method.");
    }

    if ( $in_dir eq $out_dir ) {
        warn "You must specify a different input and output directory.\n";
        exit -1;
    }

    # Make sure the output directory exists
    # (It will auto-create it, but for compatibility we should not)
    -d $out_dir || die "$out_dir: The directory does not exist\n";

    # Try to open the file, because Locale::PO doesn't check :-/
    open( INPUT, "<$str_file" ) || die "$str_file: $!\n";
    close INPUT;

    # creates the new tmpl file using the new translation
    for my $input (@in_files) {
        die "Assertion failed"
          unless substr( $input, 0, length($in_dir) + 1 ) eq "$in_dir/";

        #       print "$input / $type\n";
        if ( !defined $type || $input =~ /\.(?:$type)$/ ) {
            my $h = TmplTokenizer->new($input);
            $h->set_allow_cformat(1);
            VerboseWarnings::set_input_file_name $input;

            my $target = $out_dir . substr( $input, length($in_dir) );
            my $targetdir = $` if $target =~ /[^\/]+$/s;
            mkdir_recursive($targetdir) unless -d $targetdir;
            print STDERR "Creating $target...\n" unless $quiet;
            open( OUTPUT, ">$target" ) || die "$target: $!\n";
            text_replace( $h, *OUTPUT );
            close OUTPUT;
        } else {

            # just copying the file
            my $target = $out_dir . substr( $input, length($in_dir) );
            my $targetdir = $` if $target =~ /[^\/]+$/s;
            mkdir_recursive($targetdir) unless -d $targetdir;
            system("cp -f $input $target");
            print STDERR "Copying $input...\n" unless $quiet;
        }
    }

} else {
    usage_error('Unknown action specified.');
}

if ( $st == 0 ) {
    printf "The %s seems to be successful.\n", $action unless $quiet;
} else {
    printf "%s FAILED.\n", "\u$action" unless $quiet;
}
exit 0;

###############################################################################

=head1 SYNOPSIS

./tmpl_process3.pl [ I<tmpl_process.pl options> ]

=head1 DESCRIPTION

This is an alternative version of the tmpl_process.pl script,
using standard gettext-style PO files.  While there still might
be changes made to the way it extracts strings, at this moment
it should be stable enough for general use; it is already being
used for the Chinese and Polish translations.

Currently, the create, update, and install actions have all been
reimplemented and seem to work.

=head2 Features

=over

=item -

Translation files in standard Uniforum PO format.
All standard tools including all gettext tools,
plus PO file editors like kbabel(1) etc.
can be used.

=item -

Minor changes in whitespace in source templates
do not generally require strings to be re-translated.

=item -

Able to handle <TMPL_VAR> variables in the templates;
<TMPL_VAR> variables are usually extracted in proper context,
represented by a short %s placeholder.

=item -

Able to handle text input and radio button INPUT elements
in the templates; these INPUT elements are also usually
extracted in proper context,
represented by a short %S or %p placeholder.

=item -

Automatic comments in the generated PO files to provide
even more context (line numbers, and the names and types
of the variables).

=item -

The %I<n>$s (or %I<n>$p, etc.) notation can be used
for change the ordering of the variables,
if such a reordering is required for correct translation.

=item -

If a particular <TMPL_VAR> should not appear in the
translation, it can be suppressed with the %0.0s notation.

=item -

Using the PO format also means translators can add their
own comments in the translation files, if necessary.

=item -

Create, update, and install actions are all based on the
same scanner module. This ensures that update and install
have the same idea of what is a translatable string;
attribute names in tags, for example, will not be
accidentally translated.

=back

=head1 NOTES

Anchors are represented by an <AI<n>> notation.
The meaning of this non-standard notation might not be obvious.

The create action calls xgettext.pl to do the actual work;
the update action calls xgettext.pl and msgmerge(1) to do the
actual work.

=head1 BUGS

xgettext.pl must be present in the current directory; the
msgmerge(1) command must also be present in the search path.
The script currently does not check carefully whether these
dependent commands are present.

Locale::PO(3) has a lot of bugs. It can neither parse nor
generate GNU PO files properly; a couple of workarounds have
been written in TmplTokenizer and more is likely to be needed
(e.g., to get rid of the "Strange line" warning for #~).

This script may not work in Windows.

There are probably some other bugs too, since this has not been
tested very much.

=head1 SEE ALSO

xgettext.pl,
TmplTokenizer.pm,
msgmerge(1),
Locale::PO(3),
translator_doc.txt

http://www.saas.nsw.edu.au/koha_wiki/index.php?page=DifficultTerms

=cut
