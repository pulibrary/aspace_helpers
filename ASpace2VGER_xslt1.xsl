<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:marc="http://www.loc.gov/MARC21/slim"
version="1.0">

<xsl:import href="http://www.xsltfunctions.com/xsl/functx-1.0.1-doc.xsl"/>
<xsl:output method="xml" encoding="utf-8" indent="yes"/>

<xsl:template match="node()|@*">
	<xsl:copy>
		<xsl:apply-templates select="node()|@*"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="//marc:record/marc:datafield[@tag='049']"></xsl:template>
<xsl:template match="//marc:record/marc:datafield[@tag='852']"></xsl:template>

<xsl:template match="//marc:record">
	<xsl:copy>
		<xsl:apply-templates select="marc:leader"/>
		<controlfield xmlns="http://www.loc.gov/MARC21/slim" tag="001"><xsl:apply-templates select="marc:datafield[@tag='099']/marc:subfield[@code='a']/text()"/></controlfield>
		<controlfield xmlns="http://www.loc.gov/MARC21/slim" tag="003">PULFA</controlfield>
		<xsl:apply-templates select="marc:controlfield | marc:datafield[starts-with(@tag, '01') or starts-with(@tag, '02') or starts-with(@tag, '03') or starts-with(@tag, '04')]"/>
		<datafield xmlns="http://www.loc.gov/MARC21/slim" ind1=" " ind2=" " tag="046">
			<subfield xmlns="http://www.loc.gov/MARC21/slim" code="a">i</subfield>
			<subfield xmlns="http://www.loc.gov/MARC21/slim" code="c"><xsl:value-of select="substring(marc:controlfield[@tag='008'], 8, 4)"/></subfield>
			<subfield xmlns="http://www.loc.gov/MARC21/slim" code="e"><xsl:value-of select="substring(marc:controlfield[@tag='008'], 12, 4)"/></subfield>
		</datafield>
		<xsl:apply-templates select="marc:datafield[not(starts-with(@tag, '01') or starts-with(@tag, '02') or starts-with(@tag, '03') or starts-with(@tag, '04'))]"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="//marc:datafield[@tag='040']">
	<xsl:copy>
		<xsl:apply-templates select="@*"></xsl:apply-templates>
		<subfield xmlns="http://www.loc.gov/MARC21/slim" code="a">NjP</subfield>
		<subfield xmlns="http://www.loc.gov/MARC21/slim" code="b">eng</subfield>
		<subfield xmlns="http://www.loc.gov/MARC21/slim" code="e">dacs</subfield>
		<subfield xmlns="http://www.loc.gov/MARC21/slim" code="c">NjP</subfield>
	</xsl:copy>
</xsl:template>

<xsl:template match="//marc:datafield[@tag='544']">
	<xsl:copy>
		<xsl:apply-templates select="@*"></xsl:apply-templates>
		<subfield xmlns="http://www.loc.gov/MARC21/slim" code="a"></subfield>
		<xsl:apply-templates/> 
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
