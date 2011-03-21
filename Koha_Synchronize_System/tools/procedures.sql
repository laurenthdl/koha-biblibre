DELIMITER //
DROP PROCEDURE IF EXISTS `PROC_ID_KSS_INFOS` //
DROP PROCEDURE IF EXISTS `PROC_INIT_KSS_INFOS` //
CREATE PROCEDURE `PROC_INIT_KSS_INFOS` (
)
BEGIN
    CREATE TABLE kss_tmp_matching_(old INT(11), new INT(11));
END;
//
DROP PROCEDURE IF EXISTS `PROC_INIT_KSS_INFOS` //
CREATE PROCEDURE `PROC_INIT_KSS_INFOS` (
    IN server_db_name VARCHAR(255)
)
BEGIN
    DECLARE next_id INT(11);
    CREATE TABLE kss_infos (variable VARCHAR(255) , value VARCHAR(255));
    SET @select_next_id = CONCAT('SELECT MAX(borrowernumber) + 1 FROM ', server_db_name, '.borrowers INTO next_id');
    PREPARE stmt FROM @select_next_id;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END;
//
DROP PROCEDURE IF EXISTS `PROC_UPDATE_ID` //
CREATE PROCEDURE `PROC_UPDATE_ID` (
    IN field_name VARCHAR(255),
    IN new_id INT(11),
    IN cardnumber VARCHAR(16)
)
BEGIN
    DECLARE old_id INT(11);
    IF field_name = 'borrowers.borrowernumber' THEN
        SELECT old_max_id FROM kss_tmp_matching_borrowers WHERE `cardnumber`=cardnumber INTO old_id;
        INSERT INTO kss_tmp_matching_borrowers(old, new) VALUES(old_id, new_id);
    END IF;
END;
//
DROP PROCEDURE IF EXISTS `PROC_GET_NEW_ID` //
CREATE PROCEDURE `PROC_GET_NEW_ID` (
    IN field_name VARCHAR(255),
    IN old_id INT(11),
    OUT new_id INT(11)
)
BEGIN
    IF field_name LIKE "%.borrowernumber" THEN
        SELECT `new` FROM kss_tmp_matching_borrowers WHERE `old`=old_id INTO new_id;
    ELSE
        SELECT old_id INTO new_id;
    END IF;
END;
//
DROP PROCEDURE IF EXISTS `PROC_DELETE_FROM` //
CREATE PROCEDURE `PROC_DELETE_FROM` (
    IN field_name VARCHAR(255),
    IN id INT(11)
)
BEGIN
    DECLARE new_id INT(11);
    IF field_name = 'borrowers.borrowernumber' THEN
        CALL PROC_GET_NEW_ID(field_name, id, @new_id);
        SELECT @new_id INTO new_id;
        DELETE FROM borrowers WHERE borrowernumber=new_id;
    END IF;
END;
//
DROP PROCEDURE IF EXISTS `PROC_UPDATE` //
CREATE PROCEDURE `PROC_UPDATE` (
    IN field_name VARCHAR(255),
    IN id INT(11)
)
BEGIN
    DECLARE new_id INT(11);
    IF field_name = 'borrowers.borrowernumber' THEN
        CALL PROC_GET_NEW_ID(field_name, id, @new_id);
        SELECT @new_id INTO new_id;
        DELETE FROM borrowers WHERE borrowernumber=new_id;
    END IF;
END;
//