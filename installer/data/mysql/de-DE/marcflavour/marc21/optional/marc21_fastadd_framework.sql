INSERT IGNORE INTO biblio_framework VALUES ( 'FA','Schnellaufnahme' );
INSERT IGNORE INTO `marc_tag_structure` (`tagfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `authorised_value`, `frameworkcode`) VALUES
                ('000', 'Satzkennung', 'Satzkennung', 0, 1, '', 'FA'),
                ('008', 'Feld mit fester Länge zur physischen Beschreibung - Allgemeine Angaben', 'Feld mit fester Länge zur physischen Beschreibung - Allgemeine Angaben', 0, 1, '', 'FA'),
                ('010', 'Kontrollnummer der Library of Congress', 'Kontrollnummer der Library of Congress', 0, 0, '', 'FA'),
                ('020', 'Internationale Standardbuchnummer', 'Internationale Standardbuchnummer', 1, 0, NULL, 'FA'),
                ('022', 'Internationale Standardseriennummer', 'Internationale Standardseriennummer', 1, 0, NULL, 'FA'),
                ('050', 'Signatur der Library of Congress', 'Signatur der Library of Congress', 1, 0, NULL, 'FA'),
                ('090', 'LOCALLY ASSIGNED LC-TYPE CALL NUMBER', 'LOCALLY ASSIGNED LC-TYPE CALL NUMBER', 1, 0, '', 'FA'),
                ('099', 'LOCAL FREE-TEXT CALL NUMBER', 'LOCAL FREE-TEXT CALL NUMBER', 1, 0, '', 'FA'),
                ('100', 'Haupteintragung - Personenname', 'Haupteintragung - Personenname', 0, 0, NULL, 'FA'),
                ('245', 'Titel', 'Titel', 0, 1, '', 'FA'),
                ('250', 'Ausgabebezeichnung', 'Ausgabebezeichnung', 0, 0, NULL, 'FA'),
                ('260', 'Publikation, Vertrieb usw. (Erscheinungsvermerk)', 'Publikation, Vertrieb usw. (Erscheinungsvermerk)', 1, 0, NULL, 'FA'),
                ('300', 'Physische Beschreibung', 'Physische Beschreibung', 1, 0, NULL, 'FA'),
                ('500', 'Allgemeine Fußnote', 'Allgemeine Fußnote', 1, 0, NULL, 'FA'),
                ('942', 'Zusätzliche Felder (Koha)', 'Zusätzliche Felder (Koha)', 0, 0, '', 'FA'),
                ('952', 'Standort- und Exemplarinformationen (KOHA)', 'Standort- und Exemplarinformationen (KOHA)', 1, 0, '', 'FA'),
                ('999', 'Systemkontrollnummern (Koha)', 'Systemkontrollnummern (Koha)', 1, 0, '', 'FA');

INSERT IGNORE INTO `marc_subfield_structure` (`tagfield`, `tagsubfield`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `kohafield`, `tab`, `authorised_value`, `authtypecode`, `value_builder`, `isurl`, `hidden`, `frameworkcode`, `seealso`, `link`, `defaultvalue`) VALUES
		('000','@','Kontrollfeld mit fester Länge','Kontrollfeld mit fester Länge',0,1,'',0,'','','marc21_leader.pl',NULL,0,'FA','',NULL,NULL),
		('008','@','Kontrollfeld mit fester Länge','Kontrollfeld mit fester Länge',0,1,'',0,'','','marc21_field_008.pl',NULL,0,'FA','',NULL,NULL),
		('010','8','Feldverknüpfung und Reihenfolge','Feldverknüpfung und Reihenfolge',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('010','a','LC-Kontrollnummer','LC-Kontrollnummer',0,0,'biblioitems.lccn',0,'','','',0,0,'FA',NULL,'',''),
		('010','b','NUCMC-Kontrollnummer','NUCMC-Kontrollnummer',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('010','z','Gelöschte/ungültige LC-Kontrollnummer','Gelöschte/ungültige LC-Kontrollnummer',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('020','6','Verknüpfung','Verknüpfung',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('020','8','Feldverknüpfung und Reihenfolge','Feldverknüpfung und Reihenfolge',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('020','a','Internationale Standardbuchnummer','Internationale Standardbuchnummer',0,0,'biblioitems.isbn',0,'','','',0,0,'FA',NULL,'',''),
		('020','c','Bezugsbedingungen','Bezugsbedingungen',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('020','z','Gelöschte/ungültige ISBN','Gelöschte/ungültige ISBN',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('050','a','Notation', 'Notation', 1, 0, '', 0, '', '', '', 0, 0, 'FA', '', '', NULL),
		('050','b','Exemplarnummer', 'Exemplarnummer', 0, 0, '', 0, '', '', '', 0, 0, 'FA', '', '', NULL),
		('082','2','Ausgabenummer','Ausgabenummer',0,0,'',0,'','','',NULL,0,'FA','',NULL,NULL),
		('082','6','Verknüpfung','Verknüpfung',0,0,'',0,'','','',NULL,0,'FA','',NULL,NULL),
		('082','8','Feldverknüpfung und Reihenfolge','Feldverknüpfung und Reihenfolge',1,0,'',0,'','','',NULL,0,'FA','',NULL,NULL),
		('082','a','Notation','Notation',1,0,'',0,'','','',NULL,0,'FA','',NULL,NULL),
		('082','b','Exemplarnummer','Exemplarnummer',0,0,'',0,'','','',NULL,0,'FA','',NULL,NULL),
		('090','a','Local Classification number (NR)', 'Local Classification number (NR)', 1, 0, '', 0, '', '', '', 0, 5, 'FA', '', '', NULL),
		('090','b','Local cutter number', 'Local cutter number', 0, 0, '', 0, '', '','', 0, 5, 'FA', '', '', NULL),
		('100','4','Funktionsbezeichnungscode','Funktionsbezeichnungscode',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','6','Verknüpfung','Verknüpfung',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','8','Feldverknüpfung und Reihenfolge','Feldverknüpfung und Reihenfolge',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','9','9 (RLIN)','9 (RLIN)',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','a','Personenname','Personenname',0,0,'biblio.author',0,'','PERSO_NAME','',0,0,'FA',NULL,'',''),
		('100','b','Zählung','Zählung',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','c','Titel und andere Wörter in Verbindung mit einem Namen','Titel und andere Wörter in Verbindung mit einem Namen',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','d','Datumsangaben in Verbindung mit einem Namen','Datumsangaben in Verbindung mit einem Namen',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','e','Funktionsbezeichnung','Funktionsbezeichnung',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','f','Erscheinungsjahr eines Werkes','Erscheinungsjahr eines Werkes',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','g','Sonstige Informationen','Sonstige Informationen',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','j','Zuordnungsvermerk','Zuordnungsvermerk',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','k','Formbestandteil der Ansetzung','Formbestandteil der Ansetzung',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','l','Sprache eines Werkes','Sprache eines Werkes',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','n','Zählung des Teils/der Abteilung eines Werkes','Zählung des Teils/der Abteilung eines Werkes',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','p','Titel eines Teils/einer Abteilung eines Werkes', 'Titel eines Teils/einer Abteilung eines Werkes',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','q','Vollständige Form eines Namens','Vollständige Form eines Namens',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','t','Titel eines Werkes','Titel eines Werkes',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('100','u','Zugehörigkeit','Zugehörigkeit',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('245','6','Verknüpfung','Verknüpfung',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('245','8','Feldverknüpfung und Reihenfolge','Feldverknüpfung und Reihenfolge',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('245','a','Titel','Titel',0,1,'biblio.title',0,'','','',0,0,'FA',NULL,'',''),
		('245','b','Zusatz zum Titel','Zusatz zum Titel',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('245','c','Verfasserangabe etc.','Verfasserangabe etc.',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('245','d','Designation of section/part/series (SE) [OBSOLETE]','Designation of section section/part/series: (SE) [OBSOLETE]',0,0,'',0,'','','',0,-5,'FA',NULL,'',''),
		('245','e','Name of part/section/series (SE) [OBSOLETE]','Name of part/section/series (SE) [OBSOLETE]',0,0,'',0,'','','',0,-5,'FA',NULL,'',''),
		('245','f','Entstehungszeitraum','Entstehungszeitraum',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('245','g','Zeitabschnitt','Zeitabschnitt',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('245','h','Medium','Medium',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('245','k','Form','Form',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('245','n','Zählung des Teils/der Abteilung eines Werkes','Zählung des Teils/der Abteilung eines Werkes',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('245','p','Titel eines Teils/einer Abteilung eines Werkes', 'Titel eines Teils/einer Abteilung eines Werkes',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('245','s','Version','Version',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('250','6','Verknüpfung','Verknüpfung',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('250','8','Feldverknüpfung und Reihenfolge','Feldverknüpfung und Reihenfolge',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('250','a','Ausgabebezeichnung','Ausgabebezeichnung',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('250','b','Zusatz zur Ausgabebezeichnung','Zusatz zur Ausgabebezeichnung',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('260','6','Verknüpfung','Verknüpfung',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('260','8','Feldverknüpfung und Reihenfolge','Feldverknüpfung und Reihenfolge',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('260','a','Erscheinungsort, Vertriebsort etc.','Erscheinungsort, Vertriebsort etc.',1,0,'biblioitems.place',0,'','','',0,0,'FA',NULL,'',''),
		('260','b','Name des Verlags, des Vertriebs etc.','Name des Verlags, des Vertriebs etc.',1,0,'biblioitems.publishercode',0,'','','',0,0,'FA',NULL,'',''),
		('260','c','Date of publication, distribution, etc','Date of publication, distribution, etc',1,0,'biblio.copyrightdate',0,'','','',0,0,'FA',NULL,'',''),
		('260','d','Plate or publisher\'s number for music (Pre-AACR 2) [OBSOLETE, CAN/MARC], [LOCAL,','Plate or publisher\'s number for music (Pre-AACR 2) [OBSOLETE, CAN/MARC], [LOCAL,',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('260','e','Ort der Herstellerfirma','Ort der Herstellerfirma',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('260','f','Herstellerfirma','Herstellerfirma',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('260','g','Herstellungsjahr','Herstellungsjahr',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('260','k','Identification/manufacturer number [OBSOLETE, CAN/MARC]','Identification/manufacturer number [OBSOLETE, CAN/MARC]',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('260','l','Matrix and/or take number [OBSOLETE, CAN/MARC]','Matrix and/or take number [OBSOLETE, CAN/MARC]',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('500','3','Spezifische Materialangaben','Spezifische Materialangaben',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('500','5','Das Unterfeld gibt die Institution an, auf die sich das Feld bezieht','Das Unterfeld gibt die Institution an, auf die sich das Feld bezieht',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('500','6','Verknüpfung','Verknüpfung',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('500','8','Feldverknüpfung und Reihenfolge','Feldverknüpfung und Reihenfolge',1,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('500','a','Allgemeine Fußnote','Allgemeine Fußnote',0,0,'biblio.notes',0,'','','',0,0,'FA',NULL,'',''),
		('500','l','Library of Congress call number (SE) [OBSOLETE]','Library of Congress call number (SE) [OBSOLETE]',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('500','n','n (RLIN) [OBSOLETE]','n (RLIN) [OBSOLETE]',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('500','x','Internationale Standardseriennummer (SE) [OBSOLETE]','Internationale Standardseriennummer (SE) [OBSOLETE]',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('500','z','Source of note information (AM SE) [OBSOLETE]','Source of note information (AM SE) [OBSOLETE]',0,0,'',0,'','','',0,0,'FA',NULL,'',''),
		('942','0','Koha-Ausleihen, alle Exemplare', 'Koha-Ausleihen, alle Exemplare', 0, 0, 'biblioitems.totalissues', 9, '', '', '', NULL, 5, 'FA', '', '', NULL),
		('942','c','Medientyp', 'Medientyp', 0, 1, 'biblioitems.itemtype', 9, 'itemtypes', '', '', NULL, 5, 'FA', '', '', NULL),
		('942','n','OPAC-Anzeige unterdrücken', 'OPAC-Anzeige unterdrücken', 0, 0, NULL, 9, '', '', '', 0, 5, 'FA', '', '', NULL),
		('942','s','Kennzeichen für Zeitschrift', 'Zeitschrift', 0, 0, 'biblio.serial', 9, '', '', '', NULL, 5, 'FA', '', '', NULL),
		('952','0','Ausgeschieden','Ausgeschieden',0,0,'items.wthdrawn',10,'WITHDRAWN','','',NULL,0,'FA','',NULL,NULL),
		('952','1','Spezifische Materialangaben (gebundener Band oder anderer Teil)','Spezifische Materialangaben (gebundener Band oder anderer Teil)',0,0,'items.itemlost',10,'LOST','','',NULL,0,'FA','',NULL,NULL),
		('952','2','Klassifikation oder Aufstellungssystematik','Klassifikation oder Aufstellungssystematik',0,0,'items.cn_source',10,'cn_source','','',NULL,0,'FA','',NULL,NULL),
		('952','3','Spezifische Materialangaben (gebundener Band oder anderer Teil)','Spezifische Materialangaben (gebundener Band oder anderer Teil)',0,0,'items.materials',10,'','','',NULL,0,'FA','',NULL,NULL),
		('952','4','Beschädigt','Beschädigt',0,0,'items.damaged',10,'DAMAGED','','',NULL,0,'FA','',NULL,NULL),
		('952','5','Eingeschränkte Benutzung','Eingeschränkte Benutzung',0,0,'items.restricted',10,'RESTRICTED','','',NULL,0,'FA','',NULL,NULL),
		('952','6','Normalisierte Klassifikation für Sortierung (Koha)','Normalisierte Klassifikation für Sortierung (Koha)',0,0,'items.cn_sort',10,'','','',NULL,-5,'FA','',NULL,NULL),
		('952','7','Nicht entleihbar','Nicht entleihbar',0,0,'items.notforloan',10,'NOT_LOAN','','',NULL,0,'FA','',NULL,NULL),
		('952','8','Sammlung','Sammlung',0,0,'items.ccode',10,'CCODE','','',NULL,0,'FA','',NULL,NULL),
		('952','9','Koha-Exemplarnummer (autom. generiert)','Koha-Exemplarnummer',0,0,'items.itemnumber',-1,'','','',NULL,0,'FA','',NULL,NULL),
		('952','a','Permanenter Standort','Permanenter Standort',0,0,'items.homebranch',10,'branches','','',NULL,0,'FA','',NULL,NULL),
		('952','b','Aktueller Standort','Aktueller Standort',0,0,'items.holdingbranch',10,'branches','','',NULL,0,'FA','',NULL,NULL),
		('952','c','Aufstellungsort','Aufstellungsort',0,0,'items.location',10,'LOC','','',NULL,0,'FA','',NULL,NULL),
		('952','d','Erwerbungsdatum','Erwerbungsdatum',0,0,'items.dateaccessioned',10,'','','dateaccessioned.pl',NULL,0,'FA','',NULL,NULL),
		('952','e','Lieferant','Lieferant',0,0,'items.booksellerid',10,'','','',NULL,0,'FA','',NULL,NULL),
		('952','f','Kodierter Standort-Qualifier','Kodierter Standort-Qualifier',0,0,'items.coded_location_qualifier',10,'','','',NULL,-5,'FA','',NULL,NULL),
		('952','g','Kaufpreis','Kaufpreis',0,0,'items.price',10,'','','',NULL,0,'FA','',NULL,NULL),
		('952','h','Jahrgang/Heft','Jahrgang/Heft',0,0,'items.enumchron',10,'','','',NULL,0,'FA','',NULL,NULL),
		('952','j','Aufstellungsnummer','Aufstellungsnummer',0,0,'items.stack',10,'STACK','','',NULL,-5,'FA','',NULL,NULL),
		('952','l','Anzahl Ausleihen','Anzahl Ausleihen',0,0,'items.issues',10,'','','',NULL,-5,'FA','',NULL,NULL),
		('952','m','Anzahl Verlängerungen','Anzahl Verlängerungen',0,0,'items.renewals',10,'','','',NULL,-5,'FA','',NULL,NULL),
		('952','n','Anzahl Vormerkungen','Anzahl Vormerkungen',0,0,'items.reserves',10,'','','',NULL,-5,'FA','',NULL,NULL),
		('952','o','Signatur','Signatur',0,0,'items.itemcallnumber',10,'','',NULL,NULL,0,'FA','',NULL,NULL),
		('952','p','Barcode','Barcode',0,0,'items.barcode',10,'','','barcode.pl',NULL,0,'FA','',NULL,NULL),
		('952','q','Ausgeliehen','Ausgeliehen',0,0,'items.onloan',10,'','','',NULL,-5,'FA','',NULL,NULL),
		('952','r','Letzte Aktivität','Letzte Aktivität',0,0,'items.datelastseen',10,'','','',NULL,-5,'FA','',NULL,NULL),
		('952','s','Letzte Ausleihe','Letzte Ausleihe',0,0,'items.datelastborrowed',10,'','','',NULL,-5,'FA','',NULL,NULL),
		('952','t','Exemplarnummer','Exemplarnummer',0,0,'items.copynumber',10,'','','',NULL,0,'FA','',NULL,NULL),
		('952','u','URL','URL',0,0,'items.uri',10,'','','',NULL,0,'FA','',NULL,NULL),
		('952','v','Preis bei Buchersatz','Preis bei Buchersatz',0,0,'items.replacementprice',10,'','','',NULL,0,'FA','',NULL,NULL),
		('952','w','Preis gültig von','Preis gültig von',0,0,'items.replacementpricedate',10,'','','',NULL,0,'FA','',NULL,NULL),
		('952','x','Interne Notiz','Interne Notiz',1,0,'items.paidfor',10,'','','',NULL,0,'FA','',NULL,NULL),
		('952','y','Medientyp','Medientyp',0,0,'items.itype',10,'itemtypes','','',NULL,0,'FA','',NULL,NULL),
		('952','z','OPAC-Notiz','OPAC-Notiz',0,0,'items.itemnotes',10,'','','',NULL,0,'FA','',NULL,NULL),
		('999', 'c', 'Koha-Biblionummer', 'Koha-Biblionummer', 0, 0, 'biblio.biblionumber', -1, NULL, NULL, '', NULL, -5, 'FA', '', '', NULL),
		('999', 'd', 'Koha-Biblioitemnumber', 'Koha-Biblioitemnumber', 0, 0, 'biblioitems.biblioitemnumber', -1, NULL, NULL, '', NULL, -5, 'FA', '', '', NULL);