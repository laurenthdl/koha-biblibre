INSERT INTO issues 
                    (borrowernumber, itemnumber,issuedate, date_due, branchcode)
                VALUES ('32','131','2011-03-15','2011-03-25','BDM')
/*!*/;
UPDATE issues SET returndate= now()  WHERE  borrowernumber = '32'  AND itemnumber = '131'
/*!*/;
INSERT INTO old_issues SELECT * FROM issues
                                WHERE borrowernumber = '32'
                                AND itemnumber = '131'
/*!*/;
DELETE FROM issues
WHERE borrowernumber = '32'
AND itemnumber = '131'
/*!*/;
UPDATE issues SET returndate= now()  WHERE  borrowernumber = '32'  AND itemnumber = '131'
/*!*/;
INSERT INTO old_issues SELECT * FROM issues
                                WHERE borrowernumber = '32'
                                AND itemnumber = '131'
/*!*/;
DELETE FROM issues
WHERE borrowernumber = '32'
AND itemnumber = '131'
/*!*/;
