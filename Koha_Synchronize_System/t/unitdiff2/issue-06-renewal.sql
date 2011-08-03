INSERT INTO issues
                  (borrowernumber, itemnumber,issuedate, date_due, branchcode)
              VALUES ('100','122','2011-03-11','2011-04-01','BDM')
/*!*/;
UPDATE items SET itemnumber='122', issues='2',datelastborrowed='2011-03-11',holdingbranch='BDM',itemlost='0',onloan='2011-04-01' WHERE itemnumber='122'
/*!*/;
UPDATE items SET itemnumber='122',datelastseen='2011-03-11',itemlost='0' WHERE itemnumber='122'
/*!*/;
INSERT INTO statistics
      (datetime, branch, type, value,
      other, itemnumber, itemtype, borrowernumber, proccode)
      VALUES (now(),'BDM','issue','0.0000','','122','PG','100',NULL)
/*!*/;
UPDATE issues SET date_due = '2011-04-01', renewals = '1', lastreneweddate = '2011-03-11'
                          WHERE borrowernumber='100'
                          AND itemnumber='122'
/*!*/;
UPDATE items SET itemnumber='122',renewals='1',onloan='2011-04-01' WHERE itemnumber='122'
/*!*/;
