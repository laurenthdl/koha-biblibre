INSERT INTO reserves (borrowernumber,biblionumber,reservedate,branchcode,constrainttype, priority,reservenotes,itemnumber,found,waitingdate,expirationdate) VALUES ('100','125','2011-03-24','BDM','a', '1','',NULL,NULL,NULL,NULL)
/*!*/;
INSERT INTO old_reserves
            SELECT * FROM reserves
            WHERE reservenumber     = '4'
/*!*/;
DELETE FROM reserves
            WHERE  reservenumber   = '4'
/*!*/;
INSERT INTO reserves (borrowernumber,biblionumber,reservedate,branchcode,constrainttype, priority,reservenotes,itemnumber,found,waitingdate,expirationdate) VALUES ('100','126','2011-03-24','BDM','a', '1','',NULL,NULL,NULL,NULL)
/*!*/;
