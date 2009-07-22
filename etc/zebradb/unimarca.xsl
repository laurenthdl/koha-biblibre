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
    <xsl:variable name="identifier" select="/*/marc:controlfield[@tag='001']"/>
    <z:record z:id="{$identifier}" >
      <xsl:apply-templates/>
    </z:record>
  </xsl:template>

  <xsl:template match="/*/marc:controlfield[@tag='001']">
    <z:index name="Local-Number:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='942']/marc:subfield[@code='a']">
    <z:index name="authtype:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='152']/marc:subfield[@code='b']">
    <z:index name="authtype:w authtype:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='200']/marc:subfield[@code='a']">
    <z:index name="Personal-name-heading:w Personal-name-heading:p Personal-name-heading:s Personal-name:w Personal-name:p Heading:w Heading:p Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='200']/marc:subfield">
    <z:index name="Personal-name:w Personal-name:p Heading:w Heading:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='400']/marc:subfield">
    <z:index name="Personal-name-see:w Personal-name-see:p See:w See:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='500']/marc:subfield">
    <z:index name="Personal-name-see-also:w Personal-name-see-also:p See-also:w See-also:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='700']/marc:subfield[@code='a']">
    <z:index name="Personal-name-parallel:w Personal-name-parallel:p Parallel:w Parallel:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='210']/marc:subfield[@code='a']">
    <z:index name="Corporate-name-heading:w Corporate-name-heading:p Corporate-name-heading:s Corporate-name:w Corporate-name:p Conference-name-heading:w Conference-name-heading:p Conference-name-heading:s Conference-name:w Conference-name:p Heading:w Heading:p Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='210']/marc:subfield">
    <z:index name="Corporate-name:w Corporate-name:p Conference-name:w Conference-name:p Heading:w Heading:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='410']/marc:subfield">
    <z:index name="Corporate-name-see:w Corporate-name-see:p Conference-name-see:w Conference-name-see:p See:w See:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='510']/marc:subfield">
    <z:index name="Corporate-name-see-also:w Corporate-name-see-also:p Conference-name-see-also:w Conference-name-see-also:p See-also:w See-also:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='710']/marc:subfield">
    <z:index name="Corporate-name-parallel:w Corporate-name-parallel:p Parallel:w Parallel:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='215']/marc:subfield[@code='a']">
    <z:index name="Name-geographic-heading:w Name-geographic-heading:w Name-geographic-heading:s Name-geographic:w Name-geographic:p Term-geographic-heading:w Term-geographic-heading:p Term-geographic-heading:s Term-geographic:w Term-geographic:p Heading:w Heading:p Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='215']/marc:subfield">
    <z:index name="Name-geographic-heading:w Name-geographic-heading:w Name-geographic-heading:s Name-geographic:w Name-geographic:p Term-geographic:w Term-geographic:p Term-geographic:s Heading:w Heading:p Heading:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='415']/marc:subfield">
    <z:index name="Name-geographic-see:w Name-geographic-see:p Term-geographic-see:w Term-geographic-see:p Term-geographic-see:s See:w See:p See:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='515']/marc:subfield">
    <z:index name="Name-geographic-see-also:w Name-geographic-see-also:p Term-geographic-see-also:w Term-geographic-see-also:p Term-geographic-see-also:s See-also:w See-also:p See-also:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='715']/marc:subfield">
    <z:index name="Name-geographic-parallel:w Name-geographic-parallel:p Term-geographic-parallel:w Term-geographic-parallel:p Term-geographic-parallel:s Parallel:w Parallel:p Parallel:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='216']/marc:subfield[@code='a']">
    <z:index name="Trademark-heading:w Trademark-heading:p Trademark-heading:s Trademark:w Trademark:p Conference-name-heading:w Conference-name-heading:p Conference-name-heading:s Conference-name:w Conference-name:p Heading:w Heading:p Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='216']/marc:subfield">
    <z:index name="Trademark:w Trademark:p Conference-name:w Conference-name:p Heading:w Heading:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='416']/marc:subfield">
    <z:index name="Trademark-see:w Trademark-see:p Conference-name-see:w Conference-name-see:p See:w See:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='516']/marc:subfield">
    <z:index name="Trademark-see-also:w Trademark-see-also:p Conference-name-see-also:w Conference-name-see-also:p See-also:w See-also:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='716']/marc:subfield">
    <z:index name="Trademark-parallel:w Trademark-parallel:p Parallel:w Parallel:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='220']/marc:subfield[@code='a']">
    <z:index name="Name-heading:w Name-heading:p Name-heading:s Name:w Name:p Heading:w Heading:p Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='220']/marc:subfield">
    <z:index name="Name:w Name:p Name:s Heading:w Heading:p Heading:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='420']/marc:subfield">
    <z:index name="Name-see:w Name-see:p Name-see:s See:w See:p See:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='520']/marc:subfield">
    <z:index name="Name-see-also:w Name-see-also:p Name-see-also:s See-also:w See-also:p See-also:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='720']/marc:subfield">
    <z:index name="Name-parallel:w Name-parallel:p Name-parallel:s Parallel:w Parallel:p Parallel:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='230']/marc:subfield[@code='a']">
    <z:index name="Title-uniform-heading:w Title-uniform-heading:p Title-uniform-heading:s Title-uniform:w Title-uniform:p Heading:w Heading:p Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='230']/marc:subfield">
    <z:index name="Title-uniform:w Title-uniform:p Heading:w Heading:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='430']/marc:subfield">
    <z:index name="Title-uniform-see:w Title-uniform-see:p See:w See:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='530']/marc:subfield">
    <z:index name="Title-uniform-see-also:w Title-uniform-see-also:p See-also:w See-also:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='730']/marc:subfield[@code='a']">
    <z:index name="Title-uniform-parallel:w Title-uniform-parallel:p Parallel:w Parallel:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='235']/marc:subfield[@code='a']">
    <z:index name="Title-uniform-heading:w Title-uniform-heading:p Title-uniform-heading:s Title-uniform:w Title-uniform:p Heading:w Heading:p Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='235']/marc:subfield">
    <z:index name="Title-uniform:w Title-uniform:p Heading:w Heading:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='435']/marc:subfield">
    <z:index name="Title-uniform-see:w Title-uniform-see:p See:w See:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='535']/marc:subfield">
    <z:index name="Title-uniform-see-also:w Title-uniform-see-also:p See-also:w See-also:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='735']/marc:subfield[@code='a']">
    <z:index name="Title-uniform-parallel:w Title-uniform-parallel:p Parallel:w Parallel:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='240']/marc:subfield[@code='a']">
    <z:index name="Name-Title-heading:w Name-Title-heading:p Name-Title-heading:s Name-Title:w Name-Title:p Heading:w Heading:p Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='240']/marc:subfield">
    <z:index name="Name-Title:w Name-Title:p Heading:w Heading:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='440']/marc:subfield">
    <z:index name="Name-Title-see:w Name-Title-see:p See:w See:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='540']/marc:subfield">
    <z:index name="Name-Title-see-also:w Name-Title-see-also:p See-also:w See-also:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='740']/marc:subfield[@code='a']">
    <z:index name="Name-Title-parallel:w Name-Title-parallel:p Parallel:w Parallel:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='245']/marc:subfield[@code='a']">
    <z:index name="Title-uniform-heading:w Title-uniform-heading:p Title-uniform-heading:s Title-uniform:w Title-uniform:p Heading:w Heading:p Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='245']/marc:subfield">
    <z:index name="Title-uniform:w Title-uniform:p Heading:w Heading:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='445']/marc:subfield">
    <z:index name="Title-uniform-see:w Title-uniform-see:p See:w See:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='545']/marc:subfield">
    <z:index name="Title-uniform-see-also:w Title-uniform-see-also:p See-also:w See-also:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='745']/marc:subfield[@code='a']">
    <z:index name="Title-uniform-parallel:w Title-uniform-parallel:p Parallel:w Parallel:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='250']/marc:subfield[@code='a']">
    <z:index name="Subject-heading:w Subject-heading:p Subject-heading:s Subject:w Subject:p Heading:w Heading:p Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='250']/marc:subfield">
    <z:index name="Subject:w Subject:p Heading:w Heading:p Subject-heading:w Subject-heading:p Subject-heading:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='450']/marc:subfield">
    <z:index name="Subject-see:w Subject-see:p See:w See:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='550']/marc:subfield">
    <z:index name="Subject-see-also:w Subject-see-also:p See-also:w See-also:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='750']/marc:subfield[@code='a']">
    <z:index name="Subject-parallel:w Subject-parallel:p Parallel:w Parallel:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='260']/marc:subfield[@code='a']">
    <z:index name="Place-heading:w Place-heading:p Place-heading:s Place:w Place:p Heading:w Heading:p Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='260']/marc:subfield">
    <z:index name="Place:w Place:p Heading:w Heading:p Place-heading:w Place-heading:p Place-heading:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='460']/marc:subfield">
    <z:index name="Place-see:w Place-see:p See:w See:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='560']/marc:subfield">
    <z:index name="Place-see-also:w Place-see-also:p See-also:w See-also:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='760']/marc:subfield[@code='a']">
    <z:index name="Place-parallel:w Place-parallel:p Parallel:w Parallel:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='280']/marc:subfield[@code='a']">
    <z:index name="Form-heading:w Form-heading:p Form-heading:s Form:w Form:p Heading:w Heading:p Heading:s Heading-Main:w Heading-Main:p Heading-Main:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='280']/marc:subfield">
    <z:index name="Form:w Form:p Heading:w Heading:p Form-heading:w Form-heading:p Form-heading:s">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='480']/marc:subfield">
    <z:index name="Form-see:w Form-see:p See:w See:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='580']/marc:subfield">
    <z:index name="Form-see-also:w Form-see-also:p See-also:w See-also:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='780']/marc:subfield[@code='a']">
    <z:index name="Form-parallel:w Form-parallel:p Parallel:w Parallel:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='300']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='301']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='302']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='303']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='304']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='305']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='306']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='307']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='308']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='310']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='311']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='312']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='313']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='314']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='315']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='316']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='317']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='318']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='320']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='321']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='322']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='323']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='324']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='325']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='326']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='327']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='328']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='330']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='332']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='333']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='336']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='337']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="/*/marc:datafield[@tag='345']/marc:subfield[@code='a']">
    <z:index name="Note:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

</xsl:stylesheet>
