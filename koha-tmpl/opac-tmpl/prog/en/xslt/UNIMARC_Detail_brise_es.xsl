<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<xsl:stylesheet xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:items="http://www.koha.org/items" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" exclude-result-prefixes="marc items">
  <xsl:import href="UNIMARC_Detail_utils_brise_es.xsl"/>
  
<!-- a enlever en prod a utiliser en local   
  <xsl:output method="html" doctype-public="-//W3C/DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/transitional.dtd" />    
      <xsl:template match="/">
        <html>
          <head>
            <meta http-equiv="Content-Type" content="text/html" charset="utf-8"/>
            <link href="opac.css" rel="stylesheet" type="text/css" />
          </head>
          <body>
           <xsl:apply-templates />
          </body>
        </html>
      </xsl:template>
 -->
<!-- a remettre en prod a enlever en local -->
<xsl:output method = "xml" indent="yes" omit-xml-declaration = "yes" />   
  
<!-- 3 lignes a remettre en prod a enlever en local -->
   <xsl:template match="/">
   <xsl:apply-templates/>
   </xsl:template>
 
  
  <xsl:template match="marc:record">
    <xsl:variable name="leader" select="marc:leader" />
    <xsl:variable name="leader6" select="substring($leader,7,1)" />
    <xsl:variable name="leader7" select="substring($leader,8,1)" />
    <xsl:variable name="biblionumber" select="marc:datafield[@tag=999]/marc:subfield[@code='9']" />
   <div class="container">
    <div id="catalogue_detail_biblio">

<xsl:if test="marc:datafield[@tag=200]">
      <xsl:for-each select="marc:datafield[@tag=200]">
<!--        <div id="bookcover" style="height:200px;width:160px;border:1px solid grey;margin:2px;">couv</div> --> <h1><span class="detail_titre">
    <xsl:for-each select="marc:subfield[@code='a']">
            <xsl:variable name="title" select="."/> 
            <xsl:variable name="ntitle"
                select="translate($title, '&#x0098;&#x009C;&#xC29C;&#xC29B;&#xC298;&#xC288;&#xC289;','')"/>
             <xsl:value-of select="$ntitle" /> 
          <xsl:choose>
            <xsl:when test="position()!=last()">
              <xsl:text> ; </xsl:text>
            </xsl:when>
          </xsl:choose>
    </xsl:for-each>
          <xsl:if test="marc:subfield[@code='d']">
            <xsl:text> = </xsl:text>
            <xsl:value-of select="marc:subfield[@code='d']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='e']">
            <xsl:text> : </xsl:text>
            <xsl:value-of select="marc:subfield[@code='e']"/>
          </xsl:if>

<!-- 
          <xsl:if test="marc:subfield[@code='b']">
            <xsl:text> [</xsl:text>
            <xsl:value-of select="marc:subfield[@code='b']"/>
            <xsl:text>]</xsl:text>
          </xsl:if>
--> 
          <xsl:if test="marc:subfield[@code='h']">
            <xsl:text>. </xsl:text>
            <xsl:value-of select="marc:subfield[@code='h']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='i']">
          <xsl:choose>
            <xsl:when test="marc:subfield[@code='h']">
              <xsl:text>, </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>. </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
            <xsl:value-of select="marc:subfield[@code='i']"/>
          </xsl:if>
	</span><span class="detail_resp">
          <xsl:if test="marc:subfield[@code='f']">
            <xsl:text> / </xsl:text>
            <xsl:value-of select="marc:subfield[@code='f']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='g']">
            <xsl:text> ; </xsl:text>
            <xsl:value-of select="marc:subfield[@code='g']"/>
          </xsl:if>
        </span></h1>
      </xsl:for-each>
    </xsl:if>

<div class="notice">
<xsl:call-template name="tag_7xx" /><!-- auteurs -->
<xsl:call-template name="tag_205" /><!-- édition -->
<xsl:call-template name="tag_210" /><!-- éditeur -->

<xsl:call-template name="tag_225" /><!-- collection -->
<xsl:call-template name="tag_300" /><!-- note géné -->
<xsl:call-template name="tag_328" /><!-- note thèse -->
<xsl:call-template name="tag_099" /><!-- ccode / type de doc -->
<xsl:if test="marc:datafield[@tag=463]">
<xsl:call-template name="tag_463" /><!-- lien titre revue si article -->
</xsl:if>
<xsl:call-template name="tag_856" /><!-- url -->
<xsl:call-template name="tag_215" /><!-- description -->
<xsl:call-template name="tag_010" /><!-- isbn -->
<xsl:call-template name="tag_011" /><!-- issn -->
<xsl:call-template name="tag_930" /><!-- collection perio -->
<xsl:call-template name="tag_330" /><!-- résumé -->
<xsl:call-template name="tag_6xx" /><!-- sujets -->
<xsl:call-template name="tag_940" /><!-- en commande -->
<xsl:call-template name="tag_992" /><!-- sujet en3s -->
<xsl:call-template name="tag_993" /><!-- sujet ensase -->

</div>

</div></div> <!-- <div style="height:150px;margin-top:50px;"><hr /></div> -->
</xsl:template>

</xsl:stylesheet>
