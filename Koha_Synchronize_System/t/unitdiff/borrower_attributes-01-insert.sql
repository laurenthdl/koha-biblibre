/*!*/;
DELETE FROM borrower_attributes WHERE borrowernumber = '100'
/*!*/;
INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES ('100', 'CANTON', 'canton_client', NULL)
/*!*/;
INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES ('100', 'HORAIRES', 'horaires_client', NULL)
/*!*/;
INSERT INTO borrower_attributes (borrowernumber, code, attribute, password)
                             VALUES ('100', 'TOURNEE', 'tournee client', NULL)

