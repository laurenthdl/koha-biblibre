SET NAMES utf8;
INSERT INTO borrower_attribute_types (code, description, repeatable, unique_id, opac_display, password_allowed, staff_searchable, authorised_value_category, display_checkout, category_type) VALUES
("NOM_BIBLIOTHEQUE","Nom de la commune (nom de la bibliothèque)",0,0,0,0,0,0,1,'I'),
("NUMERO","Code barre emprunteur",0,0,0,0,0,0,1,'I'),
("RELAISTYPE", "Type de relais",0,0,0,0,0,0,1,'I'),
("STATUTADMIN", "Statut administratif",0,0,0,0,0,0,1,'I'),
("ADRESSE", "Adresse/complément d'adresse",0,0,0,0,0,0,1,'I'),
("NUMCOMMUNE", "Numéro de commune",0,0,0,0,0,0,1,'I'),
("NBHAB", "Nombre d'habitants",0,0,0,0,0,0,1,'I'),
("TELMAIRIE", "Téléphone de la mairie",0,0,0,0,0,0,1,'I'),
("MAIRIE", "Mairie",0,0,0,0,0,0,1,'I'),
("NUMCANTON", "Numéro du canton",0,0,0,0,0,0,1,'I'),
("NUMTOURNEE","Numéro de la tournée",0,0,0,0,0,0,1,'I'),
("BIBRATTACH","Bibliothèque de rattachement",0,0,0,0,0,0,1,'I'),
("HORAIRES","Horaires d'ouverture",0,0,0,0,0,0,1,'I'),
("FREQPASSAGE","Fréquence de passage",0,0,0,0,0,0,1,'I'),
("CONTRAINTESPASSAGE","Contraintes de passage",0,0,0,0,0,0,1,'I');
