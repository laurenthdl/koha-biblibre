#!/usr/bin/perl

use Modern::Perl;
use Data::Dumper;

my $matching_table_prefix = "kss_tmp_matching_";
my $kss_info_table = "kss_info";
my $server_db_name = "koha_devkss_server";
my $client_db_name = "koha_devkss_client";

my $level1_tables = {
    'borrowers' => 'borrowernumber',
    'items' => 'biblioitemnumber',
};

my $level2_tables = {
    'issues' => {
        'itemnumber' => 'items.biblioitemnumber',
        'borrowernumber' => 'borrowers.borrowernumber',
    },
    'old_issues' => {
        'itemnumber' => 'items.biblioitemnumber',
        'borrowernumber' => 'borrowers.borrowernumber',
    },
    'statistics' => {
        'borrowernumber' => 'borrowers.borrowernumber',
    },
    'reserves' => {
        'itemnumber' => 'items.biblioitemnumber',
        'borrowernumber' => 'borrowers.borrowernumber',
        'biblionmber' => 'biblio.biblionumber',
    },
    'old_reserves' => {
        'itemnumber' => 'items.biblioitemnumber',
        'borrowernumber' => 'borrowers.borrowernumber',
        'biblionmber' => 'biblio.biblionumber',
    },
    'action_logs' => {
        'user' => 'borrowers.borrowernumber',
    },
    'borrower_attributes' => {
        'borrowernumber' => 'borrower.borrowernumber',
    }
};

my $content = "DELIMITER //";


my $trigger_str;
while ( my ($table, $field) = each %$level1_tables ) {
    $trigger_str = "DROP TRIGGER IF EXISTS `TRG_INS_$table` //";
    $trigger_str .= "CREATE TRIGGER `TRG_INS_$table` AFTER INSERT ON `$table`";
    $trigger_str .= "  FOR EACH ROW BEGIN";
    $trigger_str .= "    CALL PROC_UPDATE_BORROWERNUMBER($client_db_name, NEW.borrowernumber, NEW.cardnumber);";
    $trigger_str .= "  END;";
    $trigger_str .= "//";

    $trigger_str .= "DROP TRIGGER IF EXISTS `TRG_DEL_$table` //";
    $trigger_str .= "CREATE TRIGGER `TRG_DEL_$table` BEFORE DELETE ON `$table`";
    $trigger_str .= "  FOR EACH ROW BEGIN";
    $trigger_str .= "    CALL PROC_DELETE_FROM($table, OLD.$field);";
    $trigger_str .= "    SELECT 'a' INTO @tmp;";      # Generate error
    $trigger_str .= "    SELECT 'b', 'c' INTO @tmp;"; # mysql can't stop trigger normally
    $trigger_str .= "  END;";
    $trigger_str .= "//";

    $trigger_str .= "DROP TRIGGER IF EXISTS `TRG_UPD_$table` //";
    $trigger_str .= "CREATE TRIGGER `TRG_UPD_$table` BEFORE UPDATE ON `$table`";
    $trigger_str .= "  FOR EACH ROW BEGIN"
    $trigger_str .= "    DECLARE tmp_id INT(11);";
    $trigger_str .= "    CALL PROC_GET_NEW_ID($table, OLD.$field, tmp_id);";
    $trigger_str .= "    SET NEW.id = tmp_id;";
    $trigger_str .= "  END;";
    $trigger_str .= "//";
}

while ( my ($table, $hash) = each %$level2_tables ) {
    $trigger_str .= "DROP TRIGGER IF EXISTS `TRG_UPD_$table` //";
    $trigger_str .= "CREATE TRIGGER `TRG_UPD_$table` BEFORE INSERT ON `$table`";
    $trigger_str .= "  FOR EACH ROW BEGIN";
        while (my ($field, $ref) = each %$hash) {
            my ($table_referer, $field_referer) = split /\./, $ref;
            $trigger_str .= "    CALL PROC_SAVE_ID_TO_DELETE($client_db_name, NEW.borrowernumber, NEW.cardnumber);";
        }
    $trigger_str .= "  END;";
    $trigger_str .= "//";


    }
}
