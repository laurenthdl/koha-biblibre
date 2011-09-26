select count(*) from biblio;
select count(*) from biblioitems;
select count(*) from items;
select count(*) from issues;
select count(*) from reserves;
select max(biblio.biblionumber),max(biblioitems.biblioitemnumber), max(biblio.biblionumber)=max(biblioitems.biblioitemnumber) from biblio, biblioitems;
select count(*) from issues where itemnumber is null or borrowernumber is null;
select count(*) from reserves where biblionumber is null or borrowernumber is null;
