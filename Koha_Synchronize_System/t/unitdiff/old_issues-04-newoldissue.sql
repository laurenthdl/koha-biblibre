INSERT INTO old_issues SELECT * FROM issues 
                                  WHERE borrowernumber = '100'
                                  AND itemnumber = '275'
/*!*/;
DELETE FROM issues
                                  WHERE borrowernumber = '100'
                                  AND itemnumber = '275'

