<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: MARC21slim2DC.xsl,v 1.1 2003/01/06 08:20:27 adam Exp $ -->
<xsl:stylesheet xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:items="http://www.koha.org/items" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" exclude-result-prefixes="marc items">
  <xsl:import href="UNIMARCslimUtils.xsl"/>
  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
  <xsl:template match="/">
  
  <table id="holdingst">
	    <xsl:variable name="biblionumber" select="//marc:controlfield[@tag=001]"/>
	    <thead><tr>
<!-- thead start -->
	    <!-- count items:displayedstatus : <xsl:value-of select="count(//items:displayedstatus)" /> -->
	    <!--  count items:displayedstatus where value = Available : <xsl:value-of select="count(//items:displayedstatus[text()='Available'])" /> -->
	    <!--  count syspref Version : <xsl:value-of select="count(//marc:syspref[@name='Version'])" /> -->
	    <!--  if at least on items:displayedstatus with Available value exist : <xsl:if test="count(//items:displayedstatus[text()='Available'])">TH</xsl:if>-->
	<!-- th itemnumber 
	    <th>itemnumber</th> -->
	<!-- th biblioitemnumber 
	    <th>biblioitemnumber</th> -->
	<!-- th Item type -->
	    <xsl:if test="//marc:syspref[@name='item-level_itypes']"><xsl:if test="//marc:syspref[@name='item-level_itypes'][text()!='0']">
	    <th>Item type</th>
		</xsl:if></xsl:if>
	<!-- th Location -->
		<th>Location</th>
	<!-- th Collection -->
	    <xsl:if test="count(//items:itemccode[text()])"><th>Collection</th></xsl:if>
	<!-- th Call Number  -->
	    <th>Call Number</th>
	<!-- th Vol Info -->
	    <xsl:if test="count(//items:itemenumchron[text()])"><th>Vol Info</th></xsl:if>
	<!-- th URL -->
	    <xsl:if test="count(//items:itemuri[text()])"><th>URL</th></xsl:if>
	<!-- th Copy -->
	    <xsl:if test="count(//items:itemcopynumber[text()])"><th>Copy</th></xsl:if>
	<!-- th Status -->
		<th>Status</th>
	<!-- th Notes -->
		<xsl:if test="count(//items:itemitemnotes[text()])"><th>Notes</th></xsl:if>
	<!-- th Serial number -->
	    <xsl:if test="count(//items:itemserialseq[text()])"><th>Serial number</th></xsl:if>
	<!-- th Publication date -->
	    <xsl:if test="count(//items:itempublisheddate[text()])"><th>Publication date</th></xsl:if>
	<!-- th Date Due -->
	    <th>Date Due</th>
	<!-- th barcode -->
	    <th>barcode</th>
	<!-- th price -->
		<xsl:if test="count(//items:itemprice[text()])"><th>price</th></xsl:if>
	<!-- th stack -->
		<xsl:if test="count(//items:itemstack[text()])"><th>stack</th></xsl:if>
	<!-- th notforloan 
		<xsl:if test="count(//items:itemnotforloan[text()])"><th>notforloan</th></xsl:if> --><!-- also managed with Status -->
	<!-- th damaged 
		<xsl:if test="count(//items:itemdamaged[text()])"><th>damaged</th></xsl:if> --><!-- also managed with Status -->
	<!-- th on loan 
		<xsl:if test="count(//items:itemonloan[text()])"><th>on loan</th></xsl:if> --><!-- also managed with Status -->
	<!-- th lost 
		<xsl:if test="count(//items:itemlost[text()])"><th>lost</th></xsl:if> --><!-- also managed with Status -->
	<!-- th wthdrawn 
		<xsl:if test="count(//items:itemwthdrawn[text()])"><th>wthdrawn</th></xsl:if> --><!-- also managed with Status -->
	<!-- th reserves 
		<xsl:if test="count(//items:itemreserves[text()])"><th>reserves</th></xsl:if> -->
	<!-- th holdingbranch 
		<xsl:if test="count(//items:itemholdingbranch[text()])"><th>holdingbranch</th></xsl:if> -->
	<!-- th itype 
		<xsl:if test="count(//items:itemitype[text()])"><th>itype</th></xsl:if> -->
	<!-- th cn_source 
		<xsl:if test="count(//items:itemcn_source[text()])"><th>cn_source</th></xsl:if> -->
	<!-- th cn_sort 
		<xsl:if test="count(//items:itemcn_sort[text()])"><th>cn_sort</th></xsl:if> -->
	<!-- th materials 
		<xsl:if test="count(//items:itemmaterials[text()])"><th>materials</th></xsl:if> -->
	<!-- th stocknumber 
		<xsl:if test="count(//items:itemstocknumber[text()])"><th>stocknumber</th></xsl:if> -->
	<!-- th statisticvalue 
		<xsl:if test="count(//items:itemstatisticvalue[text()])"><th>statisticvalue</th></xsl:if> -->
<!-- thead end -->
	    </tr></thead>
	    <tbody>
		<xsl:for-each select="//items:item">
			<tr>
<!-- tr start -->
	<!-- td itemnumber 
			<td><xsl:value-of select="items:itemnumber"/></td> -->
	<!-- td biblioitemnumber 
			<td><xsl:value-of select="items:biblioitemnumber"/></td> -->
	<!-- td Item type -->
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
	<!-- td Location -->
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
	<!-- td Collection -->
			<xsl:if test="count(//items:itemccode[text()])">
			<td><xsl:if test="items:itemccode[text()]"><xsl:value-of select="items:itemccode"/></xsl:if></td>
			</xsl:if>
	<!-- td Call Number  -->
			<td>
			<xsl:if test="items:itemcallnumber[text()]"><xsl:value-of select="items:itemcallnumber"></xsl:if>
			<xsl:if test="//marc:syspref[@name='OPACShelfBrowser']"><xsl:if test="//marc:syspref[@name='OPACShelfBrowser'][text()!='0']">
			 (<a><xsl:attribute name="href"><xsl:value-of select="concat('/cgi-bin/koha/opac-detail.pl?biblionumber=',$biblionumber,'&amp;shelfbrowse_itemnumber=',items:itemnumber,'#shelfbrowser')" /></xsl:attribute>Browse Shelf</a>)
			</xsl:if></xsl:if>
			</td>
	<!-- td Vol Info -->
			<xsl:if test="count(//items:itemenumchron[text()])">
			<td><xsl:if test="items:itemenumchron[text()]"><xsl:value-of select="items:itemenumchron"/></xsl:if></td>
			</xsl:if>
	<!-- td URL -->
			<xsl:if test="count(//items:itemuri[text()])">
			<td><xsl:if test="items:itemuri[text()]"><a><xsl:attribute name="href">/<xsl:value-of select="items:itemuri"/></xsl:attribute><xsl:value-of select="items:itemuri"/></a></td></xsl:if>
			</xsl:if>
	<!-- td Copy -->
			<xsl:if test="count(//items:itemcopynumber[text()])">
			<td><xsl:if test="items:itemcopynumber[text()]"><xsl:value-of select="items:itemcopynumber"/></xsl:if></td>
			</xsl:if>
	<!-- td Status -->
			<td><xsl:value-of select="items:displayedstatus" /></td>
	<!-- td Notes -->
			<xsl:if test="count(//items:itemitemnotes[text()])">
			<td><xsl:if test="items:itemitemnotes[text()]"><xsl:value-of select="items:itemitemnotes"/></xsl:if></td>
			</xsl:if>
	<!-- td Serial number -->
			<xsl:if test="count(//items:itemserialseq[text()])">
			<td><xsl:if test="items:itemserialseq[text()]"><a><xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=<xsl:value-of select="items:itemserialseq"/></xsl:attribute><xsl:value-of select="items:itemserialseq"/></a></xsl:if></td>
			</xsl:if>
	<!-- td Publication date -->
			<xsl:if test="count(//items:itempublisheddate[text()])">
			<td><xsl:if test="items:itempublisheddate[text()]"><xsl:value-of select="items:itempublisheddate"/></xsl:if></td></xsl:if>
	<!-- td Date Due -->
			<td><xsl:value-of select="items:itemdatedue"/></td>
	<!-- td barcode -->
			<td><xsl:value-of select="items:itembarcode"/></td>
	<!-- td price -->
			<xsl:if test="count(//items:itemprice[text()])">
			<td><xsl:if test="items:itemprice[text()]"><xsl:value-of select="items:itemprice"/></xsl:if></td></xsl:if>
	<!-- td stack -->
			<xsl:if test="count(//items:itemstack[text()])">
			<td><xsl:if test="items:itemstack[text()]"><xsl:value-of select="items:itemstack"/></xsl:if></td></xsl:if>
	<!-- td notforloan 
			<xsl:if test="count(//items:itemnotforloan[text()])">
			<td><xsl:if test="items:itemnotforloan[text()]"><xsl:value-of select="items:itemnotforloan"/></xsl:if></td></xsl:if> --><!-- also managed with Status -->
	<!-- td damaged 
			<xsl:if test="count(//items:itemdamaged[text()])">
			<td><xsl:if test="items:itemdamaged[text()]">damaged</xsl:if></td></xsl:if> --><!-- also managed with Status -->
	<!-- td on loan 
			<xsl:if test="count(//items:itemonloan[text()])">
			<td><xsl:if test="items:itemonloan[text()]"><xsl:value-of select="items:itemonloan"/></xsl:if></td></xsl:if> --><!-- also managed with Status -->
	<!-- td item lost 
			<xsl:if test="count(//items:itemlost[text()])">
			<td><xsl:if test="items:itemlost[text()]"><xsl:value-of select="items:itemlost"/></xsl:if></td></xsl:if> --><!-- also managed with Status -->
	<!-- td wthdrawn 
			<xsl:if test="count(//items:itemwthdrawn[text()])">
			<td><xsl:if test="items:itemwthdrawn[text()]"><xsl:value-of select="items:itemwthdrawn"/></xsl:if></td></xsl:if> --><!-- also managed with Status -->
	<!-- td reserves 
			<xsl:if test="count(//items:itemreserves[text()])">
			<td><xsl:if test="items:itemreserves[text()]"><xsl:value-of select="items:itemreserves"/></xsl:if></td></xsl:if> -->
	<!-- td holdingbranch 
			<xsl:if test="count(//items:itemholdingbranch[text()])">
			<td><xsl:if test="items:itemholdingbranch[text()]"><xsl:value-of select="items:itemholdingbranch"/></xsl:if></td></xsl:if> -->
	<!-- td itype 
			<xsl:if test="count(//items:itemitype[text()])">
			<td><xsl:if test="items:itemitype[text()]"><xsl:value-of select="items:itemitype"/></xsl:if></td></xsl:if> -->
	<!-- td cn_source 
			<xsl:if test="count(//items:itemcn_source[text()])">
			<td><xsl:if test="items:itemcn_source[text()]"><xsl:value-of select="items:itemcn_source"/></xsl:if></td></xsl:if> -->
	<!-- td cn_sort 
			<xsl:if test="count(//items:itemcn_sort[text()])">
			<td><xsl:if test="items:itemcn_sort[text()]"><xsl:value-of select="items:itemcn_sort"/></xsl:if></td></xsl:if> -->
	<!-- td materials 
			<xsl:if test="count(//items:itemmaterials[text()])">
			<td><xsl:if test="items:itemmaterials[text()]"><xsl:value-of select="items:itemmaterials"/></xsl:if></td></xsl:if> -->
	<!-- td stocknumber 
			<xsl:if test="count(//items:itemstocknumber[text()])">
			<td><xsl:if test="items:itemstocknumber[text()]"><xsl:value-of select="items:itemstocknumber"/></xsl:if></td></xsl:if> -->
	<!-- td statisticvalue 
			<xsl:if test="count(//items:itemstatisticvalue[text()])">
			<td><xsl:if test="items:itemstatisticvalue[text()]"><xsl:value-of select="items:itemstatisticvalue"/></xsl:if></td></xsl:if> -->
<!-- tr end -->
			</tr>
		</xsl:for-each>
		</tbody>
	</table>
  </xsl:template>
</xsl:stylesheet>
