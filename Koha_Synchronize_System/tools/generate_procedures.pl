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
my $matching_table_ids = $$conf{databases_infos}{matching_table_ids};

my $client_db_name = $$conf{databases_infos}{db_client};
my $server_db_name = $$conf{databases_infos}{db_server};
my $kss_infos_table = $$conf{databases_infos}{kss_infos_table};

my @proc_str;

push @proc_str, qq{DELIMITER //};

if ( $action eq "create" ) {
    push @proc_str, create_procedures()
} elsif ( $action eq "drop" ) {
    push @proc_str, drop_procedures()
} else {
    die "Cette action n'est pas attendue";
}

sub create_procedures {
    my @str;
    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_INIT_KSS` //};
    push @str, qq{CREATE PROCEDURE `PROC_INIT_KSS` (
    )
    BEGIN
        CREATE TABLE } . $matching_table_prefix . qq{borrowers(borrowernumber INT(11), cardnumber INT(11));
        CREATE TABLE } . $matching_table_prefix . qq{reserves(reservenumber INT(11), borrowernumber INT(11), biblionumber INT(11), reservedate DATE);
        CREATE TABLE $matching_table_ids (table_name VARCHAR(255), old INT(11), new INT(11));
    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_END_KSS` //};
    push @str, qq{CREATE PROCEDURE `PROC_END_KSS` (
    )
    BEGIN
        DROP TABLE } . $matching_table_prefix . qq{borrowers;
        DROP TABLE } . $matching_table_prefix . qq{reserves;
        DROP TABLE $matching_table_ids;
    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_INIT_KSS_INFOS` //};

    push @str, qq{CREATE PROCEDURE `PROC_INIT_KSS_INFOS` (
    )
    BEGIN
        DECLARE next_id INT(11);
        CREATE TABLE $kss_infos_table (variable VARCHAR(255) , value VARCHAR(255));

        SELECT MAX(borrowernumber) + 1 FROM borrowers INTO next_id;
        INSERT INTO $kss_infos_table (variable, value) VALUES ("borrowernumber", next_id);

        SELECT MAX(reservenumber) + 1 FROM reserves INTO next_id;
        INSERT INTO $kss_infos_table (variable, value) VALUES ("reservenumber", next_id);
    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_UPDATE_BORROWERNUMBER` //};
    push @str, qq{CREATE PROCEDURE `PROC_UPDATE_BORROWERNUMBER` (
        IN new_id INT(11),
        IN cardnumber INT(11)
    )
    BEGIN
        DECLARE old_id INT(11);
        SELECT borrowernumber FROM } . $matching_table_prefix . qq{borrowers WHERE `cardnumber`=cardnumber INTO old_id;
        INSERT INTO $matching_table_ids (table_name, old, new) VALUES("borrowers", old_id, new_id);
    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_UPDATE_RESERVENUMBER` //};
    push @str, qq{CREATE PROCEDURE `PROC_UPDATE_RESERVENUMBER` (
        IN new_id INT(11),
        IN borrowernumber INT(11),
        IN biblionumber INT(11),
        IN reservedate DATE
    )
    BEGIN
        DECLARE old_id INT(11);
        SELECT reservenumber FROM } . $matching_table_prefix . qq{reserves
            WHERE `borrowernumber`=borrowernumber
                AND `biblionumber`=biblionumber
                AND `reservedate`=reservedate
            INTO old_id;
        INSERT INTO $matching_table_ids (table_name, old, new) VALUES("reserves", old_id, new_id);
    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_GET_NEW_ID` //};
    push @str, qq{CREATE PROCEDURE `PROC_GET_NEW_ID` (
        IN field_name VARCHAR(255),
        IN old_id INT(11),
        OUT new_id INT(11)
    )
    BEGIN
        DECLARE nb INT;
        IF field_name LIKE "\%.borrowernumber" THEN
            SELECT COUNT(`new`) FROM kss_tmp_ids WHERE `table_name`="borrowers" AND `old`=old_id INTO nb;
            IF nb != 0 THEN
                SELECT `new` FROM $matching_table_ids WHERE `table_name`="borrowers" AND `old`=old_id INTO new_id;
            ELSE 
                SELECT old_id INTO new_id;
            END IF;
        ELSE
            SELECT old_id INTO new_id;
        END IF;
    END;
    //};


    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_DELETE_FROM` //};
    push @str, qq{CREATE PROCEDURE `PROC_DELETE_FROM` (
        IN field_name VARCHAR(255),
        IN id INT(11)
    )
    BEGIN
        DECLARE new_id INT(11);
        IF field_name = 'borrowers.borrowernumber' THEN
            CALL PROC_GET_NEW_ID("borrowers.borrowernumber", id, \@new_id);
            SELECT \@new_id INTO new_id;
            DELETE FROM borrowers WHERE borrowernumber=new_id;
        END IF;
    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_UPDATE` //};
    push @str, qq{CREATE PROCEDURE `PROC_UPDATE` (
        IN field_name VARCHAR(255),
        IN id INT(11)
    )
    BEGIN
        DECLARE new_id INT(11);
        IF field_name = 'borrowers.borrowernumber' THEN
            CALL PROC_GET_NEW_ID("borrowers.borrowernumber", id, \@new_id);
            SELECT \@new_id INTO new_id;
            DELETE FROM borrowers WHERE borrowernumber=new_id;
        END IF;
    END;
    //};

    return @str;
}

sub drop_procedures {
    my @str;
    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_INIT_KSS_INFOS` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_UPDATE_BORROWERNUMBER` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_UPDATE_RESERVENUMBER` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_GET_NEW_ID` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_DELETE_FROM` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_UPDATE` //};

    return @str;
}

print join "\n", @proc_str ;
