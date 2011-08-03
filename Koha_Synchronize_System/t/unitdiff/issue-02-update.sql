UPDATE issues SET returndate= now()  WHERE  borrowernumber = '52'  AND itemnumber = '275'
/*!*/;
UPDATE issues SET date_due = '2011-04-04', renewals = '1', lastreneweddate = '2011-03-15' WHERE borrowernumber='52' AND itemnumber='275'
/*!*/;
