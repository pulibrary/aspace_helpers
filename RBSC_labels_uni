<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:local="local.uri" exclude-result-prefixes="xs" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:functx="http://www.functx.com" version="2.0">
    <xsl:import href="http://www.xsltfunctions.com/xsl/functx-1.0-doc-2007-01.xsl"/>
    <xsl:output indent="yes"/>
    <xsl:template match="/">
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" font-family="Arial">
            <fo:layout-master-set>
                <fo:simple-page-master master-name="folderLabels" page-height="11in" page-width="8.5in" margin-top=".6in" margin-bottom=".4in"
                    margin-left="5mm" margin-right="5mm">
                    <fo:region-body margin-top="0in" margin-bottom="0in" column-count="2" column-gap="3mm"/>
                    <fo:region-before extent="0cm"/>
                    <fo:region-after extent="0cm"/>
                </fo:simple-page-master>
                <fo:page-sequence-master master-name="repeatME">
                    <fo:repeatable-page-master-reference master-reference="folderLabels"/>
                </fo:page-sequence-master>
            </fo:layout-master-set>
            <xsl:apply-templates select="ead:ead"/>
        </fo:root>
    </xsl:template>
    <xsl:template match="ead:ead">
        <fo:page-sequence master-reference="repeatME">
            <fo:flow flow-name="xsl-region-body">
                <fo:table>
                    <fo:table-column column-width="101mm"/>
                    <fo:table-body>
                        <xsl:apply-templates select="/" mode="dsc"/>
                    </fo:table-body>
                </fo:table>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>
    <xsl:key name="containerType" match="ead:container">
        <xsl:value-of select="normalize-space(lower-case(@type))"/>
    </xsl:key>
    <xsl:function name="local:compute-box-folder-combos">
        <xsl:param name="component" as="element()"/>
        <xsl:variable name="bf-groups" as="element()*">
            <xsl:for-each-group
                select="$component//ead:container[matches(@type, 'folder|box|volume', 'i')]"
                group-starting-with="key('containerType', 'box') | key('containerType', 'itemnumber')">
                <group>
                    <xsl:copy-of select="current-group()"/>
                </group>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:for-each select="$bf-groups">
            <xsl:variable name="boxnumber" as="xs:string">
                <xsl:for-each select="ead:container[position() = 1]">
                    <xsl:value-of select="normalize-space(current())"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="boxtype">
                <xsl:for-each select="ead:container[position() = 1]">
                    <xsl:value-of
                        select="
                            concat(upper-case(substring(normalize-space(@type), 1, 1)),
                            substring(normalize-space(@type), 2))"
                    />
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="folder-elements" as="xs:string*">
                <xsl:for-each
                    select="ead:container[position() > 1]">
                    <xsl:value-of select="normalize-space(current())"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="folders" as="xs:string*">
                <xsl:for-each select="$folder-elements">
                    <xsl:choose>
                        <xsl:when test="current() castable as xs:integer">
                            <xsl:value-of select="current()"/>
                        </xsl:when>
                        <xsl:when test="count(tokenize(current(), '-')) = 2">
                            <xsl:variable name="tokens" select="tokenize(current(), '-')" as="xs:string+"/>
                            <xsl:for-each select="xs:integer($tokens[1]) to xs:integer($tokens[2])">
                                <xsl:value-of select="current()"/>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="current()"/>
                            <xsl:message terminate="no">
                                <xsl:text>Found a folder pattern I don't recognize: </xsl:text>
                                <xsl:value-of select="current()"/>
                            </xsl:message>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="label" as="xs:string*">
                <xsl:for-each
                    select="(ead:container[position() > 1])/@type">
                    <xsl:value-of
                        select="
                            concat(upper-case(substring(normalize-space(current()), 1, 1)),
                            substring(normalize-space(current()), 2))"
                    />
                </xsl:for-each>
            </xsl:variable>
            <xsl:for-each select="$folders">
                <xsl:variable name="foldernumber">
                    <xsl:value-of select="current()"/>
                </xsl:variable>
                <xsl:for-each select="$label">
                <xsl:value-of select="concat($boxtype, ' ', $boxnumber, '         ', current(), ' ', $foldernumber)"/>
            </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:template match="/" mode="dsc">
        <xsl:variable name="box-folders">
            <bfs-tmp>
                <xsl:for-each
                    select="
                        //*[(matches(local-name(), 'c0\d') or matches(local-name(), 'c')) and
                        (
                        (./ead:did/ead:container[matches(@type, 'box|volume', 'i')] and ./ead:did/ead:container[matches(@type, 'folder|volume', 'i')])
                        or
                        ./ead:did/ead:container[matches(@type, 'folder', 'i') and @parent]
                        or
                        ./ead:did/ead:container[matches(@type, 'item', 'i') and @parent]
                        )]">
                    <xsl:variable name="current-title">
                        <xsl:for-each select="current()/ead:did/ead:unittitle">
                            <fo:inline>
                                <xsl:apply-templates/>
                            </fo:inline>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:variable name="current-date">
                        <xsl:for-each select="current()/ead:did/ead:unitdate[not(@type = 'bulk')]">
                            <xsl:choose>
                                <xsl:when test="following-sibling::ead:unitdate[not(@type = 'bulk')]">
                                    <xsl:value-of select="."/>
                                    <xsl:text>, </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:for-each select="local:compute-box-folder-combos(current())">
                        <bf>
                            <line1>
                                <xsl:copy-of select="$current-title"/>
                            </line1>
                            <line3>
                                <xsl:value-of select="normalize-space($current-date)"/>
                            </line3>
                            <line2>
                                <xsl:copy-of select="current()"/>
                            </line2>
                        </bf>
                    </xsl:for-each>
                </xsl:for-each>
            </bfs-tmp>
        </xsl:variable>
        <xsl:variable name="titleproper" select="//ead:archdesc/ead:did/ead:unittitle"/>
        <xsl:for-each select="distinct-values($box-folders//bf/line2)">
            <xsl:sort data-type="number"
                select="
                    if (matches(string(), 'folder', 'i'))
                    then
                        replace(substring-before(substring-after(normalize-space(lower-case(string())), 'box'), 'folder'), '\D', '')
                    else
                        if (matches(string(), 'item', 'i'))
                        then
                            replace(substring-before(substring-after(normalize-space(lower-case(string())), 'box'), 'item'), '\D', '')
                        else
                            if (matches(string(), 'volume', 'i'))
                            then
                                replace(substring-before(substring-after(normalize-space(lower-case(string())), 'box'), 'volume'), '\D', '')
                            else
                                ()"/>
            <xsl:sort data-type="number"
                select="
                    if (matches(string(), 'folder', 'i'))
                    then
                        substring-after(normalize-space(lower-case(string())), 'folder')
                    else
                        if (matches(string(), 'item', 'i'))
                        then
                            substring-after(normalize-space(lower-case(string())), 'item')
                        else
                            if (contains(string(), 'volume'))
                            then
                                substring-after(normalize-space(lower-case(string())), 'volume')
                            else
                                ()"/>
            <fo:table-row height="2in">
                <fo:table-cell margin-right="2mm" margin-left="2mm">
                    <fo:block font-weight="bold" font-size="11pt" font-family="Arial" line-height="0.2in" text-align="left" span="none"
                        padding-left=".1in" padding-right=".1in" white-space-collapse="false" padding-bottom="5pt">
                        <xsl:value-of select="current()"/>
                    </fo:block>
                    <fo:block font-size="11pt" font-family="Arial" line-height="0.2in" text-align="left" span="none"
                        padding-left=".1in" padding-right=".1in" padding-bottom="4pt">
                        <fo:inline white-space-collapse="true">
                            <xsl:choose>
                                <xsl:when test="($box-folders//bf/line1[../line2 = current()]/node())[2]">
                                    <fo:block font-style="italic" margin-left="-2mm">
                                        <xsl:text>Multiple Items</xsl:text>
                                    </fo:block>
                                    <fo:block font-size="10.5">
                                        <xsl:for-each
                                            select="($box-folders//bf/line1[../line2 = current()]/node())[position() >= 1 and not(position() = last())]">
                                            <xsl:value-of select="current()"/>
                                            <xsl:text>, </xsl:text>
                                        </xsl:for-each>
                                        <xsl:value-of select="($box-folders//bf/line1[../line2 = current()]/node())[position() = last()]"/>
                                    </fo:block>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:copy-of select="($box-folders//bf/line1[../line2 = current()]/node())"/>
                                    <xsl:if test="$box-folders//bf/line1[../line2 = current()] = $box-folders//bf/line3[../line2 = current()]"/>
                                    <xsl:if test="$box-folders//bf/line1[../line2 = current()] != $box-folders//bf/line3[../line2 = current()]">
                                        <xsl:text>, </xsl:text>
                                        <xsl:value-of select="($box-folders//bf/line3[../line2 = current()])[1]"/>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:inline>
                    </fo:block>
                    <fo:block padding-left=".1in" padding-right=".1in">
                        <fo:block font-weight="bold" font-size="11pt" font-family="Arial" line-height="0.2in" text-align="left" padding-left=".1in"
                            padding-right=".1in" span="none" padding-bottom="4pt" padding-top="4pt">
                            <xsl:value-of select="$titleproper"/>
                        </fo:block>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="ead:emph[@render = 'italic']">
        <fo:inline font-style="italic" keep-with-next="always">
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
        </fo:inline>
    </xsl:template>
    <xsl:template match="ead:emph[@render = 'doublequote']">
        <fo:inline> "<xsl:apply-templates/>" </fo:inline>
    </xsl:template>
    <xsl:template match="ead:unitdate[not(@type = 'bulk')]">
        <xsl:choose>
            <xsl:when test="following-sibling::ead:unitdate[not(@type = 'bulk')]">
                <xsl:value-of select="."/>
                <xsl:text>, </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
</xsl:stylesheet>
