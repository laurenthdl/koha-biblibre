UPDATE issues SET date_due = '2011-04-01', renewals = '1', lastreneweddate = '2011-03-11'
                          WHERE borrowernumber='2401'
                          AND itemnumber='149491';
UPDATE items SET itemnumber='149491',renewals='1',onloan='2011-04-01' WHERE itemnumber='149491';
