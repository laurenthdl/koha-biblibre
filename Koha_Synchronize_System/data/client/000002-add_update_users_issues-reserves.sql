/*!*/
INSERT INTO borrowers SET   borrowers.altcontactcountry = '' ,  borrowers.categorycode = 'COLL' ,  borrowers.othernames = 'John Carmack' ,  borrowers.B_address = '' ,  borrowers.contactnote = '' ,  borrowers.altcontactaddress2 = '' ,  borrowers.email = '' ,  borrowers.password = 'kDPg4wXyR8DDyA0MeEjIsw' ,  borrowers.B_country = '' ,  borrowers.address = '' ,  borrowers.B_address2 = '' ,  borrowers.streetnumber = '' ,  borrowers.branchcode = 'BDM' ,  borrowers.surname = 'John Carmack' ,  borrowers.cardnumber = '10001561' ,  borrowers.altcontactaddress3 = '' ,  borrowers.altcontactsurname = '' ,  borrowers.altcontactzipcode = '' ,  borrowers.opacnote = '' ,  borrowers.altcontactfirstname = '' ,  borrowers.userid = '.johncarmack' ,  borrowers.B_zipcode = '' ,  borrowers.mobile = '' ,  borrowers.B_email = '' ,  borrowers.city = '' ,  borrowers.fax = '' ,  borrowers.B_phone = '' ,  borrowers.altcontactphone = '' ,  borrowers.country = '' ,  borrowers.sort1 = '10' ,  borrowers.dateenrolled = '2011-03-15' ,  borrowers.phone = '' ,  borrowers.sex = 'N' ,  borrowers.altcontactaddress1 = '' ,  borrowers.zipcode = '11111' ,  borrowers.address2 = '' ,  borrowers.B_city = '' ,  borrowers.dateexpiry = '2012-03-15' ,  borrowers.borrowernotes = '' ,  borrowers.sort2 = '' ,  borrowers.phonepro = '' ,  borrowers.emailpro = ''
/*!*/;
DELETE FROM borrower_attributes WHERE borrowernumber = '100'
/*!*/;
INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES ('100', 'CANTON', 'canton_client', NULL)
/*!*/;
INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES ('100', 'HORAIRES', 'horaires_client', NULL)
/*!*/;
INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES ('100', 'TOURNEE', 'tournee client', NULL)
/*!*/;
UPDATE borrowers
            SET   borrowers.altcontactcountry = '' , borrowers.gonenoaddress = '0' , borrowers.categorycode = 'COLL' , borrowers.othernames = '' , borrowers.B_address = '' , borrowers.contactnote = '' , borrowers.altcontactaddress2 = '' , borrowers.email = '' , borrowers.debarred = NULL , borrowers.B_country = '' , borrowers.B_address2 = '' , borrowers.address = 'Mairie' , borrowers.streetnumber = '' , borrowers.lost = '0' , borrowers.branchcode = 'BDM' , borrowers.surname = 'modif client sur état précédent' , borrowers.gonenoaddresscomment = '' , borrowers.cardnumber = '10000955' , borrowers.altcontactaddress3 = '' , borrowers.altcontactsurname = '' , borrowers.altcontactzipcode = '' , borrowers.opacnote = '' , borrowers.altcontactfirstname = '' , borrowers.userid = '10000955' , borrowers.B_zipcode = '' , borrowers.B_email = '' , borrowers.mobile = '' , borrowers.city = 'ABAINVILLE' , borrowers.B_phone = '' , borrowers.fax = '' , borrowers.altcontactphone = '' , borrowers.debarredcomment = NULL , borrowers.country = '' , borrowers.sort1 = '10' , borrowers.dateenrolled = '1997-01-15' , borrowers.altcontactaddress1 = '' , borrowers.zipcode = '55130' , borrowers.sex = 'N' , borrowers.phone = '' , borrowers.address2 = '' , borrowers.B_city = '' , borrowers.borrowernotes = '' , borrowers.dateexpiry = '2017-01-15' , borrowers.sort2 = 'collectif' , borrowers.phonepro = '' , borrowers.emailpro = '' 
            WHERE borrowernumber='86'
/*!*/;
DELETE FROM borrower_attributes WHERE borrowernumber = '86'
/*!*/;
INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES ('86', 'CANTON', '10', NULL)
/*!*/;
UPDATE borrowers
            SET   borrowers.altcontactcountry = '' , borrowers.gonenoaddress = '0' , borrowers.categorycode = 'COLL' , borrowers.othernames = '' , borrowers.B_address = '' , borrowers.contactnote = '' , borrowers.altcontactaddress2 = '' , borrowers.email = '' , borrowers.debarred = NULL , borrowers.B_country = '' , borrowers.B_address2 = '' , borrowers.address = 'Mairie' , borrowers.streetnumber = '' , borrowers.lost = '0' , borrowers.branchcode = 'BDM' , borrowers.surname = 'modif client sur état précédent' , borrowers.gonenoaddresscomment = '' , borrowers.cardnumber = '10000955' , borrowers.altcontactaddress3 = '' , borrowers.altcontactsurname = '' , borrowers.altcontactzipcode = '' , borrowers.opacnote = '' , borrowers.altcontactfirstname = '' , borrowers.userid = '10000955' , borrowers.B_zipcode = '' , borrowers.B_email = '' , borrowers.mobile = '' , borrowers.city = 'ABAINVILLE' , borrowers.B_phone = '' , borrowers.fax = '' , borrowers.altcontactphone = '' , borrowers.debarredcomment = NULL , borrowers.country = '' , borrowers.sort1 = '10' , borrowers.dateenrolled = '1997-01-15' , borrowers.altcontactaddress1 = '' , borrowers.zipcode = '55130' , borrowers.sex = 'N' , borrowers.phone = '' , borrowers.address2 = '' , borrowers.B_city = '' , borrowers.borrowernotes = '' , borrowers.dateexpiry = '2017-01-15' , borrowers.sort2 = 'collectif' , borrowers.phonepro = '' , borrowers.emailpro = '' 
            WHERE borrowernumber='86'
/*!*/;
DELETE FROM borrower_attributes WHERE borrowernumber = '86'
/*!*/;
INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES ('86', 'CANTON', '10', NULL)
/*!*/;
INSERT INTO issues 
                    (borrowernumber, itemnumber,issuedate, date_due, branchcode)
                VALUES ('86','153','2011-03-15','2011-03-25','BDM')
/*!*/;
UPDATE items SET itemnumber='153',issues='1',datelastborrowed='2011-03-15',holdingbranch='BDM',itemlost='0',onloan='2011-03-25' WHERE itemnumber='153'
/*!*/;
UPDATE items SET itemnumber='153',datelastseen='2011-03-15',itemlost='0' WHERE itemnumber='153'
/*!*/;
INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),'BDM','issue','0.0000','','153','LIV','86',NULL)
/*!*/;
INSERT INTO issues 
                    (borrowernumber, itemnumber,issuedate, date_due, branchcode)
                VALUES ('100','275','2011-03-15','2011-03-25','BDM')
/*!*/;
UPDATE items SET itemnumber='275',issues='1',datelastborrowed='2011-03-15',holdingbranch='BDM',itemlost='0',onloan='2011-03-25' WHERE itemnumber='275'
/*!*/;
UPDATE items SET itemnumber='275',datelastseen='2011-03-15',itemlost='0' WHERE itemnumber='275'
/*!*/;
INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),'BDM','issue','0.0000','','275','LIV','100',NULL)
/*!*/;
INSERT INTO issues 
                    (borrowernumber, itemnumber,issuedate, date_due, branchcode)
                VALUES ('100','287','2011-03-15','2011-03-25','BDM')
/*!*/;
UPDATE items SET itemnumber='287',issues='1',datelastborrowed='2011-03-15',holdingbranch='BDM',itemlost='0',onloan='2011-03-25' WHERE itemnumber='287'
/*!*/;
UPDATE items SET itemnumber='287',datelastseen='2011-03-15',itemlost='0' WHERE itemnumber='287'
/*!*/;
INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),'BDM','issue','0.0000','','287','LIV','100',NULL)
/*!*/;
UPDATE issues SET returndate= now()  WHERE  borrowernumber = '100'  AND itemnumber = '275'
/*!*/;
INSERT INTO old_issues SELECT * FROM issues 
                                  WHERE borrowernumber = '100'
                                  AND itemnumber = '275'
/*!*/;
DELETE FROM issues
                                  WHERE borrowernumber = '100'
                                  AND itemnumber = '275'
/*!*/;
UPDATE items SET itemnumber='275',renewals='0',onloan=NULL WHERE itemnumber='275'
/*!*/;
UPDATE items SET itemnumber='275',datelastseen='2011-03-15',itemlost='0' WHERE itemnumber='275'
/*!*/;
INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),'BDM','return','0','','275',NULL,'100',NULL)
/*!*/;
UPDATE issues SET date_due = '2011-04-04', renewals = '1', lastreneweddate = '2011-03-15'
                            WHERE borrowernumber='100' 
                            AND itemnumber='287'
/*!*/;
UPDATE items SET itemnumber='287',renewals='1',onloan='2011-04-04' WHERE itemnumber='287'
/*!*/;
INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),'BDM','renew','0.0000','','287','LIV','100',NULL)
/*!*/;
INSERT INTO issues 
                    (borrowernumber, itemnumber,issuedate, date_due, branchcode)
                VALUES ('100','56','2011-03-15','2011-03-25','BDM')
/*!*/;
UPDATE items SET itemnumber='56',issues='1',datelastborrowed='2011-03-15',holdingbranch='BDM',itemlost='0',onloan='2011-03-25' WHERE itemnumber='56'
/*!*/;
UPDATE items SET itemnumber='56',datelastseen='2011-03-15',itemlost='0' WHERE itemnumber='56'
/*!*/;
INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),'BDM','issue','0.0000','','56','LIV','100',NULL)
/*!*/;
UPDATE issues SET returndate= now()  WHERE  borrowernumber = '100'  AND itemnumber = '56'
/*!*/;
INSERT INTO old_issues SELECT * FROM issues 
                                  WHERE borrowernumber = '100'
                                  AND itemnumber = '56'
/*!*/;
DELETE FROM issues
                                  WHERE borrowernumber = '100'
                                  AND itemnumber = '56'
/*!*/;
UPDATE items SET itemnumber='56',renewals='0',onloan=NULL WHERE itemnumber='56'
/*!*/;
UPDATE items SET itemnumber='56',datelastseen='2011-03-15',itemlost='0' WHERE itemnumber='56'
/*!*/;
INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),'BDM','return','0','','56',NULL,'100',NULL)
/*!*/;
INSERT INTO issues 
                    (borrowernumber, itemnumber,issuedate, date_due, branchcode)
                VALUES ('100','56','2011-03-15','2011-03-25','BDM')
/*!*/;
UPDATE items SET itemnumber='56',issues='2',datelastborrowed='2011-03-15',holdingbranch='BDM',itemlost='0',onloan='2011-03-25' WHERE itemnumber='56'
/*!*/;
UPDATE items SET itemnumber='56',datelastseen='2011-03-15',itemlost='0' WHERE itemnumber='56'
/*!*/;
INSERT INTO statistics
        (datetime, branch, type, value,
         other, itemnumber, itemtype, borrowernumber, proccode)
         VALUES (now(),'BDM','issue','0.0000','','56','LIV','100',NULL)
/*!*/;
INSERT INTO reserves
            (borrowernumber,biblionumber,reservedate,branchcode,constrainttype,
            priority,reservenotes,itemnumber,found,waitingdate,expirationdate)
        VALUES
             ('100','9772','2011-03-15','BDM','a',
             '1','',NULL,NULL,NULL,'2011-03-31')
/*!*/;
INSERT INTO reserves
            (borrowernumber,biblionumber,reservedate,branchcode,constrainttype,
            priority,reservenotes,itemnumber,found,waitingdate,expirationdate)
        VALUES
             ('6','9772','2011-03-15','BDM','a',
             '2','',NULL,NULL,NULL,NULL)
/*!*/;
UPDATE reserves
            SET    priority = '1'
                WHERE  reservenumber = '2'
                 AND reservedate = '2011-03-15'
         AND found IS NULL
/*!*/;
UPDATE reserves
            SET    priority = '2'
                WHERE  reservenumber = '1'
                 AND reservedate = '2011-03-15'
         AND found IS NULL
/*!*/;
UPDATE reserves SET priority = '1' ,branchcode = 'BDM', itemnumber = NULL, found = NULL, waitingdate = NULL
            WHERE reservenumber = '2'
/*!*/;
UPDATE reserves
            SET    priority = '1'
                WHERE  reservenumber = '2'
                 AND reservedate = '2011-03-15'
         AND found IS NULL
/*!*/;
UPDATE reserves
            SET    priority = '2'
                WHERE  reservenumber = '1'
                 AND reservedate = '2011-03-15'
         AND found IS NULL
/*!*/;
UPDATE reserves SET priority = '2' ,branchcode = 'BDM', itemnumber = NULL, found = NULL, waitingdate = NULL
            WHERE reservenumber = '1'
/*!*/;
UPDATE reserves
            SET    priority = '1'
                WHERE  reservenumber = '2'
                 AND reservedate = '2011-03-15'
         AND found IS NULL
/*!*/;
UPDATE reserves
            SET    priority = '2'
                WHERE  reservenumber = '1'
                 AND reservedate = '2011-03-15'
         AND found IS NULL
/*!*/;
