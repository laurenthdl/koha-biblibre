#!/bin/perl

use Modern::Perl;
use DBI;
use YAML;
use Digest::MD5;
use File::Basename;
use Koha_Synchronize_System::tools::kss;
use C4::Logguer qw(:DEFAULT $log_kss);

my $log = $log_kss;
my $conf                     = Koha_Synchronize_System::tools::kss::get_conf();
my $outbox                   = $$conf{path}{client_outbox};
my $inbox                    = $$conf{abspath}{server_inbox};
my $ip_server                = $$conf{cron}{serverhost};
my $scp_cmd                  = $$conf{which_cmd}{scp};
my $ssh_cmd                  = $$conf{which_cmd}{ssh};
my $rm_cmd                  = $$conf{which_cmd}{rm};

my $username = "kss";

$log->info("Envoi des backups au serveur");

$ip_server="localhost";
$inbox="/home/jonathan/Bureau/toto";
$username="jonathan";

my @files = <$outbox/*.tar.gz>;
for my $file ( @files ) {
    chomp $file;
    $log->info(" - $file");
    open(FILE, $file) or $log->error("Ne peut ouvrir le fichier $file ($!)");
    my $ctx = Digest::MD5->new;
    $ctx->addfile(*FILE);
    my $md5_local = $ctx->hexdigest;
    close(FILE);

    my $md5_remote = upload( $file );
    my $filename = basename($file);

    for ( 1..3 ) {
        if ( $md5_local eq $md5_remote ) {
            qx{$rm_cmd $file};
            $log->info("         Fichier envoyé sur $username\@$ip_server:$inbox/$filename et supprimé en local");
            last;
        } else {
            $log->error("        Le fichier n'est pas intègre, on réessaye");
            $log->debug("        local md5 : $md5_local");
            $log->debug("        remote md5: $md5_remote");
            $md5_remote = upload( $file );
            qx{$ssh_cmd $username\@$ip_server $rm_cmd $inbox/$filename;};
        }
    }
    
}




sub upload {
    my $file = shift;
    $log->info("        Envoi du dump au serveur");
    system( qq{$scp_cmd $file  $username\@$ip_server:$inbox} ) == 0 or next;

    $log->info("        Vérification de l'intégrité du fichier envoyé");
    my $filename = basename($file);
    my $md5 = qx{$ssh_cmd $username\@$ip_server md5sum $inbox/$filename | cut -f1 -d' ';};
    chomp $md5;
    return $md5;
}
