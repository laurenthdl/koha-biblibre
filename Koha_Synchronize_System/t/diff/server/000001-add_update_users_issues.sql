DELIMITER /*!*/;
INSERT INTO borrowers SET   borrowers.altcontactcountry = '' ,  borrowers.categorycode = 'COLL' ,  borrowers.othernames = 'Richard Stallman' ,  borrowers.B_address = '' ,  borrowers.contactnote = '' ,  borrowers.altcontactaddress2 = '' ,  borrowers.email = '' ,  borrowers.password = 'ukMdFjI43BW8MsaprXfKkg' ,  borrowers.B_country = '' ,  borrowers.address = 'adresse1' ,  borrowers.B_address2 = '' ,  borrowers.streetnumber = '11' ,  borrowers.branchcode = 'BDM' ,  borrowers.surname = 'RMS' ,  borrowers.cardnumber = '10001561' ,  borrowers.altcontactaddress3 = '' ,  borrowers.altcontactsurname = '' ,  borrowers.altcontactzipcode = '' ,  borrowers.opacnote = '' ,  borrowers.altcontactfirstname = '' ,  borrowers.userid = 'rms' ,  borrowers.B_zipcode = '' ,  borrowers.mobile = '' ,  borrowers.B_email = '' ,  borrowers.city = 'city' ,  borrowers.fax = '' ,  borrowers.B_phone = '' ,  borrowers.altcontactphone = '' ,  borrowers.country = 'country' ,  borrowers.sort1 = '10' ,  borrowers.dateenrolled = '2011-03-15' ,  borrowers.phone = '' ,  borrowers.sex = 'N' ,  borrowers.altcontactaddress1 = '' ,  borrowers.zipcode = '12345' ,  borrowers.address2 = 'adress2' ,  borrowers.B_city = '' ,  borrowers.dateexpiry = '2012-03-15' ,  borrowers.borrowernotes = '' ,  borrowers.sort2 = '' ,  borrowers.phonepro = '' ,  borrowers.emailpro = ''
/*!*/;
DELETE FROM borrower_attributes WHERE borrowernumber = '100'
/*!*/;
INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES ('100', 'CANTON', 'canton1', NULL)
/*!*/;
INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES ('100', 'HORAIRES', 'horaires', NULL)
/*!*/;
INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES ('100', 'TOURNEE', 'numéro tournée', NULL)
/*!*/;
UPDATE borrowers
            SET   borrowers.altcontactcountry = '' , borrowers.gonenoaddress = '0' , borrowers.categorycode = 'COLL' , borrowers.othernames = 'Richard Matthew Stallman' , borrowers.B_address = '' , borrowers.contactnote = '' , borrowers.altcontactaddress2 = '' , borrowers.email = '' , borrowers.debarred = NULL , borrowers.B_country = '' , borrowers.B_address2 = '' , borrowers.address = 'adresse11' , borrowers.streetnumber = '111' , borrowers.lost = '0' , borrowers.branchcode = 'BDM' , borrowers.surname = 'RMS' , borrowers.gonenoaddresscomment = '' , borrowers.cardnumber = '10001561' , borrowers.altcontactaddress3 = '' , borrowers.altcontactsurname = '' , borrowers.altcontactzipcode = '' , borrowers.opacnote = '' , borrowers.altcontactfirstname = '' , borrowers.userid = 'rms' , borrowers.B_zipcode = '' , borrowers.B_email = '' , borrowers.mobile = '' , borrowers.city = 'city' , borrowers.B_phone = '' , borrowers.fax = '' , borrowers.altcontactphone = '' , borrowers.debarredcomment = NULL , borrowers.country = 'country' , borrowers.sort1 = '10' , borrowers.dateenrolled = '2011-03-15' , borrowers.altcontactaddress1 = '' , borrowers.zipcode = '12345' , borrowers.sex = 'N' , borrowers.phone = '' , borrowers.address2 = 'adress22' , borrowers.B_city = '' , borrowers.borrowernotes = '' , borrowers.dateexpiry = '2012-03-15' , borrowers.sort2 = '' , borrowers.phonepro = '' , borrowers.emailpro = '' 
            WHERE borrowernumber='100'
/*!*/;
DELETE FROM borrower_attributes WHERE borrowernumber = '100'
/*!*/;
INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES ('100', 'CANTON', 'canton11', NULL)
/*!*/;
INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES ('100', 'HORAIRES', 'horaires', NULL)
/*!*/;
INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES ('100', 'TOURNEE', 'numéro tournée', NULL)
/*!*/;
INSERT INTO issues 
                    (borrowernumber, itemnumber,issuedate, date_due, branchcode)
                VALUES ('100','64','2011-03-15','2011-03-25','BDM')
/*!*/;
UPDATE items SET itemnumber='64',issues='1',datelastborrowed='2011-03-15',holdingbranch='BDM',itemlost='0',onloan='2011-03-25' WHERE itemnumber='64'
/*!*/;
UPDATE items SET itemnumber='64',datelastseen='2011-03-15',itemlost='0' WHERE itemnumber='64'
/*!*/;
INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),'BDM','issue','0.0000','','64','LIV','100',NULL)
/*!*/;
INSERT INTO issues 
                    (borrowernumber, itemnumber,issuedate, date_due, branchcode)
                VALUES ('100','301','2011-03-15','2011-03-25','BDM')
/*!*/;
UPDATE items SET itemnumber='301',issues='1',datelastborrowed='2011-03-15',holdingbranch='BDM',itemlost='0',onloan='2011-03-25' WHERE itemnumber='301'
/*!*/;
UPDATE items SET itemnumber='301',datelastseen='2011-03-15',itemlost='0' WHERE itemnumber='301'
/*!*/;
INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),'BDM','issue','0.0000','','301','LIV','100',NULL)
/*!*/;
INSERT INTO borrowers SET   borrowers.altcontactcountry = '' ,  borrowers.categorycode = 'COLL' ,  borrowers.othernames = 'Linus Torvald' ,  borrowers.B_address = '' ,  borrowers.contactnote = '' ,  borrowers.altcontactaddress2 = '' ,  borrowers.email = '' ,  borrowers.password = 'kDPg4wXyR8DDyA0MeEjIsw' ,  borrowers.B_country = '' ,  borrowers.address = '' ,  borrowers.B_address2 = '' ,  borrowers.streetnumber = '' ,  borrowers.branchcode = 'BDM' ,  borrowers.surname = 'Linus' ,  borrowers.cardnumber = '10001562' ,  borrowers.altcontactaddress3 = '' ,  borrowers.altcontactsurname = '' ,  borrowers.altcontactzipcode = '' ,  borrowers.opacnote = '' ,  borrowers.altcontactfirstname = '' ,  borrowers.userid = '.linus' ,  borrowers.B_zipcode = '' ,  borrowers.mobile = '' ,  borrowers.B_email = '' ,  borrowers.city = '' ,  borrowers.fax = '' ,  borrowers.B_phone = '' ,  borrowers.altcontactphone = '' ,  borrowers.country = '' ,  borrowers.sort1 = '10' ,  borrowers.dateenrolled = '2011-03-15' ,  borrowers.phone = '' ,  borrowers.sex = 'N' ,  borrowers.altcontactaddress1 = '' ,  borrowers.zipcode = '54321' ,  borrowers.address2 = '' ,  borrowers.B_city = '' ,  borrowers.dateexpiry = '2012-03-15' ,  borrowers.borrowernotes = '' ,  borrowers.sort2 = '' ,  borrowers.phonepro = '' ,  borrowers.emailpro = ''
/*!*/;
DELETE FROM borrower_attributes WHERE borrowernumber = '101'
/*!*/;
INSERT INTO issues 
                    (borrowernumber, itemnumber,issuedate, date_due, branchcode)
                VALUES ('101','208','2011-03-15','2011-03-25','BDM')
/*!*/;
UPDATE items SET itemnumber='208',issues='1',datelastborrowed='2011-03-15',holdingbranch='BDM',itemlost='0',onloan='2011-03-25' WHERE itemnumber='208'
/*!*/;
UPDATE items SET itemnumber='208',datelastseen='2011-03-15',itemlost='0' WHERE itemnumber='208'
/*!*/;
INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),'BDM','issue','0.0000','','208','LIV','101',NULL)
/*!*/;
INSERT INTO issues 
                    (borrowernumber, itemnumber,issuedate, date_due, branchcode)
                VALUES ('101','304','2011-03-15','2011-03-25','BDM')
/*!*/;
UPDATE items SET itemnumber='304',issues='1',datelastborrowed='2011-03-15',holdingbranch='BDM',itemlost='0',onloan='2011-03-25' WHERE itemnumber='304'
/*!*/;
UPDATE items SET itemnumber='304',datelastseen='2011-03-15',itemlost='0' WHERE itemnumber='304'
/*!*/;
INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),'BDM','issue','0.0000','','304','LIV','101',NULL)
/*!*/;
INSERT INTO issues 
                    (borrowernumber, itemnumber,issuedate, date_due, branchcode)
                VALUES ('101','235','2011-03-15','2011-03-25','BDM')
/*!*/;
UPDATE items SET itemnumber='235',issues='1',datelastborrowed='2011-03-15',holdingbranch='BDM',itemlost='0',onloan='2011-03-25' WHERE itemnumber='235'
/*!*/;
UPDATE items SET itemnumber='235',datelastseen='2011-03-15',itemlost='0' WHERE itemnumber='235'
/*!*/;
INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),'BDM','issue','0.0000','','235','LIV','101',NULL)
/*!*/;
INSERT INTO reserves
            (borrowernumber,biblionumber,reservedate,branchcode,constrainttype,
            priority,reservenotes,itemnumber,found,waitingdate,expirationdate)
        VALUES
             ('100','9913','2011-03-15','BDM','a',
             '1','',NULL,NULL,NULL,NULL)
/*!*/;
UPDATE issues SET returndate= now()  WHERE  borrowernumber = '101'  AND itemnumber = '235'
/*!*/;
INSERT INTO old_issues SELECT * FROM issues 
                                  WHERE borrowernumber = '101'
                                  AND itemnumber = '235'
/*!*/;
DELETE FROM issues
                                  WHERE borrowernumber = '101'
                                  AND itemnumber = '235'
/*!*/;
UPDATE items SET itemnumber='235',renewals='0',onloan=NULL WHERE itemnumber='235'
/*!*/;
UPDATE items SET itemnumber='235',datelastseen='2011-03-15',itemlost='0' WHERE itemnumber='235'
/*!*/;
INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),'BDM','return','0','','235',NULL,'101',NULL)
/*!*/;
UPDATE reserves
            SET     priority = 0,
                    found = 'W',
                    waitingdate=now(),
                    itemnumber = '235'
        WHERE reservenumber = '3'
/*!*/;
UPDATE reserves
        SET    priority = 0 , itemnumber = '235' 
        WHERE  reservenumber='3'
/*!*/;
UPDATE reserves
            SET    priority = 0
            WHERE reservenumber = '3'
              AND found ='W'
/*!*/;
UPDATE reserves
    SET    found='W',waitingdate = now()
    WHERE itemnumber='235'
      AND found IS NULL
      AND priority = 0
/*!*/;
UPDATE reserves
            SET     priority = 0,
                    found = 'W',
                    waitingdate=now(),
                    itemnumber = '235'
        WHERE reservenumber = '3'
/*!*/;
UPDATE reserves SET lowestPriority = NOT lowestPriority
         WHERE biblionumber = '9913'
         AND borrowernumber = '100'
/*!*/;
UPDATE reserves SET lowestPriority = NOT lowestPriority
         WHERE biblionumber = '9913'
         AND borrowernumber = '100'
/*!*/;
UPDATE reserves
            SET    cancellationdate = now(),
                   found            = Null,
                   priority         = 0
            WHERE  reservenumber   = '3'
/*!*/;
INSERT INTO old_reserves
            SELECT * FROM reserves
            WHERE reservenumber     = '3'
/*!*/;
DELETE FROM reserves
            WHERE  reservenumber   = '3'
/*!*/;
UPDATE reserves
	SET priority = priority-1
        WHERE  priority > '0'
	AND biblionumber = '9913'
/*!*/;
UPDATE reserves
	    SET found = 'W'
            WHERE  priority = 0
	    AND biblionumber = '9913'
/*!*/;
