#!/usr/bin/perl

use strict;
use warnings;

use C4::Auth;
use CGI qw/-utf8/;
use C4::Context;
use C4::Debug;

use C4::AuthoritiesMarc;
use C4::Output;
use File::Basename;
use Text::Undiacritic qw/undiacritic/;
use Encode;

#use open qw(:std :utf8);


my $upload_path = C4::Context->preference('uploadPath');

=head1

plugin_parameters : other parameters added when the plugin is called by the dopop function

=cut

sub plugin_parameters {
    my ( $dbh, $record, $tagslib, $i, $tabloop ) = @_;
    return "";
}

sub plugin_javascript {
    my ( $dbh, $record, $tagslib, $field_number, $tabloop ) = @_;
    my $function_name = $field_number;
    my $res           = "
    <script type=\"text/javascript\">
        function Focus$function_name(subfield_managed) {
            return 1;
        }
    
        function Blur$function_name(subfield_managed) {
            return 1;
        }
    
        function Clic$function_name(index) {
            defaultvalue = document.getElementById(index).value;
            window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=upload.pl&index=\"+index+\"&result=\"+defaultvalue,'upload','width=600,height=400,toolbar=false,scrollbars=no');
    
        }
    </script>
";

    return ( $function_name, $res );
}

sub plugin {
    my ($input)      = @_;
    my $index        = $input->param('index');
    my $result       = $input->param('result');
    my $delete       = $input->param('delete');
    my $uploaded_file = $input->param('uploaded_file');

    my $template_name = $result || $delete ? "upload_delete_file.tmpl" : "upload.tmpl";

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {   template_name   => "cataloguing/value_builder/$template_name",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { editcatalogue => '*' },
            debug           => 1,
        }
    );


    my $filefield = CGI::filefield( -name=>'uploaded_file', 
     -default=>'starting value',
     -size=>50,
     -maxlength=>80);

    $template->param(
        index      => $index,
	result     => $result,
	filefield  => $filefield
    );


    # If there's already a file uploaded for this field,
    # We handle is deletion
    if ($delete) {
        my ($filename) = fileparse($result);
	warn "deletion of $upload_path/$filename";
	my $success = unlink("$upload_path/$filename");
	if ($success) {
	    $template->param(success => $success);
	} else {
	    $template->param(error => 1);
	}
    }


    # Dealing with the uploaded file
    if ($uploaded_file) {

	my $fh = $input->upload('uploaded_file');
	my $error;
	my $success;

	if (defined $fh) {
	
	    # Dealing with filenames:

	    # Normalizing filename:
	    $uploaded_file = normalize_string($uploaded_file);
	    $uploaded_file = undiacritic($uploaded_file);

	    # Checking for an existing filename in destination directory
	    if (-f "$upload_path/$uploaded_file") {

		# And getting a new one if needed
		my ($dir, $file, $ext) = fileparse("$upload_path/$uploaded_file", qr/\.[^.]*/);
		$uploaded_file = findname($dir, $file, $ext);
	    }

	    # Copying the temp file to the destination directory
	    my $io_fh = $fh->handle;
	    open (OUTFILE, '>', "$upload_path/$uploaded_file") or $error = $!;
	    if (!$error) {
		my $buffer;
		while (my $bytesread = $io_fh->read($buffer,1024)) {
		    print OUTFILE $buffer;
		}
		close(OUTFILE);
		$success = 1;
	    } else {
		$error = "Could not write to destination file";
	    }
	} else {
	    $error = "Could not get the file";
	}
	$template->param(success       => $success)        if ($success);
	$template->param(error         => $error)          if ($error);
	$template->param(uploaded_file => $uploaded_file);
    my $uploadWebPath = C4::Context->preference('uploadWebPath');
    $uploadWebPath =~ s/\/+$//;
    $template->param(fileurl    => "$uploadWebPath/$uploaded_file");
    }

    output_html_with_http_headers $input, $cookie, $template->output;
}

sub findname {
    my $file = shift;
    my $dir = shift;
    my $ext = shift;

    my $count = 1;
    my $found = 0;

    while ($found == 0) {
	if (-f "$dir/$file-$count$ext") {
	    $count++;
	} else {
	    $found = 1;	    
	}
    }

    return "$file-$count$ext";
}

=head2 normalize_string
        Given 
            a string
        Returns a utf8 NFC normalized string
        
        Sample code :
=cut

sub normalize_string{
        my ($string)=@_;
    $debug and warn " string in normalize before normalize :",$string;
    $string=decode_utf8($string,1);
    $debug and warn " string in normalize :",$string;
    $string=~s/\<|\>|\^|\;|\?|,|\-|\(|\)|\[|\]|\{|\}|\$|\%|\!|\*|\:|\\|\/|\&|\"|\'|\s/_/g;
    $string=~s/\s+$//g;
    $string=~s/^\s+//g;
    return $string; 
}


1;
