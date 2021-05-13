<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:ead="urn:isbn:1-931666-22-9"
	xmlns:njp="http://diglib.princeton.edu" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/2005/xpath-functions" xmlns:functx="http://www.functx.com">
	<xsl:output method="xml" encoding="utf-8" indent="yes"/>
	<xsl:import href="http://www.xsltfunctions.com/xsl/functx-1.0.1-doc.xsl"/>
	<xsl:strip-space elements="*"/>
	<xsl:template match="/">
		<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
			<fo:layout-master-set>
				<fo:simple-page-master master-name="callnoLabels" page-height="278mm"
					page-width="216mm" margin-top="10mm" margin-bottom="10mm" margin-left="7mm"
					margin-right="7mm">
					<fo:region-body margin-top="0in" margin-bottom="0in" column-count="2"
						column-gap="10mm"/>
					<fo:region-before extent="0cm"/>
					<fo:region-after extent="0cm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="repeatME">
					<fo:repeatable-page-master-reference master-reference="callnoLabels"/>
				</fo:page-sequence-master>
			</fo:layout-master-set>
			<xsl:apply-templates select="ead:ead"/>
		</fo:root>
	</xsl:template>
	<xsl:template match="ead:ead">
		<fo:page-sequence master-reference="repeatME">
			<fo:flow flow-name="xsl-region-body">
				<fo:table>
					<fo:table-column column-width="96mm"/>
					<fo:table-body font-family="Arial">
						<xsl:apply-templates select="//ead:container[@label]"/>
					</fo:table-body>
				</fo:table>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template>
	<xsl:template match="ead:container[@label]">
		<fo:table-row height="2in" padding-bottom=".2in" padding-top=".2in" padding-left=".2in"
			padding-right=".2in">
			<fo:table-cell>
				<fo:block padding-bottom=".2in" padding-top=".2in" padding-left="2mm"
					padding-right="2mm" margin-top="9mm">
					<fo:block font-weight="bold" font-family="Arial" font-size="80pt"
						line-height="0.3in" text-align="center" padding-before="10pt">
						<xsl:value-of select="//ead:eadid"/>
					</fo:block>
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template>
</xsl:stylesheet>
