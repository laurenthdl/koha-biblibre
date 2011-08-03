INSERT INTO issues
                  (borrowernumber, itemnumber,issuedate, date_due, branchcode)
              VALUES ('53','101','2011-03-11','2011-04-01','BDM')
/*!*/;
UPDATE items SET itemnumber='101', issues='2',datelastborrowed='2011-03-11',holdingbranch='BDM',itemlost='0',onloan='2011-04-01' WHERE itemnumber='101'
/*!*/;
UPDATE items SET itemnumber='101',datelastseen='2011-03-11',itemlost='0' WHERE itemnumber='101'
/*!*/;
INSERT INTO statistics
      (datetime, branch, type, value,
      other, itemnumber, itemtype, borrowernumber, proccode)
      VALUES (now(),'BDM','issue','0.0000','','101','PG','53',NULL)
/*!*/;
