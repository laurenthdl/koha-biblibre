INSERT INTO old_issues SELECT * FROM issues 
                                  WHERE borrowernumber = '100'
                                  AND itemnumber = '301'
/*!*/;
DELETE FROM issues
                                  WHERE borrowernumber = '100'
                                  AND itemnumber = '301'

