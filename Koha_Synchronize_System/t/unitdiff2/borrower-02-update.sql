UPDATE borrowers
SET borrowers.altcontactcountry = '' ,  borrowers.categorycode = 'COLL' ,  borrowers.othernames = 'John Carmack' ,  borrowers.B_address = '' ,  borrowers.contactnote = '' ,  borrowers.altcontactaddress2 = '' ,  borrowers.email = '' ,  borrowers.B_country = '' ,  borrowers.address = '' ,  borrowers.B_address2 = '' ,  borrowers.streetnumber = '' ,  borrowers.branchcode = 'BDM' ,  borrowers.surname = 'John Karmacoma' ,  borrowers.cardnumber = '42424242' ,  borrowers.altcontactaddress3 = '' ,  borrowers.altcontactsurname = '' ,  borrowers.altcontactzipcode = '' ,  borrowers.opacnote = '' ,  borrowers.altcontactfirstname = '' ,  borrowers.userid = '.johncarmack' ,  borrowers.B_zipcode = '' ,  borrowers.mobile = '' ,  borrowers.B_email = '' ,  borrowers.city = '' ,  borrowers.fax = '' ,  borrowers.B_phone = '' ,  borrowers.altcontactphone = '' ,  borrowers.country = '' ,  borrowers.sort1 = '10' ,  borrowers.dateenrolled = '2011-03-15' ,  borrowers.phone = '' ,  borrowers.sex = 'N' ,  borrowers.altcontactaddress1 = '' ,  borrowers.zipcode = '11111' ,  borrowers.address2 = '' ,  borrowers.B_city = '' ,  borrowers.dateexpiry = '2012-03-15' ,  borrowers.borrowernotes = '' ,  borrowers.sort2 = '' ,  borrowers.phonepro = '' ,  borrowers.emailpro = ''
                        WHERE borrowernumber='100'
/*!*/;
UPDATE borrowers
SET  dateexpiry='2012-03-31'
WHERE borrowernumber='100'
/*!*/;
UPDATE borrowers SET password = 'forty2pwd' WHERE borrowernumber='100'
/*!*/;
