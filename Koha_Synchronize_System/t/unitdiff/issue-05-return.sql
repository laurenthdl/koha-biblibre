UPDATE issues SET returndate= now()  WHERE  borrowernumber = '11730'  AND itemnumber = '181880';
INSERT INTO old_issues SELECT * FROM issues
                                WHERE borrowernumber = '11730'
                                AND itemnumber = '181880';
DELETE FROM issues
WHERE borrowernumber = '11730'
AND itemnumber = '181880';
UPDATE items SET itemnumber='181880',renewals='0',onloan=NULL WHERE itemnumber='181880';
UPDATE items SET itemnumber='181880',datelastseen='2011-03-11',itemlost='0' WHERE itemnumber='181880';
INSERT INTO statistics
(datetime, branch, type, value,
other, itemnumber, itemtype, borrowernumber, proccode)
      VALUES (now(),'MEDIAT','return','0','','181880',NULL,'11730',NULL);
