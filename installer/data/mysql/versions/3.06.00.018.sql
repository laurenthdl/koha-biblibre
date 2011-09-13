CREATE TABLE borrowers (un TEXT);
ALTER TABLE `deleteditems` ADD `statisticvalue` varchar(80) DEFAULT NULL;
ALTER TABLE `deleteditems` ADD COLUMN `statisticvalue` varchar(80) DEFAULT NULL;
INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('SearchOPACHides','','Construct the opac query with this string at the end.','','Free');
INSERT IGNORE INTO `permissions` (`module_bit`, `code`, `description`) VALUES (15, 'check_expiration', 'Check the expiration of a serial');
