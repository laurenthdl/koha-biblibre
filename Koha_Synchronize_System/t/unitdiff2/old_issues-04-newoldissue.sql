INSERT INTO issues
                  (borrowernumber, itemnumber,issuedate, date_due, branchcode)
              VALUES ('100','123','2011-03-11','2011-04-01','BDM')
/*!*/;
UPDATE items SET itemnumber='123', issues='2',datelastborrowed='2011-03-11',holdingbranch='BDM',itemlost='0',onloan='2011-04-01' WHERE itemnumber='123'
/*!*/;
UPDATE items SET itemnumber='123',datelastseen='2011-03-11',itemlost='0' WHERE itemnumber='123'
/*!*/;
INSERT INTO statistics
      (datetime, branch, type, value,
      other, itemnumber, itemtype, borrowernumber, proccode)
      VALUES (now(),'BDM','issue','0.0000','','123','PG','100',NULL)
/*!*/;
INSERT INTO old_issues SELECT * FROM issues 
                                  WHERE borrowernumber = '100'
                                  AND itemnumber = '123'
/*!*/;
DELETE FROM issues
                                  WHERE borrowernumber = '100'
                                  AND itemnumber = '123'

