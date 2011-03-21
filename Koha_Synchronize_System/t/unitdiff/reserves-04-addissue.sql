UPDATE reserves
          SET   priority = 0,
                  found = 'W',
                  waitingdate=now(),
                  itemnumber = '193870',
                  expirationdate='2011-03-18'
      WHERE reservenumber = '1192';
UPDATE reserves
      SET priority = 0 , itemnumber = '193870'
      WHERE  reservenumber='1192';
UPDATE reserves
          SET priority = 0
          WHERE reservenumber = '1192'
            AND found ='W';
UPDATE reserves
  SET found='W',waitingdate = now()
  WHERE itemnumber='193870'
    AND found IS NULL
        AND priority = 0;
