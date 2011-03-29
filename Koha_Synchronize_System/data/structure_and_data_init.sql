-- MySQL dump 10.13  Distrib 5.1.49, for debian-linux-gnu (i486)
--
-- Host: localhost    Database: koha_kss
-- ------------------------------------------------------
-- Server version	5.1.49-1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accountlines`
--

DROP TABLE IF EXISTS `accountlines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountlines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) NOT NULL DEFAULT '0',
  `accountno` smallint(6) NOT NULL DEFAULT '0',
  `itemnumber` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `time` time DEFAULT NULL,
  `amount` decimal(28,6) DEFAULT NULL,
  `description` mediumtext,
  `dispute` mediumtext,
  `accounttype` varchar(5) DEFAULT NULL,
  `amountoutstanding` decimal(28,6) DEFAULT NULL,
  `lastincrement` decimal(28,6) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `notify_id` int(11) NOT NULL DEFAULT '0',
  `notify_level` int(2) NOT NULL DEFAULT '0',
  `note` text,
  `manager_id` int(11) DEFAULT NULL,
  `meansofpayment` text,
  PRIMARY KEY (`id`),
  KEY `acctsborridx` (`borrowernumber`),
  KEY `timeidx` (`timestamp`),
  KEY `itemnumber` (`itemnumber`),
  CONSTRAINT `accountlines_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `accountlines_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountlines`
--

LOCK TABLES `accountlines` WRITE;
/*!40000 ALTER TABLE `accountlines` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountlines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accountoffsets`
--

DROP TABLE IF EXISTS `accountoffsets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accountoffsets` (
  `borrowernumber` int(11) NOT NULL DEFAULT '0',
  `accountno` smallint(6) NOT NULL DEFAULT '0',
  `offsetaccount` smallint(6) NOT NULL DEFAULT '0',
  `offsetamount` decimal(28,6) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `accountoffsets_ibfk_1` (`borrowernumber`),
  CONSTRAINT `accountoffsets_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountoffsets`
--

LOCK TABLES `accountoffsets` WRITE;
/*!40000 ALTER TABLE `accountoffsets` DISABLE KEYS */;
/*!40000 ALTER TABLE `accountoffsets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `action_logs`
--

DROP TABLE IF EXISTS `action_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `action_logs` (
  `action_id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `user` int(11) NOT NULL DEFAULT '0',
  `module` text,
  `action` text,
  `object` int(11) DEFAULT NULL,
  `info` text,
  PRIMARY KEY (`action_id`),
  KEY `timestamp` (`timestamp`,`user`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `alert`
--

DROP TABLE IF EXISTS `alert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alert` (
  `alertid` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) NOT NULL DEFAULT '0',
  `type` varchar(10) NOT NULL DEFAULT '',
  `externalid` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`alertid`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `type` (`type`,`externalid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alert`
--

LOCK TABLES `alert` WRITE;
/*!40000 ALTER TABLE `alert` DISABLE KEYS */;
/*!40000 ALTER TABLE `alert` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aqbasket`
--

DROP TABLE IF EXISTS `aqbasket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbasket` (
  `basketno` int(11) NOT NULL AUTO_INCREMENT,
  `basketname` varchar(50) DEFAULT NULL,
  `note` mediumtext,
  `booksellernote` mediumtext,
  `contractnumber` int(11) DEFAULT NULL,
  `creationdate` date DEFAULT NULL,
  `closedate` date DEFAULT NULL,
  `booksellerid` int(11) NOT NULL DEFAULT '1',
  `authorisedby` varchar(10) DEFAULT NULL,
  `booksellerinvoicenumber` mediumtext,
  `basketgroupid` int(11) DEFAULT NULL,
  PRIMARY KEY (`basketno`),
  KEY `booksellerid` (`booksellerid`),
  KEY `basketgroupid` (`basketgroupid`),
  KEY `contractnumber` (`contractnumber`),
  CONSTRAINT `aqbasket_ibfk_1` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `aqbasket_ibfk_2` FOREIGN KEY (`contractnumber`) REFERENCES `aqcontract` (`contractnumber`),
  CONSTRAINT `aqbasket_ibfk_3` FOREIGN KEY (`basketgroupid`) REFERENCES `aqbasketgroups` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aqbasket`
--

LOCK TABLES `aqbasket` WRITE;
/*!40000 ALTER TABLE `aqbasket` DISABLE KEYS */;
/*!40000 ALTER TABLE `aqbasket` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aqbasketgroups`
--

DROP TABLE IF EXISTS `aqbasketgroups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbasketgroups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `closed` tinyint(1) DEFAULT NULL,
  `booksellerid` int(11) NOT NULL,
  `deliveryplace` varchar(10) DEFAULT NULL,
  `deliverycomment` varchar(255) DEFAULT NULL,
  `billingplace` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `booksellerid` (`booksellerid`),
  CONSTRAINT `aqbasketgroups_ibfk_1` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aqbasketgroups`
--

LOCK TABLES `aqbasketgroups` WRITE;
/*!40000 ALTER TABLE `aqbasketgroups` DISABLE KEYS */;
/*!40000 ALTER TABLE `aqbasketgroups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aqbooksellers`
--

DROP TABLE IF EXISTS `aqbooksellers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbooksellers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` mediumtext NOT NULL,
  `address1` mediumtext,
  `address2` mediumtext,
  `address3` mediumtext,
  `address4` mediumtext,
  `phone` varchar(30) DEFAULT NULL,
  `accountnumber` mediumtext,
  `othersupplier` mediumtext,
  `currency` varchar(3) NOT NULL DEFAULT '',
  `booksellerfax` mediumtext,
  `notes` mediumtext,
  `bookselleremail` mediumtext,
  `booksellerurl` mediumtext,
  `contact` varchar(100) DEFAULT NULL,
  `postal` mediumtext,
  `url` varchar(255) DEFAULT NULL,
  `contpos` varchar(100) DEFAULT NULL,
  `contphone` varchar(100) DEFAULT NULL,
  `contfax` varchar(100) DEFAULT NULL,
  `contaltphone` varchar(100) DEFAULT NULL,
  `contemail` varchar(100) DEFAULT NULL,
  `contnotes` mediumtext,
  `active` tinyint(4) DEFAULT NULL,
  `listprice` varchar(10) DEFAULT NULL,
  `invoiceprice` varchar(10) DEFAULT NULL,
  `gstreg` tinyint(4) DEFAULT NULL,
  `listincgst` tinyint(4) DEFAULT NULL,
  `invoiceincgst` tinyint(4) DEFAULT NULL,
  `gstrate` decimal(6,4) DEFAULT NULL,
  `discount` float(6,4) DEFAULT NULL,
  `fax` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `listprice` (`listprice`),
  KEY `invoiceprice` (`invoiceprice`),
  CONSTRAINT `aqbooksellers_ibfk_1` FOREIGN KEY (`listprice`) REFERENCES `currency` (`currency`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqbooksellers_ibfk_2` FOREIGN KEY (`invoiceprice`) REFERENCES `currency` (`currency`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aqbooksellers`
--

LOCK TABLES `aqbooksellers` WRITE;
/*!40000 ALTER TABLE `aqbooksellers` DISABLE KEYS */;
/*!40000 ALTER TABLE `aqbooksellers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aqbudgetperiods`
--

DROP TABLE IF EXISTS `aqbudgetperiods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbudgetperiods` (
  `budget_period_id` int(11) NOT NULL AUTO_INCREMENT,
  `budget_period_startdate` date NOT NULL,
  `budget_period_enddate` date NOT NULL,
  `budget_period_active` tinyint(1) DEFAULT '0',
  `budget_period_description` mediumtext,
  `budget_period_total` decimal(28,6) DEFAULT NULL,
  `budget_period_locked` tinyint(1) DEFAULT NULL,
  `sort1_authcat` varchar(10) DEFAULT NULL,
  `sort2_authcat` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`budget_period_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aqbudgetperiods`
--

LOCK TABLES `aqbudgetperiods` WRITE;
/*!40000 ALTER TABLE `aqbudgetperiods` DISABLE KEYS */;
/*!40000 ALTER TABLE `aqbudgetperiods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aqbudgets`
--

DROP TABLE IF EXISTS `aqbudgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbudgets` (
  `budget_id` int(11) NOT NULL AUTO_INCREMENT,
  `budget_parent_id` int(11) DEFAULT NULL,
  `budget_code` varchar(30) DEFAULT NULL,
  `budget_name` varchar(80) DEFAULT NULL,
  `budget_branchcode` varchar(10) DEFAULT NULL,
  `budget_amount` decimal(28,6) DEFAULT '0.000000',
  `budget_encumb` decimal(28,6) DEFAULT '0.000000',
  `budget_expend` decimal(28,6) DEFAULT '0.000000',
  `budget_notes` mediumtext,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `budget_period_id` int(11) DEFAULT NULL,
  `sort1_authcat` varchar(80) DEFAULT NULL,
  `sort2_authcat` varchar(80) DEFAULT NULL,
  `budget_owner_id` int(11) DEFAULT NULL,
  `budget_permission` int(1) DEFAULT '0',
  PRIMARY KEY (`budget_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aqbudgets`
--

LOCK TABLES `aqbudgets` WRITE;
/*!40000 ALTER TABLE `aqbudgets` DISABLE KEYS */;
/*!40000 ALTER TABLE `aqbudgets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aqbudgets_planning`
--

DROP TABLE IF EXISTS `aqbudgets_planning`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqbudgets_planning` (
  `plan_id` int(11) NOT NULL AUTO_INCREMENT,
  `budget_id` int(11) NOT NULL,
  `budget_period_id` int(11) NOT NULL,
  `estimated_amount` decimal(28,6) DEFAULT NULL,
  `authcat` varchar(30) NOT NULL,
  `authvalue` varchar(30) NOT NULL,
  `display` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`plan_id`),
  KEY `aqbudgets_planning_ifbk_1` (`budget_id`),
  CONSTRAINT `aqbudgets_planning_ifbk_1` FOREIGN KEY (`budget_id`) REFERENCES `aqbudgets` (`budget_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aqbudgets_planning`
--

LOCK TABLES `aqbudgets_planning` WRITE;
/*!40000 ALTER TABLE `aqbudgets_planning` DISABLE KEYS */;
/*!40000 ALTER TABLE `aqbudgets_planning` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aqcontract`
--

DROP TABLE IF EXISTS `aqcontract`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqcontract` (
  `contractnumber` int(11) NOT NULL AUTO_INCREMENT,
  `contractstartdate` date DEFAULT NULL,
  `contractenddate` date DEFAULT NULL,
  `contractname` varchar(50) DEFAULT NULL,
  `contractdescription` mediumtext,
  `booksellerid` int(11) NOT NULL,
  PRIMARY KEY (`contractnumber`),
  KEY `booksellerid_fk1` (`booksellerid`),
  CONSTRAINT `booksellerid_fk1` FOREIGN KEY (`booksellerid`) REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aqcontract`
--

LOCK TABLES `aqcontract` WRITE;
/*!40000 ALTER TABLE `aqcontract` DISABLE KEYS */;
/*!40000 ALTER TABLE `aqcontract` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aqorderdelivery`
--

DROP TABLE IF EXISTS `aqorderdelivery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqorderdelivery` (
  `ordernumber` date DEFAULT NULL,
  `deliverynumber` smallint(6) NOT NULL DEFAULT '0',
  `deliverydate` varchar(18) DEFAULT NULL,
  `qtydelivered` smallint(6) DEFAULT NULL,
  `deliverycomments` mediumtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aqorderdelivery`
--

LOCK TABLES `aqorderdelivery` WRITE;
/*!40000 ALTER TABLE `aqorderdelivery` DISABLE KEYS */;
/*!40000 ALTER TABLE `aqorderdelivery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aqorders`
--

DROP TABLE IF EXISTS `aqorders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqorders` (
  `ordernumber` int(11) NOT NULL AUTO_INCREMENT,
  `biblionumber` int(11) DEFAULT NULL,
  `entrydate` date DEFAULT NULL,
  `quantity` smallint(6) DEFAULT NULL,
  `currency` varchar(3) DEFAULT NULL,
  `listprice` decimal(28,6) DEFAULT NULL,
  `totalamount` decimal(28,6) DEFAULT NULL,
  `datereceived` date DEFAULT NULL,
  `booksellerinvoicenumber` mediumtext,
  `freight` decimal(28,6) DEFAULT NULL,
  `unitprice` decimal(28,6) DEFAULT NULL,
  `quantityreceived` smallint(6) NOT NULL DEFAULT '0',
  `cancelledby` varchar(10) DEFAULT NULL,
  `datecancellationprinted` date DEFAULT NULL,
  `notes` mediumtext,
  `supplierreference` mediumtext,
  `purchaseordernumber` mediumtext,
  `subscription` tinyint(1) DEFAULT NULL,
  `serialid` varchar(30) DEFAULT NULL,
  `basketno` int(11) DEFAULT NULL,
  `biblioitemnumber` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `rrp` decimal(13,2) DEFAULT NULL,
  `ecost` decimal(13,2) DEFAULT NULL,
  `gst` decimal(13,2) DEFAULT NULL,
  `budget_id` int(11) NOT NULL,
  `budgetgroup_id` int(11) NOT NULL,
  `budgetdate` date DEFAULT NULL,
  `sort1` varchar(80) DEFAULT NULL,
  `sort2` varchar(80) DEFAULT NULL,
  `sort1_authcat` varchar(10) DEFAULT NULL,
  `sort2_authcat` varchar(10) DEFAULT NULL,
  `uncertainprice` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`ordernumber`),
  KEY `basketno` (`basketno`),
  KEY `biblionumber` (`biblionumber`),
  KEY `budget_id` (`budget_id`),
  CONSTRAINT `aqorders_ibfk_1` FOREIGN KEY (`basketno`) REFERENCES `aqbasket` (`basketno`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aqorders_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aqorders`
--

LOCK TABLES `aqorders` WRITE;
/*!40000 ALTER TABLE `aqorders` DISABLE KEYS */;
/*!40000 ALTER TABLE `aqorders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aqorders_items`
--

DROP TABLE IF EXISTS `aqorders_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aqorders_items` (
  `ordernumber` int(11) NOT NULL,
  `itemnumber` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`itemnumber`),
  KEY `ordernumber` (`ordernumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aqorders_items`
--

LOCK TABLES `aqorders_items` WRITE;
/*!40000 ALTER TABLE `aqorders_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `aqorders_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_header`
--

DROP TABLE IF EXISTS `auth_header`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_header` (
  `authid` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `authtypecode` varchar(10) NOT NULL DEFAULT '',
  `datecreated` date DEFAULT NULL,
  `datemodified` date DEFAULT NULL,
  `origincode` varchar(20) DEFAULT NULL,
  `authtrees` mediumtext,
  `marc` blob,
  `linkid` bigint(20) DEFAULT NULL,
  `marcxml` longtext NOT NULL,
  PRIMARY KEY (`authid`),
  KEY `origincode` (`origincode`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_subfield_structure`
--

DROP TABLE IF EXISTS `auth_subfield_structure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_subfield_structure` (
  `authtypecode` varchar(10) NOT NULL DEFAULT '',
  `tagfield` varchar(3) NOT NULL DEFAULT '',
  `tagsubfield` varchar(1) NOT NULL DEFAULT '',
  `liblibrarian` varchar(255) NOT NULL DEFAULT '',
  `libopac` varchar(255) NOT NULL DEFAULT '',
  `repeatable` tinyint(4) NOT NULL DEFAULT '0',
  `mandatory` tinyint(4) NOT NULL DEFAULT '0',
  `tab` tinyint(1) DEFAULT NULL,
  `authorised_value` varchar(10) DEFAULT NULL,
  `value_builder` varchar(80) DEFAULT NULL,
  `seealso` varchar(255) DEFAULT NULL,
  `isurl` tinyint(1) DEFAULT NULL,
  `hidden` tinyint(3) NOT NULL DEFAULT '0',
  `linkid` tinyint(1) NOT NULL DEFAULT '0',
  `kohafield` varchar(45) DEFAULT '',
  `frameworkcode` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`authtypecode`,`tagfield`,`tagsubfield`),
  KEY `tab` (`authtypecode`,`tab`),
  CONSTRAINT `auth_subfield_structure_ibfk_1` FOREIGN KEY (`authtypecode`, `tagfield`) REFERENCES `auth_tag_structure` (`authtypecode`, `tagfield`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_subfield_structure`
--

LOCK TABLES `auth_subfield_structure` WRITE;
/*!40000 ALTER TABLE `auth_subfield_structure` DISABLE KEYS */;
INSERT INTO `auth_subfield_structure` VALUES ('','001','@','tag 001','',0,0,0,'','',NULL,NULL,0,0,NULL,''),('','005','@','tag 005','',0,0,0,'','',NULL,NULL,0,0,NULL,''),('','015','@','tag 015','',0,0,0,'','',NULL,NULL,0,0,NULL,''),('','035','a','Numéro de contrôle système','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','035','z','Numéro de contrôle annulé ou erroné','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','100','a','Données générale de traitement','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','101','a','Langue utilisée par l\'entité','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','102','a','Pays','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','102','b','Localité','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','106','a','Code d\'un caractère','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','120','a','Données codées : nom de personne','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','123','d','Coordonnée-Longitude la plus occidentale','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','123','e','Coordonnée-Longitude la plus orientale','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','123','f','Coordonnée-Latitude la plus septentrionale','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','123','g','Coordonnée-Latitude la plus méridionale','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','150','a','Données de traitement sur la collectivité','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','152','a','Règles de catalogage','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','152','b','système d\'indexation matière','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','154','a','Données générales de traitement du titre','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','160','a','Code de l\'aire géographique','',1,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','200','4','Code de fonction','',1,0,0,'','','',NULL,0,0,NULL,''),('','200','7','Ecriture de catalogage et écriture de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','200','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','200','a','Elément d\'entrée','',0,1,0,'','','',NULL,0,0,NULL,''),('','200','b','Prénom','',0,0,0,'','','',NULL,0,0,NULL,''),('','200','c','Qualif autre que dates','',0,0,0,'','','',NULL,0,0,NULL,''),('','200','d','Chiffres romains','',0,0,0,'','','',NULL,0,0,NULL,''),('','200','f','Dates','',0,0,0,'','','',NULL,0,0,NULL,''),('','200','g','Développement des initiales du prénom','',0,0,0,'','','',NULL,0,0,NULL,''),('','200','j','Subdivision de forme','',1,0,0,'','','',NULL,0,0,NULL,''),('','200','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','200','y','Subdiv. géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','200','z','Subdiv. chronologique','',1,0,0,'','','',NULL,0,0,NULL,''),('','210','4','Code de fonction','',1,0,0,'','','',NULL,0,0,NULL,''),('','210','7','Ecriture de catalogage et écriture de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','210','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','210','a','Elément d\'entrée','',0,1,0,'','','',NULL,0,0,NULL,''),('','210','b','Subdivision','',1,0,0,'','','',NULL,0,0,NULL,''),('','210','c','Elément ajouté au nom ou qualificatif','',1,0,0,'','','',NULL,0,0,NULL,''),('','210','d','N° de congrès/session','',0,0,0,'','','',NULL,0,0,NULL,''),('','210','e','Lieu du congrès','',0,0,0,'','','',NULL,0,0,NULL,''),('','210','f','Date du congrès','',0,0,0,'','','',NULL,0,0,NULL,''),('','210','g','Elément rejeté','',0,0,0,'','','',NULL,0,0,NULL,''),('','210','h','Partie du nom autre que l\'élément d\'entrée et autre que l\'élément rejeté 0 0','',0,0,0,'','','',NULL,0,0,NULL,''),('','210','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','210','y','Subdiv. géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','210','z','Subdiv. chronologique','',1,0,0,'','','',NULL,0,0,NULL,''),('','230','7','Ecriture de catalogage et écriture de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','230','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','230','a','Elément d\'entrée','',0,1,0,'','','',NULL,0,0,NULL,''),('','230','b','Indication générale du type de document','',1,0,0,'','','',NULL,0,0,NULL,''),('','230','h','Numéro de section ou de partie','',1,0,0,'','','',NULL,0,0,NULL,''),('','230','i','Titre de partie','',1,0,0,'','','',NULL,0,0,NULL,''),('','230','j','Subdivision de forme','',1,0,0,'','','',NULL,0,0,NULL,''),('','230','k','Date de publication','',0,0,0,'','','',NULL,0,0,NULL,''),('','230','l','Sous-vedette de forme','',0,0,0,'','','',NULL,0,0,NULL,''),('','230','m','Langue','',0,0,0,'','','',NULL,0,0,NULL,''),('','230','q','Version (ou date d\'une version)','',0,0,0,'','','',NULL,0,0,NULL,''),('','230','r','Distribution d\'exécution (pour la musique)','',1,0,0,'','','',NULL,0,0,NULL,''),('','230','s','Références numériques (pour la musique)','',1,0,0,'','','',NULL,0,0,NULL,''),('','230','u','Tonalité (pour la musique)','',0,0,0,'','','',NULL,0,0,NULL,''),('','230','w','Mention d\'arrangement','',0,0,0,'','','',NULL,0,0,NULL,''),('','230','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','230','y','Subdiv. géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','230','z','Subdiv. chronologique','',1,0,0,'','','',NULL,0,0,NULL,''),('','240','7','Ecriture de catalogage et écriture de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','240','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','240','a','Auteur','',0,1,0,'','','',NULL,0,0,NULL,''),('','240','b','Prénom','',0,0,0,'','','',NULL,0,0,NULL,''),('','240','c','Qualificatifs','',0,0,0,'','','',NULL,0,0,NULL,''),('','240','f','Dates','',0,0,0,'',NULL,'',NULL,0,0,NULL,''),('','240','j','Subdivision de forme','',1,0,0,'','','',NULL,0,0,NULL,''),('','240','t','Titre','',0,1,0,'','','',NULL,0,0,NULL,''),('','240','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','240','y','Subdiv. géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','240','z','Subdiv. chronologique','',1,0,0,'','','',NULL,0,0,NULL,''),('','250','7','Ecriture de catalogage et écriture de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','250','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','250','a','Elément d\'entrée','',0,1,0,'','','',NULL,0,0,NULL,''),('','250','b','Statut','',0,0,0,'CAND','','',NULL,0,0,NULL,''),('','250','j','Subdivision de forme','',1,0,0,'','','',NULL,0,0,NULL,''),('','250','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','250','y','Subdivision  géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','250','z','Subdiv. chronologique','',1,0,0,'','','',NULL,0,0,NULL,''),('','300','6','Données de lien entre zones','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','300','7','Ecriture de catalogage et écriture de la racine de la vedette','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','300','a','Note d\'information','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','305','6','Données de lien entre zones','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','305','7','Ecriture de la notice et écriture de la racine de la vedette','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','305','a','Formule introductive','',1,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','305','b','Vedette à laquelle on renvoie','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','310','6','Données de lien entre zones','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','310','7','Ecriture de la notice et écriture de la racine de la vedette','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','310','a','Formule introductive','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','310','b','Vedette à laquelle on renvoie','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','320','6','Données de lien entre zones','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','320','a','Note de renvoi explicatif','',1,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','330','6','Données de lien entre zones','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','330','7','Ecriture de la notice et écriture de la racine de la vedette','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','330','a','Note sur le champ d\'application','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','340','6','Données de lien entre zones','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','340','7','Ecriture de la notice et écriture de la racine de la vedette','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','340','a','Note sur la biographie ou l\'activité','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','356','6','Données de liens entre zones','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','356','7','Ecriture de la notice et écriture de la racine de la vedette','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','356','a','Note géographique','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','400','0','Formule introductive','',0,0,0,'','','',NULL,0,0,NULL,''),('','400','2','code du système d\'indexation matière','',0,0,0,'','','',NULL,0,0,NULL,''),('','400','3','Identificateur de la notice d\'autorité','',0,0,0,'','','',NULL,0,0,NULL,''),('','400','4','Code de fonction','',1,0,0,'','','',NULL,0,0,NULL,''),('','400','5','Données codées relatives aux mentions de formes rejetées ou associées    0    0','',0,0,0,'','','',NULL,0,0,NULL,''),('','400','6','Données de lien entre zones','',0,0,0,'','','',NULL,0,0,NULL,''),('','400','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','400','a','Elément d\'entrée','',0,0,0,'','','',NULL,0,0,NULL,''),('','400','b','Autre élément du nom','',0,0,0,'','','',NULL,0,0,NULL,''),('','400','c','Qualif autre que dates','',0,0,0,'','','',NULL,0,0,NULL,''),('','400','d','Chiffres romains','',0,0,0,'','','',NULL,0,0,NULL,''),('','400','f','Dates','',0,0,0,'','','',NULL,0,0,NULL,''),('','400','g','Développement des initiales du prénom','',0,0,0,'','','',NULL,0,0,NULL,''),('','400','j','Subdivision de forme','',1,0,0,'','','',NULL,0,0,NULL,''),('','400','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','400','y','Subdiv. géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','400','z','Subdivision','',0,0,0,'','','',NULL,0,0,NULL,''),('','410','0','Formule introductive','',0,0,0,'','','',NULL,0,0,NULL,''),('','410','2','Code du système d\'indexation matière','',0,0,0,'','','',NULL,0,0,NULL,''),('','410','3','Identificateur de la notice d\'autorité','',0,0,0,'','','',NULL,0,0,NULL,''),('','410','4','Code de fonction','',1,0,0,'','','',NULL,0,0,NULL,''),('','410','5','Données codées relatives aux mentions de formes rejetées ou associées    0     0','',0,0,0,'','','',NULL,0,0,NULL,''),('','410','6','Données de lien entre zones','',0,0,0,'','','',NULL,0,0,NULL,''),('','410','7','Ecriture de catalogage et écriture de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','410','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','410','a','Elément d\'entrée','',0,0,0,'','','',NULL,0,0,NULL,''),('','410','b','Subdivision','',1,0,0,'','','',NULL,0,0,NULL,''),('','410','c','Elément ajouté au nom ou qualificatif','',1,0,0,'','','',NULL,0,0,NULL,''),('','410','d','Numéro de congrès','',0,0,0,'','','',NULL,0,0,NULL,''),('','410','e','Lieu du congrès','',0,0,0,'','','',NULL,0,0,NULL,''),('','410','f','Date du congrès','',0,0,0,'','','',NULL,0,0,NULL,''),('','410','g','Elément rejeté','',0,0,0,'','','',NULL,0,0,NULL,''),('','410','h','Partie du nom autre que l\'élément d\'entrée et que l\'élément rejeté','',0,0,0,'','','',NULL,0,0,NULL,''),('','410','j','Subdivision de forme','',1,0,0,'','','',NULL,0,0,NULL,''),('','410','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','410','y','Subdiv. géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','410','z','Subdivision','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','0','Formule introductive','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','2','code du système d\'indexation matière','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','3','Identificateur de la notice d\'autorité','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','5','Données codées relatives aux mentions de formes rejetées ou associées     0','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','6','Données de lien entre zones','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','7','Ecriture de catalogage et écriture de la racine de la vedette     0','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','a','Elément d\'entrée','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','b','Indication générale du type de document','',1,0,0,'','','',NULL,0,0,NULL,''),('','430','h','Numéro de section ou  de partie','',1,0,0,'','','',NULL,0,0,NULL,''),('','430','i','titre de section ou  de partie','',1,0,0,'','','',NULL,0,0,NULL,''),('','430','j','Subdivision de forme','',1,0,0,'','','',NULL,0,0,NULL,''),('','430','k','date de publication','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','l','Sous-vedette de forme','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','m','Langue (quand elle fait partie de la vedette)','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','n','Autres informations','',1,0,0,'','','',NULL,0,0,NULL,''),('','430','q','Version (ou date d\'une version)','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','r','Distribution d\'exécution (pour la musique)','',1,0,0,'','','',NULL,0,0,NULL,''),('','430','s','Références numériques (pour la musique)','',1,0,0,'','','',NULL,0,0,NULL,''),('','430','u','Tonalité (pour la musique)','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','w','Mention d\'arrangement (pour la musique)','',0,0,0,'','','',NULL,0,0,NULL,''),('','430','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','430','y','Subdiv. géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','430','z','Subdiv. chronologique','',1,0,0,'','','',NULL,0,0,NULL,''),('','440','0','Formule introductive','',0,0,0,'','','',NULL,0,0,NULL,''),('','440','2','Code du système d\'indexation matière','',0,0,0,'','','',NULL,0,0,NULL,''),('','440','3','Identificateur de la notice d\'autorité','',0,0,0,'','','',NULL,0,0,NULL,''),('','440','5','Données codées relatives aux mentions de formes rejetées ou associées     0','',0,0,0,'','','',NULL,0,0,NULL,''),('','440','6','Données de lien entre zones','',0,0,0,'','','',NULL,0,0,NULL,''),('','440','7','Ecriture de catalogage et écriture de la racine de la vedette      0      0','',0,0,0,'','','',NULL,0,0,NULL,''),('','440','8','Langue de catalogage et langue de la racine de la vedette      0','',0,0,0,'','','',NULL,0,0,NULL,''),('','440','a','Auteur','',0,0,0,'','','',NULL,0,0,NULL,''),('','440','b','Prénom','',0,0,0,'','','',NULL,0,0,NULL,''),('','440','c','qualificatif','',0,0,0,'','','',NULL,0,0,NULL,''),('','440','d','numérotation (chiffres romains)','',0,0,0,'','','',NULL,0,0,NULL,''),('','440','f','Dates','',0,0,0,'',NULL,'',NULL,0,0,NULL,''),('','440','j','Subdivision de forme','',1,0,0,'','','',NULL,0,0,NULL,''),('','440','t','Titre','',0,0,0,'','','',NULL,0,0,NULL,''),('','440','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','440','y','Subdiv. géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','440','z','Subdiv. chronologique','',1,0,0,'','','',NULL,0,0,NULL,''),('','450','0','Formule introductive','',0,0,0,'','','',NULL,0,0,NULL,''),('','450','2','Code du système d\'indexation matière','',0,0,0,'','','',NULL,0,0,NULL,''),('','450','3','Identificateur de la notice d\'autorité','',0,0,0,'','','',NULL,0,0,NULL,''),('','450','5','Données codées relatives aux mentions de formes rejetées ou  associées    0','',0,0,0,'','','',NULL,0,0,NULL,''),('','450','6','Données de lien entre zones','',0,0,0,'','','',NULL,0,0,NULL,''),('','450','7','Ecriture de catalogage et écriture de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','450','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','450','a','Elément d\'entrée','',0,0,0,'','','',NULL,0,0,NULL,''),('','450','j','Subdivision de forme','',1,0,0,'','','',NULL,0,0,NULL,''),('','450','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','450','y','Subdiv. géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','450','z','Subdiv. chronologique','',1,0,0,'','','',NULL,0,0,NULL,''),('','500','0','Formule introductive','',0,0,0,'','','',NULL,0,0,NULL,''),('','500','2','Code du système d\'indexation matière','',0,0,0,'','','',NULL,0,0,NULL,''),('','500','3','Identificateur de la notice d\'autorité','',0,0,0,'','','',NULL,0,0,NULL,''),('','500','4','Code de fonction','',1,0,0,'','','',NULL,0,0,NULL,''),('','500','5','Données codées relatives aux mentions de formes rejetées ou  associées    0','',0,0,0,'','','',NULL,0,0,NULL,''),('','500','6','Données de lien entre zones','',0,0,0,'','','',NULL,0,0,NULL,''),('','500','7','Ecriture de catalogage et écriture de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','500','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','500','a','Elément d\'entrée','',0,0,0,'','','',NULL,0,0,NULL,''),('','500','b','Autre élément du nom','',0,0,0,'','','',NULL,0,0,NULL,''),('','500','c','Qualificatifs autres au les dates','',1,0,0,'','','',NULL,0,0,NULL,''),('','500','d','Chiffres romains','',0,0,0,'','','',NULL,0,0,NULL,''),('','500','f','Dates','',0,0,0,'','','',NULL,0,0,NULL,''),('','500','g','Développement des initiales du prénom','',0,0,0,'','','',NULL,0,0,NULL,''),('','500','j','Subdivision de forme','',1,0,0,'','','',NULL,0,0,NULL,''),('','500','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','500','y','Subdiv. géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','500','z','Subdiv. chronologique','',1,0,0,'','','',NULL,0,0,NULL,''),('','510','0','Formule introductive','',0,0,0,'','','',NULL,0,0,NULL,''),('','510','2','Code du système d\'indexation matière','',0,0,0,'','','',NULL,0,0,NULL,''),('','510','3','Identificateur de la notice d\'autorité','',0,0,0,'','','',NULL,0,0,NULL,''),('','510','4','Code de fonction','',1,0,0,'','','',NULL,0,0,NULL,''),('','510','5','Données codées relatives aux mentions de formes rejetées ou  associées    0','',0,0,0,'','','',NULL,0,0,NULL,''),('','510','6','Données de lien entre zones','',0,0,0,'','','',NULL,0,0,NULL,''),('','510','7','Ecriture de catalogage et écriture de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','510','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','510','a','Elément d\'entrée','',0,0,0,'','','',NULL,0,0,NULL,''),('','510','b','Subdivision','',1,0,0,'','','',NULL,0,0,NULL,''),('','510','c','Elément ajouté au nom ou qualificatif','',1,0,0,'','','',NULL,0,0,NULL,''),('','510','d','Numéro de congrès','',0,0,0,'','','',NULL,0,0,NULL,''),('','510','e','Lieu de congrès','',0,0,0,'','','',NULL,0,0,NULL,''),('','510','f','Date du congrès','',0,0,0,'','','',NULL,0,0,NULL,''),('','510','g','Elément rejeté','',0,0,0,'','','',NULL,0,0,NULL,''),('','510','h','Partie du nom autre que l\'élément d\'entrée et que l\'élément rejeté     0     0','',0,0,0,'','','',NULL,0,0,NULL,''),('','510','j','subdivision de forme','',1,0,0,'','','',NULL,0,0,NULL,''),('','510','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','510','y','Subdiv. géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','510','z','Subdiv. chronologique','',1,0,0,'','','',NULL,0,0,NULL,''),('','530','0','Formule introductive','',0,0,0,'','','',NULL,0,0,NULL,''),('','530','2','Code du système d\'indexation matière','',0,0,0,'','','',NULL,0,0,NULL,''),('','530','3','Identificateur de la notice d\'autorité','',0,0,0,'','','',NULL,0,0,NULL,''),('','530','5','Données codées relatives aux mentions de formes rejetées ou  associées    0','',0,0,0,'','','',NULL,0,0,NULL,''),('','530','6','Données de lien entre zones','',0,0,0,'','','',NULL,0,0,NULL,''),('','530','7','Ecriture de catalogage et écriture de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','530','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','530','a','Elément d\'entrée','',0,0,0,'','','',NULL,0,0,NULL,''),('','530','b','Indication générale du type de document','',1,0,0,'','','',NULL,0,0,NULL,''),('','530','h','Numéro de section ou de partie','',1,0,0,'','','',NULL,0,0,NULL,''),('','530','i','Titre de section ou de partie','',1,0,0,'','','',NULL,0,0,NULL,''),('','530','j','Subdivision de forme','',1,0,0,'','','',NULL,0,0,NULL,''),('','530','k','Date de publication','',0,0,0,'','','',NULL,0,0,NULL,''),('','530','l','Sous-vedette de forme','',0,0,0,'','','',NULL,0,0,NULL,''),('','530','m','langue (quand elle fait partie de la vedette)','',0,0,0,'','','',NULL,0,0,NULL,''),('','530','n','Autre informations','',1,0,0,'','','',NULL,0,0,NULL,''),('','530','q','Version (ou date d\'une version)','',0,0,0,'','','',NULL,0,0,NULL,''),('','530','r','Distribution d\'exécution (pour la musique)','',1,0,0,'','','',NULL,0,0,NULL,''),('','530','s','Références numériques (pour la musique)','',1,0,0,'','','',NULL,0,0,NULL,''),('','530','u','Tonalité (pour la musique)','',0,0,0,'','','',NULL,0,0,NULL,''),('','530','w','Mention d\'arrangement (pour la musique)','',0,0,0,'','','',NULL,0,0,NULL,''),('','530','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','530','y','Subdiv. géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','530','z','Subdiv. chronologique','',1,0,0,'','','',NULL,0,0,NULL,''),('','540','0','Formule introductive','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','540','2','Code du système d\'indexation matière','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','540','3','Identificateur de la notice d\'autorité','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','540','5','Données codées relatives aux mentions de formes rejetées ou  associées    0      0','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','540','6','Données de lien entre zones','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','540','7','Ecriture de catalogage et écriture de la racine de la vedette','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','540','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','540','a','Auteur','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','540','j','Subdivision de forme','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','540','t','Titre','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','540','x','Subdiv. de sujet','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','540','y','Subdiv. géographique','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','540','z','Subdiv. chronologique','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','550','0','Formule introductive','',0,0,0,'','','',NULL,0,0,NULL,''),('','550','2','Code du système d\'indexation matière','',0,0,0,'','','',NULL,0,0,NULL,''),('','550','3','Identificateur de la notice d\'autorité','',0,0,0,'','','',NULL,0,0,NULL,''),('','550','5','Données codées relatives aux mentions de formes rejetées ou  associées    0','',0,0,0,'','','',NULL,0,0,NULL,''),('','550','6','Données de lien entre zones','',0,0,0,'','','',NULL,0,0,NULL,''),('','550','7','Ecriture de catalogage et écriture de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','550','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','550','a','Elément d\'entrée','',0,0,0,'','','',NULL,0,0,NULL,''),('','550','j','Subdivision de forme','',1,0,0,'','','',NULL,0,0,NULL,''),('','550','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','550','y','Subdiv. géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','550','z','Subdiv. chronologique','',1,0,0,'','','',NULL,0,0,NULL,''),('','675','3','Identificateur de la notice de classification','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','675','a','Indice CDU, isolé ou début d\'une série','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','675','b','Indice CDU, fin de série','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','675','c','Termes explicatifs','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','675','v','Edition de la CDU','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','675','z','Langue de l\'édition','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','676','3','Identificateur de la notice de classification','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','676','a','Indice CDD, isolé ou début d\'une série','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','676','b','Indice CDD, fin de série','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','676','c','Termes explicatifs','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','676','v','Edition de la CDD','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','676','z','Langue de l\'édition','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','680','3','Identificateur de la notice de classification','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','680','a','Indice LCC, isolé ou début d\'une série','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','680','b','Indice LCC, fin de série','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','680','c','Termes explicatifs','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','686','3','Identificateur de la notice de classification','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','686','a','Indice , isolé ou début d\'une série','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','686','b','Indice , fin de série','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','686','c','Termes explicatifs','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','710','2','Code du système d\'indexation matière','',0,0,0,'','','',NULL,0,0,NULL,''),('','710','3','Identificateur','',0,0,0,'','','',NULL,0,0,NULL,''),('','710','4','Code de fonction','',1,0,0,'','','',NULL,0,0,NULL,''),('','710','7','Ecriture de catalogage et écriture de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','710','8','Langue de catalogage et langue de la racine de la vedette','',0,0,0,'','','',NULL,0,0,NULL,''),('','710','a','Elément d\'entrée','',0,0,0,'','','',NULL,0,0,NULL,''),('','710','b','Subdivision','',1,0,0,'','','',NULL,0,0,NULL,''),('','710','c','Elément ajouté au nom ou qualificatif','',1,0,0,'','','',NULL,0,0,NULL,''),('','710','d','Numéro de congrès','',0,0,0,'','','',NULL,0,0,NULL,''),('','710','e','Lieu du congrès','',0,0,0,'','','',NULL,0,0,NULL,''),('','710','f','Date du congrès','',0,0,0,'','','',NULL,0,0,NULL,''),('','710','g','Elément rejeté','',0,0,0,'','','',NULL,0,0,NULL,''),('','710','h','Partie du nom autre que l\'élément d\'entrée et que l\'élément rejeté','',0,0,0,'','','',NULL,0,0,NULL,''),('','710','j','Subdivision de forme','',1,0,0,'','','',NULL,0,0,NULL,''),('','710','x','Subdiv. de sujet','',1,0,0,'','','',NULL,0,0,NULL,''),('','710','y','Subdiv. géographique','',1,0,0,'','','',NULL,0,0,NULL,''),('','710','z','Subdivision','',0,0,0,'','','',NULL,0,0,NULL,''),('','801','a','Pays','',0,0,0,'','','',NULL,0,0,NULL,''),('','801','b','Etablissement catalogueur','',0,0,0,'','','',NULL,0,0,NULL,''),('','801','c','Date dernière transaction','',0,0,0,'','','',NULL,0,0,NULL,''),('','810','a','Citation','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','810','b','Information trouvée','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','815','a','Citation','',1,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','820','a','Texte de la note','',1,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','825','a','Texte de la note','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','830','a','Texte de la note','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','835','a','Texte de la note','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','835','b','Vedette de remplacement','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','835','d','Date de la transaction','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','836','b','Vedette remplacée','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','836','d','Date de transaction','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','a','Nom du serveur','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','b','Numéro d\'accès','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','c','Compression','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','d','Chemin d\'accès','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','e','Date et heure de consultation et d\'accès','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','f','Nom électronique','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','g','Nom normalisé d\'une ressource','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','h','Nom de l\'utilisateur','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','i','Instruction','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','j','Bits par seconde','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','k','Mot de passe','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','l','Logon/login','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','m','Contact pour l\'assistance technique','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','n','Adresse du serveur cité dans la sous-zone $a','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','o','système d\'exploitation','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','p','Port','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','q','Type de format électronique','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','r','Paramétrage','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','s','Taille du fichier','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','t','Emulation du terminal','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','u','Adresse électronique normalisée (URL)','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','v','Heures d\'accès','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','w','Numéro d\'identification de la notice','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','x','Note confidentielle','',0,1,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','y','Mode d\'accès','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','856','z','Note publique','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','886','2','Code de système','',0,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','886','a','Etiquette de la zone du format source','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,''),('','886','b','Indicateurs et sous-zones de la zone du format source','',1,0,0,NULL,NULL,NULL,NULL,0,0,NULL,'');
/*!40000 ALTER TABLE `auth_subfield_structure` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_tag_structure`
--

DROP TABLE IF EXISTS `auth_tag_structure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_tag_structure` (
  `authtypecode` varchar(10) NOT NULL DEFAULT '',
  `tagfield` varchar(3) NOT NULL DEFAULT '',
  `liblibrarian` varchar(255) NOT NULL DEFAULT '',
  `libopac` varchar(255) NOT NULL DEFAULT '',
  `repeatable` tinyint(4) NOT NULL DEFAULT '0',
  `mandatory` tinyint(4) NOT NULL DEFAULT '0',
  `authorised_value` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`authtypecode`,`tagfield`),
  CONSTRAINT `auth_tag_structure_ibfk_1` FOREIGN KEY (`authtypecode`) REFERENCES `auth_types` (`authtypecode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_tag_structure`
--

LOCK TABLES `auth_tag_structure` WRITE;
/*!40000 ALTER TABLE `auth_tag_structure` DISABLE KEYS */;
INSERT INTO `auth_tag_structure` VALUES ('','001','Identificateur de la notice','',0,0,NULL),('','005','Identificateur de la version','',0,0,NULL),('','015','(ISADN)','',0,0,NULL),('','035','Identificateur de la notice dans un autre système','',0,0,NULL),('','100','Données générales de traitement','',0,1,NULL),('','101','Langue de l\'entité','',0,0,NULL),('','102','Nationalité de l\'entité','',0,1,NULL),('','106','Zone de données codées : Nom de personne / Nom de collectivité / Famille /Marque, utilisés comme vedettes matières','',0,0,NULL),('','120','Zone de données codées : Nom de personne','',0,0,NULL),('','123','Zone de données codées : Nom de territoire ou nom  géographique','',1,0,NULL),('','150','Zone de données codées : Nom de collectivité','',0,0,NULL),('','152','Règles','',0,0,NULL),('','154','Zone de données codées : titre uniforme','',0,0,NULL),('','160','Code d\'aire géographique','',0,0,NULL),('','200','Vedette','',1,0,NULL),('','210','Vedette','',1,0,''),('','215','Vedette','',1,0,''),('','230','Vedette','',1,0,NULL),('','240','Vedette','',1,0,NULL),('','250','Vedette-Matière nom commun','',1,0,''),('','300','Note d\'information','',1,0,NULL),('','305','Note de renvoi textuel \"Voir aussi\"','',1,0,NULL),('','310','Note de renvoi textuel \"Voir\"','',1,0,NULL),('','320','Note de renvoi explicatif','',1,0,NULL),('','330','Note sur le champ d\'application','',1,0,NULL),('','340','Note sur la biographie et l\'activité','',1,0,NULL),('','356','Note géographique','',0,1,NULL),('','400','Forme rejetée','',1,0,''),('','410','Forme rejetée','',1,0,''),('','415','Forme rejetée','',1,0,''),('','430','Forme rejetée','',1,0,NULL),('','440','Forme rejetée','',1,0,NULL),('','450','Forme rejetée','',1,0,''),('','500','Forme associée','',1,0,''),('','510','Forme associée','',1,0,NULL),('','515','Forme associée','',1,0,NULL),('','530','Forme associée','',1,0,NULL),('','540','Forme associée','',1,0,NULL),('','550','Forme associée','',1,0,NULL),('','675','Classification décimale universelle (CDU)(provisoire)','',1,0,NULL),('','676','Classification décimale Dewey (CDD)','',1,0,NULL),('','680','Classification de la Bibliothèque du Congrès (LCC)','',1,0,NULL),('','686','Autres classifications','',1,0,NULL),('','710','Forme parallèle','',1,0,''),('','801','Origine de la notice','',1,1,''),('','810','Sources consultées avec profit','',1,0,NULL),('','815','Sources consultées en vain','',0,0,NULL),('','820','Information sur l\'utilisation ou le champ d\'application de la vedette','',1,0,NULL),('','825','Citation dans une autre notice','',1,0,NULL),('','830','Note générale de travail','',1,0,NULL),('','835','Information sur les vedettes remplaçant une vedette détruite','',1,0,NULL),('','836','Information sur les vedettes remplacées','',1,0,NULL),('','856','Adresse électronique et mode d\'accès','',1,0,NULL),('','886','Données non converties du format source','',1,0,NULL);
/*!40000 ALTER TABLE `auth_tag_structure` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_types`
--

DROP TABLE IF EXISTS `auth_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_types` (
  `authtypecode` varchar(10) NOT NULL DEFAULT '',
  `authtypetext` varchar(255) NOT NULL DEFAULT '',
  `auth_tag_to_report` varchar(3) NOT NULL DEFAULT '',
  `summary` mediumtext NOT NULL,
  PRIMARY KEY (`authtypecode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_types`
--

LOCK TABLES `auth_types` WRITE;
/*!40000 ALTER TABLE `auth_types` DISABLE KEYS */;
INSERT INTO `auth_types` VALUES ('','Défaut','',''),('CENTINT','Centre d\'intérêt','250',''),('CO','Auteur (collectif/collectivité)','210',''),('EDITORS','Editeur','210',''),('FAM','Famille','220',''),('GENRE','Genre','250',''),('NP','Auteur','200',''),('SAUT','Sujet (auteur)','200',''),('SCO','Sujet (collectivité)','210',''),('SFAM','Sujet (famille)','220',''),('SNC','Sujet (nom commun)','250',''),('SNG','Sujet (nom géographique)','215',''),('STU','Sujet (titre uniforme)','230',''),('TU','Titre Uniforme','230','');
/*!40000 ALTER TABLE `auth_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `authorised_values`
--

DROP TABLE IF EXISTS `authorised_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authorised_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(10) NOT NULL DEFAULT '',
  `authorised_value` varchar(80) NOT NULL DEFAULT '',
  `lib` varchar(80) DEFAULT NULL,
  `lib_opac` varchar(80) DEFAULT NULL,
  `imageurl` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`category`),
  KEY `lib` (`lib`)
) ENGINE=InnoDB AUTO_INCREMENT=3778 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `authorised_values`
--

LOCK TABLES `authorised_values` WRITE;
/*!40000 ALTER TABLE `authorised_values` DISABLE KEYS */;
INSERT INTO `authorised_values` VALUES (1,'CCODE','TRAD','Trad . nat.','Trad . nat.',''),(2,'CCODE','CHFR','Chanson Française','Chanson Française',''),(3,'CCODE','JAZZ','Jazz','Jazz',''),(4,'CCODE','ROCK','Rock','Rock',''),(5,'CCODE','CLAS','Classique','Classique',''),(6,'CCODE','CLASC','Clas. cont.','Clas. cont.',''),(7,'CCODE','FONC','Fonction.','Fonction.',''),(8,'CCODE','NONM','Non-mus.','Non-mus.',''),(9,'CCODE','ENFA','Enfants','Enfants',''),(10,'CCODE','GENER','Généralités','Généralités',''),(11,'CCODE','PHILOPSY','Philo. Psycho.','Philo. Psycho.',''),(12,'CCODE','RELIG','Religions','Religions',''),(13,'CCODE','SCSOC','Sc. sociales','Sc. sociales',''),(14,'CCODE','LANGU','Langues','Langues',''),(15,'CCODE','SCIEN','Sciences','Sciences',''),(16,'CCODE','TECHN','Techniques','Techniques',''),(17,'CCODE','ARTSLOIS','Arts Loisirs','Arts Loisirs',''),(18,'CCODE','BD','BD','BD',''),(19,'CCODE','LITTER','Littérature','Littérature',''),(20,'CCODE','HISTGEO','Histoire - Géographie','Histoire - Géographie',''),(21,'CCODE','LD','Documentaire Lorrain','Documentaire Lorrain',''),(22,'CCODE','GD','Documentaire en Gros caractères','Documentaire en Gros caractères',''),(23,'CCODE','ALBUMS','Albums','Albums',''),(24,'CCODE','ROMADOS','Romans ado.','Romans ado.',''),(25,'CCODE','BDJEUN','BD jeunesses','BD jeunesses',''),(26,'CCODE','CONTES','Contes','Contes',''),(27,'CCODE','GRCARACT','Gros caractères','Gros caractères',''),(28,'CCODE','ROMJEUN','Romans jeunesses','Romans jeunesses',''),(29,'CCODE','CONTESL','Contes lorrain','Contes lorrain',''),(30,'CCODE','FONDSL','Fonds lorrain','Fonds lorrain',''),(31,'CCODE','MANGAS','Mangas','Mangas',''),(32,'CCODE','ROMANS','Romans','Romans',''),(33,'CCODE','RACONTAP','Raconte tapis','Raconte tapis',''),(34,'CCODE','TAPLECT','Tapis de lecture','Tapis de lecture',''),(35,'CCODE','EXPO','Expositions','Expositions',''),(36,'CCODE','KAMISHI','Kamishibaï','Kamishibaï',''),(37,'CCODE','INSTRMUS','Instruments de musique','Instruments de musique',''),(38,'CCODE','MODULES','Modules (exposition en trois dimensions)','Modules (exposition en trois dimensions)',''),(40,'CANTON','1','Ancerville','Ancerville',''),(41,'CANTON','2','Bar le Duc canton nord','Bar le Duc canton nord',''),(42,'CANTON','3','Charny sur Meuse','Charny sur Meuse',''),(43,'CANTON','4','Clermont en Argonne','Clermont en Argonne',''),(44,'CANTON','5','Commercy','Commercy',''),(45,'CANTON','6','Damvillers','Damvillers',''),(46,'CANTON','7','Dun sur Meuse','Dun sur Meuse',''),(47,'CANTON','8','Etain','Etain',''),(48,'CANTON','9','Fresnes en Woëvre','Fresnes en Woëvre',''),(49,'CANTON','10','Gondrecourt le Château','Gondrecourt le Château',''),(50,'CANTON','11','Ligny en Barrois','Ligny en Barrois',''),(51,'CANTON','12','Montfaucon','Montfaucon',''),(52,'CANTON','13','Montiers sur Saulx','Montiers sur Saulx',''),(53,'CANTON','14','Montmédy','Montmédy',''),(54,'CANTON','15','Pierrefitte sur Aire','Pierrefitte sur Aire',''),(55,'CANTON','16','Revigny sur Ornain','Revigny sur Ornain',''),(56,'CANTON','17','Saint Mihiel','Saint Mihiel',''),(57,'CANTON','18','Souilly','Souilly',''),(58,'CANTON','19','Spincourt','Spincourt',''),(59,'CANTON','20','Stenay','Stenay',''),(60,'CANTON','21','Seuil d\'Argonne','Seuil d\'Argonne',''),(61,'CANTON','22','Varennes en Argonne','Varennes en Argonne',''),(62,'CANTON','23','Vaubécourt','Vaubécourt',''),(63,'CANTON','24','Vaucouleurs','Vaucouleurs',''),(64,'CANTON','25','Vavincourt','Vavincourt',''),(65,'CANTON','26','Verdun canton est','Verdun canton est',''),(66,'CANTON','27','Vigneulles les Hattonchâtel','Vigneulles les Hattonchâtel',''),(67,'CANTON','28','Void Vacon','Void Vacon',''),(68,'CANTON','29','Bar le Duc canton sud','Bar le Duc canton sud',''),(69,'CANTON','30','Verdun canton ouest','Verdun canton ouest',''),(70,'CANTON','31','Verdun canton centre','Verdun canton centre',''),(71,'CANTON','32','Bar le Duc Ville','Bar le Duc Ville',''),(72,'CANTON','33','Verdun Ville','Verdun Ville',''),(73,'WITHDRAWN','0',NULL,NULL,''),(74,'WITHDRAWN','1','Pilon','Pilon',''),(3000,'QUALIF','005','Acteur','Acteur',''),(3001,'QUALIF','010','Adaptateur','',''),(3002,'QUALIF','018','Auteur de L animation','Auteur de l animation',''),(3003,'QUALIF','020','Annotateur','',''),(3004,'QUALIF','030','Arrangeur','',''),(3005,'QUALIF','040','Artiste','',''),(3006,'QUALIF','050','Cessionnaire de droits','',''),(3007,'QUALIF','060','Nom associé','',''),(3008,'QUALIF','065','Commissaire priseur','',''),(3009,'QUALIF','070','Auteur','',''),(3010,'QUALIF','072','Auteur d une citation ou d extraits','',''),(3011,'QUALIF','075','Auteur d une postface  du colophon etc','',''),(3012,'QUALIF','080','Préfacier etc','',''),(3013,'QUALIF','090','Auteur du dialogue','',''),(3014,'QUALIF','100','Auteur oeuvre adaptée','',''),(3015,'QUALIF','110','Relieur','',''),(3016,'QUALIF','120','Dessinateur de la reliure','',''),(3017,'QUALIF','130','Maquettiste','',''),(3018,'QUALIF','140','Dessinateur de la jaquette','',''),(3019,'QUALIF','150','Dessinateur d ex libris','',''),(3020,'QUALIF','160','Libraire','',''),(3021,'QUALIF','170','Calligraphe','',''),(3022,'QUALIF','180','Cartographe','',''),(3023,'QUALIF','190','Censeur','',''),(3024,'QUALIF','195','Chef de chœur','Chef de chœur',''),(3025,'QUALIF','200','Chorégraphe','',''),(3026,'QUALIF','205','Collaborateur','',''),(3027,'QUALIF','207','Humoriste','Humoriste',''),(3028,'QUALIF','210','Commentateur','',''),(3029,'QUALIF','212','Commentateur de texte écrit','',''),(3030,'QUALIF','220','Compilateur','',''),(3031,'QUALIF','230','Compositeur','',''),(3032,'QUALIF','240','Compositeur typographe','',''),(3033,'QUALIF','245','Concepteur','',''),(3034,'QUALIF','250','Chef d orchestre','',''),(3035,'QUALIF','255','Consultant de projet','Consultant de projet',''),(3036,'QUALIF','260','Détenteur du copyright','',''),(3037,'QUALIF','270','Correcteur','',''),(3038,'QUALIF','273','Commissaire d une exposition','',''),(3039,'QUALIF','274','Danseur','',''),(3040,'QUALIF','280','Dédicataire','',''),(3041,'QUALIF','290','Auteur d une dédicace','',''),(3042,'QUALIF','295','Organisme de soutenance','',''),(3043,'QUALIF','300','Directeur artistique','',''),(3044,'QUALIF','305','Doctorant','',''),(3045,'QUALIF','310','Distributeur','',''),(3046,'QUALIF','320','Donateur','',''),(3047,'QUALIF','330','Auteur douteux','',''),(3048,'QUALIF','340','Editeur scientifique','',''),(3049,'QUALIF','350','Graveur','',''),(3050,'QUALIF','360','Aquafortiste','',''),(3051,'QUALIF','365','Expert','',''),(3052,'QUALIF','370','Réalisateur','',''),(3053,'QUALIF','380','Contrefacteur','',''),(3054,'QUALIF','390','Propriétaire précédent','',''),(3055,'QUALIF','395','Fondateur','',''),(3056,'QUALIF','400','Mécène','',''),(3057,'QUALIF','410','Technicien graphique','',''),(3058,'QUALIF','420','Personne honorée','',''),(3059,'QUALIF','430','Enlumineur','',''),(3060,'QUALIF','440','Illustrateur','',''),(3061,'QUALIF','450','Signataire d une présentation','',''),(3062,'QUALIF','460','Personne interviewée','',''),(3063,'QUALIF','470','Intervieweur','',''),(3064,'QUALIF','480','Librettiste','',''),(3065,'QUALIF','490','Titulaire des droits Premier titulaire','',''),(3066,'QUALIF','500','Concesseur','',''),(3067,'QUALIF','510','Lithographe','',''),(3068,'QUALIF','520','Parolier','',''),(3069,'QUALIF','530','Graveur sur métal','',''),(3070,'QUALIF','540','Contrôleur concessionnaire','',''),(3071,'QUALIF','545','Musicien','',''),(3072,'QUALIF','550','Narrateur','',''),(3073,'QUALIF','557','Organisateur congrès','',''),(3074,'QUALIF','560','Créateur','',''),(3075,'QUALIF','570','Autres','',''),(3076,'QUALIF','571','Coordinateur','',''),(3077,'QUALIF','573','Diffuseur','',''),(3078,'QUALIF','574','Présentateur','',''),(3079,'QUALIF','575','Responsable','',''),(3080,'QUALIF','580','Fabricant de papier','',''),(3081,'QUALIF','587','Titulaire de brevet','Titulaire de brevet',''),(3082,'QUALIF','590','Acteur exécutant','',''),(3144,'QUALIF','600','Photographe','',''),(3145,'QUALIF','605','Présentateur','',''),(3146,'QUALIF','610','Imprimeur','',''),(3147,'QUALIF','620','Graveur de plaques','',''),(3148,'QUALIF','630','Producteur','',''),(3149,'QUALIF','635','Programmeur','',''),(3150,'QUALIF','640','Correcteur d épreuves','',''),(3151,'QUALIF','650','Editeur','',''),(3152,'QUALIF','651','Directeur de la pub','',''),(3153,'QUALIF','660','Destinataire','',''),(3154,'QUALIF','670','Ingénieur du son','',''),(3155,'QUALIF','673','Directeur','',''),(3156,'QUALIF','675','Critique','',''),(3157,'QUALIF','680','Rubricateur','',''),(3158,'QUALIF','690','Scénariste','',''),(3159,'QUALIF','695','Conseiller scientifique','',''),(3160,'QUALIF','700','Scribe copiste','',''),(3161,'QUALIF','705','Sculpteur','',''),(3162,'QUALIF','710','Attaché de presse','',''),(3163,'QUALIF','720','Signataire','',''),(3164,'QUALIF','721','Chanteur','',''),(3165,'QUALIF','723','Commanditaire','',''),(3166,'QUALIF','727','Directeur de thèse','',''),(3167,'QUALIF','730','Traducteur','',''),(3168,'QUALIF','740','Dessinateur de caractères d imprimerie','',''),(3169,'QUALIF','750','Typographe','',''),(3170,'QUALIF','755','Exécutant vocal','Exécutant vocal',''),(3171,'QUALIF','760','Graveur sur bois','',''),(3172,'QUALIF','770','Auteur du matériel d accompagnement','',''),(3744,'Bsort1','10','Agriculteurs exploitants',NULL,NULL),(3745,'Bsort1','11','CSP non déclarée',NULL,NULL),(3746,'Bsort1','12','Elèves ou enfants non scolarisés',NULL,NULL),(3747,'Bsort1','13','Etudiants',NULL,NULL),(3748,'Bsort1','21','Artisans',NULL,NULL),(3749,'Bsort1','22','Commerçants et assimilés',NULL,NULL),(3750,'Bsort1','23','Chefs d\'entreprise de 10 salariés ou plus',NULL,NULL),(3751,'Bsort1','31','Professions libérales et assimilés',NULL,NULL),(3752,'Bsort1','32','Cadres de la fonction publique, professions intellectuelles et  artistiques',NULL,NULL),(3753,'Bsort1','36','Cadres d\'entreprise',NULL,NULL),(3754,'Bsort1','41','Professions intermédiaires de l\'enseignement, de la santé, de la fonction publiq',NULL,NULL),(3755,'Bsort1','46','Professions intermédiaires administratives et commerciales des entreprises',NULL,NULL),(3756,'Bsort1','47','Techniciens',NULL,NULL),(3757,'Bsort1','48','Contremaîtres, agents de maîtrise',NULL,NULL),(3758,'Bsort1','51','Employés de la fonction publique',NULL,NULL),(3759,'Bsort1','54','Employés administratifs d\'entreprise',NULL,NULL),(3760,'Bsort1','55','Employés de commerce',NULL,NULL),(3761,'Bsort1','56','Personnels des services directs aux particuliers',NULL,NULL),(3762,'Bsort1','61','Ouvriers qualifiés',NULL,NULL),(3763,'Bsort1','66','Ouvriers non qualifiés',NULL,NULL),(3764,'Bsort1','69','Ouvriers agricoles',NULL,NULL),(3765,'Bsort1','71','Anciens agriculteurs exploitants',NULL,NULL),(3766,'Bsort1','72','Anciens artisans, commerçants, chefs d\'entreprise',NULL,NULL),(3767,'Bsort1','73','Anciens cadres et professions intermédiaires',NULL,NULL),(3768,'Bsort1','76','Anciens employés et ouvriers',NULL,NULL),(3769,'Bsort1','81','Chômeurs n\'ayant jamais travaillé',NULL,NULL),(3770,'Bsort1','82','Inactifs divers (autres que retraités)',NULL,NULL),(3771,'ETAT','0','Empruntable','Empruntable',''),(3772,'ETAT','1','Exclu du prêt','Exclu du prêt',''),(3773,'ETAT','2','En traitement','En traitement',''),(3774,'ETAT','3','Consultation sur place','Consultation sur place',''),(3775,'ETAT','4','En réserve','En réserve',''),(3776,'ETAT','5','En réparation','En réparation',''),(3777,'ETAT','6','En reliure','En reliure','');
/*!40000 ALTER TABLE `authorised_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biblio`
--

DROP TABLE IF EXISTS `biblio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `biblio` (
  `biblionumber` int(11) NOT NULL AUTO_INCREMENT,
  `frameworkcode` varchar(4) NOT NULL DEFAULT '',
  `author` mediumtext,
  `title` mediumtext,
  `unititle` mediumtext,
  `notes` mediumtext,
  `serial` tinyint(1) DEFAULT NULL,
  `seriestitle` mediumtext,
  `copyrightdate` smallint(6) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `datecreated` date NOT NULL,
  `abstract` mediumtext,
  PRIMARY KEY (`biblionumber`),
  KEY `blbnoidx` (`biblionumber`)
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `biblio_framework`
--

DROP TABLE IF EXISTS `biblio_framework`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `biblio_framework` (
  `frameworkcode` varchar(4) NOT NULL DEFAULT '',
  `frameworktext` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`frameworkcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biblio_framework`
--

LOCK TABLES `biblio_framework` WRITE;
/*!40000 ALTER TABLE `biblio_framework` DISABLE KEYS */;
/*!40000 ALTER TABLE `biblio_framework` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biblioitems`
--

DROP TABLE IF EXISTS `biblioitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `biblioitems` (
  `biblioitemnumber` int(11) NOT NULL AUTO_INCREMENT,
  `biblionumber` int(11) NOT NULL DEFAULT '0',
  `volume` mediumtext,
  `number` mediumtext,
  `itemtype` varchar(10) DEFAULT NULL,
  `isbn` varchar(30) DEFAULT NULL,
  `issn` varchar(9) DEFAULT NULL,
  `publicationyear` text,
  `publishercode` varchar(255) DEFAULT NULL,
  `volumedate` date DEFAULT NULL,
  `volumedesc` text,
  `collectiontitle` mediumtext,
  `collectionissn` text,
  `collectionvolume` mediumtext,
  `editionstatement` text,
  `editionresponsibility` text,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `illus` varchar(255) DEFAULT NULL,
  `pages` varchar(255) DEFAULT NULL,
  `notes` mediumtext,
  `size` varchar(255) DEFAULT NULL,
  `place` varchar(255) DEFAULT NULL,
  `lccn` varchar(25) DEFAULT NULL,
  `marc` longblob,
  `url` varchar(255) DEFAULT NULL,
  `cn_source` varchar(10) DEFAULT NULL,
  `cn_class` varchar(30) DEFAULT NULL,
  `cn_item` varchar(10) DEFAULT NULL,
  `cn_suffix` varchar(10) DEFAULT NULL,
  `cn_sort` varchar(30) DEFAULT NULL,
  `totalissues` int(10) DEFAULT NULL,
  `marcxml` longtext NOT NULL,
  PRIMARY KEY (`biblioitemnumber`),
  KEY `bibinoidx` (`biblioitemnumber`),
  KEY `bibnoidx` (`biblionumber`),
  KEY `isbn` (`isbn`),
  KEY `publishercode` (`publishercode`),
  CONSTRAINT `biblioitems_ibfk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `borrower_attribute_types`
--

DROP TABLE IF EXISTS `borrower_attribute_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrower_attribute_types` (
  `code` varchar(10) NOT NULL,
  `description` varchar(255) NOT NULL,
  `repeatable` tinyint(1) NOT NULL DEFAULT '0',
  `unique_id` tinyint(1) NOT NULL DEFAULT '0',
  `opac_display` tinyint(1) NOT NULL DEFAULT '0',
  `password_allowed` tinyint(1) NOT NULL DEFAULT '0',
  `staff_searchable` tinyint(1) NOT NULL DEFAULT '0',
  `authorised_value_category` varchar(10) DEFAULT NULL,
  `display_checkout` tinyint(1) NOT NULL DEFAULT '0',
  `category_type` varchar(1) NOT NULL DEFAULT '',
  `class` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `borrower_attribute_types`
--

LOCK TABLES `borrower_attribute_types` WRITE;
/*!40000 ALTER TABLE `borrower_attribute_types` DISABLE KEYS */;
INSERT INTO `borrower_attribute_types` VALUES ('CANTON','CANTON',0,0,0,0,0,'',0,'','Test'),('HORAIRES','Horaires de la tournée',0,0,0,0,0,'',0,'I','Test'),('TOURNEE','Numéro de la tournée',0,0,0,0,0,'',0,'I','');
/*!40000 ALTER TABLE `borrower_attribute_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `borrower_attributes`
--

DROP TABLE IF EXISTS `borrower_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrower_attributes` (
  `borrowernumber` int(11) NOT NULL,
  `code` varchar(10) NOT NULL,
  `attribute` varchar(64) DEFAULT NULL,
  `password` varchar(64) DEFAULT NULL,
  KEY `borrowernumber` (`borrowernumber`),
  KEY `code_attribute` (`code`,`attribute`),
  CONSTRAINT `borrower_attributes_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_attributes_ibfk_2` FOREIGN KEY (`code`) REFERENCES `borrower_attribute_types` (`code`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `borrower_message_preferences`
--

DROP TABLE IF EXISTS `borrower_message_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrower_message_preferences` (
  `borrower_message_preference_id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) DEFAULT NULL,
  `categorycode` varchar(10) DEFAULT NULL,
  `message_attribute_id` int(11) DEFAULT '0',
  `days_in_advance` int(11) DEFAULT '0',
  `wants_digest` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`borrower_message_preference_id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `categorycode` (`categorycode`),
  KEY `message_attribute_id` (`message_attribute_id`),
  CONSTRAINT `borrower_message_preferences_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_message_preferences_ibfk_2` FOREIGN KEY (`message_attribute_id`) REFERENCES `message_attributes` (`message_attribute_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_message_preferences_ibfk_3` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `borrower_message_preferences`
--

LOCK TABLES `borrower_message_preferences` WRITE;
/*!40000 ALTER TABLE `borrower_message_preferences` DISABLE KEYS */;
/*!40000 ALTER TABLE `borrower_message_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `borrower_message_transport_preferences`
--

DROP TABLE IF EXISTS `borrower_message_transport_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrower_message_transport_preferences` (
  `borrower_message_preference_id` int(11) NOT NULL DEFAULT '0',
  `message_transport_type` varchar(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`borrower_message_preference_id`,`message_transport_type`),
  KEY `message_transport_type` (`message_transport_type`),
  CONSTRAINT `borrower_message_transport_preferences_ibfk_1` FOREIGN KEY (`borrower_message_preference_id`) REFERENCES `borrower_message_preferences` (`borrower_message_preference_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `borrower_message_transport_preferences_ibfk_2` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `borrower_message_transport_preferences`
--

LOCK TABLES `borrower_message_transport_preferences` WRITE;
/*!40000 ALTER TABLE `borrower_message_transport_preferences` DISABLE KEYS */;
/*!40000 ALTER TABLE `borrower_message_transport_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `borrowers`
--

DROP TABLE IF EXISTS `borrowers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `borrowers` (
  `borrowernumber` int(11) NOT NULL AUTO_INCREMENT,
  `cardnumber` varchar(16) DEFAULT NULL,
  `surname` mediumtext NOT NULL,
  `firstname` text,
  `title` mediumtext,
  `othernames` mediumtext,
  `initials` text,
  `streetnumber` varchar(10) DEFAULT NULL,
  `streettype` varchar(50) DEFAULT NULL,
  `address` mediumtext NOT NULL,
  `address2` text,
  `city` mediumtext NOT NULL,
  `zipcode` varchar(25) DEFAULT NULL,
  `country` text,
  `email` mediumtext,
  `phone` text,
  `mobile` varchar(50) DEFAULT NULL,
  `fax` mediumtext,
  `emailpro` text,
  `phonepro` text,
  `B_streetnumber` varchar(10) DEFAULT NULL,
  `B_streettype` varchar(50) DEFAULT NULL,
  `B_address` varchar(100) DEFAULT NULL,
  `B_address2` text,
  `B_city` mediumtext,
  `B_zipcode` varchar(25) DEFAULT NULL,
  `B_country` text,
  `B_email` text,
  `B_phone` mediumtext,
  `dateofbirth` date DEFAULT NULL,
  `branchcode` varchar(10) NOT NULL DEFAULT '',
  `categorycode` varchar(10) NOT NULL DEFAULT '',
  `dateenrolled` date DEFAULT NULL,
  `dateexpiry` date DEFAULT NULL,
  `gonenoaddress` tinyint(1) DEFAULT NULL,
  `gonenoaddresscomment` varchar(255) DEFAULT NULL,
  `lost` tinyint(1) DEFAULT NULL,
  `lostcomment` varchar(255) DEFAULT NULL,
  `debarred` date DEFAULT NULL,
  `debarredcomment` varchar(255) DEFAULT NULL,
  `contactname` mediumtext,
  `contactfirstname` text,
  `contacttitle` text,
  `guarantorid` int(11) DEFAULT NULL,
  `borrowernotes` mediumtext,
  `relationship` varchar(100) DEFAULT NULL,
  `ethnicity` varchar(50) DEFAULT NULL,
  `ethnotes` varchar(255) DEFAULT NULL,
  `sex` varchar(1) DEFAULT NULL,
  `password` varchar(30) DEFAULT NULL,
  `flags` int(11) DEFAULT NULL,
  `userid` varchar(30) DEFAULT NULL,
  `opacnote` mediumtext,
  `contactnote` varchar(255) DEFAULT NULL,
  `sort1` varchar(80) DEFAULT NULL,
  `sort2` varchar(80) DEFAULT NULL,
  `altcontactfirstname` varchar(255) DEFAULT NULL,
  `altcontactsurname` varchar(255) DEFAULT NULL,
  `altcontactaddress1` varchar(255) DEFAULT NULL,
  `altcontactaddress2` varchar(255) DEFAULT NULL,
  `altcontactaddress3` varchar(255) DEFAULT NULL,
  `altcontactzipcode` varchar(50) DEFAULT NULL,
  `altcontactcountry` text,
  `altcontactphone` varchar(50) DEFAULT NULL,
  `smsalertnumber` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`borrowernumber`),
  UNIQUE KEY `cardnumber` (`cardnumber`),
  KEY `categorycode` (`categorycode`),
  KEY `branchcode` (`branchcode`),
  KEY `userid` (`userid`),
  KEY `guarantorid` (`guarantorid`),
  CONSTRAINT `borrowers_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`),
  CONSTRAINT `borrowers_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `branch_borrower_circ_rules`
--

DROP TABLE IF EXISTS `branch_borrower_circ_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branch_borrower_circ_rules` (
  `branchcode` varchar(10) NOT NULL,
  `categorycode` varchar(10) NOT NULL,
  `maxissueqty` int(4) DEFAULT NULL,
  PRIMARY KEY (`categorycode`,`branchcode`),
  KEY `branch_borrower_circ_rules_ibfk_2` (`branchcode`),
  CONSTRAINT `branch_borrower_circ_rules_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branch_borrower_circ_rules_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch_borrower_circ_rules`
--

LOCK TABLES `branch_borrower_circ_rules` WRITE;
/*!40000 ALTER TABLE `branch_borrower_circ_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `branch_borrower_circ_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch_item_rules`
--

DROP TABLE IF EXISTS `branch_item_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branch_item_rules` (
  `branchcode` varchar(10) NOT NULL,
  `itemtype` varchar(10) NOT NULL,
  `holdallowed` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`itemtype`,`branchcode`),
  KEY `branch_item_rules_ibfk_2` (`branchcode`),
  CONSTRAINT `branch_item_rules_ibfk_1` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branch_item_rules_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch_item_rules`
--

LOCK TABLES `branch_item_rules` WRITE;
/*!40000 ALTER TABLE `branch_item_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `branch_item_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch_transfer_limits`
--

DROP TABLE IF EXISTS `branch_transfer_limits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branch_transfer_limits` (
  `limitId` int(8) NOT NULL AUTO_INCREMENT,
  `toBranch` varchar(10) NOT NULL,
  `fromBranch` varchar(10) NOT NULL,
  `itemtype` varchar(10) DEFAULT NULL,
  `ccode` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`limitId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch_transfer_limits`
--

LOCK TABLES `branch_transfer_limits` WRITE;
/*!40000 ALTER TABLE `branch_transfer_limits` DISABLE KEYS */;
/*!40000 ALTER TABLE `branch_transfer_limits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branchcategories`
--

DROP TABLE IF EXISTS `branchcategories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branchcategories` (
  `categorycode` varchar(10) NOT NULL DEFAULT '',
  `categoryname` varchar(32) DEFAULT NULL,
  `codedescription` mediumtext,
  `categorytype` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branchcategories`
--

LOCK TABLES `branchcategories` WRITE;
/*!40000 ALTER TABLE `branchcategories` DISABLE KEYS */;
/*!40000 ALTER TABLE `branchcategories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branches`
--

DROP TABLE IF EXISTS `branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branches` (
  `branchcode` varchar(10) NOT NULL DEFAULT '',
  `branchname` mediumtext NOT NULL,
  `branchaddress1` mediumtext,
  `branchaddress2` mediumtext,
  `branchaddress3` mediumtext,
  `branchzip` varchar(25) DEFAULT NULL,
  `branchcity` mediumtext,
  `branchcountry` text,
  `branchphone` mediumtext,
  `branchfax` mediumtext,
  `branchemail` mediumtext,
  `branchurl` mediumtext,
  `issuing` tinyint(4) DEFAULT NULL,
  `branchip` varchar(15) DEFAULT NULL,
  `branchprinter` varchar(100) DEFAULT NULL,
  `branchnotes` mediumtext,
  UNIQUE KEY `branchcode` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branches`
--

LOCK TABLES `branches` WRITE;
/*!40000 ALTER TABLE `branches` DISABLE KEYS */;
INSERT INTO `branches` VALUES ('BDM','Bibliothèque Départementale de la Meuse','','','','','','','','','','',NULL,'',NULL,'');
/*!40000 ALTER TABLE `branches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branchrelations`
--

DROP TABLE IF EXISTS `branchrelations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branchrelations` (
  `branchcode` varchar(10) NOT NULL DEFAULT '',
  `categorycode` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`branchcode`,`categorycode`),
  KEY `branchcode` (`branchcode`),
  KEY `categorycode` (`categorycode`),
  CONSTRAINT `branchrelations_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branchrelations_ibfk_2` FOREIGN KEY (`categorycode`) REFERENCES `branchcategories` (`categorycode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branchrelations`
--

LOCK TABLES `branchrelations` WRITE;
/*!40000 ALTER TABLE `branchrelations` DISABLE KEYS */;
/*!40000 ALTER TABLE `branchrelations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branchtransfers`
--

DROP TABLE IF EXISTS `branchtransfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branchtransfers` (
  `itemnumber` int(11) NOT NULL DEFAULT '0',
  `datesent` datetime DEFAULT NULL,
  `frombranch` varchar(10) NOT NULL DEFAULT '',
  `datearrived` datetime DEFAULT NULL,
  `tobranch` varchar(10) NOT NULL DEFAULT '',
  `comments` mediumtext,
  KEY `frombranch` (`frombranch`),
  KEY `tobranch` (`tobranch`),
  KEY `itemnumber` (`itemnumber`),
  CONSTRAINT `branchtransfers_ibfk_1` FOREIGN KEY (`frombranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branchtransfers_ibfk_2` FOREIGN KEY (`tobranch`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branchtransfers_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branchtransfers`
--

LOCK TABLES `branchtransfers` WRITE;
/*!40000 ALTER TABLE `branchtransfers` DISABLE KEYS */;
/*!40000 ALTER TABLE `branchtransfers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `browser`
--

DROP TABLE IF EXISTS `browser`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `browser` (
  `level` int(11) NOT NULL,
  `classification` varchar(20) NOT NULL,
  `description` varchar(255) NOT NULL,
  `number` bigint(20) NOT NULL,
  `endnode` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `browser`
--

LOCK TABLES `browser` WRITE;
/*!40000 ALTER TABLE `browser` DISABLE KEYS */;
/*!40000 ALTER TABLE `browser` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `categorycode` varchar(10) NOT NULL DEFAULT '',
  `description` mediumtext,
  `enrolmentperiod` smallint(6) DEFAULT NULL,
  `enrolmentperioddate` date DEFAULT NULL,
  `upperagelimit` smallint(6) DEFAULT NULL,
  `dateofbirthrequired` tinyint(1) DEFAULT NULL,
  `finetype` varchar(30) DEFAULT NULL,
  `bulk` tinyint(1) DEFAULT NULL,
  `enrolmentfee` decimal(28,6) DEFAULT NULL,
  `overduenoticerequired` tinyint(1) DEFAULT NULL,
  `issuelimit` smallint(6) DEFAULT NULL,
  `reservefee` decimal(28,6) DEFAULT NULL,
  `category_type` varchar(1) NOT NULL DEFAULT 'A',
  PRIMARY KEY (`categorycode`),
  UNIQUE KEY `categorycode` (`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES ('COLL','Collectivite',12,'0000-00-00',99,0,NULL,NULL,'0.000000',0,NULL,'0.000000','I'),('INDIVIDU','Lecteur individuel',12,'0000-00-00',99,0,NULL,NULL,'0.000000',0,NULL,'0.000000','A'),('PERSONNEL','Personnel',12,'0000-00-00',99,0,NULL,NULL,'0.000000',0,NULL,'0.000000','P'),('SCOLAIRE','Scolaire',12,'0000-00-00',99,0,NULL,NULL,'0.000000',0,NULL,'0.000000','A');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cities`
--

DROP TABLE IF EXISTS `cities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cities` (
  `cityid` int(11) NOT NULL AUTO_INCREMENT,
  `city_name` varchar(100) NOT NULL DEFAULT '',
  `city_zipcode` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`cityid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cities`
--

LOCK TABLES `cities` WRITE;
/*!40000 ALTER TABLE `cities` DISABLE KEYS */;
/*!40000 ALTER TABLE `cities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `class_sort_rules`
--

DROP TABLE IF EXISTS `class_sort_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `class_sort_rules` (
  `class_sort_rule` varchar(10) NOT NULL DEFAULT '',
  `description` mediumtext,
  `sort_routine` varchar(30) NOT NULL DEFAULT '',
  PRIMARY KEY (`class_sort_rule`),
  UNIQUE KEY `class_sort_rule_idx` (`class_sort_rule`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `class_sort_rules`
--

LOCK TABLES `class_sort_rules` WRITE;
/*!40000 ALTER TABLE `class_sort_rules` DISABLE KEYS */;
INSERT INTO `class_sort_rules` VALUES ('dewey','Default filing rules for DDC','Dewey'),('generic','Generic call number filing rules','Generic'),('lcc','Default filing rules for LCC','LCC');
/*!40000 ALTER TABLE `class_sort_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `class_sources`
--

DROP TABLE IF EXISTS `class_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `class_sources` (
  `cn_source` varchar(10) NOT NULL DEFAULT '',
  `description` mediumtext,
  `used` tinyint(4) NOT NULL DEFAULT '0',
  `class_sort_rule` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`cn_source`),
  UNIQUE KEY `cn_source_idx` (`cn_source`),
  KEY `used_idx` (`used`),
  KEY `class_source_ibfk_1` (`class_sort_rule`),
  CONSTRAINT `class_source_ibfk_1` FOREIGN KEY (`class_sort_rule`) REFERENCES `class_sort_rules` (`class_sort_rule`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `class_sources`
--

LOCK TABLES `class_sources` WRITE;
/*!40000 ALTER TABLE `class_sources` DISABLE KEYS */;
INSERT INTO `class_sources` VALUES ('anscr','ANSCR (Sound Recordings)',0,'generic'),('ddc','Dewey Decimal Classification',1,'dewey'),('lcc','Library of Congress Classification',1,'lcc'),('sudocs','SuDoc Classification (U.S. GPO)',0,'generic'),('udc','Universal Decimal Classification',0,'generic'),('z','Other/Generic Classification Scheme',0,'generic');
/*!40000 ALTER TABLE `class_sources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `creator_batches`
--

DROP TABLE IF EXISTS `creator_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `creator_batches` (
  `label_id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_id` int(10) NOT NULL DEFAULT '1',
  `item_number` int(11) DEFAULT NULL,
  `borrower_number` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `branch_code` varchar(10) NOT NULL DEFAULT 'NB',
  `creator` char(15) NOT NULL DEFAULT 'Labels',
  PRIMARY KEY (`label_id`),
  KEY `branch_fk_constraint` (`branch_code`),
  KEY `item_fk_constraint` (`item_number`),
  KEY `borrower_fk_constraint` (`borrower_number`),
  CONSTRAINT `creator_batches_ibfk_1` FOREIGN KEY (`borrower_number`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `creator_batches_ibfk_2` FOREIGN KEY (`branch_code`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE,
  CONSTRAINT `creator_batches_ibfk_3` FOREIGN KEY (`item_number`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `creator_batches`
--

LOCK TABLES `creator_batches` WRITE;
/*!40000 ALTER TABLE `creator_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `creator_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `creator_images`
--

DROP TABLE IF EXISTS `creator_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `creator_images` (
  `image_id` int(4) NOT NULL AUTO_INCREMENT,
  `imagefile` mediumblob,
  `image_name` char(20) NOT NULL DEFAULT 'DEFAULT',
  PRIMARY KEY (`image_id`),
  UNIQUE KEY `image_name_index` (`image_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `creator_images`
--

LOCK TABLES `creator_images` WRITE;
/*!40000 ALTER TABLE `creator_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `creator_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `creator_layouts`
--

DROP TABLE IF EXISTS `creator_layouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `creator_layouts` (
  `layout_id` int(4) NOT NULL AUTO_INCREMENT,
  `barcode_type` char(100) NOT NULL DEFAULT 'CODE39',
  `start_label` int(2) NOT NULL DEFAULT '1',
  `printing_type` char(32) NOT NULL DEFAULT 'BAR',
  `layout_name` char(20) NOT NULL DEFAULT 'DEFAULT',
  `guidebox` int(1) DEFAULT '0',
  `font` char(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'TR',
  `font_size` int(4) NOT NULL DEFAULT '10',
  `units` char(20) NOT NULL DEFAULT 'POINT',
  `callnum_split` int(1) DEFAULT '0',
  `text_justify` char(1) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'L',
  `format_string` varchar(210) NOT NULL DEFAULT 'barcode',
  `layout_xml` text NOT NULL,
  `creator` char(15) NOT NULL DEFAULT 'Labels',
  PRIMARY KEY (`layout_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `creator_layouts`
--

LOCK TABLES `creator_layouts` WRITE;
/*!40000 ALTER TABLE `creator_layouts` DISABLE KEYS */;
/*!40000 ALTER TABLE `creator_layouts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `creator_templates`
--

DROP TABLE IF EXISTS `creator_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `creator_templates` (
  `template_id` int(4) NOT NULL AUTO_INCREMENT,
  `profile_id` int(4) DEFAULT NULL,
  `template_code` char(100) NOT NULL DEFAULT 'DEFAULT TEMPLATE',
  `template_desc` char(100) NOT NULL DEFAULT 'Default description',
  `page_width` float NOT NULL DEFAULT '0',
  `page_height` float NOT NULL DEFAULT '0',
  `label_width` float NOT NULL DEFAULT '0',
  `label_height` float NOT NULL DEFAULT '0',
  `top_text_margin` float NOT NULL DEFAULT '0',
  `left_text_margin` float NOT NULL DEFAULT '0',
  `top_margin` float NOT NULL DEFAULT '0',
  `left_margin` float NOT NULL DEFAULT '0',
  `cols` int(2) NOT NULL DEFAULT '0',
  `rows` int(2) NOT NULL DEFAULT '0',
  `col_gap` float NOT NULL DEFAULT '0',
  `row_gap` float NOT NULL DEFAULT '0',
  `units` char(20) NOT NULL DEFAULT 'POINT',
  `creator` char(15) NOT NULL DEFAULT 'Labels',
  PRIMARY KEY (`template_id`),
  KEY `template_profile_fk_constraint` (`profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `creator_templates`
--

LOCK TABLES `creator_templates` WRITE;
/*!40000 ALTER TABLE `creator_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `creator_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currency`
--

DROP TABLE IF EXISTS `currency`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `currency` (
  `currency` varchar(10) NOT NULL DEFAULT '',
  `symbol` varchar(5) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `rate` float(7,5) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currency`
--

LOCK TABLES `currency` WRITE;
/*!40000 ALTER TABLE `currency` DISABLE KEYS */;
/*!40000 ALTER TABLE `currency` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_borrower_circ_rules`
--

DROP TABLE IF EXISTS `default_borrower_circ_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_borrower_circ_rules` (
  `categorycode` varchar(10) NOT NULL,
  `maxissueqty` int(4) DEFAULT NULL,
  PRIMARY KEY (`categorycode`),
  CONSTRAINT `borrower_borrower_circ_rules_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_borrower_circ_rules`
--

LOCK TABLES `default_borrower_circ_rules` WRITE;
/*!40000 ALTER TABLE `default_borrower_circ_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_borrower_circ_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_branch_circ_rules`
--

DROP TABLE IF EXISTS `default_branch_circ_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_branch_circ_rules` (
  `branchcode` varchar(10) NOT NULL,
  `maxissueqty` int(4) DEFAULT NULL,
  `holdallowed` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`branchcode`),
  CONSTRAINT `default_branch_circ_rules_ibfk_1` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_branch_circ_rules`
--

LOCK TABLES `default_branch_circ_rules` WRITE;
/*!40000 ALTER TABLE `default_branch_circ_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_branch_circ_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_branch_item_rules`
--

DROP TABLE IF EXISTS `default_branch_item_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_branch_item_rules` (
  `itemtype` varchar(10) NOT NULL,
  `holdallowed` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`itemtype`),
  CONSTRAINT `default_branch_item_rules_ibfk_1` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_branch_item_rules`
--

LOCK TABLES `default_branch_item_rules` WRITE;
/*!40000 ALTER TABLE `default_branch_item_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_branch_item_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_circ_rules`
--

DROP TABLE IF EXISTS `default_circ_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_circ_rules` (
  `singleton` enum('singleton') NOT NULL DEFAULT 'singleton',
  `maxissueqty` int(4) DEFAULT NULL,
  `holdallowed` int(1) DEFAULT NULL,
  PRIMARY KEY (`singleton`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_circ_rules`
--

LOCK TABLES `default_circ_rules` WRITE;
/*!40000 ALTER TABLE `default_circ_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_circ_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deletedbiblio`
--

DROP TABLE IF EXISTS `deletedbiblio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deletedbiblio` (
  `biblionumber` int(11) NOT NULL DEFAULT '0',
  `frameworkcode` varchar(4) NOT NULL DEFAULT '',
  `author` mediumtext,
  `title` mediumtext,
  `unititle` mediumtext,
  `notes` mediumtext,
  `serial` tinyint(1) DEFAULT NULL,
  `seriestitle` mediumtext,
  `copyrightdate` smallint(6) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `datecreated` date NOT NULL,
  `abstract` mediumtext,
  PRIMARY KEY (`biblionumber`),
  KEY `blbnoidx` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deletedbiblio`
--

LOCK TABLES `deletedbiblio` WRITE;
/*!40000 ALTER TABLE `deletedbiblio` DISABLE KEYS */;
/*!40000 ALTER TABLE `deletedbiblio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deletedbiblioitems`
--

DROP TABLE IF EXISTS `deletedbiblioitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deletedbiblioitems` (
  `biblioitemnumber` int(11) NOT NULL DEFAULT '0',
  `biblionumber` int(11) NOT NULL DEFAULT '0',
  `volume` mediumtext,
  `number` mediumtext,
  `itemtype` varchar(10) DEFAULT NULL,
  `isbn` varchar(30) DEFAULT NULL,
  `issn` varchar(9) DEFAULT NULL,
  `publicationyear` text,
  `publishercode` varchar(255) DEFAULT NULL,
  `volumedate` date DEFAULT NULL,
  `volumedesc` text,
  `collectiontitle` mediumtext,
  `collectionissn` text,
  `collectionvolume` mediumtext,
  `editionstatement` text,
  `editionresponsibility` text,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `illus` varchar(255) DEFAULT NULL,
  `pages` varchar(255) DEFAULT NULL,
  `notes` mediumtext,
  `size` varchar(255) DEFAULT NULL,
  `place` varchar(255) DEFAULT NULL,
  `lccn` varchar(25) DEFAULT NULL,
  `marc` longblob,
  `url` varchar(255) DEFAULT NULL,
  `cn_source` varchar(10) DEFAULT NULL,
  `cn_class` varchar(30) DEFAULT NULL,
  `cn_item` varchar(10) DEFAULT NULL,
  `cn_suffix` varchar(10) DEFAULT NULL,
  `cn_sort` varchar(30) DEFAULT NULL,
  `totalissues` int(10) DEFAULT NULL,
  `marcxml` longtext NOT NULL,
  PRIMARY KEY (`biblioitemnumber`),
  KEY `bibinoidx` (`biblioitemnumber`),
  KEY `bibnoidx` (`biblionumber`),
  KEY `isbn` (`isbn`),
  KEY `publishercode` (`publishercode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deletedbiblioitems`
--

LOCK TABLES `deletedbiblioitems` WRITE;
/*!40000 ALTER TABLE `deletedbiblioitems` DISABLE KEYS */;
/*!40000 ALTER TABLE `deletedbiblioitems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deletedborrowers`
--

DROP TABLE IF EXISTS `deletedborrowers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deletedborrowers` (
  `borrowernumber` int(11) NOT NULL DEFAULT '0',
  `cardnumber` varchar(9) NOT NULL DEFAULT '',
  `surname` mediumtext NOT NULL,
  `firstname` text,
  `title` mediumtext,
  `othernames` mediumtext,
  `initials` text,
  `streetnumber` varchar(10) DEFAULT NULL,
  `streettype` varchar(50) DEFAULT NULL,
  `address` mediumtext NOT NULL,
  `address2` text,
  `city` mediumtext NOT NULL,
  `zipcode` varchar(25) DEFAULT NULL,
  `country` text,
  `email` mediumtext,
  `phone` text,
  `mobile` varchar(50) DEFAULT NULL,
  `fax` mediumtext,
  `emailpro` text,
  `phonepro` text,
  `B_streetnumber` varchar(10) DEFAULT NULL,
  `B_streettype` varchar(50) DEFAULT NULL,
  `B_address` varchar(100) DEFAULT NULL,
  `B_address2` text,
  `B_city` mediumtext,
  `B_zipcode` varchar(25) DEFAULT NULL,
  `B_country` text,
  `B_email` text,
  `B_phone` mediumtext,
  `dateofbirth` date DEFAULT NULL,
  `branchcode` varchar(10) NOT NULL DEFAULT '',
  `categorycode` varchar(10) DEFAULT NULL,
  `dateenrolled` date DEFAULT NULL,
  `dateexpiry` date DEFAULT NULL,
  `gonenoaddress` tinyint(1) DEFAULT NULL,
  `gonenoaddresscomment` varchar(255) DEFAULT NULL,
  `lost` tinyint(1) DEFAULT NULL,
  `lostcomment` varchar(255) DEFAULT NULL,
  `debarred` date DEFAULT NULL,
  `debarredcomment` varchar(255) DEFAULT NULL,
  `contactname` mediumtext,
  `contactfirstname` text,
  `contacttitle` text,
  `guarantorid` int(11) DEFAULT NULL,
  `borrowernotes` mediumtext,
  `relationship` varchar(100) DEFAULT NULL,
  `ethnicity` varchar(50) DEFAULT NULL,
  `ethnotes` varchar(255) DEFAULT NULL,
  `sex` varchar(1) DEFAULT NULL,
  `password` varchar(30) DEFAULT NULL,
  `flags` int(11) DEFAULT NULL,
  `userid` varchar(30) DEFAULT NULL,
  `opacnote` mediumtext,
  `contactnote` varchar(255) DEFAULT NULL,
  `sort1` varchar(80) DEFAULT NULL,
  `sort2` varchar(80) DEFAULT NULL,
  `altcontactfirstname` varchar(255) DEFAULT NULL,
  `altcontactsurname` varchar(255) DEFAULT NULL,
  `altcontactaddress1` varchar(255) DEFAULT NULL,
  `altcontactaddress2` varchar(255) DEFAULT NULL,
  `altcontactaddress3` varchar(255) DEFAULT NULL,
  `altcontactzipcode` varchar(50) DEFAULT NULL,
  `altcontactcountry` text,
  `altcontactphone` varchar(50) DEFAULT NULL,
  `smsalertnumber` varchar(50) DEFAULT NULL,
  KEY `borrowernumber` (`borrowernumber`),
  KEY `cardnumber` (`cardnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deletedborrowers`
--

LOCK TABLES `deletedborrowers` WRITE;
/*!40000 ALTER TABLE `deletedborrowers` DISABLE KEYS */;
/*!40000 ALTER TABLE `deletedborrowers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deleteditems`
--

DROP TABLE IF EXISTS `deleteditems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deleteditems` (
  `itemnumber` int(11) NOT NULL DEFAULT '0',
  `biblionumber` int(11) NOT NULL DEFAULT '0',
  `biblioitemnumber` int(11) NOT NULL DEFAULT '0',
  `barcode` varchar(20) DEFAULT NULL,
  `dateaccessioned` date DEFAULT NULL,
  `booksellerid` mediumtext,
  `homebranch` varchar(10) DEFAULT NULL,
  `price` decimal(8,2) DEFAULT NULL,
  `replacementprice` decimal(8,2) DEFAULT NULL,
  `replacementpricedate` date DEFAULT NULL,
  `datelastborrowed` date DEFAULT NULL,
  `datelastseen` date DEFAULT NULL,
  `stack` tinyint(1) DEFAULT NULL,
  `notforloan` tinyint(1) NOT NULL DEFAULT '0',
  `damaged` tinyint(1) NOT NULL DEFAULT '0',
  `itemlost` tinyint(1) NOT NULL DEFAULT '0',
  `wthdrawn` tinyint(1) NOT NULL DEFAULT '0',
  `itemcallnumber` varchar(255) DEFAULT NULL,
  `issues` smallint(6) DEFAULT NULL,
  `renewals` smallint(6) DEFAULT NULL,
  `reserves` smallint(6) DEFAULT NULL,
  `restricted` tinyint(1) DEFAULT NULL,
  `itemnotes` mediumtext,
  `holdingbranch` varchar(10) DEFAULT NULL,
  `paidfor` mediumtext,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `location` varchar(80) DEFAULT NULL,
  `permanent_location` varchar(80) DEFAULT NULL,
  `onloan` date DEFAULT NULL,
  `cn_source` varchar(10) DEFAULT NULL,
  `cn_sort` varchar(30) DEFAULT NULL,
  `ccode` varchar(10) DEFAULT NULL,
  `materials` varchar(10) DEFAULT NULL,
  `uri` varchar(255) DEFAULT NULL,
  `itype` varchar(10) DEFAULT NULL,
  `more_subfields_xml` longtext,
  `enumchron` varchar(80) DEFAULT NULL,
  `copynumber` varchar(32) DEFAULT NULL,
  `stocknumber` varchar(32) DEFAULT NULL,
  `marc` longblob,
  PRIMARY KEY (`itemnumber`),
  KEY `delitembarcodeidx` (`barcode`),
  KEY `delitembinoidx` (`biblioitemnumber`),
  KEY `delitembibnoidx` (`biblionumber`),
  KEY `delhomebranch` (`homebranch`),
  KEY `delholdingbranch` (`holdingbranch`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deleteditems`
--

LOCK TABLES `deleteditems` WRITE;
/*!40000 ALTER TABLE `deleteditems` DISABLE KEYS */;
/*!40000 ALTER TABLE `deleteditems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ethnicity`
--

DROP TABLE IF EXISTS `ethnicity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ethnicity` (
  `code` varchar(10) NOT NULL DEFAULT '',
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ethnicity`
--

LOCK TABLES `ethnicity` WRITE;
/*!40000 ALTER TABLE `ethnicity` DISABLE KEYS */;
/*!40000 ALTER TABLE `ethnicity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `export_format`
--

DROP TABLE IF EXISTS `export_format`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `export_format` (
  `export_format_id` int(11) NOT NULL AUTO_INCREMENT,
  `profile` varchar(255) NOT NULL,
  `description` mediumtext NOT NULL,
  `marcfields` mediumtext NOT NULL,
  `csv_separator` varchar(2) NOT NULL,
  `field_separator` varchar(2) NOT NULL,
  `subfield_separator` varchar(2) NOT NULL,
  `encoding` varchar(255) NOT NULL,
  PRIMARY KEY (`export_format_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Used for CSV export';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `export_format`
--

LOCK TABLES `export_format` WRITE;
/*!40000 ALTER TABLE `export_format` DISABLE KEYS */;
INSERT INTO `export_format` VALUES (1,'ECHANGE','Export pour fichier d\'echange (pret)','Titre=200$a|Auteur=200$f|Editeur=210$c',',','#','|','utf8');
/*!40000 ALTER TABLE `export_format` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fieldmapping`
--

DROP TABLE IF EXISTS `fieldmapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fieldmapping` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `field` varchar(255) NOT NULL,
  `frameworkcode` char(4) NOT NULL DEFAULT '',
  `fieldcode` char(3) NOT NULL,
  `subfieldcode` char(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fieldmapping`
--

LOCK TABLES `fieldmapping` WRITE;
/*!40000 ALTER TABLE `fieldmapping` DISABLE KEYS */;
/*!40000 ALTER TABLE `fieldmapping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hold_fill_targets`
--

DROP TABLE IF EXISTS `hold_fill_targets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hold_fill_targets` (
  `borrowernumber` int(11) NOT NULL,
  `biblionumber` int(11) NOT NULL,
  `itemnumber` int(11) NOT NULL,
  `source_branchcode` varchar(10) DEFAULT NULL,
  `item_level_request` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`itemnumber`),
  KEY `bib_branch` (`biblionumber`,`source_branchcode`),
  KEY `hold_fill_targets_ibfk_1` (`borrowernumber`),
  KEY `hold_fill_targets_ibfk_4` (`source_branchcode`),
  CONSTRAINT `hold_fill_targets_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `hold_fill_targets_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `hold_fill_targets_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `hold_fill_targets_ibfk_4` FOREIGN KEY (`source_branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hold_fill_targets`
--

LOCK TABLES `hold_fill_targets` WRITE;
/*!40000 ALTER TABLE `hold_fill_targets` DISABLE KEYS */;
/*!40000 ALTER TABLE `hold_fill_targets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `import_batches`
--

DROP TABLE IF EXISTS `import_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import_batches` (
  `import_batch_id` int(11) NOT NULL AUTO_INCREMENT,
  `matcher_id` int(11) DEFAULT NULL,
  `template_id` int(11) DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `num_biblios` int(11) NOT NULL DEFAULT '0',
  `num_items` int(11) NOT NULL DEFAULT '0',
  `upload_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `overlay_action` enum('replace','create_new','use_template','ignore') NOT NULL DEFAULT 'create_new',
  `nomatch_action` enum('create_new','ignore') NOT NULL DEFAULT 'create_new',
  `item_action` enum('always_add','add_only_for_matches','add_only_for_new','ignore') NOT NULL DEFAULT 'always_add',
  `import_status` enum('staging','staged','importing','imported','reverting','reverted','cleaned') NOT NULL DEFAULT 'staging',
  `batch_type` enum('batch','z3950') NOT NULL DEFAULT 'batch',
  `file_name` varchar(100) DEFAULT NULL,
  `comments` mediumtext,
  PRIMARY KEY (`import_batch_id`),
  KEY `branchcode` (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `import_batches`
--

LOCK TABLES `import_batches` WRITE;
/*!40000 ALTER TABLE `import_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `import_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `import_biblios`
--

DROP TABLE IF EXISTS `import_biblios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import_biblios` (
  `import_record_id` int(11) NOT NULL,
  `matched_biblionumber` int(11) DEFAULT NULL,
  `control_number` varchar(25) DEFAULT NULL,
  `original_source` varchar(25) DEFAULT NULL,
  `title` varchar(128) DEFAULT NULL,
  `author` varchar(80) DEFAULT NULL,
  `isbn` varchar(30) DEFAULT NULL,
  `issn` varchar(9) DEFAULT NULL,
  `has_items` tinyint(1) NOT NULL DEFAULT '0',
  KEY `import_biblios_ibfk_1` (`import_record_id`),
  KEY `matched_biblionumber` (`matched_biblionumber`),
  KEY `title` (`title`),
  KEY `isbn` (`isbn`),
  CONSTRAINT `import_biblios_ibfk_1` FOREIGN KEY (`import_record_id`) REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `import_biblios`
--

LOCK TABLES `import_biblios` WRITE;
/*!40000 ALTER TABLE `import_biblios` DISABLE KEYS */;
/*!40000 ALTER TABLE `import_biblios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `import_items`
--

DROP TABLE IF EXISTS `import_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import_items` (
  `import_items_id` int(11) NOT NULL AUTO_INCREMENT,
  `import_record_id` int(11) NOT NULL,
  `itemnumber` int(11) DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `status` enum('error','staged','imported','reverted','ignored') NOT NULL DEFAULT 'staged',
  `marcxml` longtext NOT NULL,
  `import_error` mediumtext,
  PRIMARY KEY (`import_items_id`),
  KEY `import_items_ibfk_1` (`import_record_id`),
  KEY `itemnumber` (`itemnumber`),
  KEY `branchcode` (`branchcode`),
  CONSTRAINT `import_items_ibfk_1` FOREIGN KEY (`import_record_id`) REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `import_items`
--

LOCK TABLES `import_items` WRITE;
/*!40000 ALTER TABLE `import_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `import_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `import_record_matches`
--

DROP TABLE IF EXISTS `import_record_matches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import_record_matches` (
  `import_record_id` int(11) NOT NULL,
  `candidate_match_id` int(11) NOT NULL,
  `score` int(11) NOT NULL DEFAULT '0',
  KEY `record_score` (`import_record_id`,`score`),
  CONSTRAINT `import_record_matches_ibfk_1` FOREIGN KEY (`import_record_id`) REFERENCES `import_records` (`import_record_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `import_record_matches`
--

LOCK TABLES `import_record_matches` WRITE;
/*!40000 ALTER TABLE `import_record_matches` DISABLE KEYS */;
/*!40000 ALTER TABLE `import_record_matches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `import_records`
--

DROP TABLE IF EXISTS `import_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import_records` (
  `import_record_id` int(11) NOT NULL AUTO_INCREMENT,
  `import_batch_id` int(11) NOT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `record_sequence` int(11) NOT NULL DEFAULT '0',
  `upload_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `import_date` date DEFAULT NULL,
  `marc` longblob NOT NULL,
  `marcxml` longtext NOT NULL,
  `marcxml_old` longtext NOT NULL,
  `record_type` enum('biblio','auth','holdings') NOT NULL DEFAULT 'biblio',
  `overlay_status` enum('no_match','auto_match','manual_match','match_applied') NOT NULL DEFAULT 'no_match',
  `status` enum('error','staged','imported','reverted','items_reverted','ignored') NOT NULL DEFAULT 'staged',
  `import_error` mediumtext,
  `encoding` varchar(40) NOT NULL DEFAULT '',
  `z3950random` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`import_record_id`),
  KEY `branchcode` (`branchcode`),
  KEY `batch_sequence` (`import_batch_id`,`record_sequence`),
  CONSTRAINT `import_records_ifbk_1` FOREIGN KEY (`import_batch_id`) REFERENCES `import_batches` (`import_batch_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `import_records`
--

LOCK TABLES `import_records` WRITE;
/*!40000 ALTER TABLE `import_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `import_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `issues`
--

DROP TABLE IF EXISTS `issues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `issues` (
  `borrowernumber` int(11) DEFAULT NULL,
  `itemnumber` int(11) DEFAULT NULL,
  `date_due` date DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `issuingbranch` varchar(18) DEFAULT NULL,
  `returndate` date DEFAULT NULL,
  `lastreneweddate` date DEFAULT NULL,
  `return` varchar(4) DEFAULT NULL,
  `renewals` tinyint(4) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `issuedate` date DEFAULT NULL,
  KEY `issuesborridx` (`borrowernumber`),
  KEY `issuesitemidx` (`itemnumber`),
  KEY `bordate` (`borrowernumber`,`timestamp`),
  CONSTRAINT `issues_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `issues_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `issuingrules`
--

DROP TABLE IF EXISTS `issuingrules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `issuingrules` (
  `categorycode` varchar(10) NOT NULL DEFAULT '',
  `itemtype` varchar(10) NOT NULL DEFAULT '',
  `restrictedtype` tinyint(1) DEFAULT NULL,
  `rentaldiscount` decimal(28,6) DEFAULT NULL,
  `reservecharge` decimal(28,6) DEFAULT NULL,
  `fine` decimal(28,6) DEFAULT NULL,
  `finedays` int(11) DEFAULT NULL,
  `firstremind` int(11) DEFAULT NULL,
  `chargeperiod` int(11) DEFAULT NULL,
  `accountsent` int(11) DEFAULT NULL,
  `chargename` varchar(100) DEFAULT NULL,
  `maxissueqty` int(4) DEFAULT NULL,
  `issuelength` int(4) DEFAULT NULL,
  `allowonshelfholds` tinyint(1) DEFAULT NULL,
  `holdrestricted` tinyint(1) DEFAULT NULL,
  `holdspickupdelay` int(11) DEFAULT NULL,
  `renewalsallowed` smallint(6) DEFAULT NULL,
  `reservesallowed` smallint(6) DEFAULT NULL,
  `renewalperiod` smallint(6) DEFAULT NULL,
  `branchcode` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`branchcode`,`categorycode`,`itemtype`),
  KEY `categorycode` (`categorycode`),
  KEY `itemtype` (`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `issuingrules`
--

LOCK TABLES `issuingrules` WRITE;
/*!40000 ALTER TABLE `issuingrules` DISABLE KEYS */;
INSERT INTO `issuingrules` VALUES ('*','*',NULL,NULL,NULL,'10.000000',NULL,10,10,NULL,NULL,10,10,0,NULL,10,10,10,10,'*');
/*!40000 ALTER TABLE `issuingrules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item_circulation_alert_preferences`
--

DROP TABLE IF EXISTS `item_circulation_alert_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_circulation_alert_preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branchcode` varchar(10) NOT NULL,
  `categorycode` varchar(10) NOT NULL,
  `item_type` varchar(10) NOT NULL,
  `notification` varchar(16) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `branchcode` (`branchcode`,`categorycode`,`item_type`,`notification`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_circulation_alert_preferences`
--

LOCK TABLES `item_circulation_alert_preferences` WRITE;
/*!40000 ALTER TABLE `item_circulation_alert_preferences` DISABLE KEYS */;
/*!40000 ALTER TABLE `item_circulation_alert_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items` (
  `itemnumber` int(11) NOT NULL AUTO_INCREMENT,
  `biblionumber` int(11) NOT NULL DEFAULT '0',
  `biblioitemnumber` int(11) NOT NULL DEFAULT '0',
  `barcode` varchar(20) DEFAULT NULL,
  `dateaccessioned` date DEFAULT NULL,
  `booksellerid` mediumtext,
  `homebranch` varchar(10) DEFAULT NULL,
  `price` decimal(8,2) DEFAULT NULL,
  `replacementprice` decimal(8,2) DEFAULT NULL,
  `replacementpricedate` date DEFAULT NULL,
  `datelastborrowed` date DEFAULT NULL,
  `datelastseen` date DEFAULT NULL,
  `stack` tinyint(1) DEFAULT NULL,
  `notforloan` tinyint(1) NOT NULL DEFAULT '0',
  `damaged` tinyint(1) NOT NULL DEFAULT '0',
  `itemlost` tinyint(1) NOT NULL DEFAULT '0',
  `wthdrawn` tinyint(1) NOT NULL DEFAULT '0',
  `itemcallnumber` varchar(255) DEFAULT NULL,
  `issues` smallint(6) DEFAULT NULL,
  `renewals` smallint(6) DEFAULT NULL,
  `reserves` smallint(6) DEFAULT NULL,
  `restricted` tinyint(1) DEFAULT NULL,
  `itemnotes` mediumtext,
  `holdingbranch` varchar(10) DEFAULT NULL,
  `paidfor` mediumtext,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `location` varchar(80) DEFAULT NULL,
  `permanent_location` varchar(80) DEFAULT NULL,
  `onloan` date DEFAULT NULL,
  `cn_source` varchar(10) DEFAULT NULL,
  `cn_sort` varchar(30) DEFAULT NULL,
  `ccode` varchar(10) DEFAULT NULL,
  `materials` varchar(10) DEFAULT NULL,
  `uri` varchar(255) DEFAULT NULL,
  `itype` varchar(10) DEFAULT NULL,
  `more_subfields_xml` longtext,
  `enumchron` varchar(80) DEFAULT NULL,
  `copynumber` varchar(32) DEFAULT NULL,
  `stocknumber` varchar(32) DEFAULT NULL,
  `statisticvalue` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`itemnumber`),
  UNIQUE KEY `itembarcodeidx` (`barcode`),
  KEY `itembinoidx` (`biblioitemnumber`),
  KEY `itembibnoidx` (`biblionumber`),
  KEY `homebranch` (`homebranch`),
  KEY `holdingbranch` (`holdingbranch`),
  KEY `itemsstocknumberidx` (`stocknumber`),
  CONSTRAINT `items_ibfk_1` FOREIGN KEY (`biblioitemnumber`) REFERENCES `biblioitems` (`biblioitemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `items_ibfk_2` FOREIGN KEY (`homebranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE,
  CONSTRAINT `items_ibfk_3` FOREIGN KEY (`holdingbranch`) REFERENCES `branches` (`branchcode`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10000 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `itemtypes`
--

DROP TABLE IF EXISTS `itemtypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `itemtypes` (
  `itemtype` varchar(10) NOT NULL DEFAULT '',
  `description` mediumtext,
  `rentalcharge` double(16,4) DEFAULT NULL,
  `notforloan` smallint(6) DEFAULT NULL,
  `imageurl` varchar(200) DEFAULT NULL,
  `summary` text,
  PRIMARY KEY (`itemtype`),
  UNIQUE KEY `itemtype` (`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `itemtypes`
--

LOCK TABLES `itemtypes` WRITE;
/*!40000 ALTER TABLE `itemtypes` DISABLE KEYS */;
INSERT INTO `itemtypes` VALUES ('ANIM','Outils d\'animation',0.0000,0,NULL,''),('C-D','Compact-Disque',0.0000,0,NULL,''),('DVD','DVD',0.0000,0,NULL,''),('LIV','Livres',0.0000,0,NULL,''),('REL','Ressources Electroniques',0.0000,0,NULL,''),('REV','Revues',0.0000,0,NULL,'');
/*!40000 ALTER TABLE `itemtypes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `language_descriptions`
--

DROP TABLE IF EXISTS `language_descriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language_descriptions` (
  `subtag` varchar(25) DEFAULT NULL,
  `type` varchar(25) DEFAULT NULL,
  `lang` varchar(25) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `lang` (`lang`),
  KEY `subtag_type_lang` (`subtag`,`type`,`lang`)
) ENGINE=InnoDB AUTO_INCREMENT=132 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `language_descriptions`
--

LOCK TABLES `language_descriptions` WRITE;
/*!40000 ALTER TABLE `language_descriptions` DISABLE KEYS */;
INSERT INTO `language_descriptions` VALUES ('opac','i','en','OPAC',1),('opac','i','fr','OPAC',2),('intranet','i','en','Staff Client',3),('intranet','i','fr','????',4),('prog','t','en','Prog',5),('prog','t','fr','Prog',6),('ar','language','ar','&#1575;&#1604;&#1593;&#1585;&#1576;&#1610;&#1577;',7),('ar','language','en','Arabic',8),('ar','language','fr','Arabe',9),('hy','language','hy','&#1344;&#1377;&#1397;&#1381;&#1408;&#1383;&#1398;',10),('hy','language','en','Armenian',11),('hy','language','fr','Armenian',12),('bg','language','bg','&#1041;&#1098;&#1083;&#1075;&#1072;&#1088;&#1089;&#1082;&#1080;',13),('bg','language','en','Bulgarian',14),('bg','language','fr','Bulgare',15),('zh','language','zh','&#20013;&#25991;',16),('zh','language','en','Chinese',17),('zh','language','fr','Chinois',18),('cs','language','cs','&#x010D;e&#353;tina',19),('cs','language','en','Czech',20),('cs','language','fr','Tchèque',21),('da','language','da','D&aelig;nsk',22),('da','language','en','Danish',23),('da','language','fr','Danois',24),('nl','language','nl','ned&#601;rl&#593;ns',25),('nl','language','en','Dutch',26),('nl','language','fr','Néerlandais',27),('en','language','en','English',28),('en','language','fr','Anglais',29),('fi','language','fi','suomi',30),('fi','language','en','Finnish',31),('fr','language','en','French',32),('fr','language','fr','Fran&ccedil;ais',33),('lo','language','lo','&#3742;&#3762;&#3754;&#3762;&#3749;&#3762;&#3751;',34),('lo','language','en','Lao',35),('de','language','de','Deutsch',36),('de','language','en','German',37),('de','language','fr','Allemand',38),('el','language','el','&#949;&#955;&#955;&#951;&#957;&#953;&#954;&#940;',39),('el','language','en','Greek, Modern [1453- ]',40),('el','language','fr','Grec Moderne (Après 1453)',41),('he','language','he','&#1506;&#1489;&#1512;&#1497;&#1514;',42),('he','language','en','Hebrew',43),('he','language','fr','Hébreu',44),('hi','language','hi','&#2361;&#2367;&#2344;&#2381;&#2342;&#2368;',45),('hi','language','en','Hindi',46),('hi','language','fr','Hindi',47),('hu','language','hu','Magyar',48),('hu','language','en','Hungarian',49),('hu','language','fr','Hongrois',50),('id','language','id','Bahasa Indonesia',51),('id','language','en','Indonesian',52),('id','language','fr','Indonésien',53),('it','language','it','Italiano',54),('it','language','en','Italian',55),('it','language','fr','Italien',56),('ja','language','ja','&#26085;&#26412;&#35486;',57),('ja','language','en','Japanese',58),('ja','language','fr','Japonais',59),('ko','language','ko','&#54620;&#44397;&#50612;',60),('ko','language','en','Korean',61),('ko','language','fr','Coréen',62),('la','language','la','Latina',63),('la','language','en','Latin',64),('la','language','fr','Latin',65),('gl','language','gl','Galego',66),('gl','language','en','Galician',67),('nb','language','nb','Norsk',68),('nb','language','en','Norwegian',69),('nb','language','fr','Norvégien',70),('fa','language','fa','&#1601;&#1575;&#1585;&#1587;&#1609;',71),('fa','language','en','Persian',72),('fa','language','fr','Persan',73),('pl','language','pl','Polski',74),('pl','language','en','Polish',75),('pl','language','fr','Polonais',76),('pt','language','pt','Portugu&ecirc;s',77),('pt','language','en','Portuguese',78),('pt','language','fr','Portugais',79),('ro','language','ro','Rom&acirc;n&#259;',80),('ro','language','en','Romanian',81),('ro','language','fr','Roumain',82),('ru','language','ru','&#1056;&#1091;&#1089;&#1089;&#1082;&#1080;&#1081;',83),('ru','language','en','Russian',84),('ru','language','fr','Russe',85),('sr','language','sr','&#1089;&#1088;&#1087;&#1089;&#1082;&#1080;',86),('sr','language','en','Serbian',87),('es','language','es','Espa&ntilde;ol',88),('es','language','en','Spanish',89),('es','language','fr','Espagnol',90),('sv','language','sv','Svenska',91),('sv','language','en','Swedish',92),('sv','language','fr','Suédois',93),('tet','language','tet','tetun',94),('tet','language','en','Tetum',95),('th','language','th','&#3616;&#3634;&#3625;&#3634;&#3652;&#3607;&#3618;',96),('th','language','en','Thai',97),('th','language','fr','Thaï',98),('tr','language','tr','T&uuml;rk&ccedil;e',99),('tr','language','en','Turkish',100),('tr','language','fr','Turc',101),('uk','language','uk','&#1059;&#1082;&#1088;&#1072;&#1111;&#1085;&#1089;&#1100;&#1082;&#1072;',102),('uk','language','en','Ukranian',103),('uk','language','fr','Ukrainien',104),('ur','language','en','Urdu',105),('ur','language','ur','&#1575;&#1585;&#1583;&#1608;',106),('Arab','script','Arab','&#1575;&#1604;&#1593;&#1585;&#1576;&#1610;&#1577;',107),('Arab','script','en','Arabic',108),('Arab','script','fr','Arabic',109),('Cyrl','script','Cyrl','????',110),('Cyrl','script','en','Cyrillic',111),('Cyrl','script','fr','Cyrillic',112),('Grek','script','Grek','????',113),('Grek','script','en','Greek',114),('Grek','script','fr','Greek',115),('Hans','script','Hans','Han (Simplified variant)',116),('Hans','script','en','Han (Simplified variant)',117),('Hans','script','fr','Han (Simplified variant)',118),('Hant','script','Hant','Han (Traditional variant)',119),('Hant','script','en','Han (Traditional variant)',120),('Hebr','script','Hebr','Hebrew',121),('Hebr','script','en','Hebrew',122),('Laoo','script','lo','Lao',123),('Laoo','script','en','Lao',124),('CA','region','en','Canada',125),('DK','region','dk','Danmark',126),('FR','region','fr','France',127),('FR','region','en','France',128),('NZ','region','en','New Zealand',129),('GB','region','en','United Kingdom',130),('US','region','en','United States',131);
/*!40000 ALTER TABLE `language_descriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `language_rfc4646_to_iso639`
--

DROP TABLE IF EXISTS `language_rfc4646_to_iso639`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language_rfc4646_to_iso639` (
  `rfc4646_subtag` varchar(25) DEFAULT NULL,
  `iso639_2_code` varchar(25) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `rfc4646_subtag` (`rfc4646_subtag`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `language_rfc4646_to_iso639`
--

LOCK TABLES `language_rfc4646_to_iso639` WRITE;
/*!40000 ALTER TABLE `language_rfc4646_to_iso639` DISABLE KEYS */;
INSERT INTO `language_rfc4646_to_iso639` VALUES ('ar','ara',1),('hy','hy',2),('bg','bul',3),('zh','chi',4),('cs','cze',5),('da','dan',6),('nl','dut',7),('en','en',8),('fr','fr',9),('de','ger',10),('el','gre',11),('he','heb',12),('hi','hin',13),('hu','hun',14),('id','ind',15),('it','ind',16),('ja','jpn',17),('ko','kor',18),('la','lat',19),('gl','glg',20),('nb','nor',21),('fa','per',22),('pl','pol',23),('pt','por',24),('ro','rum',25),('ru','rus',26),('es','spa',27),('sv','swe',28),('th','tha',29),('tr','tur',30),('uk','ukr',31);
/*!40000 ALTER TABLE `language_rfc4646_to_iso639` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `language_script_bidi`
--

DROP TABLE IF EXISTS `language_script_bidi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language_script_bidi` (
  `rfc4646_subtag` varchar(25) DEFAULT NULL,
  `bidi` varchar(3) DEFAULT NULL,
  KEY `rfc4646_subtag` (`rfc4646_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `language_script_bidi`
--

LOCK TABLES `language_script_bidi` WRITE;
/*!40000 ALTER TABLE `language_script_bidi` DISABLE KEYS */;
INSERT INTO `language_script_bidi` VALUES ('Arab','rtl'),('Hebr','rtl');
/*!40000 ALTER TABLE `language_script_bidi` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `language_script_mapping`
--

DROP TABLE IF EXISTS `language_script_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language_script_mapping` (
  `language_subtag` varchar(25) DEFAULT NULL,
  `script_subtag` varchar(25) DEFAULT NULL,
  KEY `language_subtag` (`language_subtag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `language_script_mapping`
--

LOCK TABLES `language_script_mapping` WRITE;
/*!40000 ALTER TABLE `language_script_mapping` DISABLE KEYS */;
INSERT INTO `language_script_mapping` VALUES ('ar','Arab'),('he','Hebr');
/*!40000 ALTER TABLE `language_script_mapping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `language_subtag_registry`
--

DROP TABLE IF EXISTS `language_subtag_registry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language_subtag_registry` (
  `subtag` varchar(25) DEFAULT NULL,
  `type` varchar(25) DEFAULT NULL,
  `description` varchar(25) DEFAULT NULL,
  `added` date DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `subtag` (`subtag`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `language_subtag_registry`
--

LOCK TABLES `language_subtag_registry` WRITE;
/*!40000 ALTER TABLE `language_subtag_registry` DISABLE KEYS */;
INSERT INTO `language_subtag_registry` VALUES ('opac','i','OPAC','2005-10-16',1),('intranet','i','Staff Client','2005-10-16',2),('prog','t','Prog','2005-10-16',3),('ar','language','Arabic','2005-10-16',4),('hy','language','Armenian','2005-10-16',5),('bg','language','Bulgarian','2005-10-16',6),('zh','language','Chinese','2005-10-16',7),('cs','language','Czech','2005-10-16',8),('da','language','Danish','2005-10-16',9),('nl','language','Dutch','2005-10-16',10),('en','language','English','2005-10-16',11),('fi','language','Finnish','2005-10-16',12),('fr','language','French','2005-10-16',13),('lo','language','Lao','2005-10-16',14),('de','language','German','2005-10-16',15),('el','language','Greek, Modern [1453- ]','2005-10-16',16),('he','language','Hebrew','2005-10-16',17),('hi','language','Hindi','2005-10-16',18),('hu','language','Hungarian','2005-10-16',19),('id','language','Indonesian','2005-10-16',20),('it','language','Italian','2005-10-16',21),('ja','language','Japanese','2005-10-16',22),('ko','language','Korean','2005-10-16',23),('la','language','Latin','2005-10-16',24),('gl','language','Galician','2005-10-16',25),('nb','language','Norwegian','2005-10-16',26),('fa','language','Persian','2005-10-16',27),('pl','language','Polish','2005-10-16',28),('pt','language','Portuguese','2005-10-16',29),('ro','language','Romanian','2005-10-16',30),('ru','language','Russian','2005-10-16',31),('sr','language','Serbian','2005-10-16',32),('es','language','Spanish','2005-10-16',33),('sv','language','Swedish','2005-10-16',34),('tet','language','Tetum','2005-10-16',35),('th','language','Thai','2005-10-16',36),('tr','language','Turkish','2005-10-16',37),('uk','language','Ukranian','2005-10-16',38),('ur','language','Urdu','2005-10-16',39),('Arab','script','Arabic','2005-10-16',40),('Cyrl','script','Cyrillic','2005-10-16',41),('Grek','script','Greek','2005-10-16',42),('Hans','script','Han (Simplified variant)','2005-10-16',43),('Hant','script','Han (Traditional variant)','2005-10-16',44),('Hebr','script','Hebrew','2005-10-16',45),('Laoo','script','Lao','2005-10-16',46),('CA','region','Canada','2005-10-16',47),('DK','region','Denmark','2005-10-16',48),('FR','region','France','2005-10-16',49),('NZ','region','New Zealand','2005-10-16',50),('GB','region','United Kingdom','2005-10-16',51),('US','region','United States','2005-10-16',52);
/*!40000 ALTER TABLE `language_subtag_registry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `letter`
--

DROP TABLE IF EXISTS `letter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `letter` (
  `module` varchar(20) NOT NULL DEFAULT '',
  `code` varchar(20) NOT NULL DEFAULT '',
  `name` varchar(100) NOT NULL DEFAULT '',
  `title` varchar(200) NOT NULL DEFAULT '',
  `content` text,
  PRIMARY KEY (`module`,`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `letter`
--

LOCK TABLES `letter` WRITE;
/*!40000 ALTER TABLE `letter` DISABLE KEYS */;
INSERT INTO `letter` VALUES ('circulation','CHECKIN','Item Check-in (Digest)','Check-ins','The following items have been checked in:\r\n----\r\n<<biblio.title>>\r\n----\r\nThank you.'),('circulation','CHECKOUT','Item Check-out (Digest)','Checkouts','The following items have been checked out:\r\n----\r\n<<biblio.title>>\r\n----\r\nThank you for visiting <<branches.branchname>>.'),('circulation','DUE','Item Due Reminder','Item Due Reminder','Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nThe following item is now due:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)'),('circulation','DUEDGST','Item Due Reminder (Digest)','Item Due Reminder','You have <<count>> items due'),('circulation','EVENT','Upcoming Library Event','Upcoming Library Event','Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nThis is a reminder of an upcoming library event in which you have expressed interest.'),('circulation','ODUE','Overdue Notice','Item Overdue','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nAccording to our current records, you have items that are overdue.Your library does not charge late fines, but please return or renew them at the branch below as soon as possible.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPhone: <<branches.branchphone>>\nFax: <<branches.branchfax>>\nEmail: <<branches.branchemail>>\n\nIf you have registered a password with the library, and you have a renewal available, you may renew online. If an item becomes more than 30 days overdue, you will be unable to use your library card until the item is returned.\n\nThe following item(s) is/are currently overdue:\n\n<item>\"<<biblio.title>>\" by <<biblio.author>>, <<items.itemcallnumber>>, Barcode: <<items.barcode>> Fine: <fine>GBP</fine></item>\n\nThank-you for your prompt attention to this matter.\n\n<<branches.branchname>> Staff\n'),('circulation','PREDUE','Advance Notice of Item Due','Advance Notice of Item Due','Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nThe following item will be due soon:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)'),('circulation','PREDUEDGST','Advance Notice of Item Due (Digest)','Advance Notice of Item Due','You have <<count>> items due soon'),('claimacquisition','ACQCLAIM','Acquisition Claim','Item Not Received','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\nOrdernumber <<aqorders.ordernumber>> (<<aqorders.title>>) (<<aqorders.quantity>> ordered) ($<<aqorders.listprice>> each) has not been received.'),('members','ACCTDETAILS','Account Details Template - DEFAULT','Your new Koha account details.','Hello <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\nYour new Koha account details are:\r\n\r\nUser:  <<borrowers.userid>>\r\nPassword: <<borrowers.password>>\r\n\r\nIf you have any problems or questions regarding your account, please contact your Koha Administrator.\r\n\r\nThank you,\r\nKoha Administrator\r\nkohaadmin@yoursite.org'),('reserves','HOLD','Hold Available for Pickup','Hold Available for Pickup at <<branches.branchname>>','Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nYou have a hold available for pickup as of <<reserves.waitingdate>>:\r\n\r\nTitle: <<biblio.title>>\r\nAuthor: <<biblio.author>>\r\nCopy: <<items.copynumber>>\r\nLocation: <<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>\r\n<<branches.branchcity>> <<branches.branchzip>>'),('reserves','HOLDPLACED','Hold Placed on Item','Hold Placed on Item','A hold has been placed on the following item : <<title>> (<<biblionumber>>) by the user <<firstname>> <<surname>> (<<cardnumber>>).'),('reserves','HOLD_PRINT','Hold Available for Pickup (print notice)','Hold Available for Pickup (print notice)','<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>>\n\n\nChange Service Requested\n\n\n\n\n\n\n\n<<borrowers.firstname>> <<borrowers.surname>>\n<<borrowers.address>>\n<<borrowers.city>> <<borrowers.zipcode>>\n\n\n\n\n\n\n\n\n\n\n<<borrowers.firstname>> <<borrowers.surname>>\n<<borrowers.cardnumber>>\n\nYou have a hold available for pickup as of <<reserves.waitingdate>>:\r\n\r\nTitle: <<biblio.title>>\r\nAuthor: <<biblio.author>>\r\nCopy: <<items.copynumber>>\r\n'),('serial','RLIST','Routing List','Serial is now available','<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nThe following issue is now available:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)\r\n\r\nPlease pick it up at your convenience.');
/*!40000 ALTER TABLE `letter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marc_matchers`
--

DROP TABLE IF EXISTS `marc_matchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marc_matchers` (
  `matcher_id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(10) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  `record_type` varchar(10) NOT NULL DEFAULT 'biblio',
  `threshold` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`matcher_id`),
  KEY `code` (`code`),
  KEY `record_type` (`record_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marc_matchers`
--

LOCK TABLES `marc_matchers` WRITE;
/*!40000 ALTER TABLE `marc_matchers` DISABLE KEYS */;
/*!40000 ALTER TABLE `marc_matchers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marc_subfield_structure`
--

DROP TABLE IF EXISTS `marc_subfield_structure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marc_subfield_structure` (
  `tagfield` varchar(3) NOT NULL DEFAULT '',
  `tagsubfield` varchar(1) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  `liblibrarian` varchar(255) NOT NULL DEFAULT '',
  `libopac` varchar(255) NOT NULL DEFAULT '',
  `repeatable` tinyint(4) NOT NULL DEFAULT '0',
  `mandatory` tinyint(4) NOT NULL DEFAULT '0',
  `kohafield` varchar(40) DEFAULT NULL,
  `tab` tinyint(1) DEFAULT NULL,
  `authorised_value` varchar(20) DEFAULT NULL,
  `authtypecode` varchar(20) DEFAULT NULL,
  `value_builder` varchar(80) DEFAULT NULL,
  `isurl` tinyint(1) DEFAULT NULL,
  `hidden` tinyint(1) DEFAULT NULL,
  `frameworkcode` varchar(4) NOT NULL DEFAULT '',
  `seealso` varchar(1100) DEFAULT NULL,
  `link` varchar(80) DEFAULT NULL,
  `defaultvalue` text,
  PRIMARY KEY (`frameworkcode`,`tagfield`,`tagsubfield`),
  KEY `kohafield_2` (`kohafield`),
  KEY `tab` (`frameworkcode`,`tab`),
  KEY `kohafield` (`frameworkcode`,`kohafield`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marc_subfield_structure`
--

LOCK TABLES `marc_subfield_structure` WRITE;
/*!40000 ALTER TABLE `marc_subfield_structure` DISABLE KEYS */;
INSERT INTO `marc_subfield_structure` VALUES ('000','@','leader','',0,0,'',0,'','','unimarc_leader.pl',NULL,0,'','',NULL,''),('001','@','Numéro d&#39;identification notice','',0,0,'',0,'','','',NULL,0,'','',NULL,''),('005','@','Numéro d\'identification de la version','',0,0,'',0,'','','',0,0,'',NULL,'',''),('010','a','ISBN','ISBN',0,0,'biblioitems.isbn',0,'','','',0,0,'',NULL,'',''),('010','b','qualificatif','',1,0,'',0,'','','',0,0,'',NULL,'',''),('010','d','disponibilité et/ou prix','',0,0,'',0,'','','',0,0,'',NULL,'',''),('010','z','ISBN erroné','',1,0,'',0,'','','',0,0,'',NULL,'',''),('011','a','ISSN','ISSN',0,0,'biblioitems.issn',0,'','','',0,0,'',NULL,'',''),('011','b','qualificatif','',0,0,'',0,'','','',0,0,'',NULL,'',''),('011','d','disponibilité et/ou prix','',1,0,'',0,'','','',0,0,'',NULL,'',''),('011','y','ISSN annulé','',1,0,'',0,'','','',0,0,'',NULL,'',''),('011','z','ISSN erroné','',1,0,'',0,'','','',0,0,'',NULL,'',''),('012','2','code du système utilisé pour l\'empreinte','',0,0,'',0,'','','',0,0,'',NULL,'',''),('012','5','institution à laquelle s\'applique cette zone','',1,0,'',0,'','','',0,0,'',NULL,'',''),('012','a','empreinte','',0,0,'',0,'','','',0,0,'',NULL,'',''),('013','a','numéro ISMN','ISMN',0,0,'',0,'','','',0,0,'',NULL,'',''),('013','b','qualificatif','',0,0,'',0,'','','',0,0,'',NULL,'',''),('013','d','disponibilté et/ou prix','',0,0,'',0,'','','',0,0,'',NULL,'',''),('013','z','ISMN erroné','',1,0,'',0,'','','',0,0,'',NULL,'',''),('014','2','système de codification','',0,0,'',0,'','','',0,0,'',NULL,'',''),('014','a','numéro d\'article','',0,0,'',0,'','','',0,0,'',NULL,'',''),('014','z','numéro d\'article erroné','',1,0,'',-1,'','','',0,0,'',NULL,'',''),('015','a','Numéro (ISRN)','ISRN',0,0,'',0,'','','',0,0,'',NULL,'',''),('015','b','Qualificatif','',1,0,'',0,'','','',0,0,'',NULL,'',''),('015','d','Mention de disponibilité et/ou de prix','',0,0,'',0,'','','',0,0,'',NULL,'',''),('015','z','ISRN annulé, invalide ou erroné','',0,0,'',0,'','','',0,0,'',NULL,'',''),('016','a','Numéro normalisé (ISRC)','ISRC',0,0,'',0,'','','',0,0,'',NULL,'',''),('016','b','Qualificatif','',1,0,'',0,'','','',0,0,'',NULL,'',''),('016','d','Disponibilité et/ou prix','',0,0,'',0,'','','',0,0,'',NULL,'',''),('016','z','ISRC erroné','',0,0,'',0,'','','',0,0,'',NULL,'',''),('017','2','Source du code','',0,0,'',0,'','','',0,0,'',NULL,'',''),('017','a','Numéro normalisé','',0,0,'',0,'','','',0,0,'',NULL,'',''),('017','b','qualificatif','',1,0,'',0,'','','',0,0,'',NULL,'',''),('017','d','Mention de disponibilité et/ou de prix','',0,0,'',0,'','','',0,0,'',NULL,'',''),('017','z','Numéro erroné','',0,0,'',0,'','','',0,0,'',NULL,'',''),('020','a','code de pays','',0,0,'',0,'COUNTRY','','',0,0,'',NULL,'',''),('020','b','numéro','',0,0,'',0,'','','',0,0,'',NULL,'',''),('020','z','numéro erroné','',1,0,'',0,'','','',0,0,'',NULL,'',''),('021','a','code de pays','',0,0,'',0,'COUNTRY','','',0,0,'',NULL,'',''),('021','b','numéro','',0,0,'',0,'','','',0,0,'',NULL,'',''),('021','z','numéro erroné','',1,0,'',0,'','','',0,0,'',NULL,'',''),('022','a','code de pays','',0,0,'',0,'COUNTRY','','',0,0,'',NULL,'',''),('022','b','numéro','',0,0,'',0,'','','',0,0,'',NULL,'',''),('022','z','numéro erroné','',1,0,'',0,'','','',0,0,'',NULL,'',''),('035','a','Numéro de contrôle','',0,0,'',0,'','','',0,0,'',NULL,'',''),('035','z','Numéro erroné ou annulé','',1,0,'',0,'','','',0,0,'',NULL,'',''),('036','2','Système de codage de l\'incipit musical','',0,0,'',0,'','','',0,0,'',NULL,'',''),('036','a','Numérotation de l\'oeuvre dans un ensemble','',0,0,'',0,'','','',0,0,'',NULL,'',''),('036','b','Numérotation du mouvement','Numérotation du mouvement',1,0,'',0,'','','',1,0,'',NULL,'',''),('036','c','Numérotation de l\'incipit','Numérotation de l\'incipit',0,0,'',0,'','','',0,0,'',NULL,'',''),('036','d','Voix/instrument','Voix/instrument',0,0,'',0,'','','',0,0,'',NULL,'',''),('036','e','Rôle','Rôle',0,0,'',0,'','','',0,0,'',NULL,'',''),('036','f','Titre ou intitulé du mouvement','Titre ou intitulé du mouvement',0,0,'',0,'','','',0,0,'',NULL,'',''),('036','g','Tonalité ou mode','Tonalité ou mode',0,0,'',0,'','','',0,0,'',NULL,'',''),('036','m','Clef','Clef',0,0,'',0,'','','',0,0,'',NULL,'',''),('036','n','Armure','Armure',0,0,'',0,'','','',0,0,'',NULL,'',''),('036','o','Chiffre de mesure','Mesure',0,0,'',0,'','','',0,0,'',NULL,'',''),('036','p','Incipit codé','',0,0,'',0,'','','',0,0,'',NULL,'',''),('036','q','Commentaires (texte libre)','',0,0,'',0,'','','',0,0,'',NULL,'',''),('036','r','Précision codée','',0,0,'',0,'','','',0,0,'',NULL,'',''),('036','t','Incipit textuel','',1,0,'',0,'','','',0,0,'',NULL,'',''),('036','u','Uniform Resource Identifier','',1,0,'',0,'','','',0,0,'',NULL,'',''),('036','z','Langue du texte','',1,0,'',0,'','','',0,0,'',NULL,'',''),('040','a','coden','',0,0,'',0,'','','',NULL,0,'','',NULL,''),('040','z','coden erroné','',1,0,'',0,'','','',NULL,0,'','',NULL,''),('071','a','numéro d\'éditeur (enregistrements sonores et musique imprimée)','',0,0,'',0,'','','',0,0,'',NULL,'',''),('071','b','source','',0,0,'',0,'','','',0,0,'',NULL,'',''),('071','c','Qualificatif','',0,0,'',0,'','','',0,0,'',NULL,'',''),('071','d','Disponibilité et/ou prix','',0,0,'',0,'','','',0,0,'',NULL,'',''),('071','z','Numéro d\'éditeur erroné','',0,0,'',0,'','','',0,0,'',NULL,'',''),('072','a','Numéro normalisé','',0,0,'',0,'','','',0,0,'',NULL,'',''),('072','b','Qualificatif','',0,0,'',0,'','','',0,0,'',NULL,'',''),('072','c','Numéro additionnels suivant le code normalisé','',0,0,'',0,'','','',0,0,'',NULL,'',''),('072','d','Mention de disponibilité et/ou de prix','',0,0,'',0,'','','',0,0,'',NULL,'',''),('072','z','Numéro ou code erroné','',0,0,'',0,'','','',0,0,'',NULL,'',''),('073','a','Numéro','',0,0,'',0,'','','',NULL,0,'','',NULL,''),('073','b','Qualificatif','',0,0,'',0,'','','',NULL,0,'','',NULL,''),('073','c','Numéros additionnels','',0,0,'',0,'','','',NULL,0,'','',NULL,''),('073','d','Prix et disponibilité','',0,0,'',0,'','','',NULL,0,'','',NULL,''),('073','z','Numéro erroné','',0,0,'',0,'','',NULL,NULL,0,'','',NULL,''),('090','9','Numéro biblio (koha)','Numéro biblio (koha)',0,0,'',-1,'','','',NULL,0,'','',NULL,''),('090','a','Numéro biblioitem (koha)','',0,0,'',-1,'','','',NULL,0,'','',NULL,''),('099','c','date creation notice (koha)','',0,0,'biblio.datecreated',-1,'','','',0,0,'',NULL,'',''),('099','d','date modification notice (koha)','',0,0,'biblio.timestamp',-1,'','','',0,0,'',NULL,'',''),('099','s','Notice de titre de périodique','Notice de titre de périodique ',0,0,'',0,'','','',0,0,'',NULL,'',''),('100','a','données générales de traitement','',0,1,'',1,'','','unimarc_field_100.pl',NULL,0,'','',NULL,''),('101','a','langue du document','',1,1,'',1,'','','',0,0,'',NULL,'',''),('101','b','langue de la traduction intermédiaire','',1,0,'',1,'','','',0,0,'',NULL,'',''),('101','c','langue de l\'oeuvre originale','',1,0,'',1,'','','',0,0,'',NULL,'',''),('101','d','langue du résumé','',1,0,'',1,'','','',0,0,'',NULL,'',''),('101','e','langue de la table des matières','',1,0,'',1,'','','',0,0,'',NULL,'',''),('101','f','page de titre si elle diffère de celle du texte','',1,0,'',1,'','','',0,0,'',NULL,'',''),('101','g','langue du titre propre si elle diffère de la langue du texte ou de la bande son','',0,0,'',1,'','','',0,0,'',NULL,'',''),('101','h','langue d\'un livret','',1,0,'',1,'','','',0,0,'',NULL,'',''),('101','i','langue des textes d\'accompagnement','',1,0,'',1,'','','',0,0,'',NULL,'',''),('101','j','langue des sous-titres','',1,0,'',1,'','','',0,0,'',NULL,'',''),('102','2','Source du code non-ISO','',0,0,'',1,'','','',0,0,'',NULL,'',''),('102','a','pays de publication','pays de publication',1,0,'',1,'COUNTRY','','',0,0,'',NULL,'',''),('102','b','lieu  de publication (code non-ISO)','',1,0,'',1,'','','',0,0,'',NULL,'',''),('102','c','Lieu de publication (code ISO)','',0,0,'',1,'','','',0,0,'',NULL,'',''),('105','a','données codées - monographies','',0,0,'',1,'','','unimarc_field_105.pl',NULL,0,'','',NULL,''),('106','a','données codées -  textes - caractéristiques physiques','',0,0,'',1,'','','unimarc_field_106.pl',NULL,0,'','',NULL,''),('110','a','données codées pour les périodiques','',0,0,'',1,'','','unimarc_field_110.pl',NULL,0,'','',NULL,''),('115','a','données codées Généralités','',0,0,'',1,'','','unimarc_field_115a.pl',0,0,'',NULL,'',''),('115','b','données codées sur les archives de films','',0,0,'',1,'','','unimarc_field_115b.pl',0,0,'',NULL,'',''),('116','a','données codées de documents graphiques','',1,0,'',1,'','','unimarc_field_116.pl',0,0,'',NULL,'',''),('117','a','données codées de documents pour les objets en trois dimensions et artefacts','',0,0,'',1,'','','unimarc_field_117.pl',0,0,'',NULL,'',''),('120','a','données codées sur les documents cartographiques-généralités','',0,0,'',1,'','','unimarc_field_120.pl',0,0,'',NULL,'',''),('121','a','documents cartographiques-caractéristiques physiques','',0,0,'',1,'','','unimarc_field_121a.pl',0,0,'',NULL,'',''),('121','b','données codées : photographie aérienne et télédetection - caractéristiques physiques','',0,0,'',1,'','','unimarc_field_121b.pl',0,0,'',NULL,'',''),('122','a','Période  : de 9999 avant J.C. à nos jours','',0,0,'',1,'','','unimarc_field_122.pl',0,0,'',NULL,'',''),('123','a','type d\'échelle','',0,0,'',1,'','','unimarc_field_123a.pl',0,0,'',NULL,'',''),('123','b','échelle horizontale à taux linéaire constant','',0,0,'',1,'','','',0,0,'',NULL,'',''),('123','c','échelle horizontale à taux linéaire constant (échelle altimétrique)','',1,0,'',1,'','','',0,0,'',NULL,'',''),('123','d','coordonnées - longitude ouest','',0,0,'',1,'','','unimarc_field_123d.pl',0,0,'',NULL,'',''),('123','e','coordonnées - longitude est','',0,0,'',1,'','','unimarc_field_123e.pl',0,0,'',NULL,'',''),('123','f','coordonnées - longitude nord','',0,0,'',1,'','','unimarc_field_123f.pl',0,0,'',NULL,'',''),('123','g','coordonnées - longitude sud','',0,0,'',1,'','','unimarc_field_123g.pl',0,0,'',NULL,'',''),('123','h','échelle angulaire','',1,0,'',1,'','','',0,0,'',NULL,'',''),('123','i','déclinaison - limite nord','',0,0,'',1,'','','unimarc_field_123i.pl',0,0,'',NULL,'',''),('123','j','déclinaison - limite sud','',0,0,'',1,'','','unimarc_field_123j.pl',0,0,'',NULL,'',''),('123','k','ascension droite - limite est','',0,0,'',1,'','','',0,0,'',NULL,'',''),('123','m','ascension droite - limite ouest','',0,0,'',1,'','','',0,0,'',NULL,'',''),('123','n','equinoxe','',0,0,'',1,'','','',0,0,'',NULL,'',''),('123','o','époque','',0,0,'',1,'','','',0,0,'',NULL,'',''),('123','p','planète à laquelle s\'applique la zone','',0,0,'',1,'','','',0,0,'',NULL,'',''),('124','a','origine de l\'image','',0,0,'',1,'','','unimarc_field_124a.pl',0,0,'',NULL,'',''),('124','b','forme du document cartographique','',1,0,'',1,'','','unimarc_field_124b.pl',0,0,'',NULL,'',''),('124','c','présentation technique dans le cas d\'images photographiques ou non photographiques','',1,0,'',1,'','','unimarc_field_124c.pl',0,0,'',NULL,'',''),('124','d','position de la base pourles images photographiques ou de télédétection','',1,0,'',1,'','','unimarc_field_124d.pl',0,0,'',NULL,'',''),('124','e','catégorie de satellite pour la télédétection','',1,0,'',1,'','','unimarc_field_124e.pl',0,0,'',NULL,'',''),('124','f','nom du satellite pour la télédétection','',1,0,'',1,'','','unimarc_field_124f.pl',0,0,'',NULL,'',''),('124','g','technique d\'enregistrement pour les images de télédétection','',1,0,'',1,'','','unimarc_field_124g.pl',0,0,'',NULL,'',''),('125','a','nature de la musique imprimée','',0,0,'',1,'','','unimarc_field_125a.pl',0,0,'',NULL,'',''),('125','b','type de texte écrit (enregistrements parlés)','',0,0,'',1,'','','unimarc_field_125b.pl',0,0,'',NULL,'',''),('125','c','présentations musicales multiples','',0,0,'',1,'','','',0,0,'',NULL,'',''),('126','a','données codées pour les enregistrements sonores (généralités)','',1,0,'',1,'','','unimarc_field_126a.pl',0,0,'',NULL,'',''),('126','b','données codées pour les enregistrements sonores (particularités)','',0,0,'',1,'','','unimarc_field_126b.pl',0,0,'',NULL,'',''),('127','a','durée','',1,0,'',1,'','','',0,0,'',NULL,'',''),('128','a','forme de la composition (interprétation musicale ou partition)','',1,0,'',1,'','','unimarc_field_128a.pl',0,0,'',NULL,'',''),('128','b','instruments ou voix dans un ensemble (interprétation musicale ou partition)','',0,1,'',-1,'','','',0,0,'',NULL,'',''),('128','c','instruments ou voix pour soliste (interprétation musicale ou partition)','',0,0,'',-1,'','','',0,0,'',NULL,'',''),('128','d','modalité ou mode de l\'oeuvre musicale','',0,0,'',1,'','','',0,0,'',NULL,'',''),('130','a','données codées de documents : Microformes-caractéristiques physiques','',0,0,'',1,'','','unimarc_field_130.pl',0,0,'',NULL,'',''),('131','a','ellipsoïde','',1,0,'',1,'','','',0,0,'',NULL,'',''),('131','b','données horizontales','',1,0,'',1,'','','',0,0,'',NULL,'',''),('131','c','quadrillage et système de référence','',1,0,'',1,'','','',0,0,'',NULL,'',''),('131','d','recouvrement et système de référence','',1,0,'',1,'','','',0,0,'',NULL,'',''),('131','e','quadrillage et système de référence secondaire','',1,0,'',1,'','','',0,0,'',NULL,'',''),('131','f','données verticales','',1,0,'',1,'','','',0,0,'',NULL,'',''),('131','g','unité de mesure pour l\'altitude','',1,0,'',1,'','','',0,0,'',NULL,'',''),('131','h','intervalle des courbes de niveau','',1,0,'',1,'','','',0,0,'',NULL,'',''),('131','i','intervalle des courbes de niveau supplémentaires','',1,0,'',1,'','','',0,0,'',NULL,'',''),('131','j','unité de mesure de bathymétrie','',1,0,'',1,'','','',0,0,'',NULL,'',''),('131','k','intervalle bathymétrique','',1,0,'',1,'','','',0,0,'',NULL,'',''),('131','l','intervalle bathymétrique supplémentaire','',1,0,'',1,'','','',0,0,'',NULL,'',''),('135','a','données codées : ressources électroniques','',0,0,'',1,'','','unimarc_field_135a.pl',0,0,'',NULL,'',''),('140','a','données codées : livres anciens - généralités','',0,0,'',1,'','','unimarc_field_140.pl',0,0,'',NULL,'',''),('141','5','institution à laquelle cette zone s\'applique','',0,0,'',-1,'','','',0,0,'',NULL,'',''),('141','a','données codées pour le livre ancien - caractères de l\'exemplaire','',0,0,'',1,'','','unimarc_field_141.pl',0,0,'',NULL,'',''),('141','b','particularités de la reliure','',0,0,'',1,'','','',0,0,'',NULL,'',''),('145','a','type d\'exécution','',0,0,'',1,'','','',0,0,'',NULL,'',''),('145','b','Instrument/voix, chef d\'orchestre ou de choeur, autre éxecutant ou dispositif','',1,0,'',1,'','','',0,0,'',NULL,'',''),('145','c','type d\'ensemble','',0,0,'',1,'','','',0,0,'',NULL,'',''),('145','d','groupe à l\'intérieur d\'un ensemble plus large','',0,0,'',1,'','','',0,0,'',NULL,'',''),('145','e','nombre de parties','',0,0,'',1,'','','',0,0,'',NULL,'',''),('145','f','nombre d\'exécutants','',0,0,'',1,'','','',0,0,'',NULL,'',''),('200','5','nom de l\'institution à laquelle s\'applique cette zone','',0,0,'',-1,'','','',0,0,'',NULL,'',''),('200','a','titre propre','',1,1,'biblio.title',2,'','','',0,0,'',NULL,'',''),('200','b','type de document','',1,1,'biblioitems.itemtype',2,'itemtypes','','',0,0,'',NULL,'',''),('200','c','titre propre d\'un auteur différent','',1,0,'',2,'','','',0,0,'',NULL,'',''),('200','d','titre parallèle','',1,0,'',2,'','','',0,0,'',NULL,'',''),('200','e','complément du titre','',1,0,'biblioitems.volume',2,'','','',0,0,'',NULL,'',''),('200','f','1ère mention de resp.','Auteur',1,0,'biblio.author',2,'','','',0,0,'',NULL,'',''),('200','g','mention de responsabilité suivante','Auteur secondaire',1,0,'',2,'','','',0,0,'',NULL,'',''),('200','h','numéro de partie','',1,0,'',2,'','','',0,0,'',NULL,'',''),('200','i','titre de partie','',1,0,'biblio.unititle',2,'','','',0,0,'',NULL,'',''),('200','v','numéro du volume','',0,0,'',2,'','','',0,0,'',NULL,'',''),('200','z','langue du titre parallèle','',1,0,'',2,'','','',0,0,'',NULL,'',''),('205','a','mention d\'édition','',0,0,'',2,'','','',0,0,'',NULL,'',''),('205','b','autre mention d\'édition','',1,0,'',2,'','','',0,0,'',NULL,'',''),('205','d','mention parallèle d\'édition','',1,0,'',2,'','','',0,0,'',NULL,'',''),('205','f','mention de responsabilitérelative à l\'édition','',1,0,'',2,'','','',0,0,'',NULL,'',''),('205','g','mention de responsabilité suivante','',1,0,'',2,'','','',0,0,'',NULL,'',''),('206','a','mention des données mathématiques','',0,0,'',2,'','','',0,0,'',NULL,'',''),('206','b','mention de l\'échelle','',1,0,'',2,'','','',0,0,'',NULL,'',''),('206','c','mention de la projection','',0,0,'',2,'','','',0,0,'',NULL,'',''),('206','d','mention des coordonnées','',0,0,'',2,'','','',0,0,'',NULL,'',''),('206','e','mention de la zone','',0,0,'',2,'','','',0,0,'',NULL,'',''),('206','f','mention de l\'équinoxe','',0,0,'',2,'','','',0,0,'',NULL,'',''),('207','a','numérotation : indication de date et de volume','',1,0,'',2,'','','',NULL,0,'','',NULL,''),('207','z','source d\'information sur la numérotation','',1,0,'',2,'','','',NULL,0,'','',NULL,''),('208','a','mention de présentation musicale','',0,0,'',2,'','','',0,0,'',NULL,'',''),('208','d','mention parallèle de présentation musicale','',1,0,'',2,'','','',0,0,'',NULL,'',''),('210','a','lieu de publication','',1,0,'',2,'','','',0,0,'',NULL,'',''),('210','b','adresse de l\'éditeur, du diffuseur','',1,0,'',2,'','','',0,0,'',NULL,'',''),('210','c','nom de l\'éditeur','',1,0,'biblioitems.publishercode',2,'','','',0,0,'',NULL,'',''),('210','d','date de publication','',1,0,'biblioitems.publicationyear',2,'','','',0,0,'',NULL,'',''),('210','e','lieu de fabrication','',1,0,'',2,'','','',0,0,'',NULL,'',''),('210','f','adresse du fabricant','',1,0,'',2,'','','',0,0,'',NULL,'',''),('210','g','nom du fabricant','',1,0,'',2,'','','',0,0,'',NULL,'',''),('210','h','date de fabrication','',1,0,'',2,'','','',0,0,'',NULL,'',''),('211','a','date','',0,0,'',2,'','','',0,0,'',NULL,'',''),('215','a','Importance matérielle','',1,0,'biblioitems.pages',2,'','','',NULL,0,'','',NULL,''),('215','c','autres carac. matérielles','',0,0,'',2,'','','',NULL,0,'','',NULL,''),('215','d','format','',1,0,'biblioitems.size',2,'','','',NULL,0,'','',NULL,''),('215','e','matériel d\'accompagnement','',1,0,'',2,'','','',NULL,0,'','',NULL,''),('225','a','titre de la collection','',0,0,'biblioitems.collectiontitle',2,'','','unimarc_field_225a.pl',0,0,'',NULL,'',''),('225','d','titre parallèle de la collection','',1,0,'',2,'','','',0,0,'',NULL,'',''),('225','e','complément du titre','',1,0,'',2,'','','',0,0,'',NULL,'',''),('225','f','mention de responsabilité','',1,0,'biblioitems.editionresponsibility',2,'','','',0,0,'',NULL,'',''),('225','h','numéro de partie','',1,0,'',2,'','','',0,0,'',NULL,'',''),('225','i','titre de partie','',1,0,'',2,'','','',0,0,'',NULL,'',''),('225','v','numérotation du volume','',1,0,'biblioitems.collectionvolume',2,'','','',0,0,'',NULL,'',''),('225','x','ISSN de la collection','',1,0,'biblioitems.collectionissn',2,'','','',0,0,'',NULL,'',''),('225','z','langue du titre parallèle','',1,0,'',2,'','','',0,0,'',NULL,'',''),('230','a','définition et volume des fichiers','',0,0,'',2,'','','',NULL,0,'','',NULL,''),('300','a','note','',0,0,'biblio.notes',3,'','','',NULL,0,'','\'330a\',\'339a\'',NULL,''),('301','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('302','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('303','a','note','',0,0,'',3,'','','',NULL,0,'','',NULL,''),('304','a','note','note',0,0,'',3,'','','',NULL,0,'','',NULL,''),('305','a','note','',0,0,'',3,'','','',NULL,0,'','',NULL,''),('306','a','note','',0,0,'',3,'','','',NULL,0,'','',NULL,''),('307','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('308','a','texte de la note','',0,0,'',3,'','','',NULL,0,'','',NULL,''),('310','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('311','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('312','a','note','',0,0,'',3,'','','',NULL,0,'','',NULL,''),('313','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('314','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('315','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('316','5','institution à laquelle s\'applique la zone','',0,0,'',3,'','','',0,0,'',NULL,'',''),('316','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('316','u','URI','',1,0,'',3,'','','',0,0,'',NULL,'',''),('317','5','institution à laquelle s\'applique la zone','',0,0,'',3,'','','',0,0,'',NULL,'',''),('317','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('317','u','URI','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','5','institution à laquelle s\'applique cette note','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','a','opération','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','b','identification de l\'opération','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','c','date de l\'opération','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','d','intervalle entre les opérations','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','e','contingence de l\'opération','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','f','autorisation','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','h','juridiction','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','i','méthode de l\'opération','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','j','lieu de l\'opération','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','k','agent de l\'opération','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','l','état','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','n','extention','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','o','type d\'unité matérielle','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','p','note confidentielle','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','r','note publique','',1,0,'',3,'','','',0,0,'',NULL,'',''),('318','u','URI','',0,0,'',3,'','','',0,0,'',NULL,'',''),('320','a','note','',0,0,'',3,'','','',NULL,0,'','',NULL,''),('321','a','nom de la source','',0,0,'',3,'','','',0,0,'',NULL,'',''),('321','b','dates de recension','',0,0,'',3,'','','',0,0,'',NULL,'',''),('321','c','localisation dans la source','',0,0,'',3,'','','',0,0,'',NULL,'',''),('321','u','URI','',0,0,'',3,'','','',0,0,'',NULL,'',''),('321','x','numéro international normalisé','',0,0,'',3,'','','',0,0,'',NULL,'',''),('322','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('323','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('324','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('325','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('326','a','périodicité','',0,0,'',3,'','','',NULL,0,'','',NULL,''),('326','b','dates','',0,0,'',3,'','','',NULL,0,'','',NULL,''),('327','a','note','',1,0,'',3,'','','',0,0,'',NULL,'',''),('327','b','titre de la subdivision de niveau 1','',1,0,'',3,'','','',0,0,'',NULL,'',''),('327','c','titre de la subdivision de niveau 2','',1,0,'',3,'','','',0,0,'',NULL,'',''),('327','d','titre de la subdivision de niveau 3','',1,0,'',3,'','','',0,0,'',NULL,'',''),('327','e','titre de la subdivision de niveau 4','',1,0,'',3,'','','',0,0,'',NULL,'',''),('327','f','titre de la subdivision de niveau 5','',1,0,'',3,'','','',0,0,'',NULL,'',''),('327','g','titre de la subdivision de niveau 6','',1,0,'',3,'','','',0,0,'',NULL,'',''),('327','h','titre de la subdivision de niveau 7','',1,0,'',3,'','','',0,0,'',NULL,'',''),('327','i','titre de la subdivision de niveau 8','',1,0,'',3,'','','',0,0,'',NULL,'',''),('327','p','Premières pages ou séquences de page d\'une subdivision','',1,0,'',3,'','','',0,0,'',NULL,'',''),('327','u','URI','',1,0,'',3,'','','',0,0,'',NULL,'',''),('327','z','Autre information concernant une subdivision','',1,0,'',3,'','','',0,0,'',NULL,'',''),('328','a','note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('328','b','détails sur la thèse ou le mémoire dont le titre du diplôme','',0,0,'',3,'','','',0,0,'',NULL,'',''),('328','c','discipline','',0,0,'',3,'','','',0,0,'',NULL,'',''),('328','d','date du diplôme','',0,0,'',3,'','','',0,0,'',NULL,'',''),('328','e','organisme donnant le diplôme','',0,0,'',3,'','','',0,0,'',NULL,'',''),('328','t','titre d\'une autre édition de la thèse','',0,0,'',3,'','','',0,0,'',NULL,'',''),('328','z','texte précédent ou suivant la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('330','a','Résumé','',0,0,'',3,'','','',NULL,0,'','',NULL,''),('332','a','forme du titre choisi','',0,0,'',3,'','','',0,0,'',NULL,'',''),('333','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('334','a','texte de la note de récompense','',0,0,'',3,'','','',0,0,'',NULL,'',''),('334','b','nom de la récompense','',0,0,'',3,'','','',0,0,'',NULL,'',''),('334','c','année de la récompense','',0,0,'',3,'','','',0,0,'',NULL,'',''),('334','d','pays de la récompense','',0,0,'',3,'','','',0,0,'',NULL,'',''),('336','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('337','a','texte de la note','',0,0,'',3,'','','',0,0,'',NULL,'',''),('337','u','URI','',1,0,'',3,'','','',0,0,'',NULL,'',''),('345','a','source de l\'acquisition, adresse pour l\'abonnement','',1,0,'',3,'','','',0,0,'',NULL,'',''),('345','b','numéro d\'éditeur','',1,0,'',3,'','','',0,0,'',NULL,'',''),('345','c','support','',1,0,'',3,'','','',0,0,'',NULL,'',''),('345','d','disponibilité','',1,0,'',3,'','','',0,0,'',NULL,'',''),('410','0','numéro d\'identification de la notice','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','3','numéro de la notice d\'autorité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('410','5','institution à  laquelle s\'applique cette zone','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','9','Numero interne koha','numero interne koha',0,0,'',4,'','','',0,0,'',NULL,'Local-Number',''),('410','a','auteur','',0,0,'',4,'','','unimarc_field_4XX.pl',0,0,'',NULL,'',''),('410','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','c','lieu de publication','',1,0,'',4,'','','',0,0,'',NULL,'',''),('410','d','date de publication','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','e','mention d\'édition','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','f','Première mention de responsabilité','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','g','mention de responsabilité suivante','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','h','numéro de section ou de partie','',1,0,'',4,'','','',0,0,'',NULL,'',''),('410','i','titre de section ou de partie','',1,0,'',4,'','','',0,0,'',NULL,'',''),('410','l','titre parallèle','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','n','nomde l\'éditeur, du distributeur, etc','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','o','sous-titre ou complément du titre','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','p','collation','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','s','mention de collection','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','t','titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('410','u','URI','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','v','numéro de volume','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','x','ISSN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('410','y','ISBN/ISMN','',1,0,'',4,'','','',0,0,'',NULL,'',''),('410','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('411','0','numéro d\'identification de la notice','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('411','3','numéro de la notice d\'autorité','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('411','5','institution à laquelle s\'applique cette zone','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('411','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('411','a','auteur','',0,0,'',4,'','','unimarc_field_4XX.pl',NULL,0,'','',NULL,''),('411','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('411','c','lieu de publication','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('411','d','date de publication','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('411','e','mention d\'édition','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('411','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('411','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('411','h','numéro de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('411','i','titre de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('411','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('411','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('411','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('411','p','collation','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('411','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('411','t','titre','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('411','u','URL','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('411','v','numéro de volume','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('411','x','ISSN','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('411','y','ISBN/numéro international normalisé de document musical','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('411','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('412','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('412','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('412','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('412','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('412','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('412','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('412','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('412','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('412','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('413','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('413','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('413','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('413','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('413','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('413','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('413','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('413','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('413','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('421','0','numéro d\'identification de la notice','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('421','3','numéro de la notice d\'autorité','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('421','5','institution à laquelle s\'applique cette zone','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('421','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('421','a','auteur','',0,0,'',4,'','','unimarc_field_4XX.pl',NULL,0,'','',NULL,''),('421','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('421','c','lieu de publication','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('421','d','date de publication','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('421','e','mention d\'édition','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('421','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('421','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('421','h','numéro de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('421','i','titre de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('421','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('421','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('421','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('421','p','collation','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('421','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('421','t','titre','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('421','u','URL','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('421','v','numéro de volume','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('421','x','ISSN','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('421','y','ISBN/numéro international normalisé de document musical','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('421','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('422','0','numéro d\'identification de la notice','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('422','3','numéro de la notice d\'autorité','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('422','5','institution à laquelle s\'applique cette zone','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('422','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('422','a','auteur','',0,0,'',4,'','','unimarc_field_4XX.pl',NULL,0,'','',NULL,''),('422','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('422','c','lieu de publication','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('422','d','date de publication','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('422','e','mention d\'édition','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('422','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('422','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('422','h','numéro de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('422','i','titre de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('422','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('422','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('422','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('422','p','collation','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('422','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('422','t','titre','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('422','u','URL','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('422','v','numéro de volume','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('422','x','ISSN','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('422','y','ISBN/numéro international normalisé de document musical','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('422','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('423','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('423','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('423','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('423','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('423','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('423','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('423','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('423','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('423','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('423','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('423','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('423','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('423','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('423','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('423','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('423','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('423','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('423','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('423','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('423','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('423','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('423','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('423','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('423','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('424','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('424','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('424','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('424','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('424','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('424','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('424','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('424','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('424','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('425','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('430','0','numéro d\'identification de la notice','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('430','3','numéro de la notice d\'autorité','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('430','5','institution à laquelle s\'applique cette zone','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('430','a','auteur','',0,0,'',4,'','','unimarc_field_4XX.pl',NULL,0,'','',NULL,''),('430','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('430','c','lieu de publication','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('430','d','date de publication','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('430','e','mention d\'édition','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('430','h','numéro de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('430','i','titre de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('430','p','collation','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('430','t','titre','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('430','u','URL','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('430','v','numéro de volume','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('430','x','ISSN','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('430','y','ISBN/numéro international normalisé de document musical','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('431','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('431','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('431','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('431','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('431','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('431','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('431','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('431','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('431','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('431','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('431','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('431','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('431','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('431','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('431','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('431','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('432','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('432','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('432','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('432','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('432','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('432','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('432','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('432','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('432','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('432','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('433','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('433','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('433','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('433','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('433','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('433','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('433','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('433','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('433','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('433','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('433','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('433','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('433','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('433','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('433','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('433','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('433','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('433','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('433','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('433','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('433','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('433','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('433','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('433','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('434','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('434','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('434','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('434','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('434','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('434','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('434','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('434','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('434','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('434','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('434','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('434','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('434','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('434','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('434','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('434','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('434','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('434','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('434','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('434','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('434','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('434','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('434','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('434','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('435','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('435','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('435','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('435','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('435','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('435','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('435','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('435','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('435','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('435','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('435','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('435','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('435','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('435','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('435','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('435','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('435','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('435','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('435','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('435','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('435','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('435','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('435','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('435','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('436','0','numéro d\'identification de la notice','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('436','3','numéro de la notice d\'autorité','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('436','5','institution à laquelle s\'applique cette zone','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('436','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('436','a','auteur','',0,0,'',4,'','','unimarc_field_4XX.pl',NULL,0,'','',NULL,''),('436','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('436','c','lieu de publication','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('436','d','date de publication','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('436','e','mention d\'édition','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('436','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('436','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('436','h','numéro de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('436','i','titre de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('436','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('436','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('436','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('436','p','collation','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('436','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('436','t','titre','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('436','u','URL','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('436','v','numéro de volume','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('436','x','ISSN','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('436','y','ISBN/numéro international normalisé de document musical','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('436','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('437','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('437','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('437','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('437','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('437','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('437','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('437','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('437','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('437','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('437','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('437','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('437','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('437','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('437','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('437','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('437','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('437','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('437','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('437','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('437','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('437','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('437','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('437','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('437','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('440','0','numéro d\'identification de la notice','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('440','3','numéro de la notice d\'autorité','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('440','5','institution à laquelle s\'applique cette zone','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('440','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('440','a','auteur','',0,0,'',4,'','','unimarc_field_4XX.pl',NULL,0,'','',NULL,''),('440','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('440','c','lieu de publication','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('440','d','date de publication','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('440','e','mention d\'édition','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('440','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('440','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('440','h','numéro de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('440','i','titre de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('440','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('440','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('440','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('440','p','collation','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('440','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('440','t','titre','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('440','u','URL','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('440','v','numéro de volume','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('440','x','ISSN','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('440','y','ISBN/numéro international normalisé de document musical','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('440','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('441','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('441','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('441','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('441','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('441','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('441','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('441','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('441','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('441','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('441','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('441','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('441','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('441','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('441','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('441','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('441','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('441','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('441','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('441','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('441','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('441','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('441','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('441','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('441','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('442','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('442','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('442','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('442','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('442','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('442','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('442','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('442','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('442','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('442','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('442','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('442','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('442','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('442','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('442','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('442','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('442','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('442','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('442','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('442','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('442','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('442','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('442','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('442','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('443','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('443','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('443','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('443','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('443','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('443','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('443','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('443','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('443','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('443','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('443','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('443','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('443','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('443','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('443','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('443','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('443','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('443','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('443','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('443','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('443','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('443','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('443','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('443','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('444','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('444','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('444','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('444','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('444','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('444','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('444','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('444','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('444','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('444','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('444','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('444','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('444','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('444','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('444','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('444','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('444','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('444','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('444','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('444','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('444','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('444','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('444','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('444','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('445','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('445','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('445','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('445','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('445','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('445','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('445','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('445','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('445','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('445','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('445','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('445','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('445','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('445','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('445','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('445','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('445','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('445','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('445','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('445','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('445','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('445','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('445','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('445','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('446','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('446','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('446','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('446','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('446','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('446','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('446','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('446','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('446','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('446','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('446','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('446','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('446','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('446','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('446','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('446','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('446','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('446','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('446','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('446','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('446','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('446','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('446','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('446','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('447','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('447','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('447','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('447','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('447','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('447','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('447','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('447','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('447','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('447','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('447','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('447','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('447','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('447','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('447','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('447','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('447','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('447','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('447','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('447','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('447','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('447','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('447','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('447','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('448','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('448','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('448','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('448','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('448','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('448','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('448','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('448','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('448','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('448','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('448','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('448','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('448','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('448','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('448','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('448','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('448','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('448','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('448','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('448','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('448','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('448','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('448','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('448','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('451','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('451','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('451','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('451','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('451','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('451','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('451','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('451','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('451','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('451','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('451','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('451','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('451','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('451','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('451','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('451','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('451','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('451','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('451','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('451','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('451','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('451','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('451','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('451','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('452','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('452','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('452','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('452','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('452','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('452','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('452','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('452','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('452','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('452','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('452','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('452','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('452','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('452','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('452','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('452','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('452','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('452','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('452','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('452','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('452','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('452','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('452','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('452','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('453','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('453','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('453','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('453','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('453','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('453','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('453','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('453','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('453','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('453','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('453','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('453','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('453','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('453','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('453','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('453','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('453','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('453','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('453','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('453','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('453','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('453','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('453','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('453','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('454','0','numéro d\'identification de la notice','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('454','3','numéro de la notice d&#39;autorité','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('454','5','institution à laquelle s&#39;applique cette zone','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('454','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('454','@','numéro d&#39;identification de la notice','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('454','a','auteur','',0,0,'',4,'','','unimarc_field_4XX.pl',NULL,0,'','',NULL,''),('454','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('454','c','lieu de publication','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('454','d','date de publication','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('454','e','mention d&#39;édition','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('454','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('454','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('454','h','numéro de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('454','i','titre de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('454','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('454','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('454','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('454','p','collation','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('454','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('454','t','titre','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('454','u','URL','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('454','v','numéro de volume','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('454','x','ISSN','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('454','y','ISBN/numéro international normalisé de document musical','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('454','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('455','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('455','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('455','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('455','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('455','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('455','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('455','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('455','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('455','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('455','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('455','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('455','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('455','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('455','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('455','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('455','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('455','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('455','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('455','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('455','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('455','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('455','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('455','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('455','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('456','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('456','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('456','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('456','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('456','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('456','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('456','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('456','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('456','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('456','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('456','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('456','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('456','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('456','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('456','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('456','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('456','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('456','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('456','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('456','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('456','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('456','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('456','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('456','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('461','0','numéro d\'identification de la notice','',0,0,'',4,'','','',0,0,'',NULL,'',''),('461','3','numéro de la notice d\'autorité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('461','5','institution à laquelle s\'applique cette zone','',0,0,'',4,'','','',0,0,'',NULL,'',''),('461','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'Local-Number',''),('461','a','auteur','',0,0,'',4,'','','unimarc_field_4XX.pl',0,0,'',NULL,'',''),('461','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('461','c','lieu de publication','',1,0,'',4,'','','',0,0,'',NULL,'',''),('461','d','date de publication','',0,0,'',4,'','','',0,0,'',NULL,'',''),('461','e','mention d\'édition','',0,0,'',4,'','','',0,0,'',NULL,'',''),('461','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('461','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('461','h','numéro de section ou de partie','',1,0,'',4,'','','',0,0,'',NULL,'',''),('461','i','titre de section ou de partie','',1,0,'',4,'','','',0,0,'',NULL,'',''),('461','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('461','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('461','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('461','p','collation','',0,0,'',4,'','','',0,0,'',NULL,'',''),('461','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('461','t','titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('461','u','URL','',0,0,'',4,'','','',0,0,'',NULL,'',''),('461','v','numéro de volume','',0,0,'',4,'','','',0,0,'',NULL,'',''),('461','x','ISSN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('461','y','ISBN/numéro international normalisé de document musical','',1,0,'',4,'','','',0,0,'',NULL,'',''),('461','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('462','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('462','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('462','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('462','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('462','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('462','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('462','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('462','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('462','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('462','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('462','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('462','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('462','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('462','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('462','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('462','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('462','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('462','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('462','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('462','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('462','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('462','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('462','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('462','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('463','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('463','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('463','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('463','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('463','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('463','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('463','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('463','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('463','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('463','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('463','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('463','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('463','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('463','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('463','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('463','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('463','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('463','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('463','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('463','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('463','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('463','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('463','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('463','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('464','0','numéro d\'identification de la notice','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('464','3','numéro de la notice d\'autorité','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('464','5','institution à laquelle s\'applique cette zone','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('464','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('464','a','auteur','',0,0,'',4,'','','unimarc_field_4XX.pl',NULL,0,'','',NULL,''),('464','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('464','c','lieu de publication','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('464','d','date de publication','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('464','e','mention d\'édition','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('464','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('464','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('464','h','numéro de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('464','i','titre de section ou de partie','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('464','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('464','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('464','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('464','p','collation','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('464','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('464','t','titre','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('464','u','URL','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('464','v','numéro de volume','',0,0,'',4,'','','',NULL,0,'','',NULL,''),('464','x','ISSN','',0,0,'',4,'','','',NULL,0,'','\'011a\'',NULL,''),('464','y','ISBN/numéro international normalisé de document musical','',1,0,'',4,'','','',NULL,0,'','',NULL,''),('464','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('470','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('470','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('470','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('470','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('470','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('470','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('470','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('470','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('470','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('470','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('470','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('470','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('470','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('470','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('470','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('470','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('470','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('470','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('470','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('470','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('470','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('470','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('470','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('470','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('481','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('481','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('481','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('481','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('481','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('481','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('481','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('481','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('481','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('481','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('481','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('481','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('481','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('481','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('481','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('481','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('481','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('481','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('481','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('481','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('481','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('481','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('481','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('481','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('482','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('482','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('482','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('482','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('482','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('482','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('482','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('482','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('482','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('482','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('482','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('482','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('482','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('482','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('482','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('482','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('482','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('482','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('482','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('482','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('482','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('482','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('482','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('482','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('488','0','numéro d\'identification de la notice','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('488','3','numéro de la notice d\'autorité','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('488','5','institution à laquelle s\'applique cette zone','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('488','9','Numéro Koha','',1,0,'',4,'','','',0,0,'',NULL,'001@',''),('488','a','auteur','',0,0,NULL,4,NULL,NULL,'unimarc_field_4XX.pl',NULL,NULL,'',NULL,NULL,''),('488','b','indication générale du type de document','',0,0,'',4,'','','',0,0,'',NULL,'',''),('488','c','lieu de publication','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('488','d','date de publication','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('488','e','mention d\'édition','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('488','f','première mention de responsabilité','',1,0,'',4,'','','',0,0,'',NULL,'',''),('488','g','mention de responsabilité suivante','',1,0,'',4,'','','',0,0,'',NULL,'',''),('488','h','numéro de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('488','i','titre de section ou de partie','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('488','l','titre parallèle','',1,0,'',4,'','','',0,0,'',NULL,'',''),('488','n','nom éditeur','',1,0,'',4,'','','',0,0,'',NULL,'',''),('488','o','sous titre','',1,0,'',4,'','','',0,0,'',NULL,'',''),('488','p','collation','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('488','s','mention de collection','',1,0,'',4,'','','',0,0,'',NULL,'',''),('488','t','titre','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('488','u','URL','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('488','v','numéro de volume','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('488','x','ISSN','',0,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('488','y','ISBN/numéro international normalisé de document musical','',1,0,NULL,4,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('488','z','CODEN','',0,0,'',4,'','','',0,0,'',NULL,'',''),('500','2','code du référentiel','',0,0,'',5,'','','',0,0,'',NULL,'',''),('500','3','numéro de la notice d\'autorité','',1,0,'',5,'','','',0,0,'',NULL,'',''),('500','9','koha internal code','',0,0,'',5,'','','',0,0,'',NULL,'',''),('500','a','titre uniforme','titre',0,0,'',5,'','','',0,0,'',NULL,'',''),('500','b','indication générale du type de document','',1,0,'',5,'','','',0,0,'',NULL,'',''),('500','h','numéro de partie','numéro',1,0,'',5,'','','',0,0,'',NULL,'',''),('500','i','titre de partie','',1,0,'',5,'','','',0,0,'',NULL,'',''),('500','j','subdivision de forme','',0,0,'',5,'','','',0,0,'',NULL,'',''),('500','k','date de publication','publié en',0,0,'',5,'','','',0,0,'',NULL,'',''),('500','l','sous-vedette de forme','',1,0,'',5,'','','',0,0,'',NULL,'',''),('500','m','langue','langue',0,0,'',5,'','','',0,0,'',NULL,'',''),('500','n','autres informations','',1,0,'',5,'','','',0,0,'',NULL,'',''),('500','q','version','',0,0,'',5,'','','',0,0,'',NULL,'',''),('500','r','distribution instrumentale et vocale','',1,0,'',5,'','','',0,0,'',NULL,'',''),('500','s','réf. numérique (pour la musique)','',1,0,'',5,'','','',0,0,'',NULL,'',''),('500','u','tonalité','',0,0,'',5,'','','',0,0,'',NULL,'',''),('500','v','indication du volume','',0,0,'',5,'','','',0,0,'',NULL,'',''),('500','w','mention d\'arrangement (pour la musique)','',0,0,'',5,'','','',0,0,'',NULL,'',''),('500','x','subdivision de sujet','',1,0,'',5,'','','',0,0,'',NULL,'',''),('500','y','subdivision géographique','',1,0,'',5,'','','',0,0,'',NULL,'',''),('500','z','subdivision chronologique','',1,0,'',5,'','','',0,0,'',NULL,'',''),('501','2','code système','',0,0,'',5,'','','',0,0,'',NULL,'',''),('501','3','numéro de la notice d\'autorité','',0,0,'',5,'','','',0,0,'',NULL,'',''),('501','a','rubrique de classement','',0,0,'',5,'','','',0,0,'',NULL,'',''),('501','b','indication générale du type de document','',1,0,'',5,'','','',0,0,'',NULL,'',''),('501','e','subdivision','',0,0,'',5,'','','',0,0,'',NULL,'',''),('501','j','subdivision de forme','',0,0,'',5,'','','',0,0,'',NULL,'',''),('501','k','date de publication','',0,0,'',5,'','','',0,0,'',NULL,'',''),('501','m','langue','',0,0,'',5,'','','',0,0,'',NULL,'',''),('501','r','mode d\'interprétation','',1,0,'',5,'','','',0,0,'',NULL,'',''),('501','s','indication du numéro (pour la musique)','',1,0,'',5,'','','',0,0,'',NULL,'',''),('501','u','clé','',0,0,'',5,'','','',0,0,'',NULL,'',''),('501','w','mention d\'arrangement (pour la musique)','',0,0,'',5,'','','',0,0,'',NULL,'',''),('501','x','subdivision de sujet','',1,0,'',5,'','','',0,0,'',NULL,'',''),('501','y','subdivision géographique','',1,0,'',5,'','','',0,0,'',NULL,'',''),('501','z','subdivision chronologique','',1,0,'',5,'','','',0,0,'',NULL,'',''),('503','a','titre de forme','titre',0,0,'',5,'','','',0,0,'',NULL,'',''),('503','b','subdivision','',0,0,'',5,'','','',0,0,'',NULL,'',''),('503','d','mois et jour','',1,0,'',5,'','','',0,0,'',NULL,'',''),('503','e','nom de personne','',0,0,'',5,'','','',0,0,'',NULL,'',''),('503','f','élément(s) de nom rejeté(s)','',0,0,'',5,'','','',0,0,'',NULL,'',''),('503','h','qualificatif','',0,0,'',5,'','','',0,0,'',NULL,'',''),('503','i','titre de partie','',0,0,'',5,'','','',0,0,'',NULL,'',''),('503','j','année','',1,0,'',5,'','','',0,0,'',NULL,'',''),('503','k','numérotation (chiffres arabes)','',0,0,'',5,'','','',0,0,'',NULL,'',''),('503','l','numérotation (chiffres romains)','',0,0,'',5,'','','',0,0,'',NULL,'',''),('503','m','localisation','',0,0,'',5,'','','',0,0,'',NULL,'',''),('503','n','établissement présidant la localisation','',0,0,'',5,'','','',0,0,'',NULL,'',''),('510','a','titre parallèle','',0,0,'',5,'','','',0,0,'',NULL,'',''),('510','e','complément du titre','',1,0,'',5,'','','',0,0,'',NULL,'',''),('510','h','numéro de partie','',1,0,'',5,'','','',0,0,'',NULL,'',''),('510','i','titre de partie','',1,0,'',5,'','','',0,0,'',NULL,'',''),('510','j','volume ou dates associés au titre','',0,0,'',5,'','','',0,0,'',NULL,'',''),('510','n','autres informations','',0,0,'',5,'','','',0,0,'',NULL,'',''),('510','z','langue du titre','',0,0,'',5,'','','',0,0,'',NULL,'',''),('512','a','titre de couverture','',0,0,'',5,'','','',0,0,'',NULL,'',''),('512','e','complément du titre','',1,0,'',5,'','','',0,0,'',NULL,'',''),('512','n','autres informations','',0,0,'',5,'','','',0,0,'',NULL,'',''),('513','a','titre figurant sur une page de titre','',0,0,'',5,'','','',0,0,'',NULL,'',''),('513','e','complément du titre','',1,0,'',5,'','','',0,0,'',NULL,'',''),('513','h','numéro de partie','',1,0,'',5,'','','',0,0,'',NULL,'',''),('513','i','titre de partie','',1,0,'',5,'','','',0,0,'',NULL,'',''),('514','a','titre parallèle','',0,0,'',5,'','','',0,0,'',NULL,'',''),('514','e','complément du titre','',1,0,'',5,'','','',0,0,'',NULL,'',''),('515','a','titre parallèle','',0,0,'',5,'','','',0,0,'',NULL,'',''),('516','a','titre de dos','',0,0,'',5,'','','',0,0,'',NULL,'',''),('516','e','complément du titre','',1,0,'',5,'','','',0,0,'',NULL,'',''),('517','a','variante de titre','',0,0,'',5,'','','',NULL,0,'','',NULL,''),('517','e','sous-titre','',1,0,'',5,'','','',NULL,0,'','',NULL,''),('518','a','titre de dos','',0,0,'',5,'','','',0,0,'',NULL,'',''),('520','a','titre précédent','titre précédent',0,0,'',5,'','','',0,0,'',NULL,'',''),('520','e','complément du titre','',1,0,'',5,'','','',0,0,'',NULL,'',''),('520','h','numéro de partie','',0,0,'',5,'','','',0,0,'',NULL,'',''),('520','i','titre de partie','',1,0,'',5,'','','',0,0,'',NULL,'',''),('520','j','volume ou dates du titre précédent','',0,0,'',5,'','','',0,0,'',NULL,'',''),('520','n','autres informations','',0,0,'',5,'','','',0,0,'',NULL,'',''),('520','x','ISSN précédent','',0,0,'',5,'','','',0,0,'',NULL,'',''),('530','a','Titre clé','Titre clé',0,0,'',5,'','','',NULL,0,'','',NULL,''),('530','b','qualificatif','',0,0,'',5,'','','',NULL,0,'','',NULL,''),('530','j','Numéro de volume ou dates associés au titre clé','',0,0,'',5,'','','',NULL,0,'','',NULL,''),('530','v','Numéro de volume','',0,0,'',5,'','','',NULL,0,'','',NULL,''),('531','a','titre abrégé','titre abrégé',0,0,'',5,'','','',0,0,'',NULL,'',''),('531','b','qualificatif','',0,0,'',5,'','','',0,0,'',NULL,'',''),('531','v','numéro de volume','',0,0,'',5,'','','',0,0,'',NULL,'',''),('532','a','titre développé','',0,0,'',5,'','','',0,0,'',NULL,'',''),('532','z','langue du titre','',0,0,'',5,'','','',0,0,'',NULL,'',''),('540','a','titre ajouté par le catalogueur','',0,0,'',5,'','','',0,0,'',NULL,'',''),('540','e','complément du titre','',1,0,'',5,'','','',0,0,'',NULL,'',''),('540','h','numéro de partie','',1,0,'',5,'','','',0,0,'',NULL,'',''),('540','i','titre de partie','',0,0,'',5,'','','',0,0,'',NULL,'',''),('541','a','titre traduit','titre traduit',0,0,'',5,'','','',0,0,'',NULL,'',''),('541','e','complément du titre','',0,0,'',5,'','','',0,0,'',NULL,'',''),('541','h','numéro de partie','',0,0,'',5,'','','',0,0,'',NULL,'',''),('541','i','titre de partie','',0,0,'',5,'','','',0,0,'',NULL,'',''),('541','z','langue du titre traduit','',0,0,'',5,'','','',0,0,'',NULL,'',''),('545','a','titre de section','',0,0,'',5,'','','',NULL,0,'','',NULL,''),('600','2','code du système d\'indexation','',0,0,'',6,'','','',0,0,'',NULL,'',''),('600','3','numéro de la notice d\'autorité','',0,0,'',6,'','','',0,0,'',NULL,'',''),('600','9','koha internal code','',0,0,'',6,'','','',0,0,'',NULL,'',''),('600','a','élément d\'entrée','sujet',0,0,'',6,'','','',0,0,'',NULL,'',''),('600','b','partie du nom autre que l\'élément d\'entrée','',0,0,'',6,'','','',0,0,'',NULL,'',''),('600','c','qualificatifs autres que les dates','',1,0,'',6,'','','',0,0,'',NULL,'',''),('600','d','chiffres romains','',0,0,'',6,'','','',0,0,'',NULL,'',''),('600','f','dates','',0,0,'',6,'','','',0,0,'',NULL,'',''),('600','g','forme développée des initiales du prénom','',0,0,'',6,'','','',0,0,'',NULL,'',''),('600','j','Subdivision de forme','',0,0,'',6,'','','',0,0,'',NULL,'',''),('600','p','Adresse, affiliation','',0,0,'',6,'','','',0,0,'',NULL,'',''),('600','x','subdivision du sujet','',1,0,'',6,'','','',0,0,'',NULL,'',''),('600','y','subdivision géographique','',1,0,'',6,'','','',0,0,'',NULL,'',''),('600','z','subdivision chronologique','',1,0,'',6,'','','',0,0,'',NULL,'',''),('601','2','code du système d\'indexation','',0,0,'',6,'','','',0,0,'',NULL,'',''),('601','3','numéro de la notice d\'autorité','',1,0,'',6,'','','',0,0,'',NULL,'',''),('601','9','koha internal code','',0,0,'',6,'','','',0,0,'',NULL,'',''),('601','a','élément d\'entrée','sujet',0,0,'',6,'','','',0,0,'',NULL,'',''),('601','b','subdivision','sujet',1,0,'',6,'','','',0,0,'',NULL,'',''),('601','c','élément ajouté au nom','',1,0,'',6,'','','',0,0,'',NULL,'',''),('601','d','numéro du congrès','',0,0,'',6,'','','',0,0,'',NULL,'',''),('601','e','lieu du congrès','',0,0,'',6,'','','',0,0,'',NULL,'',''),('601','f','date du congrès','',0,0,'',6,'','','',0,0,'',NULL,'',''),('601','g','élément rejeté','',0,0,'',6,'','','',0,0,'',NULL,'',''),('601','h','partie du nom autre que l\'élément d\'entrée ou l\'élément rejeté','',0,0,'',6,'','','',0,0,'',NULL,'',''),('601','j','subdivision de forme','',0,0,'',6,'','','',0,0,'',NULL,'',''),('601','x','subdivision de sujet','',1,0,'',6,'','','',0,0,'',NULL,'',''),('601','y','subdivision géographique','',1,0,'',6,'','','',0,0,'',NULL,'',''),('601','z','subdivision chronologique','',1,0,'',6,'','','',0,0,'',NULL,'',''),('602','2','code du système d\'indexation','',0,0,'',6,'','','',0,0,'',NULL,'',''),('602','3','numéro de la notice d\'autorité','',1,0,'',6,'','','',0,0,'',NULL,'',''),('602','a','élément d\'entrée','sujet',0,0,'',6,'','','',0,0,'',NULL,'',''),('602','f','dates','',0,0,'',6,'','','',0,0,'',NULL,'',''),('602','j','subdivision de forme','',0,0,'',6,'','','',0,0,'',NULL,'',''),('602','x','subdivision de sujet','',1,0,'',6,'','','',0,0,'',NULL,'',''),('602','y','subdivision géographique','',1,0,'',6,'','','',0,0,'',NULL,'',''),('602','z','subdivision chronologique','',1,0,'',6,'','','',0,0,'',NULL,'',''),('604','1','données de liens','',1,0,'',6,'','','',0,0,'',NULL,'',''),('604','9','koha internal code','',0,0,'',6,'','','',0,0,'',NULL,'',''),('604','a','Nom de l\'auteur','',0,0,'',6,'','','',0,0,'',NULL,'',''),('604','b','Prénom de l\'auteur','',0,0,'',6,'','','',0,0,'',NULL,'',''),('604','c','Qualificatif','',0,0,'',6,'','','',0,0,'',NULL,'',''),('604','d','numérotation (chiffres romains)','',0,0,'',6,'','','',0,0,'',NULL,'',''),('604','f','Dates','',0,0,'',6,'','','',0,0,'',NULL,'',''),('604','t','titre','',0,0,'',6,'','','',0,0,'',NULL,'',''),('605','2','code du système d\'indexation','',0,0,'',6,'','','',0,0,'',NULL,'',''),('605','3','numéro de la notice d\'autorité','',1,0,'',6,'','','',0,0,'',NULL,'',''),('605','9','koha internal code','',0,0,'',6,'','','',0,0,'',NULL,'',''),('605','a','élément d\'entrée','sujet',0,0,'',6,'','','',0,0,'',NULL,'',''),('605','h','numéro de partie','',1,0,'',6,'','','',0,0,'',NULL,'',''),('605','i','nom de partie','',1,0,'',6,'','','',0,0,'',NULL,'',''),('605','j','subdivision de forme','',0,0,'',6,'','','',0,0,'',NULL,'',''),('605','k','date de publication','',0,0,'',6,'','','',0,0,'',NULL,'',''),('605','l','sous-vedettes de forme','',0,0,'',6,'','','',0,0,'',NULL,'',''),('605','m','langue','',0,0,'',6,'','','',0,0,'',NULL,'',''),('605','n','autres informations','',1,0,'',6,'','','',0,0,'',NULL,'',''),('605','q','version','',0,0,'',6,'','','',0,0,'',NULL,'',''),('605','r','instrument musical','',0,0,'',6,'','','',0,0,'',NULL,'',''),('605','s','numéro du morceau de musique','',0,0,'',6,'','','',0,0,'',NULL,'',''),('605','u','clé (pour la musique)','',0,0,'',6,'','','',0,0,'',NULL,'',''),('605','w','arrangement (musique)','',0,0,'',6,'','','',0,0,'',NULL,'',''),('605','x','subdivision du sujet','',1,0,'',6,'','','',0,0,'',NULL,'',''),('605','y','subdivision géographique','',1,0,'',6,'','','',0,0,'',NULL,'',''),('605','z','subdivision chronologique','',1,0,'',6,'','','',0,0,'',NULL,'',''),('606','2','code du système d\'indexation','',0,0,'',6,'','','',0,0,'',NULL,'',''),('606','3','numéro de la notice d\'autorité','',1,0,'',6,'','','',0,0,'',NULL,'',''),('606','9','koha internal code','',0,0,'',6,'','','',0,0,'',NULL,'',''),('606','a','élément d\'entrée','sujet',0,0,'',6,'','','',0,0,'',NULL,'',''),('606','j','subdivision de forme','',0,0,'',6,'','','',0,0,'',NULL,'',''),('606','x','subdivision du sujet','',1,0,'',6,'','','',0,0,'',NULL,'',''),('606','y','subdivision géographique','',1,0,'',6,'','','',0,0,'',NULL,'',''),('606','z','subdivision chronologique','',1,0,'',6,'','','',0,0,'',NULL,'',''),('607','2','code du système d\'indexation','',0,0,'',6,'','','',0,0,'',NULL,'',''),('607','3','numéro de la notice d\'autorité','',0,0,'',6,'','','',0,0,'',NULL,'',''),('607','9','koha internal code','',0,0,'',6,'','','',0,0,'',NULL,'',''),('607','a','élément d\'entrée','sujet',0,0,'',6,'','','',0,0,'',NULL,'',''),('607','j','subdivision de forme','',1,0,'',6,'','','',0,0,'',NULL,'',''),('607','x','subdivision du sujet','',1,0,'',6,'','','',0,0,'',NULL,'',''),('607','y','subdivision géographique','',1,0,'',6,'','','',0,0,'',NULL,'',''),('607','z','subdivision chronologique','',1,0,'',6,'','','',0,0,'',NULL,'',''),('608','2','code du système d\'indexation','',0,0,'',6,'','','',0,0,'',NULL,'',''),('608','3','numéro de la notice d\'autorité','',0,0,'',6,'','','',0,0,'',NULL,'',''),('608','5','institution à laquelle s\'applique cette zone','',0,0,'',6,'','','',0,0,'',NULL,'',''),('608','9','Numéro interne Koha','',0,0,'',6,'','','',0,0,'',NULL,'',''),('608','a','élément d\'entrée','sujet',0,0,'',6,'','','',0,0,'',NULL,'',''),('608','j','subdivision de forme','',1,0,'',6,'','','',0,0,'',NULL,'',''),('608','x','subdivision du sujet','',1,0,'',6,'','','',0,0,'',NULL,'',''),('608','y','subdivision géographique','',1,0,'',6,'','','',0,0,'',NULL,'',''),('608','z','subdivision chronologique','',1,0,'',6,'','','',0,0,'',NULL,'',''),('610','a','descripteur','sujet',1,0,'',6,'','','',0,0,'',NULL,'',''),('615','2','code du système d\'indexation','',0,0,'',6,'','','',0,0,'',NULL,'',''),('615','3','numéro de la notice d\'autorité','',0,0,'',6,'','','',0,0,'',NULL,'',''),('615','9','Numéro interne Koha','',0,0,'',6,'','','',0,0,'',NULL,'',''),('615','a','catégorie sujet','sujet',0,0,'',6,'','','',0,0,'',NULL,'',''),('615','m','subdivision de la catégorie sujet sous forme codée','',1,0,'',6,'','','',0,0,'',NULL,'',''),('615','n','catégorie sujet sous forme codée','',1,0,'',6,'','','',0,0,'',NULL,'',''),('615','x','subdivision de la catégorie sujet','',1,0,'',6,'','','',0,0,'',NULL,'',''),('616','2','code du système d\'indexation','',0,0,'',6,'','','',0,0,'',NULL,'',''),('616','3','numéro de la notice d\'autorité','',0,0,'',6,'','','',0,0,'',NULL,'',''),('616','9','Numéro interne Koha','',0,0,'',6,'','','',0,0,'',NULL,'',''),('616','a','élément d\'entrée','',0,0,'',6,'','','',0,0,'',NULL,'',''),('616','c','qualificatifs','',1,0,'',6,'','','',0,0,'',NULL,'',''),('616','f','dates','',1,0,'',6,'','','',0,0,'',NULL,'',''),('616','j','subdivision de forme','',0,0,'',6,'','','',0,0,'',NULL,'',''),('616','x','subdivision de la catégorie sujet sous forme textuelle','',0,0,'',6,'','','',0,0,'',NULL,'',''),('616','y','subdivision géographique','',0,0,'',6,'','','',0,0,'',NULL,'',''),('620','3','numéro de la ville d\'autorité','',0,0,'',6,'','','',0,0,'',NULL,'',''),('620','a','pays','lieu d\'édition',1,0,'',6,'','','',0,0,'',NULL,'',''),('620','b','Etat, région, etc','lieu d\'édition',0,0,'',6,'','','',0,0,'',NULL,'',''),('620','c','département, comté, etc','lieu d\'édition',0,0,'',6,'','','',0,0,'',NULL,'',''),('620','d','ville','lieu d\'édition',0,0,'',6,'','','',0,0,'',NULL,'',''),('620','e','Lieu précis, salle, etc','',0,0,'',6,'','','',0,0,'',NULL,'',''),('620','f','date','',0,0,'',6,'','','',0,0,'',NULL,'',''),('620','g','saison','',0,0,'',6,'','','',0,0,'',NULL,'',''),('620','h','occasion','',0,0,'',6,'','','',0,0,'',NULL,'',''),('620','i','date de fin','',0,0,'',6,'','','',0,0,'',NULL,'',''),('626','a','marque et modèle de machine','',0,0,NULL,-1,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('626','b','langage de programmation','',0,0,NULL,-1,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('626','c','système d\'exploitation','',0,0,NULL,-1,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('660','a','code de zone géographique','',0,0,'',6,'','','',0,0,'',NULL,'',''),('661','a','code de date','',0,0,'',6,'','','',0,0,'',NULL,'',''),('670','b','numéro indicateur de sujet','',0,0,'',6,'','','',0,0,'',NULL,'',''),('670','c','chaîne','',0,0,'',6,'','','',0,0,'',NULL,'',''),('670','e','numéro indicateur de référence','',1,0,'',6,'','','',0,0,'',NULL,'',''),('670','z','langue des termes','',0,0,'',6,'','','',0,0,'',NULL,'',''),('675','3','numéro de notice de la classification','',0,0,'',6,'','','',0,0,'',NULL,'',''),('675','a','indice CDU','',0,0,'',6,'','','',0,0,'',NULL,'',''),('675','v','édition','',0,0,'',6,'','','',0,0,'',NULL,'',''),('675','z','langue d\'édition','',0,0,'',6,'','','',0,0,'',NULL,'',''),('676','3','numéro de notice de la classification','',0,0,'',6,'','','',0,0,'',NULL,'',''),('676','a','indice Dewey','',0,0,'',6,'','','',0,0,'',NULL,'',''),('676','v','édition','',0,0,'',6,'','','',0,0,'',NULL,'',''),('676','z','langue d\'édition','',0,0,'',6,'','','',0,0,'',NULL,'',''),('680','3','numéro de notice de la classification','',0,0,'',6,'','','',0,0,'',NULL,'',''),('680','a','indice LOC','',0,0,'',6,'','','',0,0,'',NULL,'',''),('680','b','numéro de livre','',0,0,'',6,'','','',0,0,'',NULL,'',''),('686','2','code du système','',0,0,'',6,'','','',0,0,'',NULL,'',''),('686','3','numéro de notice de la classification','',0,0,'',6,'','','',0,0,'',NULL,'',''),('686','a','type (indice)','',1,0,'',6,'itemtypes','','',0,0,'',NULL,'',''),('686','b','numéro de livre','',1,0,'',6,'','','',0,0,'',NULL,'',''),('686','c','subdivision de l\'indice','',1,0,'',6,'','','',0,0,'',NULL,'',''),('689','9','Code interne koha','Code interne koha',0,0,'',6,'','','',0,0,'',NULL,'',''),('689','a','689$a','689$a',0,0,'',6,'','','',0,0,'',NULL,'',''),('700','3','numéro de la notice d\'autorité','',0,0,'',7,'','','',0,0,'',NULL,'',''),('700','4','code de fonction','',1,0,'',7,'','','',0,0,'',NULL,'',''),('700','9','koha internal code','',0,0,'',7,'','','',0,0,'',NULL,'',''),('700','a','élément d\'entrée','auteur',0,1,'',7,'','NP','',0,0,'',NULL,'',''),('700','b','partie du nom autre que l\'élément d\'entrée','',0,0,'',7,'','','',0,0,'',NULL,'',''),('700','c','qualificatifs autres que les dates','',1,0,'',7,'','','',0,0,'',NULL,'',''),('700','d','chiffres romains','',0,0,'',7,'','','',0,0,'',NULL,'',''),('700','f','dates','',0,0,'',7,'','','',0,0,'',NULL,'',''),('700','g','forme développée des initiales du prénom','',0,0,'',7,'','','',0,0,'',NULL,'',''),('700','p','affiliation ou adresse','',0,0,'',7,'','','',0,0,'',NULL,'',''),('701','3','numéro de la notice d\'autorité','',0,0,'',7,'','','',0,0,'',NULL,'',''),('701','4','code de fonction','',1,0,'',7,'','','',0,0,'',NULL,'',''),('701','9','koha internal code','',0,0,'',7,'','','',0,0,'',NULL,'',''),('701','a','nom','',0,0,'',7,'','NP','',0,0,'',NULL,'',''),('701','b','prénom','',0,0,'',7,'','','',0,0,'',NULL,'',''),('701','c','qualificatifs','',1,0,'',7,'','','',0,0,'',NULL,'',''),('701','d','numérotation','',0,0,'',7,'','','',0,0,'',NULL,'',''),('701','f','dates','',0,0,'',7,'','','',0,0,'',NULL,'',''),('701','g','forme développée des initiales du prénom','',0,0,'',7,'','','',0,0,'',NULL,'',''),('701','p','affiliation ou adresse','',0,0,'',7,'','','',0,0,'',NULL,'',''),('702','3','numéro de la notice d\'autorité','',0,0,'',7,'','','',0,0,'',NULL,'',''),('702','4','code de fonction','',1,0,'',7,'','','',0,0,'',NULL,'',''),('702','5','institution à laquelle s\'applique cette zone','',0,0,'',7,'','','',0,0,'',NULL,'',''),('702','9','koha internal code','',0,0,'',7,'','','',0,0,'',NULL,'',''),('702','a','nom','',0,0,'',7,'','NP','',0,0,'',NULL,'',''),('702','b','prénom','',0,0,'',7,'','','',0,0,'',NULL,'',''),('702','c','qualificatifs','',1,0,'',7,'','','',0,0,'',NULL,'',''),('702','d','numérotation','',0,0,'',7,'','','',0,0,'',NULL,'',''),('702','f','dates','',0,0,'',7,'','','',0,0,'',NULL,'',''),('702','g','forme développée des initiales du prénom','',0,0,'',7,'','','',0,0,'',NULL,'',''),('702','p','affiliation ou adresse','',0,0,'',7,'','','',0,0,'',NULL,'',''),('710','3','numéro de la notice d\'autorité','',0,0,'',7,'','','',0,0,'',NULL,'',''),('710','4','code de fonction','',1,0,'',7,'','','',0,0,'',NULL,'',''),('710','9','Champ interne Koha','',0,0,'',7,'','','',0,0,'',NULL,'',''),('710','a','élément d\'entrée','',0,0,'',7,'','CO','',0,0,'',NULL,'',''),('710','b','subdivision','',1,0,'',7,'','','',0,0,'',NULL,'',''),('710','c','qualificatif','',1,0,'',7,'','','',0,0,'',NULL,'',''),('710','d','numéro congrès','',1,0,'',7,'','','',0,0,'',NULL,'',''),('710','e','lieu du congrès','',0,0,'',7,'','','',0,0,'',NULL,'',''),('710','f','date du congrès','',0,0,'',7,'','','',0,0,'',NULL,'',''),('710','g','élément rejeté','',0,0,'',7,'','','',0,0,'',NULL,'',''),('710','h','partie du nom autre que l\'élément d\'entrée et que l\'élément rejeté','',0,0,'',7,'','','',0,0,'',NULL,'',''),('710','p','affiliation ou adresse','',0,0,'',7,'','','',0,0,'',NULL,'',''),('711','3','numéro de la notice d\'autorité','',0,0,'',7,'','','',0,0,'',NULL,'',''),('711','4','code de fonction','',1,0,'',7,'','','',0,0,'',NULL,'',''),('711','9','champ interne Koha','',0,0,'',7,'','','',0,0,'',NULL,'',''),('711','a','élément d\'entrée','',0,0,'',7,'','CO','',0,0,'',NULL,'',''),('711','b','subdivision','',1,0,'',7,'','','',0,0,'',NULL,'',''),('711','c','qualificatif','',1,0,'',7,'','','',0,0,'',NULL,'',''),('711','d','numéro du congrès','',1,0,'',7,'','','',0,0,'',NULL,'',''),('711','e','lieu du congrès','',0,0,'',7,'','','',0,0,'',NULL,'',''),('711','f','date du congrès','',0,0,'',7,'','','',0,0,'',NULL,'',''),('711','g','élément rejeté','',0,0,'',7,'','','',0,0,'',NULL,'',''),('711','h','partie du nom autre que l\'élément d\'entrée et que l\'élément rejeté','',1,0,'',7,'','','',0,0,'',NULL,'',''),('711','p','affiliation ou adresse','',0,0,'',7,'','','',0,0,'',NULL,'',''),('712','3','numéro de la notice d\'autorité','',0,0,'',7,'','','',0,0,'',NULL,'',''),('712','4','code de fonction','',1,0,'',7,'','','',0,0,'',NULL,'',''),('712','5','institution à laquelle s\'applique cette zone','',0,0,'',7,'','','',0,0,'',NULL,'',''),('712','9','champ interne Koha','',0,0,'',7,'','','',0,0,'',NULL,'',''),('712','a','élément d\'entrée','',0,0,'',7,'','CO','',0,0,'',NULL,'',''),('712','b','subdivision','',1,0,'',7,'','','',0,0,'',NULL,'',''),('712','c','qualificatif','',1,0,'',7,'','','',0,0,'',NULL,'',''),('712','d','numéro du congrès','',1,0,'',7,'','','',0,0,'',NULL,'',''),('712','e','lieu du congrès','',0,0,'',7,'','','',0,0,'',NULL,'',''),('712','f','date du congrès','',0,0,'',7,'','','',0,0,'',NULL,'',''),('712','g','élément rejeté','',0,0,'',7,'','','',0,0,'',NULL,'',''),('712','h','partie du nom autre que l\'élément d\'entrée et que l\'élément rejeté','',0,0,'',7,'','','',0,0,'',NULL,'',''),('712','p','affiliation ou adresse','',0,0,'',7,'','','',0,0,'',NULL,'',''),('716','3','numéro de la notice d\'autorité','',0,0,'',7,'','','',0,0,'',NULL,'',''),('716','a','élément d\'entrée','',0,0,'',7,'','','',0,0,'',NULL,'',''),('716','c','qualificatif','',0,0,'',7,'','','',0,0,'',NULL,'',''),('716','f','dates','',1,0,'',7,'','','',0,0,'',NULL,'',''),('720','3','numéro de la notice d\'autorité','',0,0,'',7,'','','',0,0,'',NULL,'',''),('720','4','code de fonction','',0,1,'',7,'qualif','','',0,0,'',NULL,'',''),('720','a','élément d\'entrée','',0,0,'',7,'','','',0,0,'',NULL,'',''),('720','f','dates','',0,0,'',7,'','','',0,0,'',NULL,'',''),('721','3','numéro de la notice d\'autorité','',0,0,'',7,'','','',0,0,'',NULL,'',''),('721','4','code de fonction','',0,1,'',7,'qualif','','',0,0,'',NULL,'',''),('721','a','élément d\'entrée','',0,0,'',7,'','','',0,0,'',NULL,'',''),('721','f','dates','',0,0,'',7,'','','',0,0,'',NULL,'',''),('722','3','numéro de la notice d\'autorité','',0,0,'',7,'','','',0,0,'',NULL,'',''),('722','4','code de fonction','',0,1,'',7,'qualif','','',0,0,'',NULL,'',''),('722','5','institution à laquelle s\'applique la zone','',0,0,'',7,'','','',0,0,'',NULL,'',''),('722','a','élément d\'entrée','',0,0,'',7,'','','',0,0,'',NULL,'',''),('722','f','dates','',0,0,'',7,'','','',0,0,'',NULL,'',''),('730','4','code de relation','',1,0,'',7,'qualif','','',0,0,'',NULL,'',''),('730','a','Nom','',0,0,'',7,'','','',0,0,'',NULL,'',''),('801','2','code du format utilisé','',0,0,'',8,'','','',0,0,'',NULL,'',''),('801','a','pays','',0,0,'',8,'','','',0,8,'',NULL,'',''),('801','b','agence de catalogage','',0,0,'',8,'','','',0,0,'',NULL,'',''),('801','c','date de la transaction','',0,0,'',8,'','','',0,0,'',NULL,'',''),('801','g','règles de catalogage utilisées','',1,0,'',8,'','','',0,0,'',NULL,'',''),('802','a','code du centre ISSN','',0,0,'',8,'','','',0,0,'',NULL,'',''),('830','a','texte de la note','note',0,0,'',8,'','','',0,0,'',NULL,'',''),('850','a','code de l\'institution','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','2','code du référentiel utilisé','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','a','Identificateur de l\'établissement','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','b','Indentification de sous-localisation','',1,0,'',8,'','','',0,0,'',NULL,'',''),('852','c','adresse','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','d','qualificatif de localisation codé','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','e','qualificatif de localisation non codé','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','g','préfixe de cote','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','j','cote','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','k','forme du titre','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','l','suffixe de cote','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','m','identificateur pour un exemplaire unique','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','n','identificateur pour des exemplaires multiples','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','p','pays','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','t','numéro pour des exemplaires multiples','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','x','note non destinée au public','',0,0,'',8,'','','',0,0,'',NULL,'',''),('852','y','note publique','',0,0,'',8,'','','',0,0,'',NULL,'',''),('856','2','affichage du lien hypertextuel','',0,0,'',8,'','','',0,0,'',NULL,'',''),('856','a','nom du serveur','',1,0,'',8,'','','',0,0,'',NULL,'',''),('856','b','numéro d\'accès','',1,0,'',8,'','','',0,0,'',NULL,'',''),('856','c','compression','compression',1,0,'',8,'','','',0,0,'',NULL,'',''),('856','d','chemin d\'accès','',1,0,'',8,'','','',0,0,'',NULL,'',''),('856','e','date et heure de la consultation','visité le',0,0,'',8,'','','',0,0,'',NULL,'',''),('856','f','nom électronique','fichier',1,0,'',8,'','','',0,0,'',NULL,'',''),('856','h','nom de l\'utilisateur','',0,0,'',8,'','','',0,0,'',NULL,'',''),('856','i','instruction','commande',1,0,'',8,'','','',0,0,'',NULL,'',''),('856','j','bits par seconde','bits par seconde',0,0,'',8,'','','',0,0,'',NULL,'',''),('856','k','mot de passe','mot de passe',0,0,'',8,'','','',0,0,'',NULL,'',''),('856','l','login','login',0,0,'',8,'','','',0,0,'',NULL,'',''),('856','m','contact pour l\'assistance technique','contact',1,0,'',8,'','','',0,0,'',NULL,'',''),('856','n','adresse du serveur','adresse',0,0,'',8,'','','',0,0,'',NULL,'',''),('856','o','système d\'exploitation','système d\'exploitation',0,0,'',8,'','','',0,0,'',NULL,'',''),('856','p','port','port',0,0,'',8,'','','',0,0,'',NULL,'',''),('856','q','type de format électronique','',0,0,'',8,'','','',0,0,'',NULL,'',''),('856','r','configuration de transfert de données','',0,0,'',8,'','','',0,0,'',NULL,'',''),('856','s','taille du fichier','taille du fichier',1,0,'',8,'','','',0,0,'',NULL,'',''),('856','t','émulation du terminal','',1,0,'',8,'','','',0,0,'',NULL,'',''),('856','u','URI','',0,0,'biblioitems.url',8,'','','',0,0,'',NULL,'',''),('856','v','heures d\'accès','heures d\'accès',1,0,'',8,'','','',0,0,'',NULL,'',''),('856','w','numéro de contrôle de la notice','',1,0,'',8,'','','',0,0,'',NULL,'',''),('856','x','note non destinée au public','',1,0,'',8,'','','',0,0,'',NULL,'',''),('856','y','mode d\'accès','mode d\'accès',0,0,'',8,'','','',0,0,'',NULL,'',''),('856','z','note publique','note',1,0,'',8,'','','',0,0,'',NULL,'',''),('886','2','code du système','',0,0,'',8,'','','',0,0,'',NULL,'',''),('886','a','étiquette de la zone du format source','',0,0,'',8,'','','',0,0,'',NULL,'',''),('886','b','indicateurs et sous-zones de la zone du format source','',0,0,'',8,'','','',0,0,'',NULL,'',''),('901','9','Numero interne koha','Numero interne koha',0,0,'',9,'','','',0,0,'',NULL,'',''),('901','a','Centre d\'intérêt','Centre d\'intérêt',0,0,'',9,'','','',0,0,'',NULL,'',''),('902','9','Numero interne koha','Numéro interne koha',0,0,'',9,'','','',0,0,'',NULL,'',''),('902','a','Genre','Genre',0,0,'',9,'','','',0,0,'',NULL,'',''),('903','a','code d\'indexation','',0,0,NULL,-1,NULL,NULL,'',NULL,NULL,'',NULL,NULL,''),('925','a','Etat de collection','Etat de collection',0,0,'',9,'','','',0,0,'',NULL,'',''),('995','1','Endommagé','Endommagé',0,0,'items.damaged',10,'','','',0,0,'',NULL,'',''),('995','2','Perdu','',0,0,'items.itemlost',10,'','','',0,1,'',NULL,'',''),('995','3','Pilon','Pilon',0,0,'items.wthdrawn',10,'','','',0,0,'',NULL,'',''),('995','9','itemnumber (koha)','',0,0,'items.itemnumber',-1,'','','',0,0,'',NULL,'',''),('995','b','Bibliothèque propriétaire','Bibliothèque propriétaire',0,1,'items.homebranch',10,'branches','','',0,0,'',NULL,'',''),('995','c','Bibliothèque dépositaire','Bibliothèque dépositaire',0,1,'items.holdingbranch',10,'branches','','',0,0,'',NULL,'',''),('995','d','Emplacement','Emplacement',0,0,'',10,'','','',0,0,'',NULL,'',''),('995','e','Localisation','Localisation',0,0,'',10,'','','',0,0,'',NULL,'',''),('995','f','Code barre','Code barre',0,0,'items.barcode',10,'','','',0,0,'',NULL,'',''),('995','h','Code de collection','Code de collection',0,0,'items.ccode',10,'CCODE','','',0,0,'',NULL,'',''),('995','i','Fournisseur','Fournisseur',0,0,'',10,'','','',0,0,'',NULL,'',''),('995','j','Section','Section',0,0,'items.location',10,'','','',0,0,'',NULL,'',''),('995','k','Cote','Cote',0,0,'items.itemcallnumber',10,'','','',0,0,'',NULL,'',''),('995','m','Date de prêt ou de dépôt','Date de prêt ou de dépôt',0,0,'',10,'','','',0,1,'',NULL,'',''),('995','n','Date de restitution prévue','à rendre pour le',0,0,'items.onloan',10,'','','',0,0,'',NULL,'',''),('995','o','Statut','Statut',0,1,'items.notforloan',10,'ETAT','','',0,0,'',NULL,'',''),('995','r','Type de document et support matériel','Type de document et support matériel',0,1,'items.itype',10,'','','',0,0,'',NULL,'',''),('995','s','Piège','Piège',0,0,'',10,'','','',0,0,'',NULL,'',''),('995','t','Eléments d\'accompagnement','Eléments d\'accompagnement',0,0,'',10,'','','',0,0,'',NULL,'',''),('995','u','Note','Note',0,0,'items.itemnotes',10,'','','',0,0,'',NULL,'',''),('995','v','Note sur le n° de périodique','Note sur le n° de périodique',0,0,'items.enumchron',10,'','','',0,0,'',NULL,'',''),('995','x','Nombre de renouvellements','Nombre de renouvellements',0,0,'items.renewals',10,'','','',0,0,'',NULL,'',''),('995','y','Nombre de réservations','Nombre de réservations',0,0,'items.reserves',10,'','','',0,0,'',NULL,'',''),('995','z','Nombre de prêts','Nombre de prêts',0,0,'items.issues',10,'','','',0,0,'',NULL,'',''),('999','9','Koha biblio number (autogenerated) ','Koha biblio number (autogenerated) ',0,0,'biblio.biblionumber',9,'','','',0,0,'',NULL,'',''),('999','a','Koha biblioitem number (autogenerated) ','Koha biblioitem number (autogenerated) ',0,0,'biblioitems.biblioitemnumber',9,'','','',0,0,'',NULL,'','');
/*!40000 ALTER TABLE `marc_subfield_structure` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marc_tag_structure`
--

DROP TABLE IF EXISTS `marc_tag_structure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marc_tag_structure` (
  `tagfield` varchar(3) NOT NULL DEFAULT '',
  `liblibrarian` varchar(255) NOT NULL DEFAULT '',
  `libopac` varchar(255) NOT NULL DEFAULT '',
  `repeatable` tinyint(4) NOT NULL DEFAULT '0',
  `mandatory` tinyint(4) NOT NULL DEFAULT '0',
  `authorised_value` varchar(10) DEFAULT NULL,
  `frameworkcode` varchar(4) NOT NULL DEFAULT '',
  PRIMARY KEY (`frameworkcode`,`tagfield`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marc_tag_structure`
--

LOCK TABLES `marc_tag_structure` WRITE;
/*!40000 ALTER TABLE `marc_tag_structure` DISABLE KEYS */;
INSERT INTO `marc_tag_structure` VALUES ('000','Label','',0,1,'',''),('001','Numéro de notice','Numéro de notice',0,1,'',''),('005','Numéro d\'identification de la version','',0,0,'',''),('010','ISBN','ISBN',1,0,'',''),('011','ISSN','ISSN',1,0,'',''),('012','Empreinte identifiant le document','',1,0,'',''),('013','numéro international normalisé de document musical (ISMN)','ISMN',1,0,'',''),('014','numéro d\'identification d\'un article de périodique','',1,0,'',''),('015','Numéro international normalisé de rapport technique','',1,0,'',''),('016','Numéro international normalisé de disque (ISRC)','',1,0,'',''),('017','Autre numéro d\'identification normalisé','',1,0,'',''),('020','Numéro de la bibliographie nationale','',1,0,'',''),('021','numéro de dépôt légal','dépôt légal',1,0,'',''),('022','Numéro de publication officielle','',1,0,'',''),('035','Autres numéros de contrôle','',1,0,'',''),('036','Incipit (Musique)','Incipit (Musique)',1,0,'',''),('040','CODEN (publications en série)','CODEN',1,0,'',''),('071','Référence éditoriale','',1,0,'',''),('072','Numéro universel de produit (UPC)','UPC',1,0,'',''),('073','EAN','',1,0,'',''),('090','Numéro biblio (koha)','Numéro biblio (koha)',0,0,'',''),('099','Informations locales','',0,0,'',''),('100','Données générales de traitement','',0,1,'',''),('101','Langue','Langue',0,0,'',''),('102','Pays de publication ou de production','',0,0,'',''),('105','Zone de données codées : textes, monographies','',0,0,'',''),('106','Zone de données codées : forme de la ressource','',0,0,'',''),('110','Zone de données codées : publications en série','',0,0,'',''),('115','Zone de données codées : vidéo et films','',0,0,'',''),('116','zone de données codées : documents graphiques','',1,0,'',''),('117','zone de données codées : objets en trois dimensions, artefacts','',1,0,'',''),('120','zone de données codées : documents cartographiques, généralités','',0,0,NULL,''),('121','zone de données codées : documents cartographiques, caractéristiques physiques','',0,0,NULL,''),('122','zone de données codées : période historique','',1,0,'',''),('123','zone de données codées : documents cartographiques, échelle et coordonnées','',1,0,'',''),('124','zone de données codées : documents cartographiques, autres caractéristiques physiques','',0,0,NULL,''),('125','zone de données codées : enregistrements sonores et musique imprimée','',0,0,NULL,''),('126','zone de données codées : enregistrements sonores, caractéristiques physiques','',0,0,NULL,''),('127','zone de données codées : durée des enregistrements sonores','',0,0,NULL,''),('128','zone de données codées : formes de l\'oeuvre musicale et tonalité ou mode','',1,0,'',''),('130','zone de données codées : microformes, caractéristiques physiques','',0,0,NULL,''),('131','zone de données codées : documents cartographiques - mesures géodésiques','',0,0,NULL,''),('135','Zone de données codées : ressources électroniques','',1,0,'',''),('140','Zone de données codées : livres anciens','',0,0,'',''),('141','Zone de données codées : livres anciens, caractères de l\'exemplaire','',1,0,'',''),('145','Zone de données codées : distribution instrumentale et vocale','',1,0,'',''),('200','Titre et mention de responsabilité','Titre',0,1,'',''),('205','Mention d\'édition','',1,0,'',''),('206','zone particulière à certains types de documents : documents cartographiques, données mathématiques','',1,0,'',''),('207','Zone particulière à certains types de documents : ressources continues, numérotation','',0,0,'',''),('208','zone particulière à certains types de documents : musique notée - présentation musicale','',0,0,'',''),('210','Publication, production, diffusion, etc.','Editeur',1,0,'',''),('211','date de publication prévue','date de publication prévue',0,0,NULL,''),('215','Description matérielle','Description',1,0,'',''),('225','collection','collection',1,0,'',''),('230','Zone particulière à certains types de documents : ressources électroniques','',1,0,'',''),('300','Note générale','Note',1,0,'',''),('301','note sur les numéros d\'identification','note',1,0,'',''),('302','note sur les informations codées','note',1,0,'',''),('303','Note générale sur la description bibliographique','Note',1,0,'',''),('304','Note sur le titre et la mention de responsabilité','Note',1,0,'',''),('305','Note sur l\'édition et l\'histoire bibliographique','Note',1,0,'',''),('306','Note sur l\'adresse bibliographique','Note',1,0,'',''),('307','note sur la collation','note',1,0,'',''),('308','note sur la collection','note',1,0,'',''),('310','note sur la reliure et la disponibilité','note',1,0,'',''),('311','note sur les zones de liens','note',1,0,'',''),('312','Note sur les titres associés','Note',1,0,'',''),('313','note sur les vedettes matières','note',1,0,'',''),('314','note sur la responsabilité intellectuelle','note',1,0,'',''),('315','note sur les informations propres au type de documents','note',1,0,'',''),('316','Note sur l\'exemplaire','Note',1,0,'',''),('317','note sur la provenance','note',0,0,NULL,''),('318','Note sur les actions de préservation','note',1,0,'',''),('320','Note sur les bibliographies ou les index contenus dans le document','Note',1,0,'',''),('321','note sur les index, extraits et citations publiés séparément','note',1,0,'',''),('322','note sur le générique','note',0,0,NULL,''),('323','note sur les interprètes','note',1,0,'',''),('324','note sur l\'original reproduit','note',0,0,'',''),('325','note sur la reproduction','note',1,0,'',''),('326','Note sur la périodicité','note',1,0,'',''),('327','Note de contenu','Note',1,0,'',''),('328','Note sur les thèses','Note',1,0,'',''),('330','Résumé ou extrait','Résumé',1,0,'',''),('332','titre choisi pour le document','forme du titre',1,0,'',''),('333','note sur le public destinataire','destiné à',1,0,'',''),('334','Note sur la récompense','',1,0,'',''),('336','note sur le type de ressource électronique','type de fichier',1,0,'',''),('337','note sur la configuration requise (ressources électroniques)','configuration requise',1,0,'',''),('345','renseignements sur l\'acquisition','note',0,0,NULL,''),('410','Collection','collection',1,0,'',''),('411','sous-collection','sous-collection',1,0,'',''),('412','Est un extrait ou un tiré à part de','',0,0,'',''),('413','A pour extrait ou tiré à part','',0,0,'',''),('421','supplément','a pour supplément',0,0,NULL,''),('422','publication-mère du supplément','supplément de',1,0,'',''),('423','publié avec','publié avec',0,0,NULL,''),('424','Est mis à jour par','',0,0,'',''),('425','Met à jour','',0,0,'',''),('430','suite de','suite de',1,0,'',''),('431','succède après scission à','succède après scission à',1,0,'',''),('432','remplace','remplace',0,0,NULL,''),('433','reprend en partie','reprend en partie',1,0,'',''),('434','absorbe','absorbe',0,0,NULL,''),('435','absorbe partiellement','absorbe partiellement',0,0,NULL,''),('436','fusion de','fusion de',1,0,'',''),('437','suite partielle de','suite partielle de',1,0,'',''),('440','devient','devient',1,0,'',''),('441','devient partiellement','devient partiellement',1,0,'',''),('442','remplacé par','remplacé par',1,0,'',''),('443','repris en partie par','repris en partie par',0,0,NULL,''),('444','absorbé par','absorbé par',1,0,'',''),('445','absorbé partiellement par','absorbé partiellement par',0,0,NULL,''),('446','scindé en ... et en ...','scindé',0,0,'',''),('447','fusionne avec pour former','fusionne avec pour former',0,0,NULL,''),('448','redevient','redevient',1,0,'',''),('451','autre édition sur le même support','autre édition',0,0,NULL,''),('452','autre édition sur un autre support','autre édition',0,0,NULL,''),('453','traduit sous le titre','traduit sous le titre',0,0,NULL,''),('454','traduit de','traduit de',0,0,NULL,''),('455','reproduction de','',0,0,NULL,''),('456','reproduit comme','',0,0,NULL,''),('461','niveau de l\'ensemble','',1,0,'',''),('462','niveau du sous-ensemble','',1,0,'',''),('463','niveau de l\'unité matérielle','',0,0,NULL,''),('464','niveau du dépouillement','',0,0,NULL,''),('470','document analysé','',0,0,NULL,''),('481','est relié avec ce volume','est rélié avec ce volume',0,0,NULL,''),('482','relié avec','relié avec',0,0,NULL,''),('488','autres oeuvres en liaison','',0,0,NULL,''),('500','Titre uniforme','Titre',1,0,'',''),('501','rubrique de classement','',1,0,'',''),('503','Titre de forme','Titre',1,0,'',''),('510','Titre parallèle','',1,0,'',''),('512','Titre de couverture','',1,0,'',''),('513','titre figurant sur une autre page de titre','',1,0,'',''),('514','titre de départ','',1,0,'',''),('515','titre courant','',1,0,'',''),('516','titre de dos','',1,0,'',''),('517','Autres variantes du titre','Autres variantes du titre',1,0,'',''),('518','titre dans un alphabet moderne','',1,0,'',''),('520','Titre précédent (publications en série)','titre précédent',1,0,'',''),('530','Titre clé (publications en série)','',1,0,'',''),('531','titre abrégé (publications en série)','titre abrégé',1,0,'',''),('532','titre développé (publications en série)','',1,0,'',''),('540','Titre ajouté par le catalogueur','',1,0,'',''),('541','titre traduit ajouté par le catalogueur','',1,0,'',''),('545','Titre de section','',1,0,'',''),('600','Nom de personne - vedette matière','sujets',1,0,'',''),('601','Collectivité - vedette matière','sujets',1,0,'',''),('602','Nom générique de famille - vedette matière','sujets',1,0,'',''),('604','Auteur-titre - vedette matière','sujets',1,0,'',''),('605','Titre - vedette matière','sujets',1,0,'',''),('606','Nom commun - vedette matière','sujets',1,0,'',''),('607','Nom géographique - vedette matière','sujets',1,0,'',''),('608','vedette matière de forme, de genre ou des caractéristiques physiques','sujets',1,0,'',''),('610','indexation en vocabulaire libre','sujets',1,0,'',''),('615','catégorie sujet (provisoire)','',1,0,'',''),('616','marque déposée utilisée comme sujet','',1,0,'',''),('620','accès par le lieu et la date','lieu d\'édition',1,0,'',''),('626','accès par des données techniques (périmé)','',1,0,'',''),('660','code de zone géographique','',1,0,'',''),('661','code de date','',1,0,'',''),('670','PRECIS','',1,0,'',''),('675','Classification Décimale Universelle','classification',1,0,'',''),('676','classification décimale Dewey','classification',1,0,'',''),('680','classification de la Bibliothèque du Congrès','classification',1,0,'',''),('686','autres classifications','classification',1,0,'',''),('689','689','689',0,0,'',''),('700','Auteur principal','Auteur',0,0,'',''),('701','Coauteur','coauteur',1,0,'',''),('702','Nom de personne - mention de responsabilité secondaire','',1,0,'',''),('710','collectivité principale','auteur',0,0,'',''),('711','collectivité - coauteur','',1,0,'',''),('712','collectivité - mention de responsabilité secondaire','',1,0,'',''),('716','Marque déposée','',1,0,'',''),('720','nom générique de famille - mention de responsabilité principale','',0,0,NULL,''),('721','nom générique de famille - coauteur','',1,0,'',''),('722','nom générique de famille - mention de responsabilité secondaire','',1,0,'',''),('730','Nom - responsabilité intellectuelle','',1,0,'',''),('801','source de catalogage','',1,1,'',''),('802','centre ISSN','',0,0,NULL,''),('830','note générale du catalogueur','note',1,0,'',''),('850','Institution possédant le document','',1,0,'',''),('852','Localisation et cote','',1,0,'',''),('856','adresse électronique et mode d\'accès','accès',1,0,'',''),('886','données non converties du format source','',1,0,'',''),('901','Centre d\'intérêt','Centre d\'intérêt',0,0,'',''),('902','Genre','Genre',0,0,'',''),('903','indexation','cote',0,0,NULL,''),('925','Etat de collection','Etat de collection',0,0,'',''),('995','Exemplaires','',0,0,'',''),('999','System Control Numbers (Koha)','System Control Numbers (Koha)',0,0,'','');
/*!40000 ALTER TABLE `marc_tag_structure` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `matchchecks`
--

DROP TABLE IF EXISTS `matchchecks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `matchchecks` (
  `matcher_id` int(11) NOT NULL,
  `matchcheck_id` int(11) NOT NULL AUTO_INCREMENT,
  `source_matchpoint_id` int(11) NOT NULL,
  `target_matchpoint_id` int(11) NOT NULL,
  PRIMARY KEY (`matchcheck_id`),
  KEY `matcher_matchchecks_ifbk_1` (`matcher_id`),
  KEY `matcher_matchchecks_ifbk_2` (`source_matchpoint_id`),
  KEY `matcher_matchchecks_ifbk_3` (`target_matchpoint_id`),
  CONSTRAINT `matcher_matchchecks_ifbk_1` FOREIGN KEY (`matcher_id`) REFERENCES `marc_matchers` (`matcher_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `matcher_matchchecks_ifbk_2` FOREIGN KEY (`source_matchpoint_id`) REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `matcher_matchchecks_ifbk_3` FOREIGN KEY (`target_matchpoint_id`) REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `matchchecks`
--

LOCK TABLES `matchchecks` WRITE;
/*!40000 ALTER TABLE `matchchecks` DISABLE KEYS */;
/*!40000 ALTER TABLE `matchchecks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `matcher_matchpoints`
--

DROP TABLE IF EXISTS `matcher_matchpoints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `matcher_matchpoints` (
  `matcher_id` int(11) NOT NULL,
  `matchpoint_id` int(11) NOT NULL,
  KEY `matcher_matchpoints_ifbk_1` (`matcher_id`),
  KEY `matcher_matchpoints_ifbk_2` (`matchpoint_id`),
  CONSTRAINT `matcher_matchpoints_ifbk_1` FOREIGN KEY (`matcher_id`) REFERENCES `marc_matchers` (`matcher_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `matcher_matchpoints_ifbk_2` FOREIGN KEY (`matchpoint_id`) REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `matcher_matchpoints`
--

LOCK TABLES `matcher_matchpoints` WRITE;
/*!40000 ALTER TABLE `matcher_matchpoints` DISABLE KEYS */;
/*!40000 ALTER TABLE `matcher_matchpoints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `matchpoint_component_norms`
--

DROP TABLE IF EXISTS `matchpoint_component_norms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `matchpoint_component_norms` (
  `matchpoint_component_id` int(11) NOT NULL,
  `sequence` int(11) NOT NULL DEFAULT '0',
  `norm_routine` varchar(50) NOT NULL DEFAULT '',
  KEY `matchpoint_component_norms` (`matchpoint_component_id`,`sequence`),
  CONSTRAINT `matchpoint_component_norms_ifbk_1` FOREIGN KEY (`matchpoint_component_id`) REFERENCES `matchpoint_components` (`matchpoint_component_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `matchpoint_component_norms`
--

LOCK TABLES `matchpoint_component_norms` WRITE;
/*!40000 ALTER TABLE `matchpoint_component_norms` DISABLE KEYS */;
/*!40000 ALTER TABLE `matchpoint_component_norms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `matchpoint_components`
--

DROP TABLE IF EXISTS `matchpoint_components`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `matchpoint_components` (
  `matchpoint_id` int(11) NOT NULL,
  `matchpoint_component_id` int(11) NOT NULL AUTO_INCREMENT,
  `sequence` int(11) NOT NULL DEFAULT '0',
  `tag` varchar(3) NOT NULL DEFAULT '',
  `subfields` varchar(40) NOT NULL DEFAULT '',
  `offset` int(4) NOT NULL DEFAULT '0',
  `length` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`matchpoint_component_id`),
  KEY `by_sequence` (`matchpoint_id`,`sequence`),
  CONSTRAINT `matchpoint_components_ifbk_1` FOREIGN KEY (`matchpoint_id`) REFERENCES `matchpoints` (`matchpoint_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `matchpoint_components`
--

LOCK TABLES `matchpoint_components` WRITE;
/*!40000 ALTER TABLE `matchpoint_components` DISABLE KEYS */;
/*!40000 ALTER TABLE `matchpoint_components` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `matchpoints`
--

DROP TABLE IF EXISTS `matchpoints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `matchpoints` (
  `matcher_id` int(11) NOT NULL,
  `matchpoint_id` int(11) NOT NULL AUTO_INCREMENT,
  `search_index` varchar(30) NOT NULL DEFAULT '',
  `score` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`matchpoint_id`),
  KEY `matchpoints_ifbk_1` (`matcher_id`),
  CONSTRAINT `matchpoints_ifbk_1` FOREIGN KEY (`matcher_id`) REFERENCES `marc_matchers` (`matcher_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `matchpoints`
--

LOCK TABLES `matchpoints` WRITE;
/*!40000 ALTER TABLE `matchpoints` DISABLE KEYS */;
/*!40000 ALTER TABLE `matchpoints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_attributes`
--

DROP TABLE IF EXISTS `message_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message_attributes` (
  `message_attribute_id` int(11) NOT NULL AUTO_INCREMENT,
  `message_name` varchar(20) NOT NULL DEFAULT '',
  `takes_days` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`message_attribute_id`),
  UNIQUE KEY `message_name` (`message_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_attributes`
--

LOCK TABLES `message_attributes` WRITE;
/*!40000 ALTER TABLE `message_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `message_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_queue`
--

DROP TABLE IF EXISTS `message_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message_queue` (
  `message_id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) DEFAULT NULL,
  `subject` text,
  `content` text,
  `metadata` text,
  `letter_code` varchar(64) DEFAULT NULL,
  `message_transport_type` varchar(20) NOT NULL,
  `status` enum('sent','pending','failed','deleted') NOT NULL DEFAULT 'pending',
  `time_queued` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `to_address` mediumtext,
  `from_address` mediumtext,
  `content_type` text,
  KEY `message_id` (`message_id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `message_transport_type` (`message_transport_type`),
  CONSTRAINT `messageq_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `messageq_ibfk_2` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_queue`
--

LOCK TABLES `message_queue` WRITE;
/*!40000 ALTER TABLE `message_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `message_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_transport_types`
--

DROP TABLE IF EXISTS `message_transport_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message_transport_types` (
  `message_transport_type` varchar(20) NOT NULL,
  PRIMARY KEY (`message_transport_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_transport_types`
--

LOCK TABLES `message_transport_types` WRITE;
/*!40000 ALTER TABLE `message_transport_types` DISABLE KEYS */;
INSERT INTO `message_transport_types` VALUES ('email'),('feed'),('print'),('sms');
/*!40000 ALTER TABLE `message_transport_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_transports`
--

DROP TABLE IF EXISTS `message_transports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message_transports` (
  `message_attribute_id` int(11) NOT NULL,
  `message_transport_type` varchar(20) NOT NULL,
  `is_digest` tinyint(1) NOT NULL DEFAULT '0',
  `letter_module` varchar(20) NOT NULL DEFAULT '',
  `letter_code` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`message_attribute_id`,`message_transport_type`,`is_digest`),
  KEY `message_transport_type` (`message_transport_type`),
  KEY `letter_module` (`letter_module`,`letter_code`),
  CONSTRAINT `message_transports_ibfk_1` FOREIGN KEY (`message_attribute_id`) REFERENCES `message_attributes` (`message_attribute_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `message_transports_ibfk_2` FOREIGN KEY (`message_transport_type`) REFERENCES `message_transport_types` (`message_transport_type`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `message_transports_ibfk_3` FOREIGN KEY (`letter_module`, `letter_code`) REFERENCES `letter` (`module`, `code`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_transports`
--

LOCK TABLES `message_transports` WRITE;
/*!40000 ALTER TABLE `message_transports` DISABLE KEYS */;
/*!40000 ALTER TABLE `message_transports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messages` (
  `message_id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) NOT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `message_type` varchar(1) NOT NULL,
  `message` text NOT NULL,
  `message_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifys`
--

DROP TABLE IF EXISTS `notifys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifys` (
  `notify_id` int(11) NOT NULL DEFAULT '0',
  `borrowernumber` int(11) NOT NULL DEFAULT '0',
  `itemnumber` int(11) NOT NULL DEFAULT '0',
  `notify_date` date DEFAULT NULL,
  `notify_send_date` date DEFAULT NULL,
  `notify_level` int(1) NOT NULL DEFAULT '0',
  `method` varchar(20) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifys`
--

LOCK TABLES `notifys` WRITE;
/*!40000 ALTER TABLE `notifys` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nozebra`
--

DROP TABLE IF EXISTS `nozebra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nozebra` (
  `server` varchar(20) NOT NULL,
  `indexname` varchar(40) NOT NULL,
  `value` varchar(250) NOT NULL,
  `biblionumbers` longtext NOT NULL,
  KEY `indexname` (`server`,`indexname`),
  KEY `value` (`server`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nozebra`
--

LOCK TABLES `nozebra` WRITE;
/*!40000 ALTER TABLE `nozebra` DISABLE KEYS */;
/*!40000 ALTER TABLE `nozebra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `old_issues`
--

DROP TABLE IF EXISTS `old_issues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `old_issues` (
  `borrowernumber` int(11) DEFAULT NULL,
  `itemnumber` int(11) DEFAULT NULL,
  `date_due` date DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `issuingbranch` varchar(18) DEFAULT NULL,
  `returndate` date DEFAULT NULL,
  `lastreneweddate` date DEFAULT NULL,
  `return` varchar(4) DEFAULT NULL,
  `renewals` tinyint(4) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `issuedate` date DEFAULT NULL,
  KEY `old_issuesborridx` (`borrowernumber`),
  KEY `old_issuesitemidx` (`itemnumber`),
  KEY `old_bordate` (`borrowernumber`,`timestamp`),
  CONSTRAINT `old_issues_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_issues_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `old_reserves`
--

DROP TABLE IF EXISTS `old_reserves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `old_reserves` (
  `reservenumber` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) DEFAULT NULL,
  `reservedate` date DEFAULT NULL,
  `biblionumber` int(11) DEFAULT NULL,
  `constrainttype` varchar(1) DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `notificationdate` date DEFAULT NULL,
  `reminderdate` date DEFAULT NULL,
  `cancellationdate` date DEFAULT NULL,
  `reservenotes` mediumtext,
  `priority` smallint(6) DEFAULT NULL,
  `found` varchar(1) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `itemnumber` int(11) DEFAULT NULL,
  `waitingdate` date DEFAULT NULL,
  `expirationdate` date DEFAULT NULL,
  `lowestPriority` tinyint(1) NOT NULL,
  PRIMARY KEY (`reservenumber`),
  KEY `old_reserves_borrowernumber` (`borrowernumber`),
  KEY `old_reserves_biblionumber` (`biblionumber`),
  KEY `old_reserves_itemnumber` (`itemnumber`),
  KEY `old_reserves_branchcode` (`branchcode`),
  CONSTRAINT `old_reserves_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_reserves_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `old_reserves_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `old_reserves`
--

LOCK TABLES `old_reserves` WRITE;
/*!40000 ALTER TABLE `old_reserves` DISABLE KEYS */;
/*!40000 ALTER TABLE `old_reserves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `opac_news`
--

DROP TABLE IF EXISTS `opac_news`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opac_news` (
  `idnew` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(250) NOT NULL DEFAULT '',
  `new` text NOT NULL,
  `lang` varchar(25) NOT NULL DEFAULT '',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expirationdate` date DEFAULT NULL,
  `number` int(11) DEFAULT NULL,
  PRIMARY KEY (`idnew`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `opac_news`
--

LOCK TABLES `opac_news` WRITE;
/*!40000 ALTER TABLE `opac_news` DISABLE KEYS */;
/*!40000 ALTER TABLE `opac_news` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `overduerules`
--

DROP TABLE IF EXISTS `overduerules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `overduerules` (
  `branchcode` varchar(10) NOT NULL DEFAULT '',
  `categorycode` varchar(10) NOT NULL DEFAULT '',
  `delay1` int(4) DEFAULT NULL,
  `letter1` varchar(20) DEFAULT NULL,
  `debarred1` varchar(1) DEFAULT '0',
  `delay2` int(4) DEFAULT NULL,
  `debarred2` varchar(1) DEFAULT '0',
  `letter2` varchar(20) DEFAULT NULL,
  `delay3` int(4) DEFAULT NULL,
  `letter3` varchar(20) DEFAULT NULL,
  `debarred3` int(1) DEFAULT '0',
  PRIMARY KEY (`branchcode`,`categorycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `overduerules`
--

LOCK TABLES `overduerules` WRITE;
/*!40000 ALTER TABLE `overduerules` DISABLE KEYS */;
/*!40000 ALTER TABLE `overduerules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patroncards`
--

DROP TABLE IF EXISTS `patroncards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `patroncards` (
  `cardid` int(11) NOT NULL AUTO_INCREMENT,
  `batch_id` varchar(10) NOT NULL DEFAULT '1',
  `borrowernumber` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`cardid`),
  KEY `patroncards_ibfk_1` (`borrowernumber`),
  CONSTRAINT `patroncards_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patroncards`
--

LOCK TABLES `patroncards` WRITE;
/*!40000 ALTER TABLE `patroncards` DISABLE KEYS */;
/*!40000 ALTER TABLE `patroncards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patronimage`
--

DROP TABLE IF EXISTS `patronimage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `patronimage` (
  `cardnumber` varchar(16) NOT NULL,
  `mimetype` varchar(15) NOT NULL,
  `imagefile` mediumblob NOT NULL,
  PRIMARY KEY (`cardnumber`),
  CONSTRAINT `patronimage_fk1` FOREIGN KEY (`cardnumber`) REFERENCES `borrowers` (`cardnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patronimage`
--

LOCK TABLES `patronimage` WRITE;
/*!40000 ALTER TABLE `patronimage` DISABLE KEYS */;
/*!40000 ALTER TABLE `patronimage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pending_offline_operations`
--

DROP TABLE IF EXISTS `pending_offline_operations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pending_offline_operations` (
  `operationid` int(11) NOT NULL AUTO_INCREMENT,
  `userid` varchar(30) NOT NULL,
  `branchcode` varchar(10) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `action` varchar(10) NOT NULL,
  `barcode` varchar(20) NOT NULL,
  `cardnumber` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`operationid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pending_offline_operations`
--

LOCK TABLES `pending_offline_operations` WRITE;
/*!40000 ALTER TABLE `pending_offline_operations` DISABLE KEYS */;
/*!40000 ALTER TABLE `pending_offline_operations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permissions` (
  `module_bit` int(11) NOT NULL DEFAULT '0',
  `code` varchar(64) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`module_bit`,`code`),
  CONSTRAINT `permissions_ibfk_1` FOREIGN KEY (`module_bit`) REFERENCES `userflags` (`bit`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES (1,'circulate_remaining_permissions','Remaining circulation permissions'),(1,'override_renewals','Override blocked renewals'),(1,'view_borrowers_logs','Can see the borrowers logs'),(6,'modify_holds_priority','Modify holds priority'),(6,'place_holds','Place holds for patrons'),(9,'edit_catalogue','Edit catalog (Modify bibliographic/holdings data)'),(9,'edit_items','Edit Items'),(9,'fast_cataloging','Fast cataloging'),(11,'budget_add_del','Add and delete budgets (but cant modify budgets)'),(11,'budget_manage','Manage budgets'),(11,'budget_modify','Modify budget (can\'t create lines, but can modify existing ones)'),(11,'contracts_manage','Manage contracts'),(11,'group_manage','Manage orders & basketgroups'),(11,'order_manage','Manage orders & basket'),(11,'order_receive','Manage orders & basket'),(11,'period_manage','Manage periods'),(11,'planning_manage','Manage budget plannings'),(11,'vendors_manage','Manage vendors'),(13,'batchedit','Perform batch modification of records'),(13,'batch_upload_patron_images','Upload patron images in batch or one at a time'),(13,'delete_anonymize_patrons','Delete old borrowers and anonymize circulation history (deletes borrower reading history)'),(13,'edit_calendar','Define days when the library is closed'),(13,'edit_news','Write news for the OPAC and staff interfaces'),(13,'edit_notices','Define notices'),(13,'edit_notice_status_triggers','Set notice/status triggers for overdue items'),(13,'export_catalog','Export bibliographic and holdings data'),(13,'import_patrons','Import patron data'),(13,'inventory','Perform inventory (stocktaking) of your catalog'),(13,'items_batchdel','Perform batch deletion of items'),(13,'items_batchmod','Perform batch modification of items'),(13,'label_creator','Create printable labels and barcodes from catalog and patron data'),(13,'manage_csv_profiles','Manage CSV export profiles'),(13,'manage_staged_marc','Managed staged MARC records, including completing and reversing imports'),(13,'moderate_comments','Moderate patron comments'),(13,'moderate_tags','Moderate patron tags'),(13,'rotating_collections','Manage rotating collections'),(13,'schedule_tasks','Schedule tasks to run'),(13,'stage_marc_import','Stage MARC records into the reservoir'),(13,'view_system_logs','Browse the system logs'),(15,'check_expiration','Check the expiration of a serial'),(15,'claim_serials','Claim missing serials'),(15,'create_subscription','Create a new subscription'),(15,'delete_subscription','Delete an existing subscription'),(15,'edit_subscription','Edit an existing subscription'),(15,'receive_serials','Serials receiving'),(15,'renew_subscription','Renew a subscription'),(15,'routing','Routing'),(16,'create_reports','Create SQL Reports'),(16,'execute_reports','Execute SQL reports');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `printers`
--

DROP TABLE IF EXISTS `printers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `printers` (
  `printername` varchar(40) NOT NULL DEFAULT '',
  `printqueue` varchar(20) DEFAULT NULL,
  `printtype` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`printername`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `printers`
--

LOCK TABLES `printers` WRITE;
/*!40000 ALTER TABLE `printers` DISABLE KEYS */;
/*!40000 ALTER TABLE `printers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `printers_profile`
--

DROP TABLE IF EXISTS `printers_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `printers_profile` (
  `profile_id` int(4) NOT NULL AUTO_INCREMENT,
  `printer_name` varchar(40) NOT NULL DEFAULT 'Default Printer',
  `template_id` int(4) NOT NULL DEFAULT '0',
  `paper_bin` varchar(20) NOT NULL DEFAULT 'Bypass',
  `offset_horz` float NOT NULL DEFAULT '0',
  `offset_vert` float NOT NULL DEFAULT '0',
  `creep_horz` float NOT NULL DEFAULT '0',
  `creep_vert` float NOT NULL DEFAULT '0',
  `units` char(20) NOT NULL DEFAULT 'POINT',
  `creator` char(15) NOT NULL DEFAULT 'Labels',
  PRIMARY KEY (`profile_id`),
  UNIQUE KEY `printername` (`printer_name`,`template_id`,`paper_bin`,`creator`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `printers_profile`
--

LOCK TABLES `printers_profile` WRITE;
/*!40000 ALTER TABLE `printers_profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `printers_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `repeatable_holidays`
--

DROP TABLE IF EXISTS `repeatable_holidays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `repeatable_holidays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branchcode` varchar(10) NOT NULL DEFAULT '',
  `weekday` smallint(6) DEFAULT NULL,
  `day` smallint(6) DEFAULT NULL,
  `month` smallint(6) DEFAULT NULL,
  `title` varchar(50) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `repeatable_holidays`
--

LOCK TABLES `repeatable_holidays` WRITE;
/*!40000 ALTER TABLE `repeatable_holidays` DISABLE KEYS */;
/*!40000 ALTER TABLE `repeatable_holidays` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports_dictionary`
--

DROP TABLE IF EXISTS `reports_dictionary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports_dictionary` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `date_created` datetime DEFAULT NULL,
  `date_modified` datetime DEFAULT NULL,
  `saved_sql` text,
  `area` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports_dictionary`
--

LOCK TABLES `reports_dictionary` WRITE;
/*!40000 ALTER TABLE `reports_dictionary` DISABLE KEYS */;
/*!40000 ALTER TABLE `reports_dictionary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reserveconstraints`
--

DROP TABLE IF EXISTS `reserveconstraints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reserveconstraints` (
  `borrowernumber` int(11) NOT NULL DEFAULT '0',
  `reservedate` date DEFAULT NULL,
  `biblionumber` int(11) NOT NULL DEFAULT '0',
  `biblioitemnumber` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reserveconstraints`
--

LOCK TABLES `reserveconstraints` WRITE;
/*!40000 ALTER TABLE `reserveconstraints` DISABLE KEYS */;
/*!40000 ALTER TABLE `reserveconstraints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reserves`
--

DROP TABLE IF EXISTS `reserves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reserves` (
  `reservenumber` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) NOT NULL DEFAULT '0',
  `reservedate` date DEFAULT NULL,
  `biblionumber` int(11) NOT NULL DEFAULT '0',
  `constrainttype` varchar(1) DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `notificationdate` date DEFAULT NULL,
  `reminderdate` date DEFAULT NULL,
  `cancellationdate` date DEFAULT NULL,
  `reservenotes` mediumtext,
  `priority` smallint(6) DEFAULT NULL,
  `found` varchar(1) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `itemnumber` int(11) DEFAULT NULL,
  `waitingdate` date DEFAULT NULL,
  `expirationdate` date DEFAULT NULL,
  `lowestPriority` tinyint(1) NOT NULL,
  PRIMARY KEY (`reservenumber`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `biblionumber` (`biblionumber`),
  KEY `itemnumber` (`itemnumber`),
  KEY `branchcode` (`branchcode`),
  CONSTRAINT `reserves_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reserves_ibfk_4` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reserves`
--

LOCK TABLES `reserves` WRITE;
/*!40000 ALTER TABLE `reserves` DISABLE KEYS */;
/*!40000 ALTER TABLE `reserves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reviews` (
  `reviewid` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) DEFAULT NULL,
  `biblionumber` int(11) DEFAULT NULL,
  `review` text,
  `approved` tinyint(4) DEFAULT NULL,
  `datereviewed` datetime DEFAULT NULL,
  PRIMARY KEY (`reviewid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roadtype`
--

DROP TABLE IF EXISTS `roadtype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roadtype` (
  `roadtypeid` int(11) NOT NULL AUTO_INCREMENT,
  `road_type` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`roadtypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roadtype`
--

LOCK TABLES `roadtype` WRITE;
/*!40000 ALTER TABLE `roadtype` DISABLE KEYS */;
/*!40000 ALTER TABLE `roadtype` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `saved_reports`
--

DROP TABLE IF EXISTS `saved_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `saved_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_id` int(11) DEFAULT NULL,
  `report` longtext,
  `date_run` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `saved_reports`
--

LOCK TABLES `saved_reports` WRITE;
/*!40000 ALTER TABLE `saved_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `saved_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `saved_sql`
--

DROP TABLE IF EXISTS `saved_sql`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `saved_sql` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) DEFAULT NULL,
  `date_created` datetime DEFAULT NULL,
  `last_modified` datetime DEFAULT NULL,
  `savedsql` text,
  `last_run` datetime DEFAULT NULL,
  `report_name` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `boridx` (`borrowernumber`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `saved_sql`
--

LOCK TABLES `saved_sql` WRITE;
/*!40000 ALTER TABLE `saved_sql` DISABLE KEYS */;
INSERT INTO `saved_sql` VALUES (1,0,'2011-03-07 17:39:45','2011-03-07 17:48:23','SELECT  borrowers.cardnumber,borrowers.surname,borrowers.firstname,items.barcode,reserves.reservedate FROM reserves, borrowers, items WHERE reserves.borrowernumber = borrowers.borrowernumber AND reserves.itemnumber = items.itemnumber AND items.biblionumber = biblio.biblionumber\r\n',NULL,'Reservations',NULL,'');
/*!40000 ALTER TABLE `saved_sql` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_history`
--

DROP TABLE IF EXISTS `search_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_history` (
  `userid` int(11) NOT NULL,
  `sessionid` varchar(32) NOT NULL,
  `query_desc` varchar(255) NOT NULL,
  `query_cgi` varchar(255) NOT NULL,
  `limit_desc` varchar(255) DEFAULT NULL,
  `limit_cgi` varchar(255) DEFAULT NULL,
  `total` int(11) NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `userid` (`userid`),
  KEY `sessionid` (`sessionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Opac search history results';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_history`
--

LOCK TABLES `search_history` WRITE;
/*!40000 ALTER TABLE `search_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `search_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `serial`
--

DROP TABLE IF EXISTS `serial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `serial` (
  `serialid` int(11) NOT NULL AUTO_INCREMENT,
  `biblionumber` varchar(100) NOT NULL DEFAULT '',
  `subscriptionid` varchar(100) NOT NULL DEFAULT '',
  `serialseq` varchar(100) NOT NULL DEFAULT '',
  `status` tinyint(4) NOT NULL DEFAULT '0',
  `planneddate` date DEFAULT NULL,
  `notes` text,
  `publisheddate` date DEFAULT NULL,
  `itemnumber` text,
  `claimdate` date DEFAULT NULL,
  `routingnotes` text,
  PRIMARY KEY (`serialid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `serial`
--

LOCK TABLES `serial` WRITE;
/*!40000 ALTER TABLE `serial` DISABLE KEYS */;
/*!40000 ALTER TABLE `serial` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `serialitems`
--

DROP TABLE IF EXISTS `serialitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `serialitems` (
  `itemnumber` int(11) NOT NULL,
  `serialid` int(11) NOT NULL,
  UNIQUE KEY `serialitemsidx` (`itemnumber`),
  KEY `serialitems_sfk_1` (`serialid`),
  CONSTRAINT `serialitems_sfk_1` FOREIGN KEY (`serialid`) REFERENCES `serial` (`serialid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `serialitems`
--

LOCK TABLES `serialitems` WRITE;
/*!40000 ALTER TABLE `serialitems` DISABLE KEYS */;
/*!40000 ALTER TABLE `serialitems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `services_throttle`
--

DROP TABLE IF EXISTS `services_throttle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `services_throttle` (
  `service_type` varchar(10) NOT NULL DEFAULT '',
  `service_count` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`service_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `services_throttle`
--

LOCK TABLES `services_throttle` WRITE;
/*!40000 ALTER TABLE `services_throttle` DISABLE KEYS */;
/*!40000 ALTER TABLE `services_throttle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` varchar(32) NOT NULL,
  `a_session` text NOT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `special_holidays`
--

DROP TABLE IF EXISTS `special_holidays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `special_holidays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branchcode` varchar(10) NOT NULL DEFAULT '',
  `day` smallint(6) NOT NULL DEFAULT '0',
  `month` smallint(6) NOT NULL DEFAULT '0',
  `year` smallint(6) NOT NULL DEFAULT '0',
  `isexception` smallint(1) NOT NULL DEFAULT '1',
  `title` varchar(50) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `special_holidays`
--

LOCK TABLES `special_holidays` WRITE;
/*!40000 ALTER TABLE `special_holidays` DISABLE KEYS */;
/*!40000 ALTER TABLE `special_holidays` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `statistics`
--

DROP TABLE IF EXISTS `statistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `statistics` (
  `datetime` datetime DEFAULT NULL,
  `branch` varchar(10) DEFAULT NULL,
  `proccode` varchar(4) DEFAULT NULL,
  `value` double(16,4) DEFAULT NULL,
  `type` varchar(16) DEFAULT NULL,
  `other` mediumtext,
  `usercode` varchar(10) DEFAULT NULL,
  `itemnumber` int(11) DEFAULT NULL,
  `itemtype` varchar(10) DEFAULT NULL,
  `borrowernumber` int(11) DEFAULT NULL,
  `associatedborrower` int(11) DEFAULT NULL,
  KEY `timeidx` (`datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stopwords`
--

DROP TABLE IF EXISTS `stopwords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stopwords` (
  `word` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stopwords`
--

LOCK TABLES `stopwords` WRITE;
/*!40000 ALTER TABLE `stopwords` DISABLE KEYS */;
INSERT INTO `stopwords` VALUES ('a'),('about'),('also'),('an'),('and'),('another'),('any'),('are'),('as'),('at'),('back'),('be'),('because'),('been'),('being'),('but'),('by'),('can'),('could'),('did'),('do'),('each'),('end'),('even'),('for'),('from'),('get'),('go'),('had'),('have'),('he'),('her'),('here'),('his'),('how'),('i'),('if'),('in'),('into'),('is'),('it'),('just'),('may'),('me'),('might'),('much'),('must'),('my'),('no'),('not'),('of'),('off'),('on'),('only'),('or'),('other'),('our'),('out'),('should'),('so'),('some'),('still'),('such'),('than'),('that'),('the'),('their'),('them'),('then'),('there'),('these'),('they'),('this'),('those'),('to'),('too'),('try'),('two'),('under'),('up'),('us'),('was'),('we'),('were'),('what'),('when'),('where'),('which'),('while'),('who'),('why'),('will'),('with'),('within'),('without'),('would'),('you'),('your');
/*!40000 ALTER TABLE `stopwords` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription`
--

DROP TABLE IF EXISTS `subscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription` (
  `biblionumber` int(11) NOT NULL DEFAULT '0',
  `subscriptionid` int(11) NOT NULL AUTO_INCREMENT,
  `librarian` varchar(100) DEFAULT '',
  `startdate` date DEFAULT NULL,
  `aqbooksellerid` int(11) DEFAULT '0',
  `cost` int(11) DEFAULT '0',
  `aqbudgetid` int(11) DEFAULT '0',
  `weeklength` int(11) DEFAULT '0',
  `monthlength` int(11) DEFAULT '0',
  `numberlength` int(11) DEFAULT '0',
  `periodicity` tinyint(4) DEFAULT '0',
  `dow` varchar(100) DEFAULT '',
  `numberingmethod` varchar(100) DEFAULT '',
  `notes` mediumtext,
  `status` varchar(100) NOT NULL DEFAULT '',
  `add1` int(11) DEFAULT '0',
  `every1` int(11) DEFAULT '0',
  `whenmorethan1` int(11) DEFAULT '0',
  `setto1` int(11) DEFAULT NULL,
  `lastvalue1` int(11) DEFAULT NULL,
  `add2` int(11) DEFAULT '0',
  `every2` int(11) DEFAULT '0',
  `whenmorethan2` int(11) DEFAULT '0',
  `setto2` int(11) DEFAULT NULL,
  `lastvalue2` int(11) DEFAULT NULL,
  `add3` int(11) DEFAULT '0',
  `every3` int(11) DEFAULT '0',
  `innerloop1` int(11) DEFAULT '0',
  `innerloop2` int(11) DEFAULT '0',
  `innerloop3` int(11) DEFAULT '0',
  `whenmorethan3` int(11) DEFAULT '0',
  `setto3` int(11) DEFAULT NULL,
  `lastvalue3` int(11) DEFAULT NULL,
  `issuesatonce` tinyint(3) NOT NULL DEFAULT '1',
  `firstacquidate` date DEFAULT NULL,
  `manualhistory` tinyint(1) NOT NULL DEFAULT '0',
  `irregularity` text,
  `letter` varchar(20) DEFAULT NULL,
  `numberpattern` tinyint(3) DEFAULT '0',
  `distributedto` text,
  `internalnotes` longtext,
  `callnumber` text,
  `location` varchar(80) DEFAULT '',
  `branchcode` varchar(10) NOT NULL DEFAULT '',
  `hemisphere` tinyint(3) DEFAULT '0',
  `lastbranch` varchar(10) DEFAULT NULL,
  `serialsadditems` tinyint(1) NOT NULL DEFAULT '0',
  `staffdisplaycount` varchar(10) DEFAULT NULL,
  `opacdisplaycount` varchar(10) DEFAULT NULL,
  `graceperiod` int(11) NOT NULL DEFAULT '0',
  `enddate` date DEFAULT NULL,
  PRIMARY KEY (`subscriptionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription`
--

LOCK TABLES `subscription` WRITE;
/*!40000 ALTER TABLE `subscription` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscription` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscriptionhistory`
--

DROP TABLE IF EXISTS `subscriptionhistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscriptionhistory` (
  `biblionumber` int(11) NOT NULL DEFAULT '0',
  `subscriptionid` int(11) NOT NULL DEFAULT '0',
  `histstartdate` date DEFAULT NULL,
  `histenddate` date DEFAULT NULL,
  `missinglist` longtext NOT NULL,
  `recievedlist` longtext NOT NULL,
  `opacnote` varchar(150) NOT NULL DEFAULT '',
  `librariannote` varchar(150) NOT NULL DEFAULT '',
  PRIMARY KEY (`subscriptionid`),
  KEY `biblionumber` (`biblionumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptionhistory`
--

LOCK TABLES `subscriptionhistory` WRITE;
/*!40000 ALTER TABLE `subscriptionhistory` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscriptionhistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscriptionroutinglist`
--

DROP TABLE IF EXISTS `subscriptionroutinglist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscriptionroutinglist` (
  `routingid` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) DEFAULT NULL,
  `ranking` int(11) DEFAULT NULL,
  `subscriptionid` int(11) DEFAULT NULL,
  PRIMARY KEY (`routingid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptionroutinglist`
--

LOCK TABLES `subscriptionroutinglist` WRITE;
/*!40000 ALTER TABLE `subscriptionroutinglist` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscriptionroutinglist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suggestions`
--

DROP TABLE IF EXISTS `suggestions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `suggestions` (
  `suggestionid` int(8) NOT NULL AUTO_INCREMENT,
  `suggestedby` int(11) NOT NULL DEFAULT '0',
  `suggesteddate` date NOT NULL DEFAULT '0000-00-00',
  `managedby` int(11) DEFAULT NULL,
  `manageddate` date DEFAULT NULL,
  `acceptedby` int(11) DEFAULT NULL,
  `accepteddate` date DEFAULT NULL,
  `rejectedby` int(11) DEFAULT NULL,
  `rejecteddate` date DEFAULT NULL,
  `STATUS` varchar(10) NOT NULL DEFAULT '',
  `note` mediumtext,
  `author` varchar(80) DEFAULT NULL,
  `title` varchar(80) DEFAULT NULL,
  `copyrightdate` smallint(6) DEFAULT NULL,
  `publishercode` varchar(255) DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `volumedesc` varchar(255) DEFAULT NULL,
  `publicationyear` smallint(6) DEFAULT '0',
  `place` varchar(255) DEFAULT NULL,
  `isbn` varchar(30) DEFAULT NULL,
  `mailoverseeing` smallint(1) DEFAULT '0',
  `biblionumber` int(11) DEFAULT NULL,
  `reason` text,
  `budgetid` int(11) DEFAULT NULL,
  `branchcode` varchar(10) DEFAULT NULL,
  `collectiontitle` text,
  `itemtype` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`suggestionid`),
  KEY `suggestedby` (`suggestedby`),
  KEY `managedby` (`managedby`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suggestions`
--

LOCK TABLES `suggestions` WRITE;
/*!40000 ALTER TABLE `suggestions` DISABLE KEYS */;
/*!40000 ALTER TABLE `suggestions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `systempreferences`
--

DROP TABLE IF EXISTS `systempreferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `systempreferences` (
  `variable` varchar(50) NOT NULL DEFAULT '',
  `value` text,
  `options` mediumtext,
  `explanation` text,
  `type` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`variable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `systempreferences`
--

LOCK TABLES `systempreferences` WRITE;
/*!40000 ALTER TABLE `systempreferences` DISABLE KEYS */;
INSERT INTO `systempreferences` VALUES ('AcqCreateItem','ordering','ordering|receiving|cataloguing','Define when the item is created : when ordering, when receiving, or in cataloguing module','Choice'),('acquisitions','normal','simple|normal','Choose Normal, budget-based acquisitions, or Simple bibliographic-data acquisitions','Choice'),('AddPatronLists','categorycode','categorycode|category_type','Allow user to choose what list to pick up from when adding patrons','Choice'),('advancedMARCeditor','0','','If ON, the MARC editor won\'t display field/subfield descriptions','YesNo'),('AdvancedSearchContent','','70|10','Use HTML tabs to create your own advanced search menu','Textarea'),('AdvancedSearchTypes','itemtypes','itemtypes|ccode','Select which set of fields comprise the Type limit in the advanced search','Choice'),('AllowAllMessageDeletion','0','','Allow any Library to delete any message','YesNo'),('AllowHoldDateInFuture','0','','If set a date field is displayed on the Hold screen of the Staff Interface, allowing the hold date to be set in the future.','YesNo'),('AllowHoldPolicyOverride','0',NULL,'Allow staff to override hold policies when placing holds','YesNo'),('AllowHoldsOnDamagedItems','1','','Allow hold requests to be placed on damaged items','YesNo'),('AllowMultipleHoldsPerBib','','','Enter here the different itemtypes separated by space you want to allow librarians or OPAC users (if OPACItemHolds is enabled) to set holds on multiple items','Free'),('AllowNotForLoanOverride','0','','If ON, Koha will allow the librarian to loan a not for loan item.','YesNo'),('AllowOnShelfHolds','0','','Allow hold requests to be placed on items that are not on loan','YesNo'),('AllowRenewalLimitOverride','0',NULL,'if ON, allows renewal limits to be overridden on the circulation screen','YesNo'),('AmazonAssocTag','','','See:  http://aws.amazon.com','free'),('AmazonCoverImages','0','','Display Cover Images in Staff Client from Amazon Web Services','YesNo'),('AmazonEnabled','0','','Turn ON Amazon Content - You MUST set AWSAccessKeyID, AWSPrivateKey, and AmazonAssocTag if enabled','YesNo'),('AmazonLocale','US','US|CA|DE|FR|JP|UK','Use to set the Locale of your Amazon.com Web Services','Choice'),('AmazonReviews','0','','Display Amazon review on staff interface - You MUST set AWSAccessKeyID, AWSPrivateKey, and AmazonAssocTag if enabled','YesNo'),('AmazonSimilarItems','0','','Turn ON Amazon Similar Items feature  - You MUST set AWSAccessKeyID, AWSPrivateKey, and AmazonAssocTag if enabled','YesNo'),('AnonSuggestions','0',NULL,'Set to anonymous borrowernumber to enable Anonymous suggestions','free'),('authoritysep','--','10','Used to separate a list of authorities in a display. Usually --','free'),('autoBarcode','OFF','incremental|annual|hbyymmincr|OFF','Used to autogenerate a barcode: incremental will be of the form 1, 2, 3; annual of the form 2007-0001, 2007-0002; hbyymmincr of the form HB08010001 where HB=Home Branch','Choice'),('AutoEmailOpacUser','0',NULL,'Sends notification emails containing new account details to patrons - when account is created.','YesNo'),('AutoEmailPrimaryAddress','0','email|emailpro|B_email|cardnumber|OFF','Defines the default email address where \'Account Details\' emails are sent.','Choice'),('AutoLocation','0',NULL,'If ON, IP authentication is enabled, blocking access to the staff client from unauthorized IP addresses','YesNo'),('AutomaticItemReturn','1',NULL,'If ON, Koha will automatically set up a transfer of this item to its homebranch','YesNo'),('autoMemberNum','1','','If ON, patron number is auto-calculated','YesNo'),('AutoSelfCheckAllowed','0','','For corporate and special libraries which want web-based self-check available from any PC without the need for a manual staff login. Most libraries will want to leave this turned off. If on, requires self-check ID and password to be entered in AutoSelfCheckID and AutoSelfCheckPass sysprefs.','YesNo'),('AutoSelfCheckID','','','Staff ID with circulation rights to be used for automatic web-based self-check. Only applies if AutoSelfCheckAllowed syspref is turned on.','free'),('AutoSelfCheckPass','','','Password to be used for automatic web-based self-check. Only applies if AutoSelfCheckAllowed syspref is turned on.','free'),('AWSAccessKeyID','','','See:  http://aws.amazon.com','free'),('AWSPrivateKey','','','See:  http://aws.amazon.com.  Note that this is required after 2009/08/15 in order to retrieve any enhanced content other than book covers from Amazon.','free'),('Babeltheque','0','','Turn ON Babeltheque content  - See babeltheque.com to subscribe to this service','YesNo'),('BakerTaylorBookstoreURL','','','URL template for \"My Libary Bookstore\" links, to which the \"key\" value is appended, and \"https://\" is prepended.  It should include your hostname and \"Parent Number\".  Make this variable empty to turn MLB links off.  Example: ocls.mylibrarybookstore.com/MLB/actions/searchHandler.do?nextPage=bookDetails&parentNum=10923&key=',''),('BakerTaylorEnabled','0','','Enable or disable all Baker & Taylor features.','YesNo'),('BakerTaylorPassword','','','Baker & Taylor Password for Content Cafe (external content)','Free'),('BakerTaylorUsername','','','Baker & Taylor Username for Content Cafe (external content)','Free'),('BiblioAddsAuthorities','0',NULL,'If ON, adding a new biblio will check for an existing authority record and create one on the fly if one doesn\'t exist','YesNo'),('BiblioDefaultView','normal','normal|marc|isbd','Choose the default detail view in the catalog; choose between normal, marc or isbd','Choice'),('BlockRenewWhenOverdue','0','','If Set, when item is overdue, renewals are blocked','YesNo'),('BorrowerMandatoryField','zipcode|surname|cardnumber',NULL,'Choose the mandatory fields for a patron\'s account','free'),('borrowerRelationship','father|mother','','Define valid relationships between a guarantor & a guarantee (separated by | or ,)','free'),('BorrowersLog','1',NULL,'If ON, log edit/create/delete actions on patron data','YesNo'),('BorrowersTitles','M.|Mme|Mlle','','Define appropriate Titles for patrons','free'),('BranchTransferLimitsType','ccode','itemtype|ccode','When using branch transfer limits, choose whether to limit by itemtype or collection code.','Choice'),('canreservefromotherbranches','1','','With Independent branches on, can a user from one library place a hold on an item from another library','YesNo'),('casAuthentication','0','','Enable or disable CAS authentication','YesNo'),('casLogout','0','','Does a logout from Koha should also log the user out of CAS?','YesNo'),('casServerUrl','https://localhost:8443/cas','','URL of the cas server','Free'),('CataloguingLog','1',NULL,'If ON, log edit/create/delete actions on bibliographic data. WARNING: this feature is very resource consuming.','YesNo'),('ceilingDueDate','',NULL,'If set, date due will not be past this date.  Enter date according to the dateformat System Preference','free'),('checkdigit','none','none|katipo','If ON, enable checks on patron cardnumber: none or \"Katipo\" style checks','Choice'),('CI-3M:AuthorizedIPs','','','Authorized IPs for CI3M magnetisation','Free'),('CircAutocompl','1',NULL,'If ON, autocompletion is enabled for the Circulation input','YesNo'),('CircControl','ItemHomeLibrary','PickupLibrary|PatronLibrary|ItemHomeLibrary','Specify the agency that controls the circulation and fines policy','Choice'),('CsvProfileForExport','ECHANGE','','Set a profile name for CSV export',''),('CurrencyFormat','US','US|FR','Determines the display format of currencies. eg: \'36000\' is displayed as \'360 000,00\'  in \'FR\' or \'360,000.00\'  in \'US\'.','Choice'),('dateformat','metric','metric|us|iso','Define global date format (us mm/dd/yyyy, metric dd/mm/yyy, ISO yyyy/mm/dd)','Choice'),('DebugLevel','2','0|1|2','Define the level of debugging information sent to the browser when errors are encountered (set to 0 in production). 0=none, 1=some, 2=most','Choice'),('DefaultClassificationSource','ddc',NULL,'Default classification scheme used by the collection. E.g., Dewey, LCC, etc.','ClassSources'),('defaultSortField',NULL,'relevance|popularity|call_number|pubdate|acqdate|title|author','Specify the default field used for sorting','Choice'),('defaultSortOrder',NULL,'asc|dsc|az|za','Specify the default sort order','Choice'),('delimiter',';',';|tabulation|,|/|\\|#||','Define the default separator character for exporting reports','Choice'),('DisplayClearScreenButton','0','','If set to ON, a clear screen button will appear on the circulation page.','YesNo'),('DisplayOPACiconsXSLT','1','','If ON, displays the format, audience, type icons in XSLT MARC21 results and display pages.','YesNo'),('dontmerge','1',NULL,'If ON, modifying an authority record will not update all associated bibliographic records immediately, ask your system administrator to enable the merge_authorities.pl cron job','YesNo'),('emailLibrarianWhenHoldIsPlaced','0',NULL,'If ON, emails the librarian whenever a hold is placed','YesNo'),('EnableOpacSearchHistory','1','YesNo','Enable or disable opac search history',''),('EnhancedMessagingPreferences','0','','If ON, allows patrons to select to receive additional messages about items due or nearly due.','YesNo'),('expandedSearchOption','0',NULL,'If ON, set advanced search to be expanded by default','YesNo'),('ExtendedPatronAttributes','1','','Use extended patron IDs and attributes','YesNo'),('FilterBeforeOverdueReport','0','','Do not run overdue report until filter selected','YesNo'),('finesCalendar','noFinesWhenClosed','ignoreCalendar|noFinesWhenClosed','Specify whether to use the Calendar in calculating duedates and fines','Choice'),('FinesLog','1',NULL,'If ON, log fines','YesNo'),('finesMode','test','off|test|production','Choose the fines mode, \'off\', \'test\' (emails admin report) or \'production\' (accrue overdue fines).  Requires accruefines cronjob.','Choice'),('FrameworksLoaded','authorities_normal_unimarc.sql|class_sources.sql|message_transport_types.sql|sample_notices.sql|stopwords.sql|subtag_registry.sql|sysprefs.sql|unimarc_framework_DEFAULT.sql|userflags.sql|userpermissions.sql',NULL,'Frameworks loaded through webinstaller','choice'),('FRBRizeEditions','0','','If ON, Koha will query one or more ISBN web services for associated ISBNs and display an Editions tab on the details pages','YesNo'),('gist','0','','Default Goods and Services tax rate NOT in %, but in numeric form (0.12 for 12%), set to 0 to disable GST','Integer'),('globalDueDate','','10','If set, allows a global static due date for all checkouts','free'),('GoogleJackets','0',NULL,'if ON, displays jacket covers from Google Books API','YesNo'),('GranularPermissions','0',NULL,'Use detailed staff user permissions','YesNo'),('hidelostitems','0','','If ON, disables display of\"lost\" items in OPAC.','YesNo'),('HidePatronName','0','','If this is switched on, patron\'s cardnumber will be shown instead of their name on the holds and catalog screens','YesNo'),('hide_marc','0',NULL,'If ON, disables display of MARC fields, subfield codes & indicators (still shows data)','YesNo'),('holdCancelLength','',NULL,'Specify how many days before a hold is canceled','Integer'),('HomeOrHoldingBranch','holdingbranch','holdingbranch|homebranch','Used by Circulation to determine which branch of an item to check with independent branches on, and by search to determine which branch to choose for availability ','Choice'),('ILS-DI','0','','Enables ILS-DI services at OPAC.','YesNo'),('ILS-DI:Authorized_IPs','','Restricts usage of ILS-DI to some IPs','.','Free'),('ImageLimit','5','','Limit images stored in the database by the Patron Card image manager to this number.','Integer'),('IndependantBranches','0',NULL,'If ON, increases security between libraries','YesNo'),('IndependentBranchPatron','0',NULL,'If ON, librarian patron search can only be done on patron of same library as librarian','YesNo'),('InProcessingToShelvingCart','0','','If set, when any item with a location code of PROC is \'checked in\', it\'s location code will be changed to CART.','YesNo'),('insecure','0',NULL,'If ON, bypasses all authentication. Be careful!','YesNo'),('IntranetBiblioDefaultView','normal','normal|marc|isbd|labeled_marc','Choose the default detail view in the staff interface; choose between normal, labeled_marc, marc or isbd','Choice'),('intranetbookbag','1','','If ON, enables display of Cart feature in the intranet','YesNo'),('intranetcolorstylesheet','','50','Define the color stylesheet to use in the Staff Client','free'),('IntranetmainUserblock','','70|10','Add a block of HTML that will display on the intranet home page','Textarea'),('IntranetNav','','70|10','Use HTML tabs to add navigational links to the top-hand navigational bar in the Staff Client','Textarea'),('intranetreadinghistory','1','','If ON, Reading History is enabled for all patrons','YesNo'),('intranetstylesheet','','50','Enter a complete URL to use an alternate layout stylesheet in Intranet','free'),('intranetuserjs','','70|10','Custom javascript for inclusion in Intranet','Textarea'),('IntranetXSLTDetailsDisplay','','','Enable XSL stylesheet control over details page display on Intranet exemple : ../koha-tmpl/intranet-tmpl/prog/en/xslt/MARC21slim2intranetDetail.xsl','Free'),('IntranetXSLTResultsDisplay','','','Enable XSL stylesheet control over results page display on Intranet exemple : ../koha-tmpl/intranet-tmpl/prog/en/xslt/MARC21slim2intranetResults.xsl','Free'),('intranet_includes','includes',NULL,'The includes directory you want for specific look of Koha (includes or includes_npl for example)','Free'),('ISBD','#100||{ 100a }{ 100b }{ 100c }{ 100d }{ 110a }{ 110b }{ 110c }{ 110d }{ 110e }{ 110f }{ 110g }{ 130a }{ 130d }{ 130f }{ 130g }{ 130h }{ 130k }{ 130l }{ 130m }{ 130n }{ 130o }{ 130p }{ 130r }{ 130s }{ 130t }|<br/><br/>\r\n#245||{ 245a }{ 245b }{245f }{ 245g }{ 245k }{ 245n }{ 245p }{ 245s }{ 245h }|\r\n#246||{ : 246i }{ 246a }{ 246b }{ 246f }{ 246g }{ 246n }{ 246p }{ 246h }|\r\n#242||{ = 242a }{ 242b }{ 242n }{ 242p }{ 242h }|\r\n#245||{ 245c }|\r\n#242||{ = 242c }|\r\n#250| - |{ 250a }{ 250b }|\r\n#254|, |{ 254a }|\r\n#255|, |{ 255a }{ 255b }{ 255c }{ 255d }{ 255e }{ 255f }{ 255g }|\r\n#256|, |{ 256a }|\r\n#257|, |{ 257a }|\r\n#258|, |{ 258a }{ 258b }|\r\n#260| - |{ 260a }{ 260b }{ 260c }|\r\n#300| - |{ 300a }{ 300b }{ 300c }{ 300d }{ 300e }{ 300f }{ 300g }|\r\n#306| - |{ 306a }|\r\n#307| - |{ 307a }{ 307b }|\r\n#310| - |{ 310a }{ 310b }|\r\n#321| - |{ 321a }{ 321b }|\r\n#340| - |{ 3403 }{ 340a }{ 340b }{ 340c }{ 340d }{ 340e }{ 340f }{ 340h }{ 340i }|\r\n#342| - |{ 342a }{ 342b }{ 342c }{ 342d }{ 342e }{ 342f }{ 342g }{ 342h }{ 342i }{ 342j }{ 342k }{ 342l }{ 342m }{ 342n }{ 342o }{ 342p }{ 342q }{ 342r }{ 342s }{ 342t }{ 342u }{ 342v }{ 342w }|\r\n#343| - |{ 343a }{ 343b }{ 343c }{ 343d }{ 343e }{ 343f }{ 343g }{ 343h }{ 343i }|\r\n#351| - |{ 3513 }{ 351a }{ 351b }{ 351c }|\r\n#352| - |{ 352a }{ 352b }{ 352c }{ 352d }{ 352e }{ 352f }{ 352g }{ 352i }{ 352q }|\r\n#362| - |{ 362a }{ 351z }|\r\n#440| - |{ 440a }{ 440n }{ 440p }{ 440v }{ 440x }|.\r\n#490| - |{ 490a }{ 490v }{ 490x }|.\r\n#800| - |{ 800a }{ 800b }{ 800c }{ 800d }{ 800e }{ 800f }{ 800g }{ 800h }{ 800j }{ 800k }{ 800l }{ 800m }{ 800n }{ 800o }{ 800p }{ 800q }{ 800r }{ 800s }{ 800t }{ 800u }{ 800v }|.\r\n#810| - |{ 810a }{ 810b }{ 810c }{ 810d }{ 810e }{ 810f }{ 810g }{ 810h }{ 810k }{ 810l }{ 810m }{ 810n }{ 810o }{ 810p }{ 810r }{ 810s }{ 810t }{ 810u }{ 810v }|.\r\n#811| - |{ 811a }{ 811c }{ 811d }{ 811e }{ 811f }{ 811g }{ 811h }{ 811k }{ 811l }{ 811n }{ 811p }{ 811q }{ 811s }{ 811t }{ 811u }{ 811v }|.\r\n#830| - |{ 830a }{ 830d }{ 830f }{ 830g }{ 830h }{ 830k }{ 830l }{ 830m }{ 830n }{ 830o }{ 830p }{ 830r }{ 830s }{ 830t }{ 830v }|.\r\n#500|<br/><br/>|{ 5003 }{ 500a }|\r\n#501|<br/><br/>|{ 501a }|\r\n#502|<br/><br/>|{ 502a }|\r\n#504|<br/><br/>|{ 504a }|\r\n#505|<br/><br/>|{ 505a }{ 505t }{ 505r }{ 505g }{ 505u }|\r\n#506|<br/><br/>|{ 5063 }{ 506a }{ 506b }{ 506c }{ 506d }{ 506u }|\r\n#507|<br/><br/>|{ 507a }{ 507b }|\r\n#508|<br/><br/>|{ 508a }{ 508a }|\r\n#510|<br/><br/>|{ 5103 }{ 510a }{ 510x }{ 510c }{ 510b }|\r\n#511|<br/><br/>|{ 511a }|\r\n#513|<br/><br/>|{ 513a }{513b }|\r\n#514|<br/><br/>|{ 514z }{ 514a }{ 514b }{ 514c }{ 514d }{ 514e }{ 514f }{ 514g }{ 514h }{ 514i }{ 514j }{ 514k }{ 514m }{ 514u }|\r\n#515|<br/><br/>|{ 515a }|\r\n#516|<br/><br/>|{ 516a }|\r\n#518|<br/><br/>|{ 5183 }{ 518a }|\r\n#520|<br/><br/>|{ 5203 }{ 520a }{ 520b }{ 520u }|\r\n#521|<br/><br/>|{ 5213 }{ 521a }{ 521b }|\r\n#522|<br/><br/>|{ 522a }|\r\n#524|<br/><br/>|{ 524a }|\r\n#525|<br/><br/>|{ 525a }|\r\n#526|<br/><br/>|{\\n510i }{\\n510a }{ 510b }{ 510c }{ 510d }{\\n510x }|\r\n#530|<br/><br/>|{\\n5063 }{\\n506a }{ 506b }{ 506c }{ 506d }{\\n506u }|\r\n#533|<br/><br/>|{\\n5333 }{\\n533a }{\\n533b }{\\n533c }{\\n533d }{\\n533e }{\\n533f }{\\n533m }{\\n533n }|\r\n#534|<br/><br/>|{\\n533p }{\\n533a }{\\n533b }{\\n533c }{\\n533d }{\\n533e }{\\n533f }{\\n533m }{\\n533n }{\\n533t }{\\n533x }{\\n533z }|\r\n#535|<br/><br/>|{\\n5353 }{\\n535a }{\\n535b }{\\n535c }{\\n535d }|\r\n#538|<br/><br/>|{\\n5383 }{\\n538a }{\\n538i }{\\n538u }|\r\n#540|<br/><br/>|{\\n5403 }{\\n540a }{ 540b }{ 540c }{ 540d }{\\n520u }|\r\n#544|<br/><br/>|{\\n5443 }{\\n544a }{\\n544b }{\\n544c }{\\n544d }{\\n544e }{\\n544n }|\r\n#545|<br/><br/>|{\\n545a }{ 545b }{\\n545u }|\r\n#546|<br/><br/>|{\\n5463 }{\\n546a }{ 546b }|\r\n#547|<br/><br/>|{\\n547a }|\r\n#550|<br/><br/>|{ 550a }|\r\n#552|<br/><br/>|{ 552z }{ 552a }{ 552b }{ 552c }{ 552d }{ 552e }{ 552f }{ 552g }{ 552h }{ 552i }{ 552j }{ 552k }{ 552l }{ 552m }{ 552n }{ 562o }{ 552p }{ 552u }|\r\n#555|<br/><br/>|{ 5553 }{ 555a }{ 555b }{ 555c }{ 555d }{ 555u }|\r\n#556|<br/><br/>|{ 556a }{ 506z }|\r\n#563|<br/><br/>|{ 5633 }{ 563a }{ 563u }|\r\n#565|<br/><br/>|{ 5653 }{ 565a }{ 565b }{ 565c }{ 565d }{ 565e }|\r\n#567|<br/><br/>|{ 567a }|\r\n#580|<br/><br/>|{ 580a }|\r\n#581|<br/><br/>|{ 5633 }{ 581a }{ 581z }|\r\n#584|<br/><br/>|{ 5843 }{ 584a }{ 584b }|\r\n#585|<br/><br/>|{ 5853 }{ 585a }|\r\n#586|<br/><br/>|{ 5863 }{ 586a }|\r\n#020|<br/><br/><label>ISBN: </label>|{ 020a }{ 020c }|\r\n#022|<br/><br/><label>ISSN: </label>|{ 022a }|\r\n#222| = |{ 222a }{ 222b }|\r\n#210| = |{ 210a }{ 210b }|\r\n#024|<br/><br/><label>Standard No.: </label>|{ 024a }{ 024c }{ 024d }{ 0242 }|\r\n#027|<br/><br/><label>Standard Tech. Report. No.: </label>|{ 027a }|\r\n#028|<br/><br/><label>Publisher. No.: </label>|{ 028a }{ 028b }|\r\n#013|<br/><br/><label>Patent No.: </label>|{ 013a }{ 013b }{ 013c }{ 013d }{ 013e }{ 013f }|\r\n#030|<br/><br/><label>CODEN: </label>|{ 030a }|\r\n#037|<br/><br/><label>Source: </label>|{ 037a }{ 037b }{ 037c }{ 037f }{ 037g }{ 037n }|\r\n#010|<br/><br/><label>LCCN: </label>|{ 010a }|\r\n#015|<br/><br/><label>Nat. Bib. No.: </label>|{ 015a }{ 0152 }|\r\n#016|<br/><br/><label>Nat. Bib. Agency Control No.: </label>|{ 016a }{ 0162 }|\r\n#600|<br/><br/><label>Subjects--Personal Names: </label>|{\\n6003 }{\\n600a}{ 600b }{ 600c }{ 600d }{ 600e }{ 600f }{ 600g }{ 600h }{--600k}{ 600l }{ 600m }{ 600n }{ 600o }{--600p}{ 600r }{ 600s }{ 600t }{ 600u }{--600x}{--600z}{--600y}{--600v}|\r\n#610|<br/><br/><label>Subjects--Corporate Names: </label>|{\\n6103 }{\\n610a}{ 610b }{ 610c }{ 610d }{ 610e }{ 610f }{ 610g }{ 610h }{--610k}{ 610l }{ 610m }{ 610n }{ 610o }{--610p}{ 610r }{ 610s }{ 610t }{ 610u }{--610x}{--610z}{--610y}{--610v}|\r\n#611|<br/><br/><label>Subjects--Meeting Names: </label>|{\\n6113 }{\\n611a}{ 611b }{ 611c }{ 611d }{ 611e }{ 611f }{ 611g }{ 611h }{--611k}{ 611l }{ 611m }{ 611n }{ 611o }{--611p}{ 611r }{ 611s }{ 611t }{ 611u }{--611x}{--611z}{--611y}{--611v}|\r\n#630|<br/><br/><label>Subjects--Uniform Titles: </label>|{\\n630a}{ 630b }{ 630c }{ 630d }{ 630e }{ 630f }{ 630g }{ 630h }{--630k }{ 630l }{ 630m }{ 630n }{ 630o }{--630p}{ 630r }{ 630s }{ 630t }{--630x}{--630z}{--630y}{--630v}|\r\n#648|<br/><br/><label>Subjects--Chronological Terms: </label>|{\\n6483 }{\\n648a }{--648x}{--648z}{--648y}{--648v}|\r\n#650|<br/><br/><label>Subjects--Topical Terms: </label>|{\\n6503 }{\\n650a}{ 650b }{ 650c }{ 650d }{ 650e }{--650x}{--650z}{--650y}{--650v}|\r\n#651|<br/><br/><label>Subjects--Geographic Terms: </label>|{\\n6513 }{\\n651a}{ 651b }{ 651c }{ 651d }{ 651e }{--651x}{--651z}{--651y}{--651v}|\r\n#653|<br/><br/><label>Subjects--Index Terms: </label>|{ 653a }|\r\n#654|<br/><br/><label>Subjects--Facted Index Terms: </label>|{\\n6543 }{\\n654a}{--654b}{--654x}{--654z}{--654y}{--654v}|\r\n#655|<br/><br/><label>Index Terms--Genre/Form: </label>|{\\n6553 }{\\n655a}{--655b}{--655x }{--655z}{--655y}{--655v}|\r\n#656|<br/><br/><label>Index Terms--Occupation: </label>|{\\n6563 }{\\n656a}{--656k}{--656x}{--656z}{--656y}{--656v}|\r\n#657|<br/><br/><label>Index Terms--Function: </label>|{\\n6573 }{\\n657a}{--657x}{--657z}{--657y}{--657v}|\r\n#658|<br/><br/><label>Index Terms--Curriculum Objective: </label>|{\\n658a}{--658b}{--658c}{--658d}{--658v}|\r\n#050|<br/><br/><label>LC Class. No.: </label>|{ 050a }{ / 050b }|\r\n#082|<br/><br/><label>Dewey Class. No.: </label>|{ 082a }{ / 082b }|\r\n#080|<br/><br/><label>Universal Decimal Class. No.: </label>|{ 080a }{ 080x }{ / 080b }|\r\n#070|<br/><br/><label>National Agricultural Library Call No.: </label>|{ 070a }{ / 070b }|\r\n#060|<br/><br/><label>National Library of Medicine Call No.: </label>|{ 060a }{ / 060b }|\r\n#074|<br/><br/><label>GPO Item No.: </label>|{ 074a }|\r\n#086|<br/><br/><label>Gov. Doc. Class. No.: </label>|{ 086a }|\r\n#088|<br/><br/><label>Report. No.: </label>|{ 088a }|','70|10','ISBD','Textarea'),('IssueLog','1',NULL,'If ON, log checkout activity','YesNo'),('IssuingInProcess','0',NULL,'If ON, disables fines if the patron is issuing item that accumulate debt','YesNo'),('item-level_itypes','1','','If ON, enables Item-level Itemtype / Issuing Rules','YesNo'),('itemBarcodeInputFilter','','whitespace|T-prefix|cuecat','If set, allows specification of a item barcode input filter','Choice'),('itemcallnumber','082ab',NULL,'The MARC field/subfield that is used to calculate the itemcallnumber (Dewey would be 082ab or 092ab; LOC would be 050ab or 090ab) could be 852hi from an item record','free'),('KohaAdminEmailAddress','root@localhost','','Define the email address where patron modification requests are sent','free'),('kohaspsuggest','','','Track search queries, turn on by defining host:dbname:user:pass',''),('LabelMARCView','standard','standard|economical','Define how a MARC record will display','Choice'),('language','en',NULL,'Set the default language in the staff client.','Languages'),('LetterLog','1',NULL,'If ON, log all notices sent','YesNo'),('libraryAddress','',NULL,'The address to use for printing receipts, overdues, etc. if different than physical address','free'),('LibraryName','','','Define the library name as displayed on the OPAC',''),('LibraryThingForLibrariesEnabled','0','','Enable or Disable Library Thing for Libraries Features','YesNo'),('LibraryThingForLibrariesID','','','See:http://librarything.com/forlibraries/','free'),('LibraryThingForLibrariesTabbedView','0','','Put LibraryThingForLibraries Content in Tabs.','YesNo'),('LibraryType','Special','Academic|Public|Special','Set a type for the library','Choice'),('marc','1',NULL,'Turn on MARC support','YesNo'),('marcflavour','UNIMARC','MARC21|UNIMARC','Define global MARC flavor (MARC21 or UNIMARC) used for character encoding','Choice'),('MARCOrgCode','OSt','','Define MARC Organization Code - http://www.loc.gov/marc/organizations/orgshome.html','free'),('MaxFine','9999','','Maximum fine a patron can have for a single late return','Integer'),('maxoutstanding','5','','maximum amount withstanding to be able make holds','Integer'),('MeansOfPayment','Undefined|Cash|Cheque|Bank card|Credit transfer|Direct debit','Undefined|Cash|Cheque|Bank card|Credit transfer|Direct debit','Define means of payment for borrowers payments','free'),('memberofinstitution','0',NULL,'If ON, patrons can be linked to institutions','YesNo'),('MIME','EXCEL','EXCEL|OPENOFFICE.ORG','Define the default application for exporting report data','Choice'),('minPasswordLength','3',NULL,'Specify the minimum length of a patron/staff password','free'),('NewItemsDefaultLocation','','','If set, all new items will have a location of the given Location Code ( Authorized Value type LOC )',''),('noissuescharge','5','','Define maximum amount withstanding before check outs are blocked','Integer'),('noItemTypeImages','0',NULL,'If ON, disables item-type images','YesNo'),('NotifyBorrowerDeparture','30',NULL,'Define number of days before expiry where circulation is warned about patron account expiry','Integer'),('NoZebra','0','','If ON, Zebra indexing is turned off, simpler setup, but slower searches. WARNING: using NoZebra on even modest sized collections is very slow.','YesNo'),('NoZebraIndexes','\'title\' => \'130a,210a,222a,240a,243a,245a,245b,246a,246b,247a,247b,250a,250b,440a,830a\',\r\n\'author\' => \'100a,100b,100c,100d,110a,111a,111b,111c,111d,245c,700a,710a,711a,800a,810a,811a\',\r\n\'isbn\' => \'020a\',\r\n\'issn\' => \'022a\',\r\n\'lccn\' => \'010a\',\r\n\'biblionumber\' => \'999c\',\r\n\'itemtype\' => \'942c\',\r\n\'publisher\' => \'260b\',\r\n\'date\' => \'260c\',\r\n\'note\' => \'500a, 501a,504a,505a,508a,511a,518a,520a,521a,522a,524a,526a,530a,533a,538a,541a,546a,555a,556a,562a,563a,583a,585a,582a\',\r\n\'subject\' => \'600*,610*,611*,630*,650*,651*,653*,654*,655*,662*,690*\',\r\n\'dewey\' => \'082\',\r\n\'bc\' => \'952p\',\r\n\'callnum\' => \'952o\',\r\n\'an\' => \'6009,6109,6119\',\r\n\'homebranch\' => \'952a,952c\'','70|10','Enter a specific hash for NoZebra indexes. Enter : \'indexname\' => \'100a,245a,500*\',\'index2\' => \'...\'','Textarea'),('numReturnedItemsToShow','20',NULL,'Number of returned items to show on the check-in page','Integer'),('numSearchResults','20',NULL,'Specify the maximum number of results to display on a page of results','Integer'),('OAI-PMH','0',NULL,'if ON, OAI-PMH server is enabled','YesNo'),('OAI-PMH:archiveID','KOHA-OAI-TEST',NULL,'OAI-PMH archive identification','Free'),('OAI-PMH:ConfFile','',NULL,'If empty, Koha OAI Server operates in normal mode, otherwise it operates in extended mode.','File'),('OAI-PMH:MaxCount','50',NULL,'OAI-PMH maximum number of records by answer to ListRecords and ListIdentifiers queries','Integer'),('OAI-PMH:Set','SET,Experimental set\r\nSET:SUBSET,Experimental subset','30|10','OAI-PMH exported set, the set name is followed by a comma and a short description, one set by line','Textarea'),('OCLCAffiliateID','','','Use with FRBRizeEditions and XISBN. You can sign up for an AffiliateID here: http://www.worldcat.org/wcpa/do/AffiliateUserServices?method=initSelfRegister','free'),('OpacAddMastheadLibraryPulldown','0','','Adds a pulldown menu to select the library to search on the opac masthead.','YesNo'),('OpacAdvancedSearchContent','','70|10','Use HTML tabs to create your own advanced search menu in OPAC','Textarea'),('OPACAllowHoldDateInFuture','0','','If set, along with the AllowHoldDateInFuture system preference, OPAC users can set the date of a hold to be in the future.','YesNo'),('OPACAmazonCoverImages','0','','Display cover images on OPAC from Amazon Web Services','YesNo'),('OPACAmazonEnabled','0','','Turn ON Amazon Content in the OPAC - You MUST set AWSAccessKeyID, AWSPrivateKey, and AmazonAssocTag if enabled','YesNo'),('OPACAmazonReviews','0','','Display Amazon readers reviews on OPAC','YesNo'),('OPACAmazonSimilarItems','0','','Turn ON Amazon Similar Items feature  - You MUST set AWSAccessKeyID, AWSPrivateKey, and AmazonAssocTag if enabled','YesNo'),('OpacAuthorities','1',NULL,'If ON, enables the search authorities link on OPAC','YesNo'),('OPACBaseURL',NULL,NULL,'Specify the Base URL of the OPAC, e.g., opac.mylibrary.com, the http:// will be added automatically by Koha.','Free'),('opacbookbag','1','','If ON, enables display of Cart feature','YesNo'),('OpacBrowser','0',NULL,'If ON, enables subject authorities browser on OPAC (needs to set misc/cronjob/sbuild_browser_and_cloud.pl)','YesNo'),('OpacCloud','0',NULL,'If ON, enables subject cloud on OPAC','YesNo'),('opaccolorstylesheet','colors.css','','Define the color stylesheet to use in the OPAC','free'),('opaccredits','','70|10','Define HTML Credits at the bottom of the OPAC page','Textarea'),('OPACdefaultSortField',NULL,'relevance|popularity|call_number|pubdate|acqdate|title|author','Specify the default field used for sorting','Choice'),('OPACdefaultSortOrder',NULL,'asc|dsc|za|az','Specify the default sort order','Choice'),('OPACDisplayExtendedSubInfo','1',NULL,'If ON, extended subscription information is displayed in the OPAC','YesNo'),('OPACDisplayRequestPriority','0','','Show patrons the priority level on holds in the OPAC','YesNo'),('OPACFineNoRenewals','100','','Fine limit above which user cannot renew books via OPAC','Integer'),('OPACFinesTab','1','','If OFF the patron fines tab in the OPAC is disabled.','YesNo'),('OPACFRBRizeEditions','0','','If ON, the OPAC will query one or more ISBN web services for associated ISBNs and display an Editions tab on the details pages','YesNo'),('opacheader','','70|10','Add HTML to be included as a custom header in the OPAC','Textarea'),('OpacHighlightedWords','1','','If Set, then queried words are higlighted in OPAC','YesNo'),('OPACItemHolds','1','','Allow OPAC users to place hold on specific items. If OFF, users can only request next available copy.','YesNo'),('OPACItemsResultsDisplay','statuses','statuses|itemdetails','statuses : show only the status of items in result list. itemdisplay : show full location of items (branch+location+callnumber) as in staff interface','Choice'),('opaclanguages','en',NULL,'Set the default language in the OPAC.','Languages'),('opaclanguagesdisplay','0','','If ON, enables display of Change Language feature on OPAC','YesNo'),('opaclayoutstylesheet','opac.css','','Enter the name of the layout CSS stylesheet to use in the OPAC','free'),('OpacMaintenance','0','','If ON, enables maintenance warning in OPAC','YesNo'),('OpacMainUserBlock','Welcome to Koha...\r\n<hr>','70|10','A user-defined block of HTML  in the main content area of the opac main page','Textarea'),('OpacNav','Important links here.','70|10','Use HTML tags to add navigational links to the left-hand navigational bar in OPAC','Textarea'),('OPACnumSearchResults','20',NULL,'Specify the maximum number of results to display on a page of results','Integer'),('OpacPasswordChange','1',NULL,'If ON, enables patron-initiated password change in OPAC (disable it when using LDAP auth)','YesNo'),('OPACPatronDetails','1','','If OFF the patron details tab in the OPAC is disabled.','YesNo'),('OPACPickUpLocation','1','','Enable Pickup location choice for holds','YesNo'),('opacreadinghistory','1','','If ON, enables display of Patron Circulation History in OPAC','YesNo'),('OpacRenewalAllowed','0',NULL,'If ON, users can renew their issues directly from their OPAC account','YesNo'),('OPACSearchForTitleIn','<li><a  href=\"http://worldcat.org/search?q={TITLE}\" target=\"_blank\">Other Libraries (WorldCat)</a></li>\n<li><a href=\"http://www.scholar.google.com/scholar?q={TITLE}\" target=\"_blank\">Other Databases (Google Scholar)</a></li>\n<li><a href=\"http://www.bookfinder.com/search/?author={AUTHOR}&amp;title={TITLE}&amp;st=xl&amp;ac=qr\" target=\"_blank\">Online Stores (Bookfinder.com)</a></li>','70|10','Enter the HTML that will appear in the \'Search for this title in\' box on the detail page in the OPAC.  Enter {TITLE}, {AUTHOR}, or {ISBN} in place of their respective variables in the URL. Leave blank to disable \'More Searches\' menu.','Textarea'),('OPACSearchReboundBy','term','term|authority','determines if the rebound search use authority number or term.','Choice'),('opacSerialDefaultTab','subscriptions','holdings|serialcollection|subscriptions','Define the default tab for serials in OPAC.','Choice'),('OPACSerialIssueDisplayCount','3','','Number of serial issues to display per subscription in the OPAC','Integer'),('OPACShelfBrowser','1','','Enable/disable Shelf Browser on item details page. WARNING: this feature is very resource consuming on collections with large numbers of items.','YesNo'),('OPACShowCheckoutName','0','','Displays in the OPAC the name of patron who has checked out the material. WARNING: Most sites should leave this off. It is intended for corporate or special sites which need to track who has the item.','YesNo'),('opacsmallimage','','','Enter a complete URL to an image to replace the default Koha logo','free'),('opacstylesheet','','','Enter a complete URL to use an alternate layout stylesheet in OPAC','free'),('OPACSubscriptionDisplay','economical','economical|off|full','Specify how to display subscription information in the OPAC','Choice'),('OpacSuppression','0','','Turn ON the OPAC Suppression feature, requires further setup, ask your system administrator for details','YesNo'),('opacthemes','prog','','Define the current theme for the OPAC interface.','Themes'),('OpacTopissue','0',NULL,'If ON, enables the \'most popular items\' link on OPAC. Warning, this is an EXPERIMENTAL feature, turning ON may overload your server','YesNo'),('OPACURLOpenInNewWindow','0',NULL,'If ON, URLs in the OPAC open in a new window','YesNo'),('OPACUserCSS','',NULL,'Add CSS to be included in the OPAC in an embedded <style> tag.','free'),('opacuserjs','','70|10','Define custom javascript for inclusion in OPAC','Textarea'),('opacuserlogin','1',NULL,'Enable or disable display of user login features','YesNo'),('OPACviewISBD','1','','Allow display of ISBD view of bibiographic records in OPAC','YesNo'),('OPACviewMARC','1','','Allow display of MARC view of bibiographic records in OPAC','YesNo'),('OPACViewOthersSuggestions','0',NULL,'If ON, allows all suggestions to be displayed in the OPAC','YesNo'),('OPACXSLTDetailsDisplay','','','Enable XSL stylesheet control over details page display on OPAC exemple : ../koha-tmpl/opac-tmpl/prog/en/xslt/MARC21slim2OPACDetail.xsl','Free'),('OPACXSLTResultsDisplay','','','Enable XSL stylesheet control over results page display on OPAC exemple : ../koha-tmpl/opac-tmpl/prog/en/xslt/MARC21slim2OPACResults.xsl','Free'),('OrderPdfFormat','pdfformat::layout3pages','Controls what script is used for printing (basketgroups)','','free'),('OrderPdfTemplate','','NULL','Uploads a PDF template to use for printing baskets','Upload'),('OverdueNoticeBcc','','','Email address to bcc outgoing overdue notices sent by email','free'),('OverduesBlockCirc','noblock','noblock|confirmation|block','When checking out an item should overdues block checkout, generate a confirmation dialogue, or allow checkout','Choice'),('patronimages','0',NULL,'Enable patron images for the Staff Client','YesNo'),('PatronsPerPage','20','20','Number of Patrons Per Page displayed by default','Integer'),('PINESISBN','0','','Use with FRBRizeEditions. If ON, Koha will use PINES OISBN web service in the Editions tab on the detail pages.','YesNo'),('PrefillItem','0','','When a new item is added, should it be prefilled with last created item values?','YesNo'),('previousIssuesDefaultSortOrder','asc','asc|desc','Specify the sort order of Previous Issues on the circulation page','Choice'),('printcirculationslips','1','','If ON, enable printing circulation receipts','YesNo'),('PrintNoticesMaxLines','0','','If greater than 0, sets the maximum number of lines an overdue notice will print. If the number of items is greater than this number, the notice will end with a warning asking the borrower to check their online account for a full list of overdue items.','Integer'),('QueryAutoTruncate','1',NULL,'If ON, query truncation is enabled by default','YesNo'),('QueryFuzzy','1',NULL,'If ON, enables fuzzy option for searches','YesNo'),('QueryRemoveStopwords','0',NULL,'If ON, stopwords listed in the Administration area will be removed from queries','YesNo'),('QueryStemming','1',NULL,'If ON, enables query stemming','YesNo'),('QueryWeightFields','1',NULL,'If ON, enables field weighting','YesNo'),('RandomizeHoldsQueueWeight','0',NULL,'if ON, the holds queue in circulation will be randomized, either based on all location codes, or by the location codes specified in StaticHoldsQueueWeight','YesNo'),('RenewalPeriodBase','date_due','date_due|now','Set whether the renewal date should be counted from the date_due or from the moment the Patron asks for renewal ','Choice'),('RenewSerialAddsSuggestion','0',NULL,'If ON, adds a new suggestion at serial subscription renewal','YesNo'),('RequestOnOpac','1',NULL,'If ON, globally enables patron holds on OPAC','YesNo'),('ReservesControlBranch','PatronLibrary','ItemHomeLibrary|PatronLibrary','Branch checked for members reservations rights','Choice'),('ReservesNeedReturns','1','','If ON, a hold placed on an item available in this library must be checked-in, otherwise, a hold on a specific item, that is in the library & available is considered available','YesNo'),('ReturnBeforeExpiry','0',NULL,'If ON, checkout will be prevented if returndate is after patron card expiry','YesNo'),('ReturnLog','1',NULL,'If ON, enables the circulation (returns) log','YesNo'),('ReturnToShelvingCart','0','','If set, when any item is \'checked in\', it\'s location code will be changed to CART.','YesNo'),('reviewson','1','','If ON, enables patron reviews of bibliographic records in the OPAC','YesNo'),('RoutingListAddReserves','1','','If ON the patrons on routing lists are automatically added to holds on the issue.','YesNo'),('RoutingSerials','1',NULL,'If ON, serials routing is enabled','YesNo'),('SearchMyLibraryFirst','0',NULL,'If ON, OPAC searches return results limited by the user\'s library by default if they are logged in','YesNo'),('SessionStorage','mysql','mysql|Pg|tmp','Use database or a temporary file for storing session data','Choice'),('ShowPatronImageInWebBasedSelfCheck','0','','If ON, displays patron image when a patron uses web-based self-checkout','YesNo'),('singleBranchMode','0',NULL,'Operate in Single-branch mode, hide branch selection in the OPAC','YesNo'),('SMSSendDriver','','','Sets which SMS::Send driver is used to send SMS messages.','free'),('sortbynonfiling','0',NULL,'Sort search results by MARC nonfiling characters (deprecated)','YesNo'),('soundon','0','','Enable circulation sounds during checkin and checkout in the staff interface.  Not supported by all web browsers yet.','YesNo'),('SpecifyDueDate','1','','Define whether to display \"Specify Due Date\" form in Circulation','YesNo'),('SpineLabelAutoPrint','0','','If this setting is turned on, a print dialog will automatically pop up for the quick spine label printer.','YesNo'),('SpineLabelFormat','<itemcallnumber><copynumber>','30|10','This preference defines the format for the quick spine label printer. Just list the fields you would like to see in the order you would like to see them, surrounded by <>, for example <itemcallnumber>.','Textarea'),('SpineLabelShowPrintOnBibDetails','0','','If turned on, a \"Print Label\" link will appear for each item on the bib details page in the staff interface.','YesNo'),('staffClientBaseURL','',NULL,'Specify the base URL of the staff client','free'),('StaffSerialIssueDisplayCount','3','','Number of serial issues to display per subscription in the Staff client','Integer'),('StaticHoldsQueueWeight','0',NULL,'Specify a list of library location codes separated by commas -- the list of codes will be traversed and weighted with first values given higher weight for holds fulfillment -- alternatively, if RandomizeHoldsQueueWeight is set, the list will be randomly selective','Integer'),('StatisticsFields','location|itype|ccode','location|itype|ccode','Define Fields used for statistics members (5 max !)','free'),('SubscriptionHistory',';','simplified|full','Define the display preference for serials issue history in OPAC','Choice'),('SubscriptionLog','1',NULL,'If ON, enables subscriptions log','YesNo'),('suggestion','1','','If ON, enables patron suggestions feature in OPAC','YesNo'),('SyndeticsAuthorNotes','0','','Display Notes about the Author on OPAC from Syndetics','YesNo'),('SyndeticsAwards','0','','Display Awards on OPAC from Syndetics','YesNo'),('SyndeticsClientCode','0','','Client Code for using Syndetics Solutions content','free'),('SyndeticsCoverImages','0','','Display Cover Images from Syndetics','YesNo'),('SyndeticsCoverImageSize','MC','MC|LC','Choose the size of the Syndetics Cover Image to display on the OPAC detail page, MC is Medium, LC is Large','Choice'),('SyndeticsEditions','0','','Display Editions from Syndetics','YesNo'),('SyndeticsEnabled','0','','Turn on Syndetics Enhanced Content','YesNo'),('SyndeticsExcerpt','0','','Display Excerpts and first chapters on OPAC from Syndetics','YesNo'),('SyndeticsReviews','0','','Display Reviews on OPAC from Syndetics','YesNo'),('SyndeticsSeries','0','','Display Series information on OPAC from Syndetics','YesNo'),('SyndeticsSummary','0','','Display Summary Information from Syndetics','YesNo'),('SyndeticsTOC','0','','Display Table of Content information from Syndetics','YesNo'),('TagsEnabled','1','','Enables or disables all tagging features.  This is the main switch for tags.','YesNo'),('TagsExternalDictionary',NULL,'','Path on server to local ispell executable, used to set $Lingua::Ispell::path  This dictionary is used as a \"whitelist\" of pre-allowed tags.',''),('TagsInputOnDetail','1','','Allow users to input tags from the detail page.','YesNo'),('TagsInputOnList','0','','Allow users to input tags from the search results list.','YesNo'),('TagsModeration',NULL,'','Require tags from patrons to be approved before becoming visible.','YesNo'),('TagsShowOnDetail','10','','Number of tags to display on detail page.  0 is off.','Integer'),('TagsShowOnList','6','','Number of tags to display on search results list.  0 is off.','Integer'),('template','prog','','Define the preferred staff interface template','Themes'),('TemplateEncoding','utf-8','iso-8859-1|utf-8','Globally define the default character encoding','Choice'),('ThingISBN','0','','Use with FRBRizeEditions. If ON, Koha will use the ThingISBN web service in the Editions tab on the detail pages.','YesNo'),('timeout','12000000',NULL,'Inactivity timeout for cookies authentication (in seconds)','Integer'),('todaysIssuesDefaultSortOrder','desc','asc|desc','Specify the sort order of Todays Issues on the circulation page','Choice'),('TransfersMaxDaysWarning','3',NULL,'Define the days before a transfer is suspected of having a problem','Integer'),('uploadPath','','','Sets the upload path for the upload.pl plugin',''),('uploadWebPath','','','Set the upload path starting from document root for the upload.pl plugin',''),('uppercasesurnames','0',NULL,'If ON, surnames are converted to upper case in patron entry form','YesNo'),('URLLinkText','',NULL,'Text to display as the link anchor in the OPAC','free'),('UseBranchTransferLimits','0','','If ON, Koha will will use the rules defined in branch_transfer_limits to decide if an item transfer should be allowed.','YesNo'),('useDaysMode','Calendar','Calendar|Days|Datedue','Choose the method for calculating due date: select Calendar to use the holidays module, and Days to ignore the holidays module','Choice'),('Version','3.0200066',NULL,'The Koha database version. WARNING: Do not change this value manually, it is maintained by the webinstaller',NULL),('viewISBD','1','','Allow display of ISBD view of bibiographic records','YesNo'),('viewLabeledMARC','0','','Allow display of labeled MARC view of bibiographic records','YesNo'),('viewMARC','1','','Allow display of MARC view of bibiographic records','YesNo'),('virtualshelves','1','','If ON, enables Lists management','YesNo'),('WebBasedSelfCheck','0',NULL,'If ON, enables the web-based self-check system','YesNo'),('XISBN','0','','Use with FRBRizeEditions. If ON, Koha will use the OCLC xISBN web service in the Editions tab on the detail pages. See: http://www.worldcat.org/affiliate/webservices/xisbn/app.jsp','YesNo'),('XISBNDailyLimit','499','','The xISBN Web service is free for non-commercial use when usage does not exceed 500 requests per day','Integer'),('yuipath','local','local|http://yui.yahooapis.com/2.5.1/build','Insert the path to YUI libraries, choose local if you use koha offline','Choice'),('z3950AuthorAuthFields','701,702,700',NULL,'Define the MARC biblio fields for Personal Name Authorities to fill biblio.author','free'),('z3950NormalizeAuthor','0','','If ON, Personal Name Authorities will replace authors in biblio.author','YesNo');
/*!40000 ALTER TABLE `systempreferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `entry` varchar(255) NOT NULL DEFAULT '',
  `weight` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags_all`
--

DROP TABLE IF EXISTS `tags_all`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags_all` (
  `tag_id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) NOT NULL,
  `biblionumber` int(11) NOT NULL,
  `term` varchar(255) NOT NULL,
  `language` int(4) DEFAULT NULL,
  `date_created` datetime NOT NULL,
  PRIMARY KEY (`tag_id`),
  KEY `tags_borrowers_fk_1` (`borrowernumber`),
  KEY `tags_biblionumber_fk_1` (`biblionumber`),
  CONSTRAINT `tags_biblionumber_fk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tags_borrowers_fk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags_all`
--

LOCK TABLES `tags_all` WRITE;
/*!40000 ALTER TABLE `tags_all` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags_all` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags_approval`
--

DROP TABLE IF EXISTS `tags_approval`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags_approval` (
  `term` varchar(255) NOT NULL,
  `approved` int(1) NOT NULL DEFAULT '0',
  `date_approved` datetime DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `weight_total` int(9) NOT NULL DEFAULT '1',
  PRIMARY KEY (`term`),
  KEY `tags_approval_borrowers_fk_1` (`approved_by`),
  CONSTRAINT `tags_approval_borrowers_fk_1` FOREIGN KEY (`approved_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags_approval`
--

LOCK TABLES `tags_approval` WRITE;
/*!40000 ALTER TABLE `tags_approval` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags_approval` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags_index`
--

DROP TABLE IF EXISTS `tags_index`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags_index` (
  `term` varchar(255) NOT NULL,
  `biblionumber` int(11) NOT NULL,
  `weight` int(9) NOT NULL DEFAULT '1',
  PRIMARY KEY (`term`,`biblionumber`),
  KEY `tags_index_biblionumber_fk_1` (`biblionumber`),
  CONSTRAINT `tags_index_biblionumber_fk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tags_index_term_fk_1` FOREIGN KEY (`term`) REFERENCES `tags_approval` (`term`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags_index`
--

LOCK TABLES `tags_index` WRITE;
/*!40000 ALTER TABLE `tags_index` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags_index` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tmp_holdsqueue`
--

DROP TABLE IF EXISTS `tmp_holdsqueue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tmp_holdsqueue` (
  `biblionumber` int(11) DEFAULT NULL,
  `itemnumber` int(11) DEFAULT NULL,
  `barcode` varchar(20) DEFAULT NULL,
  `surname` mediumtext NOT NULL,
  `firstname` text,
  `phone` text,
  `borrowernumber` int(11) NOT NULL,
  `cardnumber` varchar(16) DEFAULT NULL,
  `reservedate` date DEFAULT NULL,
  `title` mediumtext,
  `itemcallnumber` varchar(255) DEFAULT NULL,
  `holdingbranch` varchar(10) DEFAULT NULL,
  `pickbranch` varchar(10) DEFAULT NULL,
  `notes` text,
  `item_level_request` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tmp_holdsqueue`
--

LOCK TABLES `tmp_holdsqueue` WRITE;
/*!40000 ALTER TABLE `tmp_holdsqueue` DISABLE KEYS */;
/*!40000 ALTER TABLE `tmp_holdsqueue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_permissions`
--

DROP TABLE IF EXISTS `user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_permissions` (
  `borrowernumber` int(11) NOT NULL DEFAULT '0',
  `module_bit` int(11) NOT NULL DEFAULT '0',
  `code` varchar(64) DEFAULT NULL,
  KEY `user_permissions_ibfk_1` (`borrowernumber`),
  KEY `user_permissions_ibfk_2` (`module_bit`,`code`),
  CONSTRAINT `user_permissions_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_permissions_ibfk_2` FOREIGN KEY (`module_bit`, `code`) REFERENCES `permissions` (`module_bit`, `code`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_permissions`
--

LOCK TABLES `user_permissions` WRITE;
/*!40000 ALTER TABLE `user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userflags`
--

DROP TABLE IF EXISTS `userflags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userflags` (
  `bit` int(11) NOT NULL DEFAULT '0',
  `flag` varchar(30) DEFAULT NULL,
  `flagdesc` varchar(255) DEFAULT NULL,
  `defaulton` int(11) DEFAULT NULL,
  PRIMARY KEY (`bit`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userflags`
--

LOCK TABLES `userflags` WRITE;
/*!40000 ALTER TABLE `userflags` DISABLE KEYS */;
INSERT INTO `userflags` VALUES (0,'superlibrarian','Access to all librarian functions',0),(1,'circulate','Circulate books',0),(2,'catalogue','View Catalog (Librarian Interface)',0),(3,'parameters','Set Koha system parameters',0),(4,'borrowers','Add or modify borrowers',0),(5,'permissions','Set user permissions',0),(6,'reserveforothers','Place and modify holds for patrons',0),(7,'borrow','Borrow books',1),(9,'editcatalogue','Edit Catalog (Modify bibliographic/holdings data)',0),(10,'updatecharges','Update borrower charges',0),(11,'acquisition','Acquisition and/or suggestion management',0),(12,'management','Set library management parameters',0),(13,'tools','Use tools (export, import, barcodes)',0),(14,'editauthorities','Allow to edit authorities',0),(15,'serials','Allow to manage serials subscriptions',0),(16,'reports','Allow to access to the reports module',0),(17,'staffaccess','Modify login / permissions for staff users',0);
/*!40000 ALTER TABLE `userflags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `virtualshelfcontents`
--

DROP TABLE IF EXISTS `virtualshelfcontents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtualshelfcontents` (
  `shelfnumber` int(11) NOT NULL DEFAULT '0',
  `biblionumber` int(11) NOT NULL DEFAULT '0',
  `flags` int(11) DEFAULT NULL,
  `dateadded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `shelfnumber` (`shelfnumber`),
  KEY `biblionumber` (`biblionumber`),
  CONSTRAINT `shelfcontents_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `virtualshelfcontents_ibfk_1` FOREIGN KEY (`shelfnumber`) REFERENCES `virtualshelves` (`shelfnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `virtualshelfcontents`
--

LOCK TABLES `virtualshelfcontents` WRITE;
/*!40000 ALTER TABLE `virtualshelfcontents` DISABLE KEYS */;
/*!40000 ALTER TABLE `virtualshelfcontents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `virtualshelves`
--

DROP TABLE IF EXISTS `virtualshelves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtualshelves` (
  `shelfnumber` int(11) NOT NULL AUTO_INCREMENT,
  `shelfname` varchar(255) DEFAULT NULL,
  `owner` varchar(80) DEFAULT NULL,
  `category` varchar(1) DEFAULT NULL,
  `sortfield` varchar(16) DEFAULT NULL,
  `lastmodified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`shelfnumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `virtualshelves`
--

LOCK TABLES `virtualshelves` WRITE;
/*!40000 ALTER TABLE `virtualshelves` DISABLE KEYS */;
/*!40000 ALTER TABLE `virtualshelves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `z3950servers`
--

DROP TABLE IF EXISTS `z3950servers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `z3950servers` (
  `host` varchar(255) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `db` varchar(255) DEFAULT NULL,
  `userid` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `name` mediumtext,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `checked` smallint(6) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `syntax` varchar(80) DEFAULT NULL,
  `icon` text,
  `position` enum('primary','secondary','') NOT NULL DEFAULT 'primary',
  `type` enum('zed','opensearch') NOT NULL DEFAULT 'zed',
  `encoding` text,
  `description` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

