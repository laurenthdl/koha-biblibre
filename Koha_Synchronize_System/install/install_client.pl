use Modern::Perl;
use DBI;
use YAML;

use Koha_Synchronize_System::tools::kss;

my $conf                     = Koha_Synchronize_System::tools::kss::get_conf();
my $kss_dir                  = $$conf{path}{kss_dir};
my $db_client                = $$conf{databases_infos}{db_client};
my $mysql_cmd                = $$conf{which_cmd}{mysql};
my $hostname                 = $$conf{databases_infos}{hostname};
my $user                     = $$conf{databases_infos}{user};
my $passwd                   = $$conf{databases_infos}{passwd};
my $dump_id_dir              = $$conf{path}{dump_ids};
my $kss_infos_table          = $$conf{databases_infos}{kss_infos_table};
my $kss_home                 = $$conf{path}{kss_client_home};
my $inbox                    = $$conf{path}{client_inbox};
my $outbox                   = $$conf{path}{client_outbox};
my $ip_server                = $$conf{cron}{serverhost};

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
    qx{useradd --home $kss_home --create-home $username --password $pwd};
};
if ( $@ ) {
    print "Can't create user kss";
    exit(1);
}

qx{mkdir -p $inbox};
qx{mkdir -p $outbox};
qx{chown -R $username:$username $inbox};
qx{chown -R $username:$username $outbox};

print "Génération de la clé ssh...\n";

qx{ssh-keygen -t rsa -N "" -f $kss_home/.ssh/id_rsa};

qx{chown -R $username:$username $kss_home};

# su kss
$< = (getpwnam($username))[2];

print "/!\ Changer le mot de passe pour l'utilisateur $username\n";
print "Éxécutez la commande suivante : \nssh-copy-id -i $kss_home/.ssh/id_rsa.pub $username\@$ip_server\n";
