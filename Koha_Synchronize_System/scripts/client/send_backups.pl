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
my $outbox                   = $$conf{abspath}{client_outbox};
my $inbox                    = $$conf{abspath}{server_inbox};
my $ip_server                = $$conf{cron}{serverhost};
my $scp_cmd                  = $$conf{which_cmd}{scp};
my $ssh_cmd                  = $$conf{which_cmd}{ssh};
my $rm_cmd                   = $$conf{which_cmd}{rm};
my $backup_dir               = $$conf{abspath}{client_backup};
my $backup_delay             = $$conf{backup_delay}{client};

my $username = "kss";

$log->info("Création du dernier backup");
eval {
    Koha_Synchronize_System::tools::kss::backup_client_logbin;
};
if ( $@ ) {
    $log->error("Échec : $@");
    die "Impossible de créer le nouveau backup $@";
}

$log->info("Envoi des backups au serveur");
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
        }
    }

    delete_old_backup();
    
}


sub delete_old_backup {
    $log->info("Suppression des anciens fichiers de backup");
    system( qq{find $backup_dir -maxdepth 1 -mtime +$backup_delay -exec rm -R {} \\;} ) == 0 or $log->error("Can't delete old backup ($!)");
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
