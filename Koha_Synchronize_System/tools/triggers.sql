DELIMITER //
DROP TRIGGER IF EXISTS `TRG_AFT_INS_borrowers` //
CREATE TRIGGER `TRG_AFT_INS_borrowers` AFTER INSERT ON `borrowers`
  FOR EACH ROW BEGIN
    CALL PROC_UPDATE_ID(borrowers.borrowernumber, NEW.borrowernumber, NEW.cardnumber);
  END;
//
DROP TRIGGER IF EXISTS `TRG_BEF_DEL_borrowers` //
CREATE TRIGGER `TRG_BEF_DEL_borrowers` BEFORE DELETE ON `borrowers`
  FOR EACH ROW BEGIN
    CALL PROC_DELETE_FROM(borrowers.borrowernumber, OLD.borrowernumber);
    SELECT 'a' INTO @tmp;
    SELECT 'b', 'c' INTO @tmp;
  END;
//
DROP TRIGGER IF EXISTS `TRG_INS_issues` //
CREATE TRIGGER `TRG_DEL_issues` BEFORE INSERT ON `issues`
  FOR EACH ROW BEGIN
    DECLARE tmp_id INT(11);
    CALL PROC_GET_NEW_ID(items.itemnumber, NEW.itemnumber, @tmp_id);
    SELECT @tmp_id INTO tmp_id;
    SET NEW.itemnumber = tmp_id;
    CALL PROC_GET_NEW_ID(borrowers.borrowernumber, NEW.borrowernumber, @tmp_id);
    SELECT @tmp_id INTO tmp_id;
    SET NEW.borrowernumber = tmp_id;
  END;
//
DROP TRIGGER IF EXISTS `TRG_INS_old_reserves` //
CREATE TRIGGER `TRG_DEL_old_reserves` BEFORE INSERT ON `old_reserves`
  FOR EACH ROW BEGIN
    DECLARE tmp_id INT(11);
    CALL PROC_GET_NEW_ID(items.itemnumber, NEW.itemnumber, @tmp_id);
    SELECT @tmp_id INTO tmp_id;
    SET NEW.itemnumber = tmp_id;
    CALL PROC_GET_NEW_ID(biblio.biblionumber, NEW.biblionumber, @tmp_id);
    SELECT @tmp_id INTO tmp_id;
    SET NEW.biblionumber = tmp_id;
    CALL PROC_GET_NEW_ID(borrowers.borrowernumber, NEW.borrowernumber, @tmp_id);
    SELECT @tmp_id INTO tmp_id;
    SET NEW.borrowernumber = tmp_id;
  END;
//
DROP TRIGGER IF EXISTS `TRG_INS_old_issues` //
CREATE TRIGGER `TRG_DEL_old_issues` BEFORE INSERT ON `old_issues`
  FOR EACH ROW BEGIN
    DECLARE tmp_id INT(11);
    CALL PROC_GET_NEW_ID(items.itemnumber, NEW.itemnumber, @tmp_id);
    SELECT @tmp_id INTO tmp_id;
    SET NEW.itemnumber = tmp_id;
    CALL PROC_GET_NEW_ID(borrowers.borrowernumber, NEW.borrowernumber, @tmp_id);
    SELECT @tmp_id INTO tmp_id;
    SET NEW.borrowernumber = tmp_id;
  END;
//
DROP TRIGGER IF EXISTS `TRG_INS_borrower_attributes` //
CREATE TRIGGER `TRG_DEL_borrower_attributes` BEFORE INSERT ON `borrower_attributes`
  FOR EACH ROW BEGIN
    DECLARE tmp_id INT(11);
    CALL PROC_GET_NEW_ID(borrower.borrowernumber, NEW.borrowernumber, @tmp_id);
    SELECT @tmp_id INTO tmp_id;
    SET NEW.borrowernumber = tmp_id;
  END;
//
DROP TRIGGER IF EXISTS `TRG_INS_action_logs` //
CREATE TRIGGER `TRG_DEL_action_logs` BEFORE INSERT ON `action_logs`
  FOR EACH ROW BEGIN
    DECLARE tmp_id INT(11);
    CALL PROC_GET_NEW_ID(borrowers.borrowernumber, NEW.user, @tmp_id);
    SELECT @tmp_id INTO tmp_id;
    SET NEW.user = tmp_id;
  END;
//
DROP TRIGGER IF EXISTS `TRG_INS_statistics` //
CREATE TRIGGER `TRG_DEL_statistics` BEFORE INSERT ON `statistics`
  FOR EACH ROW BEGIN
    DECLARE tmp_id INT(11);
    CALL PROC_GET_NEW_ID(borrowers.borrowernumber, NEW.borrowernumber, @tmp_id);
    SELECT @tmp_id INTO tmp_id;
    SET NEW.borrowernumber = tmp_id;
  END;
//
DROP TRIGGER IF EXISTS `TRG_INS_reserves` //
CREATE TRIGGER `TRG_DEL_reserves` BEFORE INSERT ON `reserves`
  FOR EACH ROW BEGIN
    DECLARE tmp_id INT(11);
    CALL PROC_GET_NEW_ID(items.itemnumber, NEW.itemnumber, @tmp_id);
    SELECT @tmp_id INTO tmp_id;
    SET NEW.itemnumber = tmp_id;
    CALL PROC_GET_NEW_ID(biblio.biblionumber, NEW.biblionumber, @tmp_id);
    SELECT @tmp_id INTO tmp_id;
    SET NEW.biblionumber = tmp_id;
    CALL PROC_GET_NEW_ID(borrowers.borrowernumber, NEW.borrowernumber, @tmp_id);
    SELECT @tmp_id INTO tmp_id;
    SET NEW.borrowernumber = tmp_id;
  END;
//