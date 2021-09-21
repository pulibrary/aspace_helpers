<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="2.0" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:njp="http://diglib.princeton.edu" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.w3.org/2005/xpath-functions"
    xmlns:functx="http://www.functx.com">
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
	<xsl:import href="http://www.xsltfunctions.com/xsl/functx-1.0.1-doc.xsl"/>
	
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
            <fo:layout-master-set>
                <fo:simple-page-master master-name="boxLabels" page-height="278mm"
                    page-width="216mm" margin-top="10mm" margin-bottom="10mm" margin-left="7mm"
                    margin-right="7mm">
                    <fo:region-body margin-top="0in" margin-bottom="0in" column-count="2"
                        column-gap="10mm"/>
                    <fo:region-before extent="0cm"/>
                    <fo:region-after extent="0cm"/>
                </fo:simple-page-master>
                
                <fo:page-sequence-master master-name="repeatME">
                    <fo:repeatable-page-master-reference master-reference="boxLabels"/>
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
                    	<xsl:apply-templates select="//ead:container[matches(@type, 'box|volume', 'i')]"/>
                    </fo:table-body>
                </fo:table>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>
    
    <xsl:template match="ead:container[matches(@type, 'box|volume', 'i')]">
        
    	<xsl:for-each select=".[not(.=preceding::ead:container[matches(@type, 'box|volume', 'i')])]">
			<xsl:apply-templates mode="single" select="."/>
        </xsl:for-each>
    </xsl:template>
    
	<xsl:template mode="single" match="ead:container[matches(@type, 'box|volume', 'i')]">
        <fo:table-row height="2in" padding-left=".2in" padding-right=".2in">
            <fo:table-cell>
                <fo:block padding-bottom=".2in" padding-top=".2in" padding-left="2mm"
                    padding-right="2mm" margin-top="5mm">
                    <fo:block font-weight="bold" font-size="16pt" font-family="Arial"
                    	text-align="center" span="none" line-height="0.3in">
                        <xsl:value-of select="//ead:archdesc/ead:did/ead:unittitle"/>
                    </fo:block>
                    <fo:block font-weight="bold" font-family="Arial" font-size="16pt"
                        line-height="0.3in" span="none" text-align="center" padding-before="6pt">
                    	<xsl:value-of select="//ead:eadid"/>
                    </fo:block>
                	<fo:block font-weight="bold" font-family="Arial" font-size="16pt"
                		line-height="0.3in" span="none" text-align="right" padding-before="30pt">
                		<xsl:value-of
                			select="concat(upper-case(substring(normalize-space(@type),1,1)),
                			substring(normalize-space(@type), 2))"/>
                		<xsl:text> </xsl:text>
                		<xsl:value-of select="."/>
                		<xsl:text> </xsl:text>
                	</fo:block>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    
</xsl:stylesheet>
