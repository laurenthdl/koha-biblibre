-- Reasons for acceptance or rejection of suggestions in acquisitions
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','BSELL','Bestseller');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','SCD','Shelf Copy Damaged');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','LCL','Library Copy Lost');
INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('SUGGEST','AVILL','Available via ILL');

-- availability statuses
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOST','0','');
INSERT INTO `authorised_values`  (category, authorised_value, lib) VALUES ('LOST','2','Long Overdue (Lost)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOST','1','Lost');
INSERT INTO `authorised_values`  (category, authorised_value, lib ) VALUES ('LOST','3','Lost and Paid For');
INSERT INTO `authorised_values`  (category, authorised_value, lib )VALUES ('LOST','4','Missing');

-- damaged status of an item
INSERT INTO `authorised_values`  (category, authorised_value, lib) VALUES ('DAMAGED','0','');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('DAMAGED','1','Damaged');

-- location qualification for an item, departments are linked by default to items.location
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','FIC','Fiction');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','CHILD','Children\'s Area');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','DISPLAY','On Display');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','NEW','New Materials Shelf');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','STAFF','Staff Office');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','GEN','General Stacks');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','AV','Audio Visual');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','REF','Reference');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','CART','Book Cart');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('LOC','PROC','Processing Center');

-- collection codes for an item
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','FIC','Fiction');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','REF','Reference');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('CCODE','NFIC','Non Fiction');

-- withdrawn status of an item, linked to items.wthdrawn
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('WITHDRAWN','0','');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('WITHDRAWN','1','Withdrawn');

-- loanability status of an item, linked to items.notforloan
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','-1','Ordered');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','0','');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','1','Not For Loan');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('NOT_LOAN','2','Staff Collection');

-- restricted status of an item, linked to items.restricted
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RESTRICTED','0','');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RESTRICTED','1','Restricted Access');

-- manual invoice types
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('MANUAL_INV','Copier Fees','.25');

-- custom borrower notes
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('BOR_NOTES','ADDR','Address Notes');

-- order status
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'ORDRSTATUS', '0', 'New');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'ORDRSTATUS', '1', 'Requested');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'ORDRSTATUS', '2', 'Partial');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'ORDRSTATUS', '3', 'Complete');
INSERT INTO `authorised_values` ( `category`, `authorised_value`, `lib`) VALUES ( 'ORDRSTATUS', '4', 'Deleted');

-- stocknumber prefixes
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'A', 'A');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'ARC', 'ARC');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'B', 'B');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'C', 'C');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'D', 'D');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'DS', 'DS');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'E', 'E');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'EM', 'EM');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'EMT', 'EMT');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'ENS', 'ENS');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'F', 'F');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'L', 'L');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'M', 'M');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'MEM', 'MEM');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'MET', 'MET');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'PH', 'PH');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'R', 'R');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'RO', 'RO');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'S', 'S');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'TSE', 'TSE');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'U', 'U');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'V', 'V');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'W', 'W');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'XA', 'XA');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'XB', 'XB');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'XBL', 'XBL');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'XC', 'XC');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'XD', 'XD');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'XEE', 'XEE');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'XEI', 'XEI');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'XFG', 'XFG');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'XFL', 'XFL');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'XG', 'XG');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'Y', 'Y');
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES ('SNPREFIX', 'Z', 'Z');
