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
my $kss_logs_table = $$conf{databases_infos}{kss_logs_table};
my $kss_errors_table = $$conf{databases_infos}{kss_errors_table};
my $kss_sql_errors_table = $$conf{databases_infos}{kss_sql_errors_table};
my $kss_statistics_table = $$conf{databases_infos}{kss_statistics_table};
my $max_old_borrowernumber_fieldname = $$conf{databases_infos}{max_borrowers_fieldname};
my $max_old_reservenumber_fieldname = $$conf{databases_infos}{max_reserves_fieldname};
my @proc_str;

push @proc_str, qq{DELIMITER //};

if ( $action eq "create" ) {
    push @proc_str, create_procedures()
} elsif ( $action eq "drop" ) {
    push @proc_str, drop_procedures()
} else {
    die "Cette action n'est pas attendue";
}

push @proc_str, qq{DELIMITER ;};

sub create_procedures {
    my @str;
    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_INIT_KSS` //};
    push @str, qq{CREATE PROCEDURE `PROC_INIT_KSS` (
    )
    BEGIN
        CREATE TABLE } . $matching_table_prefix . qq{borrowers(
            borrowernumber INT(11),
            cardnumber VARCHAR(16)
        )ENGINE=InnoDB DEFAULT CHARSET=utf8;

        CREATE TABLE } . $matching_table_prefix . qq{reserves(
            reservenumber INT(11),
            borrowernumber INT(11),
            biblionumber INT(11),
            itemnumber iNT(11),
            reservedate DATE
        )ENGINE=InnoDB DEFAULT CHARSET=utf8;
        
        CREATE TABLE $matching_table_ids (
            table_name VARCHAR(255),
            old INT(11),
            new INT(11)
        )ENGINE=InnoDB DEFAULT CHARSET=utf8;
        
        CREATE TABLE IF NOT EXISTS $kss_logs_table (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `progress` int(11) ,
          `status` text ,
          `start_time` TIMESTAMP  NOT NULL DEFAULT NOW(),
          `end_time` TIMESTAMP ,
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

        CREATE TABLE IF NOT EXISTS $kss_errors_table (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `kss_id` int(11) NOT NULL,
          `error` text NOT NULL,
          `message` text NULL,
          CONSTRAINT `ksserr_ksslogs` FOREIGN KEY (`kss_id`) REFERENCES `kss_logs` (`id`) ON DELETE CASCADE,
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

        CREATE TABLE IF NOT EXISTS $kss_sql_errors_table (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `kss_id` int(11) NOT NULL,
          `error` text NOT NULL,
          `query` text NULL,
          CONSTRAINT `ksssql_ksslogs` FOREIGN KEY (`kss_id`) REFERENCES `kss_logs` (`id`) ON DELETE CASCADE,
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

        CREATE TABLE IF NOT EXISTS $kss_sql_errors_table (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `kss_id` int(11) NOT NULL,
          `error` text NOT NULL,
          `query` text NULL,
          CONSTRAINT `ksssql_ksslogs` FOREIGN KEY (`kss_id`) REFERENCES `kss_logs` (`id`) ON DELETE CASCADE,
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

        CREATE TABLE IF NOT EXISTS $kss_statistics_table (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `kss_id` int(11) NOT NULL,
          `variable` VARCHAR(255) NOT NULL,
          `itemnumber` INT(11) NULL,
          `biblionumber` INT(11) NULL,
          CONSTRAINT `kssstats_ksslogs` FOREIGN KEY (`kss_id`) REFERENCES `kss_logs` (`id`) ON DELETE CASCADE,
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_CLEAN_KSS` //};
    push @str, qq{CREATE PROCEDURE `PROC_CLEAN_KSS` (
    )
    BEGIN
        DROP TABLE } . $matching_table_prefix . qq{borrowers;
        DROP TABLE } . $matching_table_prefix . qq{reserves;
        DROP TABLE $matching_table_ids;
    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_CREATE_KSS_INFOS` //};

    push @str, qq{CREATE PROCEDURE `PROC_CREATE_KSS_INFOS` (
    )
    BEGIN
        DECLARE next_id INT(11);
        CREATE TABLE $client_db_name.$kss_infos_table (variable VARCHAR(255) , value VARCHAR(255));

        SELECT MAX(GREATEST(o.borrowernumber, b.borrowernumber)) + 1 FROM deletedborrowers o, borrowers b INTO next_id;
        INSERT INTO $client_db_name.$kss_infos_table (variable, value) VALUES ("$max_old_borrowernumber_fieldname", next_id);
        
        SELECT MAX(GREATEST(o.reservenumber, r.reservenumber)) + 1 FROM old_reserves o, reserves r INTO next_id;
        INSERT INTO $client_db_name.$kss_infos_table (variable, value) VALUES ("$max_old_reservenumber_fieldname", next_id);
    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_UPDATE_BORROWERNUMBER` //};
    push @str, qq{CREATE PROCEDURE `PROC_UPDATE_BORROWERNUMBER` (
        IN new_id INT(11),
        IN cardout VARCHAR(16)
    )
    BEGIN
        DECLARE old_id INT(11);
        SELECT borrowernumber FROM } . $matching_table_prefix . qq{borrowers WHERE `cardnumber` LIKE cardout INTO old_id;
        INSERT INTO $matching_table_ids (table_name, old, new) VALUES("borrowers", old_id, new_id);
    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_UPDATE_RESERVENUMBER` //};
    push @str, qq{CREATE PROCEDURE `PROC_UPDATE_RESERVENUMBER` (
        IN new_id INT(11),
        IN bn INT(11),
        IN bibn INT(11),
        IN itemn INT(11),
        IN rd DATE
    )
    BEGIN
        DECLARE old_id INT(11);
        IF itemn IS NULL THEN
            SELECT reservenumber FROM } . $matching_table_prefix . qq{reserves
                WHERE `borrowernumber`=bn
                    AND `biblionumber`=bibn
                    AND `itemnumber` IS NULL
                    AND `reservedate`=rd
                INTO old_id;
        ELSE
            SELECT reservenumber FROM } . $matching_table_prefix . qq{reserves
                WHERE `borrowernumber`=bn
                    AND `biblionumber`=bibn
                    AND `itemnumber`=itemn
                    AND `reservedate`=rd
                INTO old_id;
        END IF;

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
            IF field_name LIKE "\%.reservenumber" THEN
                SELECT COUNT(`new`) FROM kss_tmp_ids WHERE `table_name`="reserves" AND `old`=old_id INTO nb;
                IF nb != 0 THEN
                    SELECT `new` FROM $matching_table_ids WHERE `table_name`="reserves" AND `old`=old_id INTO new_id;
                ELSE 
                    SELECT old_id INTO new_id;
                END IF;
            ELSE
                SELECT old_id INTO new_id;
            END IF;
        END IF;
    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_GET_OLD_ID` //};
    push @str, qq{CREATE PROCEDURE `PROC_GET_OLD_ID` (
        IN field_name VARCHAR(255),
        IN new_id INT(11),
        OUT old_id INT(11)
    )
    BEGIN
        DECLARE nb INT;
        IF field_name LIKE "\%.borrowernumber" THEN
            SELECT COUNT(`old`) FROM kss_tmp_ids WHERE `table_name`="borrowers" AND `new`=new_id INTO nb;
            IF nb != 0 THEN
                SELECT `old` FROM $matching_table_ids WHERE `table_name`="borrowers" AND `new`=new_id INTO old_id;
            ELSE 
                SELECT new_id INTO old_id;
            END IF;
        ELSE
            IF field_name LIKE "\%.reservenumber" THEN
                SELECT COUNT(`old`) FROM kss_tmp_ids WHERE `table_name`="reserves" AND `new`=new_id INTO nb;
                IF nb != 0 THEN
                    SELECT `old` FROM $matching_table_ids WHERE `table_name`="reserves" AND `new`=new_id INTO old_id;
                ELSE 
                    SELECT new_id INTO old_id;
                END IF;
            ELSE
                SELECT new_id INTO old_id;
            END IF;
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

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_KSS_START` //};
    push @str, qq{CREATE PROCEDURE `PROC_KSS_START` (
    )
    BEGIN
        CALL PROC_INIT_KSS();
        INSERT INTO $kss_logs_table (`progress`, `status`, `start_time`) VALUES (0, "Starting...", NOW());
    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_KSS_END` //};
    push @str, qq{CREATE PROCEDURE `PROC_KSS_END` (
    )
    BEGIN
        UPDATE $kss_logs_table SET `end_time` = NOW(), `status` = "End !" WHERE `id` = (SELECT MAX(id) from (select id from $kss_logs_table) as id );
        CALL PROC_CLEAN_KSS();
    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_SET_STATUS` //};
    push @str, qq{CREATE PROCEDURE `PROC_SET_STATUS` (
        IN status TEXT
    )
    BEGIN
        UPDATE $kss_logs_table SET `status` = "status !" WHERE `id` = (SELECT MAX(id) from (select id from $kss_logs_table) as id );
    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_ADD_ERROR` //};
    push @str, qq{CREATE PROCEDURE `PROC_ADD_ERROR` (
        IN error TEXT,
        IN message TEXT
    )
    BEGIN
        INSERT INTO $kss_errors_table (`kss_id`, `error`, `message`) VALUES (
            ( SELECT MAX(`id`) FROM $kss_logs_table ),
            error,
            message
        );
    END;
    //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_ADD_SQL_ERROR` //};
    push @str, qq{CREATE PROCEDURE `PROC_ADD_SQL_ERROR` (
        IN error TEXT,
        IN query TEXT
    )
    BEGIN
        INSERT INTO $kss_sql_errors_table (`kss_id`, `error`, `query`) VALUES (
            ( SELECT MAX(`id`) FROM $kss_logs_table ),
            error,
            query
        );
    END;
    //};


    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_ADD_STATISTIC` //};
    push @str, qq{CREATE PROCEDURE `PROC_ADD_STATISTIC` (
        IN stat_type VARCHAR(255),
        IN itemnumber INT(11),
        IN biblionumber INT(11)
    )
    BEGIN
        INSERT INTO $kss_statistics_table (`kss_id`, `variable`, `itemnumber`, `biblionumber`) VALUES (
            ( SELECT MAX(id) FROM $kss_logs_table ),
            stat_type,
            itemnumber,
            biblionumber
        );
    END;
    //};

    return @str;
}

sub drop_procedures {
    my @str;
    
    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_INIT_KSS` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_CLEAN_KSS` //};
    
    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_CREATE_KSS_INFOS` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_UPDATE_BORROWERNUMBER` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_UPDATE_RESERVENUMBER` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_GET_NEW_ID` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_GET_OLD_ID` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_DELETE_FROM` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_KSS_END` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_KSS_START` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_SET_STATUS` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_ADD_ERROR` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_ADD_SQL_ERROR` //};

    push @str, qq{DROP PROCEDURE IF EXISTS `PROC_ADD_STATISTIC` //};

    return @str;
}

print join "\n", @proc_str ;
