#!/usr/bin/perl

use Modern::Perl;
use Data::Dumper;
use Getopt::Long;
use YAML;

use C4::Context;

my $action = "create";
GetOptions( 'action=s' => \$action );

my $koha_dir = C4::Context->config('intranetdir');

my $kss_dir = "$koha_dir/Koha_Synchronize_System";

my $conf = YAML::LoadFile("$kss_dir/conf/kss.yaml");
my $matching_table_prefix = $$conf{databases_infos}{matching_table_prefix};
my $client_db_name = $$conf{databases_infos}{db_client};
my $server_db_name = $$conf{databases_infos}{db_server};
my $kss_infos_table = $$conf{databases_infos}{kss_infos_table};

my $level1_tables = {
    'borrowers' => {
        'primary_key' => 'borrowernumber',
        'second_primary_key' => 'cardnumber'
    },
    'deletedborrowers' => {
        'primary_key' => 'borrowernumber',
        'second_primary_key' => 'cardnumber'
    }
    #'items' => 'biblioitemnumber', # replace itemnumber
};

my $level2_tables = {
    'issues' => {
        'itemnumber' => 'items.itemnumber',
        'borrowernumber' => 'borrowers.borrowernumber',
    },
    'old_issues' => {
        'itemnumber' => 'items.itemnumber',
        'borrowernumber' => 'borrowers.borrowernumber',
    },
    'statistics' => {
        'borrowernumber' => 'borrowers.borrowernumber',
    },
    'reserves' => {
        'itemnumber' => 'items.itemnumber',
        'borrowernumber' => 'borrowers.borrowernumber',
        'biblionumber' => 'biblio.biblionumber',
    },
    'old_reserves' => {
        'itemnumber' => 'items.itemnumber',
        'borrowernumber' => 'borrowers.borrowernumber',
        'biblionumber' => 'biblio.biblionumber',
    },
    'action_logs' => {
        'user' => 'borrowers.borrowernumber',
    },
    'borrower_attributes' => {
        'borrowernumber' => 'borrower.borrowernumber',
    }
};




my @trigger_str;
push @trigger_str, "DELIMITER //";

if ( $action eq "create" ) {
    push @trigger_str, create_triggers()
} elsif ( $action eq "drop" ) {
    push @trigger_str, drop_triggers()
} else {
    die "Cette action n'est pas attendue";
}

push @trigger_str, "DELIMITER ;";

sub create_triggers {

    my @str;
    # Gestion des tables de niveau 1
    while ( my ($table, $infos) = each %$level1_tables ) {

        # Trigger insert
        # Met à jour la table de correspondance des ids
        push @str, "DROP TRIGGER IF EXISTS `TRG_AFT_INS_$table` //";
        push @str, "CREATE TRIGGER `TRG_AFT_INS_$table` AFTER INSERT ON `$table`";
        push @str, "  FOR EACH ROW BEGIN";
        if ( $table eq "borrowers" ) {
            push @str, "    CALL PROC_UPDATE_BORROWERNUMBER(NEW.borrowernumber, NEW.cardnumber);";
        }
        push @str, "  END;";
        push @str, "//";


        push @str, "DROP TRIGGER IF EXISTS `TRG_BEF_INS_$table` //";
        push @str, "CREATE TRIGGER `TRG_BEF_INS_$table` BEFORE INSERT ON `$table`";
        push @str, "  FOR EACH ROW BEGIN";
        if ( $table eq "deletedborrowers" ) {
            push @str, "    DECLARE tmp_id INT(11);";
            push @str, "    CALL PROC_GET_NEW_ID(\"borrower.borrowernumber\", NEW.borrowernumber, \@tmp_id);";
            push @str, "    SELECT \@tmp_id INTO tmp_id;";
            push @str, "    SET NEW.borrowernumber = tmp_id;";
        }
        push @str, "  END;";
        push @str, "//";

        # Trigger delete
        # supprime l'enregistrement qui doit être supprimé et génère une erreur sur le delete courant
        # Can't update table 'borrowers' in stored function/trigger because it is already used by statement which invoked this stored function/trigger. 
        # error mysql ...
        #push @str, "DROP TRIGGER IF EXISTS `TRG_BEF_DEL_$table` //";
        #push @str, "CREATE TRIGGER `TRG_BEF_DEL_$table` BEFORE DELETE ON `$table`";
        #push @str, "  FOR EACH ROW BEGIN";
        #push @str, "    CALL PROC_DELETE_FROM(\"$table.$$infos{primary_key}\", OLD.$$infos{primary_key});";
        #push @str, "    SELECT 'a' INTO \@tmp;";      # Generate error
        #push @str, "    SELECT 'b', 'c' INTO \@tmp;"; # mysql can't stop trigger normally
        #push @str, "  END;";
        #push @str, "//";

    }

    # Gestion des tables de niveau 2
    while ( my ($table, $hash) = each %$level2_tables ) {

        # Trigger insert
        # Insertion de l'enregistrement avec remplacement des clés étrangères
        # qui pointent vers des clés primaires des tables de niveau  1
        push @str, "DROP TRIGGER IF EXISTS `TRG_BEF_INS_$table` //";
        push @str, "CREATE TRIGGER `TRG_BEF_INS_$table` BEFORE INSERT ON `$table`";
        push @str, "  FOR EACH ROW BEGIN";
        push @str, "    DECLARE tmp_id INT(11);";
            while (my ($field, $ref) = each %$hash) {
                my ($table_referer, $field_referer) = split /\./, $ref;
                push @str, "    CALL PROC_GET_NEW_ID(\"" . $table_referer . "." . $field_referer . "\", NEW.$field, \@tmp_id);";
                push @str, "    SELECT \@tmp_id INTO tmp_id;";
                push @str, "    SET NEW.$field = tmp_id;";
            }
        push @str, "  END;";
        push @str, "//";

        if ( $table eq "reserves" ) {
            push @str, "DROP TRIGGER IF EXISTS `TRG_AFT_INS_reserves` //";
            push @str, "CREATE TRIGGER `TRG_AFT_INS_reserves` AFTER INSERT ON `reserves`";
            push @str, "  FOR EACH ROW BEGIN";
            push @str, "    CALL PROC_UPDATE_RESERVENUMBER(NEW.reservenumber, NEW.borrowernumber, NEW.biblionumber, NEW.itemnumber, NEW.reservedate);";
            push @str, "  END;";
            push @str, "//";
        }

    }

    return @str;
}

sub drop_triggers {
    my @str;

    # Gestion des tables de niveau 1
    while ( my ($table, $infos) = each %$level1_tables ) {

        push @str, "DROP TRIGGER IF EXISTS `TRG_AFT_INS_$table` //";

        push @str, "DROP TRIGGER IF EXISTS `TRG_BEF_DEL_$table` //";

    }

    # Gestion des tables de niveau 2
    while ( my ($table, $hash) = each %$level2_tables ) {

        push @str, "DROP TRIGGER IF EXISTS `TRG_BEF_INS_$table` //";

        if ( $table eq "reserves" ) {
            push @str, "DROP TRIGGER IF EXISTS `TRG_AFT_INS_reserves` //";
        }

    }
    return @str;
}

print join "\n", @trigger_str ;
