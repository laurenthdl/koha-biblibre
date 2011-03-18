#!/usr/bin/perl

use Modern::Perl;
use Data::Dumper;

my $matching_table_prefix = "kss_tmp_matching_";
my $kss_info_table = "kss_info";
my $server_db_name = "koha_devkss_server";
my $client_db_name = "koha_devkss_client";

my $level1_tables = {
    'borrowers' => {
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

# Gestion des tables de niveau 1
while ( my ($table, $infos) = each %$level1_tables ) {

    # Trigger insert
    # Met à jour la table de correspondance des ids
    push @trigger_str, "DROP TRIGGER IF EXISTS `TRG_AFT_INS_$table` //";
    push @trigger_str, "CREATE TRIGGER `TRG_AFT_INS_$table` AFTER INSERT ON `$table`";
    push @trigger_str, "  FOR EACH ROW BEGIN";
    push @trigger_str, "    CALL PROC_UPDATE_ID($table.$$infos{primary_key}, NEW.$$infos{primary_key}, NEW.cardnumber);";
    push @trigger_str, "  END;";
    push @trigger_str, "//";

    # Trigger delete
    # supprime l'enregistrement qui doit être supprimé et génère une erreur sur le delete courant
    push @trigger_str, "DROP TRIGGER IF EXISTS `TRG_BEF_DEL_$table` //";
    push @trigger_str, "CREATE TRIGGER `TRG_BEF_DEL_$table` BEFORE DELETE ON `$table`";
    push @trigger_str, "  FOR EACH ROW BEGIN";
    push @trigger_str, "    CALL PROC_DELETE_FROM($table.$$infos{primary_key}, OLD.$$infos{primary_key});";
    push @trigger_str, "    SELECT 'a' INTO \@tmp;";      # Generate error
    push @trigger_str, "    SELECT 'b', 'c' INTO \@tmp;"; # mysql can't stop trigger normally
    push @trigger_str, "  END;";
    push @trigger_str, "//";

}

# Gestion des tables de niveau 2
while ( my ($table, $hash) = each %$level2_tables ) {

    # Trigger insert
    # Insertion de l'enregistrement avec remplacement des clés étrangères
    # qui pointent vers des clés primaires des tables de niveau  1
    push @trigger_str, "DROP TRIGGER IF EXISTS `TRG_INS_$table` //";
    push @trigger_str, "CREATE TRIGGER `TRG_DEL_$table` BEFORE INSERT ON `$table`";
    push @trigger_str, "  FOR EACH ROW BEGIN";
    push @trigger_str, "    DECLARE tmp_id INT(11);";
        while (my ($field, $ref) = each %$hash) {
            my ($table_referer, $field_referer) = split /\./, $ref;
            push @trigger_str, "    CALL PROC_GET_NEW_ID(" . $table_referer . "." . $field_referer . ", NEW.$field, \@tmp_id);";
            push @trigger_str, "    SELECT \@tmp_id INTO tmp_id;";
            push @trigger_str, "    SET NEW.$field = tmp_id;";
        }
    push @trigger_str, "  END;";
    push @trigger_str, "//";

}

print join "\n", @trigger_str ;
