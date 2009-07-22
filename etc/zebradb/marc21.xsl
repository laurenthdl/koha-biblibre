<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:z="http://indexdata.com/zebra-2.0"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                version="1.0">

  <xsl:output indent="yes"
        method="xml"
        version="1.0"
        encoding="UTF-8"/>

  <xsl:template match="/">
    <z:record>
      <xsl:apply-templates/>
    </z:record>
  </xsl:template>

  <xsl:template match="/record/leader">
    <z:index name="llength:w rtype:w:range(data 6 1) Bib-level:w:range(data 7 1)">
      <xsl:value-of select="substring(.,0,5)"/>
    </z:index>
    <z:index name="rtype:w">
      <xsl:value-of select="substring(.,6,1)"/>
    </z:index>
     <z:index name="Bib-level:w">
      <xsl:value-of select="substring(.,7,1)"/>
    </z:index>
   </xsl:template>

  <xsl:template match="/*/marc:controlfield[@tag='001']">
    <z:index name="Control-number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:controlfield[@tag='005']">
    <z:index name="Date/time-last-modified">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:controlfield[@tag='007']">
    <z:index name="Microform-generation:n:range(data 11 1) Material-type ff7-00:w:range(data 0 1) ff7-01:w:range(data 1 1) ff7-02:w:range(data 2 1) ff7-01-02:w:range(data 0 2)">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:controlfield[@tag='008']">
    <z:index name="date-entered-on-file:n:range(data 0 5) date-entered-on-file:s:range(data 0 5) pubdate:w:range(data 7 4) pubdate:n:range(data 7 4) pubdate:y:range(data 7 4) pubdate:s:range(data 7 4) pl:w:range(data 15 3) ta:w:range(data 22 1) ff8-23:w:range(data 23 1) ff8-29:w:range(data 29 1) lf:w:range(data 33 1) bio:w:range(data 34 1) ln:n:range(data 35 3) ctype:w:range(data 24 4) Record-source:w:range(data 39 0)">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='010']/marc:subfield">
    <z:index name="LC-card-number Identifier-standard">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='011']/marc:subfield">
    <z:index name="LC-card-number Identifier-standard">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='015']/marc:subfield">
    <z:index name="BNB-card-number BGF-number Number-db Number-natl-biblio Identifier-standard">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='017']/marc:subfield">
    <z:index name="Number-legal-deposit Identifier-standard">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='018']/marc:subfield">
    <z:index name="Identifier-standard">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='020']/marc:subfield[@code='a']">
    <z:index name="ISBN:w Identifier-standard:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='020']/marc:subfield">
    <z:index name="ISBN Identifier-standard">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='022']/marc:subfield[@code='a']">
    <z:index name="ISSN:w ISBN:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='022']/marc:subfield">
    <z:index name="ISSN Identifier-standard">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='023']/marc:subfield">
    <z:index name="Identifier-standard">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='024']/marc:subfield">
    <z:index name="Identifier-standard">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='025']/marc:subfield">
    <z:index name="Identifier-standard">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='027']/marc:subfield">
    <z:index name="Report-number Identifier-standard">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='028']/marc:subfield">
    <z:index name="Number-music-publisher Identifier-standard">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='030']/marc:subfield">
    <z:index name="CODEN Identifier-standard">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='034']/marc:subfield">
    <z:index name="Map-scale">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='037']/marc:subfield">
    <z:index name="Identifier-standard Stock-number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='040']/marc:subfield">
    <z:index name="Code-institution Record-source">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='041']/marc:subfield">
    <z:index name="ln">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='043']/marc:subfield">
    <z:index name="Code-geographic">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='050']/marc:subfield[@code='b']">
    <z:index name="LC-call-number:w LC-call-number:p LC-call-number:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='050']/marc:subfield">
    <z:index name="LC-call-number:w LC-call-number:p LC-call-number:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='052']/marc:subfield">
    <z:index name="Geographic-class">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='060']/marc:subfield">
    <z:index name="NLM-call-number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='070']/marc:subfield">
    <z:index name="NAL-call-number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='080']/marc:subfield">
    <z:index name="UDC-classification">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='082']/marc:subfield">
    <z:index name="Dewey-classification:w Dewey-classification:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='086']/marc:subfield">
    <z:index name="Number-govt-pub">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='100']/marc:subfield[@code='9']">
    <z:index name="Cross-Reference:w Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='100']/marc:subfield[@code='a']">
    <z:index name="Author Author:p Author:s Editor Author-personal-bibliography Author-personal-bibliography:p Author-personal-bibliography:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='100']/marc:subfield">
    <z:index name="Author Author-title Author-name-personal Name Name-and-title Personal-name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='110']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='110']/marc:subfield">
    <z:index name="Author Author-title Author-name-corporate Name Name-and-title Corporate-name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='111']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='111']/marc:subfield">
    <z:index name="Author Author-title Author-name-corporate Name Name-and-title Conference-name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='130']/marc:subfield[@code='n']">
    <z:index name="Thematic-number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='130']/marc:subfield[@code='r']">
    <z:index name="Music-key">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='130']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='130']/marc:subfield">
    <z:index name="Title Title-uniform">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='210']/marc:subfield">
    <z:index name="Title Title-abbreviated">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='211']/marc:subfield">
    <z:index name="Title Title-abbreviated">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='212']/marc:subfield">
    <z:index name="Title Title-other-variant">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='214']/marc:subfield">
    <z:index name="Title Title-expanded">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='222']/marc:subfield">
    <z:index name="Title Title-key">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='240']/marc:subfield[@code='r']">
    <z:index name="Music-key">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='240']/marc:subfield[@code='n']">
    <z:index name="Thematic-number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='240']/marc:subfield">
    <z:index name="Title:w Title:p Title-uniform">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='243']/marc:subfield[@code='n']">
    <z:index name="Thematic-number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='243']/marc:subfield[@code='r']">
    <z:index name="Music-key">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='243']/marc:subfield">
    <z:index name="Title:w Title:p Title-collective">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='245']/marc:subfield[@code='a']">
    <z:index name="Title-cover:w Title-cover:p Title-cover:s Title:w Title:p Title:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='245']/marc:subfield[@code='c']">
    <z:index name="Author Author-in-order:w Author-in-order:p Author-in-order:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='245']/marc:subfield[@code='9']">
    <z:index name="Cross-Reference:w Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='245']/marc:subfield">
    <z:index name="Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='246']/marc:subfield">
    <z:index name="Title Title:p Title-abbreviated Title-expanded Title-former">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='247']/marc:subfield">
    <z:index name="Title Title:p Title-former Title-other-variant Related-periodical">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='260']/marc:subfield[@code='a']">
    <z:index name="pl:w pl:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='260']/marc:subfield[@code='b']">
    <z:index name="Publisher:w Publisher:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='260']/marc:subfield[@code='c']">
    <z:index name="copydate copydate:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='260']/marc:subfield">
    <z:index name="pl">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='300']/marc:subfield">
    <z:index name="Extent:w Extent:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='400']/marc:subfield[@code='a']">
    <z:index name="Name-and-title">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='400']/marc:subfield[@code='t']">
    <z:index name="Author-title Name-and-title Title Title-series">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='400']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='400']/marc:subfield">
    <z:index name="Author Author-name-personal Name Personal-name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='410']/marc:subfield">
    <z:index name="Author Corporate-name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='410']/marc:subfield[@code='a']">
    <z:index name="Name-and-title">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='410']/marc:subfield[@code='t']">
    <z:index name="Author-title Title Title-series">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='410']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='410']/marc:subfield">
    <z:index name="Author-name-corporate Name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='411']/marc:subfield">
    <z:index name="Author Conference-name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='411']/marc:subfield[@code='a']">
    <z:index name="Name-and-title">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='411']/marc:subfield[@code='t']">
    <z:index name="Author-title Title-series">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='411']/marc:subfield">
    <z:index name="Author-name-corporate Name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='440']/marc:subfield[@code='a']">
    <z:index name="Title-series:w Title-series:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='440']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='440']/marc:subfield">
    <z:index name="Title-series:w Title-series:p Title Title-series">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='490']/marc:subfield[@code='a']">
    <z:index name="Title-series:w Title-series:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='490']/marc:subfield">
    <z:index name="Title Title-series">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='490']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='502']/marc:subfield">
    <z:index name="Material-type">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='505']/marc:subfield[@code='r']">
    <z:index name="Author">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='505']/marc:subfield[@code='t']">
    <z:index name="Title">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='505']/marc:subfield">
    <z:index name="Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='510']/marc:subfield">
    <z:index name="Indexed-by">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='520']/marc:subfield">
    <z:index name="Abstract:w Abstract:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='600']/marc:subfield[@code='a']">
    <z:index name="Name-and-title Name Personal-name Subject-name-personal Subject">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='600']/marc:subfield[@code='t']">
    <z:index name="Name-and-title Title Subject">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='600']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='600']/marc:subfield">
    <z:index name="Name Personal-name Subject-name-personal Subject">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='610']/marc:subfield[@code='a']">
    <z:index name="Name-and-title">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='610']/marc:subfield[@code='t']">
    <z:index name="Name-and-title Title">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='610']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='610']/marc:subfield">
    <z:index name="Name Subject Corporate-name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='611']/marc:subfield">
    <z:index name="Conference-name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='611']/marc:subfield[@code='a']">
    <z:index name="Name-and-title">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='611']/marc:subfield[@code='t']">
    <z:index name="Name-and-title Title">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='611']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='611']/marc:subfield">
    <z:index name="Name Subject">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='630']/marc:subfield[@code='n']">
    <z:index name="Thematic-number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='630']/marc:subfield[@code='r']">
    <z:index name="Music-key">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='630']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='630']/marc:subfield">
    <z:index name="Subject">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='650']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='650']/marc:subfield">
    <z:index name="Subject Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='651']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='651']/marc:subfield">
    <z:index name="Name-geographic Subject Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='652']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='653']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='653']/marc:subfield">
    <z:index name="Subject Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='654']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='654']/marc:subfield">
    <z:index name="Subject">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='655']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='655']/marc:subfield">
    <z:index name="Subject">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='656']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='656']/marc:subfield">
    <z:index name="Subject">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='657']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='657']/marc:subfield">
    <z:index name="Subject">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='690']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='690']/marc:subfield">
    <z:index name="Subject Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='700']/marc:subfield[@code='9']">
    <z:index name="Cross-Reference Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='700']/marc:subfield[@code='a']">
    <z:index name="Author Author:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='700']/marc:subfield[@code='n']">
    <z:index name="Thematic-number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='700']/marc:subfield[@code='r']">
    <z:index name="Music-key">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='700']/marc:subfield[@code='t']">
    <z:index name="Author-title Name-and-title Title Title-uniform">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='700']/marc:subfield">
    <z:index name="Author Author-name-corporate Author-name-personal Name Editor Personal-name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='710']/marc:subfield">
    <z:index name="Author Corporate-name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='710']/marc:subfield[@code='t']">
    <z:index name="Author-title Name-and-title Title Title-uniform">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='710']/marc:subfield[@code='a']">
    <z:index name="Name-and-title">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='710']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='710']/marc:subfield">
    <z:index name="Author Name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='711']/marc:subfield[@code='a']">
    <z:index name="Name-and-title">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='711']/marc:subfield[@code='t']">
    <z:index name="Author-title Title Title-uniform">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='711']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='711']/marc:subfield">
    <z:index name="Author-name-corporate Name Conference-name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='730']/marc:subfield[@code='n']">
    <z:index name="Thematic-number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='730']/marc:subfield[@code='r']">
    <z:index name="Music-key">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='730']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='730']/marc:subfield">
    <z:index name="Title Title-uniform">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='740']/marc:subfield">
    <z:index name="Title Title-other-variant">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='773']/marc:subfield[@code='t']">
    <z:index name="Host-item">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='780']/marc:subfield[@code='t']">
    <z:index name="Title">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='780']/marc:subfield">
    <z:index name="Title Title-former Related-periodical">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='785']/marc:subfield">
    <z:index name="Related-periodical">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='800']/marc:subfield[@code='a']">
    <z:index name="Name-and-title">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='800']/marc:subfield[@code='t']">
    <z:index name="Author-title Name-and-title Title Title-series">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='800']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='800']/marc:subfield">
    <z:index name="Author Author-name-personal Name Personal-name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='810']/marc:subfield[@code='a']">
    <z:index name="Name-and-title">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='810']/marc:subfield[@code='t']">
    <z:index name="Author-title Name-and-title Title Title-series">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='810']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='810']/marc:subfield">
    <z:index name="Author Corporate-name Author-name-corporate Name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='811']/marc:subfield[@code='a']">
    <z:index name="Name-and-title">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='811']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='811']/marc:subfield[@code='t']">
    <z:index name="Author-title Name-and-title Title Title-series">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='811']/marc:subfield">
    <z:index name="Author Author-name-corporate Name Conference-name">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='830']/marc:subfield[@code='9']">
    <z:index name="Koha-Auth-Number">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='830']/marc:subfield">
    <z:index name="Title Title-series">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='840']/marc:subfield">
    <z:index name="Title Title-series">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='999']/marc:subfield[@code='c']">
    <z:index name="Local-Number:n Local-Number:w Local-Number:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='999']/marc:subfield[@code='d']">
    <z:index name="biblioitemnumber:n biblioitemnumber:w biblioitemnumber:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='942']/marc:subfield[@code='0']">
    <z:index name="totalissues:n totalissues:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='942']/marc:subfield[@code='2']">
    <z:index name="cn-bib-source">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='942']/marc:subfield[@code='6']">
    <z:index name="cn-bib-sort:n cn-bib-sort:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='942']/marc:subfield[@code='c']">
    <z:index name="itemtype:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='942']/marc:subfield[@code='n']">
    <z:index name="Suppress:w Suppress:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='942']/marc:subfield[@code='h']">
    <z:index name="cn-class">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='942']/marc:subfield[@code='i']">
    <z:index name="cn-item">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='942']/marc:subfield[@code='k']">
    <z:index name="cn-prefix">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='942']/marc:subfield[@code='m']">
    <z:index name="cn-suffix">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='0']">
    <z:index name="withdrawn:n withdrawn:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='1']">
    <z:index name="lost lost:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='2']">
    <z:index name="classification-source">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='3']">
    <z:index name="materials-specified">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='4']">
    <z:index name="damaged:n damaged:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='5']">
    <z:index name="restricted:n restricted:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='6']">
    <z:index name="cn-sort:n cn-sort:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='7']">
    <z:index name="notforloan:n notforloan:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='8']">
    <z:index name="ccode">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='9']">
    <z:index name="itemnumber:n itemnumber:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='a']">
    <z:index name="homebranch">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='b']">
    <z:index name="holdingbranch">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='c']">
    <z:index name="location">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='d']">
    <z:index name="Date-of-acquisition Date-of-acquisition:d Date-of-acquisition:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='e']">
    <z:index name="acqsource">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='f']">
    <z:index name="coded-location-qualifier">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='g']">
    <z:index name="price">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='j']">
    <z:index name="stack:n stack:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='l']">
    <z:index name="issues:n issues:w issues:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='m']">
    <z:index name="renewals:n renewals:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='n']">
    <z:index name="reserves:n reserves:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='o']">
    <z:index name="Local-classification:w Local-classification:p Local-classification:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='p']">
    <z:index name="barcode barcode:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='q']">
    <z:index name="onloan:n onloan:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='r']">
    <z:index name="datelastseen">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='s']">
    <z:index name="datelastborrowed">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='t']">
    <z:index name="copynumber">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='u']">
    <z:index name="uri:u">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='v']">
    <z:index name="replacementprice">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='w']">
    <z:index name="replacementpricedate">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='952']/marc:subfield[@code='y']">
    <z:index name="itype:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

</xsl:stylesheet>
