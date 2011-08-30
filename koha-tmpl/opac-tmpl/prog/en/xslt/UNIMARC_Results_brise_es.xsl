<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:items="http://www.koha.org/items"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="marc items">

<xsl:import href="UNIMARC_Results_utils_brise_es.xsl"/>
<!-- pour visu autonome  
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
<xsl:output method = "xml" indent="yes" omit-xml-declaration = "yes" /> 

<xsl:key name="item-by-status" match="items:item" use="items:status"/>
<xsl:key name="item-by-status-and-branch" match="items:item" use="concat(items:status, ' ', items:homebranch)"/>

<!-- 
<xsl:template match="/">

<xsl:apply-templates/>
</xsl:template>
-->
<xsl:template match="marc:record">
  <xsl:variable name="leader" select="marc:leader"/>
  <xsl:variable name="leader6" select="substring($leader,7,1)"/>
  <xsl:variable name="leader7" select="substring($leader,8,1)"/>
  <xsl:variable name="biblionumber" 
select="marc:datafield[@tag=999]/marc:subfield[@code='9']"/>
  <xsl:variable name="isbn" select="marc:datafield[@tag=010]/marc:subfield[@code='a']"/>

  <xsl:if test="marc:datafield[@tag=200]">
      	<span class="results_icon">
<xsl:if test="marc:datafield[@tag=099]/marc:subfield[@code='t']">
<xsl:choose>
<xsl:when test="marc:datafield[@tag=099]/marc:subfield[@code='t']='Livre imprimé'"><img src="/opac-tmpl/prog/itemtypeimg/sudoc/book_b.gif" alt="book" title="book"/>&#xA0;</xsl:when>
<xsl:when test="marc:datafield[@tag=099]/marc:subfield[@code='t']='Livre numérique'"><img src="/opac-tmpl/prog/itemtypeimg/sudoc/binary_b.gif" alt="electronic ressource" title="electronic ressource"/>&#xA0;</xsl:when>
<xsl:when test="marc:datafield[@tag=099]/marc:subfield[@code='t']='Revue imprimée'"><img src="/opac-tmpl/prog/itemtypeimg/sudoc/periodical_b.gif" alt="periodical" title="periodical"/>&#xA0;</xsl:when>
<xsl:when test="marc:datafield[@tag=099]/marc:subfield[@code='t']='Thèse, mémoire, rapport'"><img src="/opac-tmpl/prog/itemtypeimg/sudoc/thesis_b.gif" alt="thesis" title="thesis"/>&#xA0;</xsl:when>
<xsl:when test="marc:datafield[@tag=099]/marc:subfield[@code='t']='Carte'"><img src="/opac-tmpl/prog/itemtypeimg/sudoc/map_b.gif" alt="map" title="map"/>&#xA0;</xsl:when>
<xsl:when test="marc:datafield[@tag=099]/marc:subfield[@code='t']='Partition'"><img src="/opac-tmpl/prog/itemtypeimg/sudoc/score_b.gif" alt="score" title="score"/>&#xA0;</xsl:when>
<xsl:when test="marc:datafield[@tag=099]/marc:subfield[@code='t']='Article'"><img src="/opac-tmpl/prog/itemtypeimg/sudoc/article_b.gif" alt="article" title="article"/>&#xA0;</xsl:when>
<xsl:when test="marc:datafield[@tag=099]/marc:subfield[@code='t']='DVD'"><img src="/opac-tmpl/prog/itemtypeimg/sudoc/audiovisual_b.gif" alt="audiovisuel" title="audiovisuel"/>&#xA0;</xsl:when>
<xsl:when test="marc:datafield[@tag=099]/marc:subfield[@code='t']='Video'"><img src="/opac-tmpl/prog/itemtypeimg/sudoc/audiovisual_b.gif" alt="audiovisuel" title="audiovisuel"/>&#xA0;</xsl:when>
<xsl:otherwise><img src="/opac-tmpl/prog/itemtypeimg/sudoc/unknown_b.gif" alt="autre" title="autre"/>&#xA0;</xsl:otherwise>
</xsl:choose>
</xsl:if>
</span>
      	<span class="results_titre">
    <xsl:for-each select="marc:datafield[@tag=200]">
<a><xsl:attribute name="href">/cgi-bin/koha/opac-detail.pl?biblionumber=<xsl:value-of select="$biblionumber"/>
           </xsl:attribute>
        <xsl:variable name="title" select="marc:subfield[@code='a']"/>
        <xsl:variable name="ntitle"
             select="translate($title, '&#x0098;&#x009C;&#xC29C;&#xC29B;&#xC298;&#xC288;&#xC289;','')"/>
        <xsl:value-of select="$ntitle" />
      </a>
     <!-- sous titre -->
      <xsl:if test="marc:subfield[@code='e']">
        <xsl:text> : </xsl:text>
        <xsl:value-of select="marc:subfield[@code='e']"/>
      </xsl:if>

      <!-- la valeur de 200$b ne semble plus exister quand xslt traite le marcxml  
      <xsl:if test="marc:subfield[@code='b']">
        <xsl:text> [</xsl:text>
        <xsl:value-of select="marc:subfield[@code='b']"/>
        <xsl:text>]</xsl:text>
      </xsl:if>
-->

      <!--tomaison-->
      <xsl:if test="marc:subfield[@code='h']">
        <xsl:text>. </xsl:text>
        <xsl:value-of select="marc:subfield[@code='h']"/>
      </xsl:if>
      
      <!-- titre de partie -->
      <xsl:if test="marc:subfield[@code='i']">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="marc:subfield[@code='i']"/>
      </xsl:if>
      
      <!-- titre parallele -->
      <xsl:if test="marc:subfield[@code='d']">
        <xsl:text> = </xsl:text>
        <xsl:value-of select="marc:subfield[@code='d']"/>
      </xsl:if>
      
      <!-- responsabilite ppale -->
      <xsl:if test="marc:subfield[@code='f']">
        <xsl:text> / </xsl:text>
        <xsl:value-of select="marc:subfield[@code='f']"/>
      </xsl:if>
      
      <!--  responsabilte secondaire, pas dans liste resultat 
      <xsl:if test="marc:subfield[@code='g']">
        <xsl:text> ; </xsl:text>
        <xsl:value-of select="marc:subfield[@code='g']"/>
      </xsl:if>
      -->
      <xsl:text> </xsl:text>
    </xsl:for-each>
    </span>
  </xsl:if>


<span class="result_summary">
  <!-- <xsl:call-template name="tag_4xx" /> -->

  <xsl:call-template name="tag_205" />
  
  <xsl:call-template name="tag_210" />
  
<xsl:call-template name="tag_225" />


  <!-- <xsl:call-template name="tag_215" /> -->

  <xsl:call-template name="tag_930" />

  <xsl:call-template name="tag_940" />
</span>

  <span class="results_summary_dispo">
    
    <xsl:choose>
      <xsl:when test="marc:datafield[@tag=856]">
        <xsl:for-each select="marc:datafield[@tag=856]">
          <!-- <xsl:choose> -->
            <!-- <xsl:when test="@ind2=0"> a quoi correspond ce 0 ??? indic2 est blanc non def !! -->
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="marc:subfield[@code='u']"/>
                </xsl:attribute>
                <xsl:attribute name="target">_blank</xsl:attribute>
                <xsl:choose>
                  <xsl:when test="marc:subfield[@code='y' or @code='3' or @code='z']"> <!-- code=3 ??? -->
                    <xsl:call-template name="subfieldSelect">                        
                      <xsl:with-param name="codes">y3z</xsl:with-param>                    
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:when test="not(marc:subfield[@code='y']) and not(marc:subfield[@code='3']) and not(marc:subfield[@code='z'])"><!-- code=3 ??? -->
                    Click here to access online
                  </xsl:when>
                </xsl:choose>
              </a>
              <xsl:choose>
                <xsl:when test="position()=last()"></xsl:when>
                <xsl:otherwise> | </xsl:otherwise>
              </xsl:choose>
           <!--  </xsl:when> -->
          <!-- </xsl:choose> -->
        </xsl:for-each>
      </xsl:when>
<!--      <xsl:when test="count(key('item-by-status', 'available'))=0 and count(key('item-by-status', 'reference'))=0">
        Pas de copie disponible
      </xsl:when> -->
      <xsl:when test="count(key('item-by-status', 'available'))>0">
        <span class="available">
          <b><xsl:text>For loan: </xsl:text></b>
          <xsl:variable name="available_items" select="key('item-by-status', 'available')"/>
          <xsl:for-each select="$available_items[generate-id() = generate-id(key('item-by-status-and-branch', concat(items:status, ' ', items:homebranch))[1])]">
            <xsl:value-of select="items:homebranch"/>
  			    <xsl:if test="items:itemcallnumber != '' and items:itemcallnumber"> [<xsl:value-of select="items:itemcallnumber"/>]
  			    </xsl:if>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="count(key('item-by-status-and-branch', concat(items:status, ' ', items:homebranch)))"/>
            <xsl:text>)</xsl:text>
            <xsl:choose>
              <xsl:when test="position()=last()">
                <xsl:text>. </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>, </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </span>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="count(key('item-by-status', 'reference'))>0">
        <span class="available">
          <b><xsl:text>Copies available for reference: </xsl:text></b>
          <xsl:variable name="reference_items"
                        select="key('item-by-status', 'reference')"/>
          <xsl:for-each select="$reference_items[generate-id() = generate-id(key('item-by-status-and-branch', concat(items:status, ' ', items:homebranch))[1])]">
            <xsl:value-of select="items:homebranch"/>
            <xsl:if test="items:itemcallnumber != '' and items:itemcallnumber"> [<xsl:value-of select="items:itemcallnumber"/>]</xsl:if>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="count(key('item-by-status-and-branch', concat(items:status, ' ', items:homebranch)))"/>
            <xsl:text>)</xsl:text>
            <xsl:choose>
              <xsl:when test="position()=last()">
                <xsl:text>. </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>, </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </span>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="count(key('item-by-status', 'Checked out'))>0">
      <span class="unavailable">
        <xsl:text>Checked out (</xsl:text>
        <xsl:value-of select="count(key('item-by-status', 'Checked out'))"/>
        <xsl:text>). </xsl:text>
      </span>
    </xsl:if>
    <xsl:if test="count(key('item-by-status', 'Withdrawn'))>0">
      <span class="unavailable">
        <xsl:text>Withdrawn (</xsl:text>
        <xsl:value-of select="count(key('item-by-status', 'Withdrawn'))"/>
        <xsl:text>). </xsl:text>
      </span>
    </xsl:if>
    <xsl:if test="count(key('item-by-status', 'Lost'))>0">
      <span class="unavailable">
        <xsl:text>Lost (</xsl:text>
        <xsl:value-of select="count(key('item-by-status', 'Lost'))"/>
        <xsl:text>). </xsl:text>
      </span>
    </xsl:if>
    <xsl:if test="count(key('item-by-status', 'Damaged'))>0">
      <span class="unavailable">
        <xsl:text>Damaged (</xsl:text>
        <xsl:value-of select="count(key('item-by-status', 'Damaged'))"/>
        <xsl:text>). </xsl:text>
      </span>
    </xsl:if>
    <xsl:if test="count(key('item-by-status', 'On Orangemanr'))>0">
      <span class="unavailable">
        <xsl:text>On order (</xsl:text>
        <xsl:value-of select="count(key('item-by-status', 'On order'))"/>
        <xsl:text>). </xsl:text>
      </span>
    </xsl:if>
    <xsl:if test="count(key('item-by-status', 'In transit'))>0">
      <span class="unavailable">
        <xsl:text>In transit (</xsl:text>
        <xsl:value-of select="count(key('item-by-status', 'In transit'))"/>
        <xsl:text>). </xsl:text>
      </span>
    </xsl:if>
    <xsl:if test="count(key('item-by-status', 'Waiting'))>0">
      <span class="unavailable">
        <xsl:text>On hold (</xsl:text>
        <xsl:value-of select="count(key('item-by-status', 'Waiting'))"/>
        <xsl:text>). </xsl:text>
      </span>
    </xsl:if>
  </span>

</xsl:template>

</xsl:stylesheet>
