<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<xsl:stylesheet xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:items="http://www.koha.org/items" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" exclude-result-prefixes="marc items">
  <xsl:import href="UNIMARCslimUtils.xsl"/>
  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="marc:record">
    <xsl:variable name="leader" select="marc:leader"/>
    <xsl:variable name="leader6" select="substring($leader,7,1)"/>
    <xsl:variable name="leader7" select="substring($leader,8,1)"/>
    <xsl:variable name="biblionumber" select="marc:datafield[@tag=999]/marc:subfield[@code='a']"/>
    <xsl:if test="marc:datafield[@tag=200]">
      <xsl:for-each select="marc:datafield[@tag=200]">
        <h1>
          <xsl:value-of select="marc:subfield[@code='a']"/>
          <xsl:if test="marc:subfield[@code='e']">
            <xsl:text> : </xsl:text>
            <xsl:value-of select="marc:subfield[@code='e']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='b']">
            <xsl:text> [</xsl:text>
            <xsl:value-of select="marc:subfield[@code='b']"/>
            <xsl:text>]</xsl:text>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='h']">
            <xsl:text> ; </xsl:text>
            <xsl:value-of select="marc:subfield[@code='h']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='i']">
            <xsl:text> ; </xsl:text>
            <xsl:value-of select="marc:subfield[@code='i']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='f']">
            <xsl:text> / </xsl:text>
            <xsl:value-of select="marc:subfield[@code='f']"/>
          </xsl:if>
          <xsl:if test="marc:subfield[@code='g']">
            <xsl:text> ; </xsl:text>
            <xsl:value-of select="marc:subfield[@code='g']"/>
          </xsl:if>
        </h1>
      </xsl:for-each>
    </xsl:if>
<br/>
    <xsl:call-template name="tag_4xx"/>
    <xsl:if test="marc:datafield[@tag=700] or marc:datafield[@tag=701] or marc:datafield[@tag=702] or marc:datafield[@tag=710] or marc:datafield[@tag=711] or marc:datafield[@tag=712]">
      <span class="results_summary">
      <span class="label">Auteur(s) : </span>
      <xsl:for-each select="marc:datafield[@tag=700]">
            <a>
              <xsl:choose>
                <xsl:when test="marc:subfield[@code=8]">
                  <xsl:attribute name="href">
                  /cgi-bin/koha/opac-search.pl?q=an:<xsl:value-of select="marc:subfield[@code=8]"/>
                </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=au:<xsl:value-of select="marc:subfield[@code='a']"/><xsl:text> </xsl:text><xsl:value-of select="marc:subfield[@code='b']"/></xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="marc:subfield[@code='a']">
                <xsl:value-of select="marc:subfield[@code='a']"/>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='b']">,
              <xsl:value-of select="marc:subfield[@code='b']"/>
            </xsl:if>
              <xsl:if test="marc:subfield[@code='f']"> (<xsl:value-of select="marc:subfield[@code='f']"/>)
            </xsl:if>
            </a>
      </xsl:for-each>
      <xsl:if test="marc:datafield[@tag=700] and marc:datafield[@tag>700]/@tag &lt; 800"><xsl:text> ; </xsl:text></xsl:if>
      <xsl:for-each select="marc:datafield[@tag=701]">
          <a>
            <xsl:choose>
              <xsl:when test="marc:subfield[@code=8]">
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=an:<xsl:value-of select="marc:subfield[@code=8]"/></xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=au:<xsl:value-of select="marc:subfield[@code='a']"/><xsl:text> </xsl:text><xsl:value-of select="marc:subfield[@code='b']"/></xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="marc:subfield[@code='a']">
              <xsl:value-of select="marc:subfield[@code='a']"/>
            </xsl:if>
            <xsl:if test="marc:subfield[@code='b']">,
              <xsl:value-of select="marc:subfield[@code='b']"/>
            </xsl:if>
            <xsl:if test="marc:subfield[@code='f']"> (<xsl:value-of select="marc:subfield[@code='f']"/>)
            </xsl:if>
          </a>
          <xsl:call-template name="RelatorCode"/>
          <xsl:choose>
            <xsl:when test="position()=last()">
              <xsl:text></xsl:text>
            </xsl:when>
            <xsl:otherwise>
	      <xsl:text> ; </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
      </xsl:for-each>
      <xsl:if test="marc:datafield[@tag=701] and marc:datafield[@tag>701]/@tag &lt; 800"><xsl:text> ; </xsl:text></xsl:if>
      <xsl:for-each select="marc:datafield[@tag=702]">
          <a>
          <xsl:choose>
            <xsl:when test="marc:subfield[@code=8]"><xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=an:<xsl:value-of select="marc:subfield[@code=8]"/></xsl:attribute></xsl:when>
            <xsl:otherwise><xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=au:<xsl:value-of select="marc:subfield[@code='a']"/><xsl:text></xsl:text><xsl:value-of select="marc:subfield[@code='b']"/></xsl:attribute></xsl:otherwise>
	  </xsl:choose>
	  <xsl:if test="marc:subfield[@code='a']"><xsl:value-of select="marc:subfield[@code='a']"/></xsl:if>
          <xsl:if test="marc:subfield[@code='b']">, <xsl:value-of select="marc:subfield[@code='b']"/></xsl:if>
	  <xsl:if test="marc:subfield[@code='f']"> (<xsl:value-of select="marc:subfield[@code='f']"/>)</xsl:if>
	  </a>
          <xsl:call-template name="RelatorCode"/>
          <xsl:choose><xsl:when test="position()=last()"><xsl:text/></xsl:when><xsl:otherwise><xsl:text> 
; </xsl:text></xsl:otherwise></xsl:choose>
      </xsl:for-each>
      <xsl:if test="marc:datafield[@tag=702] and marc:datafield[@tag>702]/@tag &lt; 800"><xsl:text> ; </xsl:text></xsl:if>
      <xsl:for-each select="marc:datafield[@tag=710]">
            <a>
              <xsl:choose>
                <xsl:when test="marc:subfield[@code=8]">
                  <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=an:<xsl:value-of select="marc:subfield[@code=8]"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=au:<xsl:value-of select="marc:subfield[@code='a']"/><xsl:text> </xsl:text><xsl:value-of select="marc:subfield[@code='b']"/></xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="marc:subfield[@code='a']">
                <xsl:value-of select="marc:subfield[@code='a']"/>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='b']">,
              <xsl:value-of select="marc:subfield[@code='b']"/>
            </xsl:if>
              <xsl:if test="marc:subfield[@code='d']">,
              <xsl:value-of select="marc:subfield[@code='d']"/>
            </xsl:if>
              <xsl:if test="marc:subfield[@code='e']">,
              <xsl:value-of select="marc:subfield[@code='e']"/>
            </xsl:if>
              <xsl:if test="marc:subfield[@code='f']"> (<xsl:value-of select="marc:subfield[@code='f']"/>)
            </xsl:if>
            </a>
      </xsl:for-each>
      <xsl:if test="marc:datafield[@tag=710] and marc:datafield[@tag>710]/@tag &lt; 800"><xsl:text> ; </xsl:text></xsl:if>
      <xsl:for-each select="marc:datafield[@tag=711]">
            <a>
            <xsl:choose>
              <xsl:when test="marc:subfield[@code=8]">
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=an:<xsl:value-of select="marc:subfield[@code=8]"/></xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=au:<xsl:value-of select="marc:subfield[@code='a']"/><xsl:text> </xsl:text><xsl:value-of select="marc:subfield[@code='b']"/></xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="marc:subfield[@code='a']">
              <xsl:value-of select="marc:subfield[@code='a']"/>
            </xsl:if>
            <xsl:if test="marc:subfield[@code='b']">,
              <xsl:value-of select="marc:subfield[@code='b']"/>
            </xsl:if>
            <xsl:if test="marc:subfield[@code='d']">,
              <xsl:value-of select="marc:subfield[@code='d']"/>
            </xsl:if>
            <xsl:if test="marc:subfield[@code='e']">,
              <xsl:value-of select="marc:subfield[@code='e']"/>
            </xsl:if>
            <xsl:if test="marc:subfield[@code='f']"> (<xsl:value-of select="marc:subfield[@code='f']"/>)
            </xsl:if>
            </a>
            <xsl:call-template name="RelatorCode"/>
            <xsl:choose>
              <xsl:when test="position()=last()">
                <xsl:text/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text> ; </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
      </xsl:for-each>
      <xsl:if test="marc:datafield[@tag=711] and marc:datafield[@tag>711]/@tag &lt; 800"><xsl:text> ; </xsl:text></xsl:if>
      <xsl:for-each select="marc:datafield[@tag=712]">
            <a>
              <xsl:choose>
                <xsl:when test="marc:subfield[@code=8]">
                  <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=an:<xsl:value-of select="marc:subfield[@code=8]"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=au:<xsl:value-of select="marc:subfield[@code='a']"/><xsl:text> </xsl:text><xsl:value-of select="marc:subfield[@code='b']"/></xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="marc:subfield[@code='a']">
                <xsl:value-of select="marc:subfield[@code='a']"/>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='b']">,
                <xsl:value-of select="marc:subfield[@code='b']"/>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='d']">,
                <xsl:value-of select="marc:subfield[@code='d']"/>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='e']">,
                <xsl:value-of select="marc:subfield[@code='e']"/>
              </xsl:if>
              <xsl:if test="marc:subfield[@code='f']"> (<xsl:value-of select="marc:subfield[@code='f']"/>)
              </xsl:if>
            </a>
          <xsl:call-template name="RelatorCode"/>
          <xsl:choose>
              <xsl:when test="position()=last()">
                <xsl:text/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text> ; </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
      </xsl:for-each>
      </span>
    </xsl:if>
<!--  <xsl:if test="marc:datafield[@tag=101]"><span class="results_summary"><span class="label">Langue: </span><xsl:for-each select="marc:datafield[@tag=101]"><xsl:for-each select="marc:subfield"><xsl:choose><xsl:when test="@code='b'">de la trad. intermédiaire, </xsl:when><xsl:when test="@code='c'">de l'œuvre originale, </xsl:when><xsl:when test="@code='d'">du résumé, </xsl:when><xsl:when test="@code='e'">de la table des matières, </xsl:when><xsl:when test="@code='f'">de la page de titre, </xsl:when><xsl:when test="@code='g'">du titre propre, </xsl:when><xsl:when test="@code='h'">d'un livret, </xsl:when><xsl:when test="@code='i'">des textes d'accompagnement, </xsl:when><xsl:when test="@code='j'">des sous-titres, </xsl:when></xsl:choose><xsl:value-of select="text()"/><xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text> ; </xsl:text></xsl:otherwise></xsl:choose></xsl:for-each></xsl:for-each></span></xsl:if>
      <xsl:if test="marc:datafield[@tag=102]"><span class="results_summary"><span class="label">Pays: </span><xsl:for-each select="marc:datafield[@tag=102]"><xsl:for-each select="marc:subfield"><xsl:value-of select="text()"/><xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise></xsl:choose></xsl:for-each></xsl:for-each></span></xsl:if>
-->
    <xsl:call-template name="tag_210"/>
    <xsl:call-template name="tag_215"/>
    <abbr class="unapi-id" title="koha:biblionumber:{marc:datafield[@tag=090]/marc:subfield[@code='a']}">
      <!-- unAPI -->
    </abbr>
    <xsl:if test="marc:datafield[@tag=010]/marc:subfield[@code='a']">
      <span class="results_summary">
        <span class="label">ISBN: </span>
        <xsl:for-each select="marc:datafield[@tag=010]">
          <xsl:variable name="isbn" select="marc:subfield[@code='a']"/>
          <xsl:value-of select="marc:subfield[@code='a']"/>
          <xsl:choose>
            <xsl:when test="position()=last()">
              <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text> ; </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </span>
    </xsl:if>
    <xsl:if test="marc:datafield[@tag=011]">
      <span class="results_summary">
        <span class="label">ISSN: </span>
        <xsl:for-each select="marc:datafield[@tag=011]">
          <xsl:value-of select="marc:subfield[@code='a']"/>
          <xsl:choose>
            <xsl:when test="position()=last()">
              <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>; </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </span>
    </xsl:if>
    <xsl:if test="marc:datafield[@tag=676]">
      <span class="results_summary">
        <span class="label">Dewey: </span>
        <xsl:for-each select="marc:datafield[@tag=676]">
          <xsl:value-of select="marc:subfield[@code='a']"/>
          <xsl:choose>
            <xsl:when test="position()=last()">
              <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>; </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </span>
    </xsl:if>
    <xsl:if test="marc:datafield[@tag=330]">
      <span class="results_summary">
        <span class="label">Résumé: </span>
        <xsl:for-each select="marc:datafield[@tag=330]">
          <xsl:value-of select="marc:subfield[@code='a']"/>
          <xsl:choose>
            <xsl:when test="position()=last()">
              <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>; </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </span>
    </xsl:if>
    <xsl:if test="marc:datafield[@tag=317]">
      <span class="results_summary">
        <span class="label">Note sur la provenance: </span>
        <xsl:for-each select="marc:datafield[@tag=317]">
          <xsl:value-of select="marc:subfield[@code='a']"/>
        </xsl:for-each>
      </span>
    </xsl:if>
    <xsl:if test="marc:datafield[@tag=320]">
      <span class="results_summary">
        <span class="label">Bibliographie: </span>
        <xsl:for-each select="marc:datafield[@tag=320]">
          <xsl:value-of select="marc:subfield[@code='a']"/>
          <xsl:choose>
            <xsl:when test="position()=last()">
              <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>; </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </span>
    </xsl:if>
    <xsl:if test="marc:datafield[@tag=328]">
      <span class="results_summary">
        <span class="label">Thèse: </span>
        <xsl:for-each select="marc:datafield[@tag=328]">
          <xsl:value-of select="marc:subfield[@code='a']"/>
          <xsl:choose>
            <xsl:when test="position()=last()">
              <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>; </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </span>
    </xsl:if>
    <xsl:if test="marc:datafield[@tag=333]">
      <span class="results_summary">
        <span class="label">Public: </span>
        <xsl:for-each select="marc:datafield[@tag=333]">
          <xsl:value-of select="marc:subfield[@code='a']"/>
          <xsl:choose>
            <xsl:when test="position()=last()">
              <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>; </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </span>
    </xsl:if>
    <xsl:if test="marc:datafield[@tag=600 or @tag=601 or @tag=606 or @tag=607 or @tag=610]">
      <span class="results_summary">
        <span class="label">Sujets: </span>
        <xsl:for-each select="marc:datafield[@tag=600 or @tag=601 or @tag=606 or @tag=607 or @tag=610]">
          <a>
            <xsl:choose>
              <xsl:when test="marc:subfield[@code=8]">
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=an:<xsl:value-of select="marc:subfield[@code=8]"/></xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=su:<xsl:value-of select="marc:subfield[@code='a']"/></xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:call-template name="subfieldSelect">
                  <xsl:with-param name="codes">abcdjpvxyz</xsl:with-param>
                  <xsl:with-param name="subdivCodes">jpxyz</xsl:with-param>
                  <xsl:with-param name="subdivDelimiter">-- </xsl:with-param>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
          </a>
          <xsl:choose>
            <xsl:when test="position()=last()"/>
            <xsl:otherwise> | </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </span>
    </xsl:if>
    <xsl:if test="marc:datafield[@tag=856]">
      <span class="results_summary">
        <span class="label">Online Resources: </span>
        <xsl:for-each select="marc:datafield[@tag=856]">
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="marc:subfield[@code='u']"/>
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="marc:subfield[@code='y' or @code='3' or @code='z']">
                <xsl:call-template name="subfieldSelect">
                  <xsl:with-param name="codes">y3z</xsl:with-param>
                </xsl:call-template>
              </xsl:when>
              <xsl:when test="not(marc:subfield[@code='y']) and not(marc:subfield[@code='3']) and not(marc:subfield[@code='z'])">
              Click here to access online
            </xsl:when>
            </xsl:choose>
          </a>
          <xsl:choose>
            <xsl:when test="position()=last()"/>
            <xsl:otherwise> | </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </span>
    </xsl:if>
    <!-- 780 -->
    <xsl:if test="marc:datafield[@tag=780]">
      <xsl:for-each select="marc:datafield[@tag=780]">
        <span class="results_summary">
          <span class="label">
            <xsl:choose>
              <xsl:when test="@ind2=0">
            Continues:
        </xsl:when>
              <xsl:when test="@ind2=1">
            Continues in part:
        </xsl:when>
              <xsl:when test="@ind2=2">
            Supersedes:
        </xsl:when>
              <xsl:when test="@ind2=3">
            Supersedes in part:
        </xsl:when>
              <xsl:when test="@ind2=4">
            Formed by the union: ... and: ...
        </xsl:when>
              <xsl:when test="@ind2=5">
            Absorbed:
        </xsl:when>
              <xsl:when test="@ind2=6">
            Absorbed in part:
        </xsl:when>
              <xsl:when test="@ind2=7">
            Separated from:
        </xsl:when>
            </xsl:choose>
          </span>
          <xsl:variable name="f780">
            <xsl:call-template name="subfieldSelect">
              <xsl:with-param name="codes">at</xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <a>
            <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=<xsl:value-of select="translate($f780, '()', '')"/></xsl:attribute>
            <xsl:value-of select="translate($f780, '()', '')"/>
          </a>
        </span>
        <xsl:choose>
          <xsl:when test="@ind1=0">
            <span class="results_summary">
              <xsl:value-of select="marc:subfield[@code='n']"/>
            </span>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
    <!-- 785 -->
    <xsl:if test="marc:datafield[@tag=785]">
      <xsl:for-each select="marc:datafield[@tag=785]">
        <span class="results_summary">
          <span class="label">
            <xsl:choose>
              <xsl:when test="@ind2=0">
            Continued by:
        </xsl:when>
              <xsl:when test="@ind2=1">
            Continued in part by:
        </xsl:when>
              <xsl:when test="@ind2=2">
            Superseded by:
        </xsl:when>
              <xsl:when test="@ind2=3">
            Superseded in part by:
        </xsl:when>
              <xsl:when test="@ind2=4">
            Absorbed by:
        </xsl:when>
              <xsl:when test="@ind2=5">
            Absorbed in part by:
        </xsl:when>
              <xsl:when test="@ind2=6">
            Split into .. and ...:
        </xsl:when>
              <xsl:when test="@ind2=7">
            Merged with ... to form ...
        </xsl:when>
              <xsl:when test="@ind2=8">
            Changed back to:
        </xsl:when>
            </xsl:choose>
          </span>
          <xsl:variable name="f785">
            <xsl:call-template name="subfieldSelect">
              <xsl:with-param name="codes">at</xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <a>
            <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=<xsl:value-of select="translate($f785, '()', '')"/></xsl:attribute>
            <xsl:value-of select="translate($f785, '()', '')"/>
          </a>
        </span>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  <xsl:template name="nameABCDQ">
    <xsl:call-template name="chopPunctuation">
      <xsl:with-param name="chopString">
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">aq</xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="punctuation">
        <xsl:text>:,;/ </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="termsOfAddress"/>
  </xsl:template>
  <xsl:template name="nameABCDN">
    <xsl:for-each select="marc:subfield[@code='a']">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString" select="."/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="marc:subfield[@code='b']">
      <xsl:value-of select="."/>
    </xsl:for-each>
    <xsl:if test="marc:subfield[@code='c'] or marc:subfield[@code='d'] or marc:subfield[@code='n']">
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">cdn</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template name="nameACDEQ">
    <xsl:call-template name="subfieldSelect">
      <xsl:with-param name="codes">acdeq</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template name="termsOfAddress">
    <xsl:if test="marc:subfield[@code='b' or @code='c']">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">bc</xsl:with-param>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template name="part">
    <xsl:variable name="partNumber">
      <xsl:call-template name="specialSubfieldSelect">
        <xsl:with-param name="axis">n</xsl:with-param>
        <xsl:with-param name="anyCodes">n</xsl:with-param>
        <xsl:with-param name="afterCodes">fghkdlmor</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="partName">
      <xsl:call-template name="specialSubfieldSelect">
        <xsl:with-param name="axis">p</xsl:with-param>
        <xsl:with-param name="anyCodes">p</xsl:with-param>
        <xsl:with-param name="afterCodes">fghkdlmor</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="string-length(normalize-space($partNumber))">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString" select="$partNumber"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="string-length(normalize-space($partName))">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString" select="$partName"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template name="specialSubfieldSelect">
    <xsl:param name="anyCodes"/>
    <xsl:param name="axis"/>
    <xsl:param name="beforeCodes"/>
    <xsl:param name="afterCodes"/>
    <xsl:variable name="str">
      <xsl:for-each select="marc:subfield">
        <xsl:if test="contains($anyCodes, @code)      or (contains($beforeCodes,@code) and following-sibling::marc:subfield[@code=$axis])      or (contains($afterCodes,@code) and preceding-sibling::marc:subfield[@code=$axis])">
          <xsl:value-of select="text()"/>
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="substring($str,1,string-length($str)-1)"/>
  </xsl:template>
</xsl:stylesheet>
