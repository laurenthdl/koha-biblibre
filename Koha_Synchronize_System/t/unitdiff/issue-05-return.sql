UPDATE issues SET returndate= now()  WHERE  borrowernumber = '53'  AND itemnumber = '101'
/*!*/;
INSERT INTO old_issues SELECT * FROM issues
                                WHERE borrowernumber = '53'
                                AND itemnumber = '101'
/*!*/;
DELETE FROM issues
WHERE borrowernumber = '53'
AND itemnumber = '101'
/*!*/;
UPDATE items SET itemnumber='101',renewals='0',onloan=NULL WHERE itemnumber='101'
/*!*/;
UPDATE items SET itemnumber='101',datelastseen='2011-03-11',itemlost='0' WHERE itemnumber='101'
/*!*/;
INSERT INTO statistics
(datetime, branch, type, value,
other, itemnumber, itemtype, borrowernumber, proccode)
      VALUES (now(),'BDM','return','0','','101',NULL,'53',NULL)
/*!*/;
