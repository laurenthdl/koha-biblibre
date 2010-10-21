<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<xsl:stylesheet xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:items="http://www.koha.org/items" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" exclude-result-prefixes="marc items">
  <xsl:import href="UNIMARCslimUtils.xsl"/>
  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
  <xsl:template match="/">
  
  <table id="holdingst">
	    <xsl:variable name="biblionumber" select="//marc:controlfield[@tag=001]"/>
	    <thead><tr>
	    <!-- count items:displayedstatus : <xsl:value-of select="count(//items:displayedstatus)" /> -->
	    <!--  count items:displayedstatus where value = Available : <xsl:value-of select="count(//items:displayedstatus[text()='Available'])" /> -->
	    <!--  count syspref Version : <xsl:value-of select="count(//marc:syspref[@name='Version'])" /> -->
	    <!--  if at least on items:displayedstatus with Available value exist : <xsl:if test="count(//items:displayedstatus[text()='Available'])">TH</xsl:if>-->
	    <xsl:if test="//marc:syspref[@name='item-level_itypes']"><xsl:if test="//marc:syspref[@name='item-level_itypes'][text()!='0']">
	    <th>Item type</th>
		</xsl:if></xsl:if>
		<th>Location</th>
	    <xsl:if test="count(//items:itemccode[text()])"><th>Collection</th></xsl:if>
	    <th>Call Number</th>
	    <xsl:if test="count(//items:itemenumchron[text()])"><th>Vol Info</th></xsl:if>
	    <xsl:if test="count(//items:itemuri[text()])"><th>URL</th></xsl:if>
	    <xsl:if test="count(//items:itemcopynumber[text()])"><th>Copy</th></xsl:if>
		<th>Status</th>
		<xsl:if test="count(//items:itemitemnotes[text()])"><th>Notes</th></xsl:if>
		<th>Date Due</th>
	    <xsl:if test="count(//items:itemserialseq[text()])"><th>Serial number</th></xsl:if>
	    <xsl:if test="count(//items:itempublisheddate[text()])"><th>Publication date</th></xsl:if>
	    </tr></thead>
	    <tbody>
		<xsl:for-each select="//items:item">
			<tr>
			<xsl:if test="//marc:syspref[@name='item-level_itypes']"><xsl:if test="//marc:syspref[@name='item-level_itypes'][text()!='0']">
			<td>
			<xsl:if test="items:itemimageurl[text()]">
			<img>
			<xsl:attribute name="src"><xsl:value-of select="items:itemimageurl"/></xsl:attribute>
			<xsl:attribute name="title"><xsl:value-of select="items:itemdescription"/></xsl:attribute>
			<xsl:attribute name="alt"><xsl:value-of select="items:itemdescription"/></xsl:attribute>
			</img>
			</xsl:if>
			<xsl:value-of select="concat(' ', items:itemdescription)" /></td>
			</xsl:if></xsl:if>
			<td>
			<xsl:if test="//marc:syspref[@name='item-singleBranchMode']"><xsl:if test="//marc:syspref[@name='item-singleBranchMode'][text()='0']">
		    <xsl:if test="items:itembranchurl[text()]"><a><xsl:attribute name="href"><xsl:value-of select="items:itembranchurl"/></xsl:attribute><xsl:value-of select="items:homebranch"/></a></xsl:if>
			<xsl:if test="not(items:itembranchurl[text()])"><xsl:value-of select="items:homebranch"/></xsl:if>
			</xsl:if></xsl:if>
			<xsl:if test="not(//marc:syspref[@name='item-singleBranchMode'])">
			<xsl:if test="items:itembranchurl[text()]"><a><xsl:attribute name="href"><xsl:value-of select="items:itembranchurl"/></xsl:attribute><xsl:value-of select="items:homebranch"/></a></xsl:if>
			<xsl:if test="not(items:itembranchurl[text()])"><xsl:value-of select="items:homebranch"/></xsl:if>
			</xsl:if>
			<xsl:value-of select="concat(' ', items:itemlocation,' ')"/>
			</td>
			<xsl:if test="items:itemccode[text()]"><td><xsl:value-of select="items:itemccode"/></td></xsl:if>
			<td>
			<xsl:if test="items:itemcallnumber[text()]"><xsl:value-of select="items:itemcallnumber"></xsl:if>
			<xsl:if test="//marc:syspref[@name='OPACShelfBrowser']"><xsl:if test="//marc:syspref[@name='OPACShelfBrowser'][text()!='0']">
			 (<a><xsl:attribute name="href"><xsl:value-of select="concat('/cgi-bin/koha/opac-detail.pl?biblionumber=',$biblionumber,'&amp;shelfbrowse_itemnumber=',items:itemnumber,'#shelfbrowser')" /></xsl:attribute>Browse Shelf</a>)
			</xsl:if></xsl:if>
			</td>
			<xsl:if test="items:itemenumchron[text()]"><td><xsl:value-of select="items:itemenumchron"/></td></xsl:if>
			<xsl:if test="items:itemuri[text()]"><td><a><xsl:attribute name="href"><xsl:value-of select="items:itemuri"/></xsl:attribute><xsl:value-of select="items:itemuri"/></a></td></xsl:if>
			<xsl:if test="items:itemcopynumber[text()]"><td><xsl:value-of select="items:itemcopynumber"/></td></xsl:if>
			<td><xsl:value-of select="items:displayedstatus" /></td>
			<xsl:if test="items:itemitemnotes[text()]"><td><xsl:value-of select="items:itemitemnotes"/></td></xsl:if>
			<td><xsl:value-of select="items:itemdatedue"/></td>
			<xsl:if test="items:itemserialseq[text()]"><td><xsl:value-of select="items:itemserialseq"/></td></xsl:if>
			<xsl:if test="items:itempublisheddate[text()]"><td><xsl:value-of select="items:itempublisheddate"/></td></xsl:if>
			</tr>
		</xsl:for-each>
		</tbody>
	</table>
  </xsl:template>
</xsl:stylesheet>
