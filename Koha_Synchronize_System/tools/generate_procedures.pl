#!/usr/bin/perl

use Modern::Perl;
use Data::Dumper;
use YAML;

use C4::Context;

my $koha_dir = C4::Context->config('intranetdir');

my $kss_dir = "$koha_dir/Koha_Synchronize_System";

my $conf = YAML::LoadFile("$kss_dir/conf/kss.yaml");
my $matching_table_prefix = $$conf{databases_infos}{matching_table_prefix};

my $client_db_name = $$conf{databases_infos}{db_client};
my $server_db_name = $$conf{databases_infos}{db_server};
my $kss_infos_table = $$conf{databases_infos}{kss_infos_table};

my @proc_str;

push @proc_str, qq{DELIMITER //};

push @proc_str, qq{DROP PROCEDURE IF EXISTS `PROC_INIT_KSS_INFOS` //};
push @proc_str, qq{CREATE PROCEDURE `PROC_INIT_KSS_INFOS` (
)
BEGIN
    CREATE TABLE $matching_table_prefix(old INT(11), new INT(11));
END;
//};


push @proc_str, qq{DROP PROCEDURE IF EXISTS `PROC_INIT_KSS_INFOS` //};

push @proc_str, qq{CREATE PROCEDURE `PROC_INIT_KSS_INFOS` (
    IN server_db_name VARCHAR(255)
)
BEGIN
    DECLARE next_id INT(11);
    CREATE TABLE $kss_infos_table (variable VARCHAR(255) , value VARCHAR(255));
    SET \@select_next_id = CONCAT('SELECT MAX(borrowernumber) + 1 FROM ', server_db_name, '.borrowers INTO next_id');
    PREPARE stmt FROM \@select_next_id;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    INSERT INTO $kss_infos_table(variable, value) VALUES ("borrowernumber", next_id);

    CREATE TABLE $kss_infos_table (variable VARCHAR(255) , value VARCHAR(255));
    SET \@select_next_id = CONCAT('SELECT MAX(reservenumber) + 1 FROM ', server_db_name, '.reserves INTO next_id');
    PREPARE stmt FROM \@select_next_id;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    INSERT INTO $kss_infos_table(variable, value) VALUES ("reservenumber", next_id);
END;
//};

push @proc_str, qq{DROP PROCEDURE IF EXISTS `PROC_UPDATE_BORROWERNUMBER` //};
push @proc_str, qq{CREATE PROCEDURE `PROC_UPDATE_BORROWERNUMBER` (
    IN new_id INT(11),
    IN cardnumber INT(11)
)
BEGIN
    DECLARE old_id INT(11);
    SELECT old_max_id FROM } . $matching_table_prefix . qq{borrowers WHERE `cardnumber`=cardnumber INTO old_id;
    INSERT INTO } . $matching_table_prefix . qq{borrowers(old, new) VALUES(old_id, new_id);
END;
//};

push @proc_str, qq{DROP PROCEDURE IF EXISTS `PROC_UPDATE_RESERVENUMBER` //};
push @proc_str, qq{CREATE PROCEDURE `PROC_UPDATE_RESERVENUMBER` (
    IN new_id INT(11),
    IN borrowernumber INT(11),
    IN biblionumber INT(11),
    IN reservedate DATE
)
BEGIN
    DECLARE old_id INT(11);
    SELECT old_max_id FROM } . $matching_table_prefix . qq{reserves
        WHERE `borrowernumber`=borrowernumber
            AND `biblionumber`=biblionumber
            AND `reservedate`=reservedate
        INTO old_id;
    INSERT INTO } . $matching_table_prefix . qq{borrowers(old, new) VALUES(old_id, new_id);
END;
//};

push @proc_str, qq{DROP PROCEDURE IF EXISTS `PROC_GET_NEW_ID` //};
push @proc_str, qq{CREATE PROCEDURE `PROC_GET_NEW_ID` (
    IN field_name VARCHAR(255),
    IN old_id INT(11),
    OUT new_id INT(11)
)
BEGIN
    IF field_name LIKE "\%.borrowernumber" THEN
        SELECT `new` FROM } . $matching_table_prefix . qq{borrowers WHERE `old`=old_id INTO new_id;
        IF new_id IS NULL THEN
            SELECT old_id INTO new_id;
        END IF;
    ELSE
        SELECT old_id INTO new_id;
    END IF;
END;
//};


push @proc_str, qq{DROP PROCEDURE IF EXISTS `PROC_DELETE_FROM` //};
push @proc_str, qq{CREATE PROCEDURE `PROC_DELETE_FROM` (
    IN field_name VARCHAR(255),
    IN id INT(11)
)
BEGIN
    DECLARE new_id INT(11);
    IF field_name = 'borrowers.borrowernumber' THEN
        CALL PROC_GET_NEW_ID(field_name, id, \@new_id);
        SELECT \@new_id INTO new_id;
        DELETE FROM borrowers WHERE borrowernumber=new_id;
    END IF;
END;
//};

push @proc_str, qq{DROP PROCEDURE IF EXISTS `PROC_UPDATE` //};
push @proc_str, qq{CREATE PROCEDURE `PROC_UPDATE` (
    IN field_name VARCHAR(255),
    IN id INT(11)
)
BEGIN
    DECLARE new_id INT(11);
    IF field_name = 'borrowers.borrowernumber' THEN
        CALL PROC_GET_NEW_ID(field_name, id, \@new_id);
        SELECT \@new_id INTO new_id;
        DELETE FROM borrowers WHERE borrowernumber=new_id;
    END IF;
END;
//};

print join "\n", @proc_str ;
