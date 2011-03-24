INSERT INTO borrowers SET   borrowers.altcontactcountry = '' ,  borrowers.categorycode = 'COLL' ,  borrowers.othernames = 'TMP Borrower' ,  borrowers.B_address = '' ,  borrowers.contactnote = '' ,  borrowers.altcontactaddress2 = '' ,  borrowers.email = '' ,  borrowers.password = 'tmp' ,  borrowers.B_country = '' ,  borrowers.address = '' ,  borrowers.B_address2 = '' ,  borrowers.streetnumber = '' ,  borrowers.branchcode = 'BDM' ,  borrowers.surname = 'Surname tmp' ,  borrowers.cardnumber = '01010101' ,  borrowers.altcontactaddress3 = '' ,  borrowers.altcontactsurname = '' ,  borrowers.altcontactzipcode = '' ,  borrowers.opacnote = '' ,  borrowers.altcontactfirstname = '' ,  borrowers.userid = '.tmp' ,  borrowers.B_zipcode = '' ,  borrowers.mobile = '' ,  borrowers.B_email = '' ,  borrowers.city = '' ,  borrowers.fax = '' ,  borrowers.B_phone = '' ,  borrowers.altcontactphone = '' ,  borrowers.country = '' ,  borrowers.sort1 = '10' ,  borrowers.dateenrolled = '2011-03-15' ,  borrowers.phone = '' ,  borrowers.sex = 'N' ,  borrowers.altcontactaddress1 = '' ,  borrowers.zipcode = '11111' ,  borrowers.address2 = '' ,  borrowers.B_city = '' ,  borrowers.dateexpiry = '2012-03-15' ,  borrowers.borrowernotes = '' ,  borrowers.sort2 = '' ,  borrowers.phonepro = '' ,  borrowers.emailpro = ''
/*!*/;
INSERT INTO deletedborrowers VALUES ('101','01010101','Surname tmp',NULL,NULL,'TMP Borrower',NULL,'',NULL,'','','','11111','','','','','','','',NULL,NULL,'','','','','','','',NULL,'BDM','COLL','2011-03-15','2012-03-15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,'N','tmp',NULL,'.tmp','','','10','','','','','','','','','',NULL)

/*!*/;
DELETE 
FROM  reserves 
WHERE borrowernumber='101'
/*!*/;
DELETE
FROM borrowers
WHERE borrowernumber = '101'
/*!*/;
