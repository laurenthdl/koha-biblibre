UPDATE reserves SET    priority = '1'
WHERE  reservenumber = '2' AND reservedate = '2011-03-24' AND found IS NULL
/*!*/;
UPDATE reserves SET priority = '2'
WHERE  reservenumber = '1' AND reservedate = '2011-03-24' AND found IS NULL
/*!*/;
