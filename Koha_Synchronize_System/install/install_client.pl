use Modern::Perl;
use DBI;
use YAML;

use Koha_Synchronize_System::tools::kss;

my $conf                     = Koha_Synchronize_System::tools::kss::get_conf();
my $kss_dir                  = $$conf{path}{kss_dir};
my $db_client                = $$conf{databases_infos}{db_client};
my $mysql_cmd                = $$conf{which_cmd}{mysql};
my $scp_cmd                  = $$conf{which_cmd}{scp};
my $ssh_copy_id_cmd          = $$conf{which_cmd}{'ssh-copy-id'};
my $mkdir_cmd                = $$conf{which_cmd}{mkdir};
my $chown_cmd                = $$conf{which_cmd}{chown};
my $useradd_cmd              = $$conf{which_cmd}{useradd};
my $ssh_keygen_cmd           = $$conf{which_cmd}{'ssh-keygen'};
my $hostname                 = $$conf{databases_infos}{hostname};
my $user                     = $$conf{databases_infos}{user};
my $passwd                   = $$conf{databases_infos}{passwd};
my $backup_dir               = $$conf{abspath}{client_backup};
my $kss_infos_table          = $$conf{databases_infos}{kss_infos_table};
my $kss_home                 = $$conf{abspath}{kss_client_home};
my $inbox                    = $$conf{abspath}{client_inbox};
my $outbox                   = $$conf{abspath}{client_outbox};
my $ip_server                = $$conf{cron}{serverhost};
my $remote_dump_filepath     = $$conf{abspath}{server_dump_filepath};
my $local_dump_filepath      = $$conf{abspath}{client_dump_filepath};

if ( $< ne "0" ) {
   print "You must logged in root";
   exit 1
}

if ( -f "$kss_home/.ssh/id_rsa" ) {
    print "Une clé ssh existe déjà dans $kss_home/.ssh/id_rsa\n";
    print "Veuillez la supprimer avant de lancer ce script\n";
    exit 2;
}

my $username = "kss";
print "Création de l'utilisateur $username\n";
my $pwd = crypt("kss", "kss");
eval {
    qx{useradd --home $kss_home --create-home --password $pwd --group mysql $username};
};
if ( $@ ) {
    print "Can't create user kss";
    exit(1);
}

qx{$mkdir_cmd -p $inbox};
qx{$mkdir_cmd -p $outbox};
qx{$mkdir_cmd -p $backup_dir};
qx{$chown_cmd -R $username:$username $inbox};
qx{$chown_cmd -R $username:$username $outbox};
qx{$chown_cmd -R $username:$username $backup_dir};
qx{$mkdir_cmd -p $kss_home/.ssh};
qx{$chown_cmd -R $username:$username $kss_home/.ssh};

print "Génération de la clé ssh...\n";

qx{$ssh_keygen_cmd -t rsa -N "" -f $kss_home/.ssh/id_rsa};

qx{$chown_cmd -R $username:$username $kss_home};

print "=== Création des cronjobs ===\n";
system( qq{perl $kss_dir/tools/insert_or_update_crontab.pl --host=slave} ) == 0 or die "Can't insert crontab";

# su kss
$< = (getpwnam($username))[2];

print "/!\ Changer le mot de passe pour l'utilisateur $username\n";
print "Éxécutez la commande suivante en tant qu'utilisateur kss: \n$ssh_copy_id_cmd -i $kss_home/.ssh/id_rsa.pub $username\@$ip_server\n";

print "\n\nAppuyer sur entrée lorsque c'est réalisé\n";
my $tmp = <>;

print "\nRécupération du dump distant\n";
qx{$scp_cmd $username\@$ip_server:$remote_dump_filepath $local_dump_filepath};

print "\nInsertion dans la base de données locale\n";
qx{$mysql_cmd -u $user -p$passwd $db_client < $local_dump_filepath};

qx{$chown_cmd -R $username:$username $kss_home};

print "\n\nCréer un fichier .bashrc (ou équivalent) afin d'exporter les variables KOHA_CONF et PERL5LIB\n";
