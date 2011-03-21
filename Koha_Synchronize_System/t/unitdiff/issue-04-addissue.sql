INSERT INTO issues
                  (borrowernumber, itemnumber,issuedate, date_due, branchcode)
              VALUES ('5676','43592','2011-03-11','2011-04-01','MEDIAT');
UPDATE items SET itemnumber='43592', issues='2',datelastborrowed='2011-03-11',holdingbranch='MEDIAT',itemlost='0',onloan='2011-04-01' WHERE itemnumber='43592';
UPDATE items SET itemnumber='43592',datelastseen='2011-03-11',itemlost='0' WHERE itemnumber='43592'
INSERT INTO statistics
      (datetime, branch, type, value,
      other, itemnumber, itemtype, borrowernumber, proccode)
      VALUES (now(),'MEDIAT','issue','0.0000','','43592','PG','5676',NULL)
