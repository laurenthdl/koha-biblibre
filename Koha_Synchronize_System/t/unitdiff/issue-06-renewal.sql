INSERT INTO issues
                  (borrowernumber, itemnumber,issuedate, date_due, branchcode)
              VALUES ('54','102','2011-03-11','2011-04-01','BDM')
/*!*/;
UPDATE items SET itemnumber='102', issues='2',datelastborrowed='2011-03-11',holdingbranch='BDM',itemlost='0',onloan='2011-04-01' WHERE itemnumber='102'
/*!*/;
UPDATE items SET itemnumber='102',datelastseen='2011-03-11',itemlost='0' WHERE itemnumber='102'
/*!*/;
INSERT INTO statistics
      (datetime, branch, type, value,
      other, itemnumber, itemtype, borrowernumber, proccode)
      VALUES (now(),'BDM','issue','0.0000','','102','PG','54',NULL)
/*!*/;
UPDATE issues SET date_due = '2011-04-01', renewals = '1', lastreneweddate = '2011-03-11'
                          WHERE borrowernumber='54'
                          AND itemnumber='102'
/*!*/;
UPDATE items SET itemnumber='102',renewals='1',onloan='2011-04-01' WHERE itemnumber='102'
/*!*/;
