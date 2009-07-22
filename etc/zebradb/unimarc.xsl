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
    <xsl:variable name="identifier" select="/*/marc:datafield[@tag='090']/marc:subfield[@code='9']"/>
    <z:record z:id="{$identifier}" >
     <xsl:apply-templates/>
    </z:record>
  </xsl:template>

  <xsl:template match="/*/marc:controlfield[@tag='001']">
    <z:index name="any:w Local-number:w Local-number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='090']/marc:subfield[@code='9']">
    <z:index name="any:w Local-number:w Local-number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='099']/marc:subfield[@code='c']">
    <z:index name="any:w date-entered-on-file:s date-entered-on-file:n date-entered-on-file:y">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='099']/marc:subfield[@code='d']">
    <z:index name="any:w Date/time-last-modified:s Date/time-last-modified:n Date/time-last-modified:y">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='010']/marc:subfield[@code='a']">
    <z:index name="any:w ISBN:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='010']/marc:subfield[@code='z']">
    <z:index name="any:w ISBN:w Identifier-standard:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='011']/marc:subfield[@code='a']">
    <z:index name="any:w ISSN:w Identifier-standard:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='011']/marc:subfield[@code='y']">
    <z:index name="any:w ISSN:w Identifier-standard:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='011']/marc:subfield[@code='z']">
    <z:index name="any:w ISSN:w Identifier-standard:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='200']/marc:subfield[@code='b']">
    <z:index name="any:w itemtype:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='995']/marc:subfield[@code='r']">
    <z:index name="any:w itype:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <!--<xsl:template match="/*/marc:datafield[@tag='100']/marc:subfield[@code='a']">
    <z:index name="any:w tpubdate:s:range(data 8 1) ta:w:range(data 17 1) ta:w:range(data 18 1) ta:w:range(data 19 1) Modified-code:n:range(data 21 1) ln:s:range(data 22 3) char-encoding:n:range(data 26 2) char-encoding:n:range(data 28 2) char-encoding:n:range(data 30 2) script-Title:n:range(data 34 2)">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>
-->

  <xsl:template match="/*/marc:datafield[@tag='101']/marc:subfield[@code='a']">
    <z:index name="any:w ln:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='102']/marc:subfield[@code='a']">
    <z:index name="any:w Country-heading:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>
<!--
  <xsl:template match="/*/marc:datafield[@tag='105']/marc:subfield[@code='a']">
    <z:index name="any:w Illustration-code:w:range(data 0 4) Content-type:w:range(data 4 1) Content-type:w:range(data 5 1) Content-type:w:range(data 6 1) Content-type:w:range(data 7 1) Conference-code:w:range(data 8 1) Festschrift-indicator:w:range(data 9 1) Index-indicator:w:range(data 10 1) Literature-Code:w:range(data 11 1) Biography-Code:w:range(data 12 1)">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>
-->

  <xsl:template match="/*/marc:datafield[@tag='106']/marc:subfield[@code='a']">
    <z:index name="any:w itype:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

<!--
  <xsl:template match="/*/marc:datafield[@tag='110']/marc:subfield[@code='a']">
    <z:index name="any:w Type-Of-Serial:w:range(data 0 1) Frequency-code:w:range(data 1 1) Regularity-code:w:range(data 2 1) Content-type:w:range(data 3 1) Content-type:w:range(data 4 3) Conference-publication-Code:w:range(data 7 1) Title-Page-availability-Code:w:range(data 8 1) Index-availability-Code:w:range(data 9 1) Cumulative-Index-availability-Code:w:range(data 10 1)">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='115']/marc:subfield[@code='a']">
    <z:index name="any:w Video-mt:w:range(data 0 1)">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='116']/marc:subfield[@code='a']">
    <z:index name="any:w Graphics-type:w:range(data 0 1) Graphics-support:w:range(data 1 1) Graphics-support:w:range(data 2 1)">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>
-->
  <xsl:template match="/*/marc:datafield[@tag='680']/marc:subfield[@code='b']">
    <z:index name="any:w LC-call-number:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='680']/marc:subfield">
    <z:index name="any:w LC-call-number:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='200']/marc:subfield[@code='b']">
    <z:index name="any:w itype:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='200']/marc:subfield[@code='f']">
    <z:index name="any:w Author:w Author:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='200']/marc:subfield[@code='g']">
    <z:index name="any:w Author:w Author:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='700']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='700']/marc:subfield[@code='a']">
    <z:index name="any:w Author:w Author-name-personal:w Author:p Author-name-personal:p Author:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='700']/marc:subfield">
    <z:index name="any:w Author:w Author-name-personal:w Author:p Author-name-personal:p Author-name-personal:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='701']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='701']/marc:subfield">
    <z:index name="any:w Author:w Author-name-personal:w Author:p Author-name-personal:p Author-name-personal:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='702']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='702']/marc:subfield">
    <z:index name="any:w Author:w Author-name-personal:w Author:p Author-name-personal:p Author-name-personal:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='710']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='710']/marc:subfield">
    <z:index name="any:w Author:w Author-name-corporate:w Author-name-conference:w Corporate-name:w Conference-name:w Author:p Author-name-corporate:p Author-name-conference:p Corporate-name:p Conference-name:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='711']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='711']/marc:subfield">
    <z:index name="any:w Author:w Author-name-corporate:w Author-name-conference Corporate-name:w Conference-name:w Author:p Author-name-corporate:p Author-name-conference:p Corporate-name:p Conference-name:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='712']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='712']/marc:subfield">
    <z:index name="any:w Author:w Author-name-corporate:w Author-name-conference:w Corporate-name:w Conference-name:w Author:p Author-name-corporate:p Author-name-conference:p Corporate-name:p Conference-name:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='200']/marc:subfield[@code='a']">
    <z:index name="any:w Title:w Title:p Title:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='200']/marc:subfield[@code='c']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='200']/marc:subfield[@code='d']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='200']/marc:subfield[@code='e']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='200']/marc:subfield[@code='i']">
    <z:index name="any:w title:w title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='205']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='208']/marc:subfield">
    <z:index name="any:w Serials:w Serials:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='207']/marc:subfield">
    <z:index name="any:w Printed-music:w Printed-music:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='210']/marc:subfield[@code='a']">
    <z:index name="any:w pl:w pl:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='210']/marc:subfield[@code='c']">
    <z:index name="any:w Publisher:w Publisher:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='210']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n pubdate:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='215']/marc:subfield">
    <z:index name="any:w Extent:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='225']/marc:subfield[@code='a']">
    <z:index name="any:w Title-series:w Title-series:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='225']/marc:subfield[@code='d']">
    <z:index name="any:w Title-series:w Title-series:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='225']/marc:subfield[@code='e']">
    <z:index name="any:w Title-series:w Title-series:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='225']/marc:subfield[@code='f']">
    <z:index name="any:w Author:w Author:p Name-and-title:w Name-and-title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='225']/marc:subfield[@code='h']">
    <z:index name="any:w Title-series:w Title-series:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='225']/marc:subfield[@code='i']">
    <z:index name="any:w Title-series:w Title-series:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='225']/marc:subfield[@code='v']">
    <z:index name="any:w Title-series:w Title-series:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='225']/marc:subfield[@code='x']">
    <z:index name="any:w ISSN:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='230']/marc:subfield[@code='a']">
    <z:index name="any:w Electronic-ressource:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='300']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='301']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='302']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='303']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='304']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='305']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='306']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='307']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='308']/marc:subfield">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='308']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='310']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='311']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='312']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='313']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='314']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='315']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='316']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='317']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='318']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='320']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='321']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='322']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='323']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='324']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='325']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='326']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='327']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='328']/marc:subfield">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='328']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='330']/marc:subfield[@code='a']">
    <z:index name="any:w Abstract Note:w Abstract:p Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='332']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='333']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='336']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='337']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='345']/marc:subfield[@code='a']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='400']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='401']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='403']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p Title-Uniform Title-Uniform:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='410']/marc:subfield[@code='t']">
    <z:index name="any:w Title-series Title-series:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='412']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='413']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='414']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='415']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='416']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='417']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='418']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='419']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='420']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='430']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='431']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='432']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='440']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='441']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='445']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='461']/marc:subfield[@code='t']">
    <z:index name="any:w Title:w Title-host:w title-host:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='400']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='401']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='403']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='410']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='412']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='413']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='414']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='415']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='416']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='417']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='418']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='419']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='420']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='430']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='431']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='432']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='440']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='441']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='445']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='461']/marc:subfield[@code='d']">
    <z:index name="any:w pubdate:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='500']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='501']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='503']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='510']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='512']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='513']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='514']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='515']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='516']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='517']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='518']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='519']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='520']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='530']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='531']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='532']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='540']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='541']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='545']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='500']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='501']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='503']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='510']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='512']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='513']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='514']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='515']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='516']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='517']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='518']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='519']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='520']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='530']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='531']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='532']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='540']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='541']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='545']/marc:subfield">
    <z:index name="any:w Title:w Title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='600']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='601']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='602']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='603']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='604']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='605']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='606']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='607']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='610']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='630']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='631']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='632']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='633']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='634']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='635']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='636']/marc:subfield[@code='9']">
    <z:index name="any:w Koha-Auth-Number:w Koha-Auth-Number:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='600']/marc:subfield[@code='a']">
    <z:index name="any:w Personal-name:w Personal-name:p Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='600']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='601']/marc:subfield[@code='a']">
    <z:index name="any:w Corporate-name:w Conference-name:w Corporate-name:p Conference-name:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='601']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='602']/marc:subfield[@code='a']">
    <z:index name="any:w Personal-name:w Personal-name:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='602']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='604']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='605']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='606']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='607']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='630']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='631']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='632']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='633']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='634']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='635']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='636']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='610']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='640']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='641']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='642']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='643']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='644']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='645']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='646']/marc:subfield">
    <z:index name="any:w Subject:w Subject:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='676']/marc:subfield[@code='a']">
    <z:index name="any:w Dewey-classification:w Dewey-classification:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='995']/marc:subfield[@code='2']">
    <z:index name="any:w lost:w lost:n">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='995']/marc:subfield[@code='a']">
    <z:index name="any:w homebranch:w Host-item:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='995']/marc:subfield[@code='b']">
    <z:index name="any:w homebranch:w Host-item:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='995']/marc:subfield[@code='c']">
    <z:index name="any:w holdingbranch:w Record-Source:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='995']/marc:subfield[@code='d']">
    <z:index name="any:w holdingbranch:w Record-Source:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='995']/marc:subfield[@code='e']">
    <z:index name="any:w location:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='995']/marc:subfield[@code='f']">
    <z:index name="any:w barcode">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='995']/marc:subfield[@code='j']">
    <z:index name="any:w LC-card-number:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='995']/marc:subfield[@code='k']">
    <z:index name="any:w Call-Number Local-Classification lcn:w Call-Number:p Local-Classification:p lcn:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='995']/marc:subfield[@code='s']">
    <z:index name="any:w popularity:n popularity:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='995']/marc:subfield[@code='n']">
    <z:index name="any:w onloan:d onloan:n onloan:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='995']/marc:subfield[@code='u']">
    <z:index name="any:w Note:w Note:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='995']">
    <z:index name="any:w item:w">
      <xsl:value-of select="."/>
      <xsl:apply-templates/>
    </z:index>
  </xsl:template>

</xsl:stylesheet>
