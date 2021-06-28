<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:njp="http://diglib.princeton.edu"
	xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:srw="http://www.loc.gov/zing/srw/" xmlns:xcql="http://www.loc.gov/zing/cql/xcql/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:functx="http://www.functx.com">
	<xsl:output method="xml" encoding="utf-8" indent="yes"/>
	<xsl:strip-space elements="*"/>
	<xsl:function name="functx:capitalize-first" as="xs:string?"
		xmlns:functx="http://www.functx.com">
		<xsl:param name="arg" as="xs:string?"/>
		<xsl:sequence
			select="
				concat(upper-case(substring($arg, 1, 1)),
				substring($arg, 2))
				"/>
	</xsl:function>
	<xsl:key name="arrangementScope" match="ead:ead/ead:archdesc/ead:dsc/*[@level = 'series']"
		use="@id"/>
	<xsl:key name="arrangementScopeSub"
		match="ead:ead/ead:archdesc/ead:dsc/*/*[@level = 'subseries']" use="@id"/>
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- Don't know if this is needed any more. -->
	<xsl:template match="srw:searchRetrieve">
		<xsl:apply-templates
			select="srw:searchRetrieve/srw:records/srw:record/srw:recordData/ead:ead"/>
	</xsl:template>
	<xsl:template match="text()">
		<xsl:analyze-string select="." regex="\P{{IsBasicLatin}}">
			<xsl:matching-substring>
				<fo:inline font-family="Arialuni">
					<xsl:value-of select="."/>
				</fo:inline>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	<xsl:template match="ead:ead">
		<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" font-family="Arialuni"
			font-size="11pt">
			<fo:layout-master-set>
				<fo:simple-page-master master-name="cover" page-width="8.5in" page-height="11in"
					margin-top="0.2in" margin-bottom="0.5in" margin-left="0.5in"
					margin-right="0.5in">
					<fo:region-body margin-top="0.2in" margin-bottom="0.2in"/>
					<fo:region-before extent="0.2in"/>
					<fo:region-after extent="0.2in"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="toc" page-width="8.5in" page-height="11in"
					margin-top="0.2in" margin-bottom="0.5in" margin-left="0.5in"
					margin-right="0.5in">
					<fo:region-body margin-top="0.3in" margin-bottom="0.3in"/>
					<fo:region-before extent="0.2in"/>
					<fo:region-after extent="0.2in"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="content" page-width="8.5in" page-height="11in"
					margin-top="0.2in" margin-bottom="0.5in" margin-left="0.5in"
					margin-right="0.5in">
					<fo:region-body margin-top="0.3in" margin-bottom="0.3in"/>
					<fo:region-before extent="0.2in"/>
					<fo:region-after extent="0.2in"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="list" page-width="8.5in" page-height="11in"
					margin-top="0.2in" margin-bottom="0.5in" margin-left="0.5in"
					margin-right="0.5in">
					<fo:region-body margin-top="0.3in" margin-bottom="0.3in"/>
					<fo:region-before extent="0.2in"/>
					<fo:region-after extent="0.2in"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="container" page-width="8.5in" page-height="11in"
					margin-top="0.2in" margin-bottom="0.5in" margin-left="0.5in"
					margin-right="0.5in">
					<fo:region-body margin-top="0.5in" margin-bottom="0.3in"/>
					<fo:region-before extent="2.5in"/>
					<fo:region-after extent="0.2in"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="cover-page">
					<fo:single-page-master-reference master-reference="cover"/>
				</fo:page-sequence-master>
				<fo:page-sequence-master master-name="table-of-contents">
					<fo:single-page-master-reference master-reference="toc"/>
				</fo:page-sequence-master>
				<fo:page-sequence-master master-name="contents">
					<fo:repeatable-page-master-reference master-reference="content"/>
					<fo:repeatable-page-master-reference master-reference="container"/>
				</fo:page-sequence-master>
			</fo:layout-master-set>
			<xsl:apply-templates select="ead:eadheader"/>
			<xsl:call-template name="toc"/>
			<xsl:apply-templates select="ead:archdesc"/>
			<xsl:apply-templates select="ead:archdesc/ead:dsc"/>
		</fo:root>
	</xsl:template>
	<xsl:template name="cover" match="ead:eadheader">
		<fo:page-sequence master-reference="cover-page">
			<fo:flow flow-name="xsl-region-body">
				<fo:block space-before="0.5in" text-align="center" background-color="black"
					color="white" font-size="30pt"> Princeton University Library <fo:block
						text-align="center" background-color="orange" font-size="18pt" color="black">
						<fo:inline text-transform="uppercase">Department of Rare Books and Special
							Collections</fo:inline>
					</fo:block>
					<fo:block line-height="16pt" text-align="center" background-color="white"
						font-size="10pt" color="black">
						<xsl:text> * </xsl:text>
						<xsl:for-each
							select="ead:filedesc/ead:publicationstmt/ead:address/ead:addressline">
							<fo:inline>
								<xsl:value-of select="(.)"/>
							</fo:inline>
							<xsl:text> * </xsl:text>
						</xsl:for-each>
					</fo:block>
				</fo:block>
				<fo:block space-before="0.5in" font-size="18pt" text-align="center"
					font-weight="bold" line-height="24pt" font-family="Arialuni">
					<!--rh edit 5/12/14 -->
					<xsl:apply-templates select="ead:filedesc/ead:titlestmt/ead:titleproper"/>
				</fo:block>
				<!--ds edit 3.12.2007 -->
				<fo:block space-before="0.5in" font-size="10pt" text-align="center"
					line-height="14pt">
					<xsl:value-of select="ead:filedesc/ead:titlestmt/ead:sponsor"/>
				</fo:block>
				<xsl:apply-templates select="//ead:archdesc/ead:did" mode="descSummary"/>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template>
	<xsl:template name="toc">
		<fo:page-sequence master-reference="table-of-contents">
			<fo:static-content flow-name="xsl-region-before">
				<fo:block color="gray" font-size="8pt" text-align="center">
					<!--rh edit 5/12/14 -->
					<xsl:apply-templates
						select="//ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper"/>
				</fo:block>
			</fo:static-content>
			<!-- Table of Contents -->
			<fo:flow flow-name="xsl-region-body">
				<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
					text-align="center" background-color="#eee" color="black" padding-after=".10in"
					padding-before=".10in" border-style="solid" border-color="#666"> Table of
					Contents </fo:block>
				<fo:block line-height="2">
					<xsl:for-each select="ead:archdesc/child::ead:*">
						<xsl:choose>
							<xsl:when test="self::ead:did">
								<fo:block text-align-last="justify">
									<fo:basic-link internal-destination="{generate-id(.)}"
										text-decoration="underline" color="blue">
										<!--<xsl:value-of select="child::ead:head"/>-->
										<xsl:text>Summary Information</xsl:text>
									</fo:basic-link>
									<xsl:text> 
		    </xsl:text>
									<fo:leader leader-pattern="dots"/>
									<fo:page-number-citation ref-id="{generate-id(.)}"/>
								</fo:block>
							</xsl:when>
							<xsl:when
								test="
									self::ead:scopecontent | self::ead:arrangement | self::ead:accessrestrict | self::ead:userestrict | self::ead:acqinfo | self::ead:processinfo
									| self::ead:relatedmaterial | self::ead:appraisal | self::ead:bioghist | self::ead:controlaccess | self::ead:altformavail | self::ead:phystech
									| self::ead:otherfindaid | self::ead:accruals | self::ead:prefercite | self::ead:bibliography | self::ead:originalsloc | self::ead:custodhist">
								<xsl:for-each select=".">
									<fo:block text-align-last="justify">
										<fo:basic-link internal-destination="{generate-id(.)}"
											text-decoration="underline" color="blue">
											<xsl:value-of select="ead:head"/>
										</fo:basic-link>
										<fo:leader leader-pattern="dots"/>
										<fo:page-number-citation ref-id="{generate-id(.)}"/>
									</fo:block>
								</xsl:for-each>
							</xsl:when>
							<xsl:when test="self::ead:dsc">
								<fo:block text-align-last="justify">
									<fo:basic-link internal-destination="{generate-id(.)}"
										text-decoration="underline" color="blue">
										<xsl:text>Contents List</xsl:text>
									</fo:basic-link>
									<fo:leader leader-pattern="dots"/>
									<fo:page-number-citation ref-id="{generate-id(.)}"/>
								</fo:block>
							</xsl:when>
						</xsl:choose>
						<xsl:for-each select="./(child::ead:c[@level = 'series'])">
							<xsl:if
								test="ead:did/ead:unittitle[string-length(normalize-space(.)) &gt; 1]">
								<fo:block text-align-last="justify" margin-left=".25in">
									<fo:basic-link internal-destination="{generate-id(.)}"
										text-decoration="underline" color="blue">
										<!-- ds edit for formatting within TOC <xsl:value-of select="ead:did/ead:unittitle">
		    </xsl:value-of> -->
										<!-- RH edit to display de-nested unitdate -->
										<xsl:choose>
											<xsl:when test="ead:did/ead:unitdate">
												<xsl:for-each select="ead:did">
												<xsl:choose>
												<xsl:when test="ead:unittitle = ead:unitdate">
												<xsl:apply-templates select="ead:unitdate[1]"/>
												<xsl:if test="ead:unitdate[position() > 1]">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates
												select="ead:unitdate[position() > 1]"/>
												</xsl:if>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="ead:unittitle">
												<xsl:apply-templates select="ead:unittitle"/>
												<xsl:for-each select="ead:unitdate">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates select="current()"/>
												</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
												<xsl:apply-templates select="ead:unitdate[1]"/>
												<xsl:if test="ead:unitdate[position() > 1]">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates
												select="ead:unitdate[position() > 1]"/>
												</xsl:if>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:apply-templates select="ead:did/ead:unittitle"
												/>
											</xsl:otherwise>
										</xsl:choose>
									</fo:basic-link>
									<xsl:text> 
		  </xsl:text>
									<fo:leader leader-pattern="dots"/>
									<xsl:text> 
		  </xsl:text>
									<fo:page-number-citation ref-id="{generate-id(.)}"/>
								</fo:block>
							</xsl:if>
							<xsl:for-each select=".//child::ead:*[@level = 'subseries']">
								<xsl:if
									test="ead:did/ead:unittitle[string-length(normalize-space(.)) &gt; 1]">
									<fo:block text-align-last="justify" margin-left=".5in">
										<fo:basic-link internal-destination="{generate-id(.)}"
											text-decoration="underline" color="blue">
											<!-- ds edit for  formatting within TOC <xsl:value-of select="ead:did/ead:unittitle">
		      </xsl:value-of> -->
											<!-- RH edit -->
											<xsl:choose>
												<xsl:when test="ead:did/ead:unitdate">
												<xsl:for-each select="ead:did">
												<xsl:choose>
												<xsl:when test="ead:unittitle = ead:unitdate">
												<xsl:apply-templates select="ead:unitdate[1]"/>
												<xsl:if test="ead:unitdate[position() > 1]">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates
												select="ead:unitdate[position() > 1]"/>
												</xsl:if>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="ead:unittitle">
												<xsl:apply-templates select="ead:unittitle"/>
												<xsl:for-each select="ead:unitdate">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates select="current()"/>
												</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
												<xsl:apply-templates select="ead:unitdate[1]"/>
												<xsl:if test="ead:unitdate[position() > 1]">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates
												select="ead:unitdate[position() > 1]"/>
												</xsl:if>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
												<xsl:apply-templates
												select="ead:did/ead:unittitle"/>
												</xsl:otherwise>
											</xsl:choose>
										</fo:basic-link>
										<xsl:text> 
		    </xsl:text>
										<fo:leader leader-pattern="dots"/>
										<xsl:text> 
		    </xsl:text>
										<fo:page-number-citation ref-id="{generate-id(.)}"/>
									</fo:block>
								</xsl:if>
							</xsl:for-each>
						</xsl:for-each>
					</xsl:for-each>
				</fo:block>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template>
	<xsl:template match="ead:archdesc" name="contents">
		<fo:page-sequence master-reference="content">
			<fo:static-content flow-name="xsl-region-before">
				<fo:block color="gray" font-size="8pt" text-align="center">
					<!--rh edit 5/12/14 -->
					<xsl:apply-templates
						select="../ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper"/>
				</fo:block>
			</fo:static-content>
			<fo:static-content flow-name="xsl-region-after">
				<fo:block text-align="center" color="gray" font-size="8pt">
					<xsl:text>Page </xsl:text>
					<fo:page-number/>
				</fo:block>
			</fo:static-content>
			<fo:flow flow-name="xsl-region-body">
				<fo:block font-size="12pt">
					<xsl:call-template name="collection_notes"/>
					<!--<xsl:apply-templates select="ead:head"/>-->
					<!--<xsl:apply-templates select="ead:bioghist"/>
					<xsl:apply-templates select="ead:scopecontent"/>
					<xsl:apply-templates select="ead:arrangement"/>
					<xsl:apply-templates select="ead:accessrestrict"/>
					<xsl:apply-templates select="ead:userestrict"/>
					<xsl:apply-templates select="ead:acqinfo"/>
					<xsl:apply-templates select="ead:appraisal"/>
					<xsl:apply-templates select="ead:accruals"/>
					<xsl:apply-templates select="ead:processinfo"/>
					<xsl:apply-templates select="ead:relatedmaterial"/>
					<xsl:apply-templates select="ead:otherfindaid"/>
					<xsl:apply-templates select="ead:altformavail"/>
					<xsl:apply-templates select="ead:phystech"/>
					<xsl:apply-templates select="ead:prefercite"/>
					<xsl:apply-templates select="ead:bibliography"/>
					<xsl:apply-templates select="ead:controlaccess"/>-->
					<!--<xsl:apply-templates select="dsc[@type='combined']"/>-->
					<!--<xsl:apply-templates select="ead:index"/>-->
				</fo:block>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template>
	<xsl:template match="ead:dsc" name="container-list">
		<fo:page-sequence master-reference="container">
			<fo:static-content flow-name="xsl-region-before">
				<fo:block color="gray" font-size="8pt" text-align="center">
					<!--rh edit 5/12/14 -->
					<xsl:apply-templates
						select="//ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper"/>
				</fo:block>
				<fo:retrieve-marker retrieve-class-name="series-title"/>
			</fo:static-content>
			<fo:static-content flow-name="xsl-region-after">
				<fo:block text-align="center" color="gray" font-size="8pt">
					<xsl:text>Page </xsl:text>
					<fo:page-number/>
				</fo:block>
			</fo:static-content>
			<fo:flow flow-name="xsl-region-body">
				<fo:block font-size="12pt">
					<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
						text-align="center" background-color="#eee" color="black"
						padding-after=".10in" padding-before=".10in" border-style="solid"
						border-color="#666">
						<xsl:text>Contents List</xsl:text>
					</fo:block>
					<xsl:apply-templates select="ead:*[not(self::ead:head)]"/>
				</fo:block>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template>
	<xsl:template match="//ead:archdesc/ead:did" mode="descSummary">
		<fo:block id="{generate-id(.)}">
			<!--<xsl:apply-templates select="ead:head"/>-->
			<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
				text-align="center" background-color="#eee" color="black" padding-after=".10in"
				padding-before=".10in" border-style="solid" border-color="#666">
				<xsl:text>Summary Information</xsl:text>
			</fo:block>
			<fo:table table-layout="fixed" space-before="0.1in" font-size="12pt" line-height="18pt">
				<fo:table-column column-width="2.5in" column-number="1"/>
				<fo:table-column column-width="4in" column-number="2"/>
				<fo:table-body>
					<fo:table-row>
						<xsl:apply-templates mode="reference-code" select="ead:unitid[1]"/>
					</fo:table-row>
					<fo:table-row>
						<xsl:apply-templates mode="location" select="ead:repository"/>
					</fo:table-row>
					<!--       <fo:table-row>
	       <xsl:apply-templates mode="unitTitle" select="ead:unittitle"/>
	       </fo:table-row>
               -->
					<!-- RH: added dimensions, physfacet (to accommodate LAE) -->
					<xsl:for-each select="ead:physdesc">
						<fo:table-row>
							<fo:table-cell column-number="1">
								<fo:block font-weight="bold">
									<!-- <xsl:apply-templates select="@label"/>-->
									<xsl:text>Size: </xsl:text>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell column-number="2">
								<fo:block>
									<xsl:for-each select="text()">
										<fo:block>
											<xsl:apply-templates mode="physDesc" select="."/>
											<xsl:text> </xsl:text>
										</fo:block>
									</xsl:for-each>
									<xsl:for-each select="ead:extent[not(@type)]">
										<fo:block>
											<xsl:apply-templates mode="physDesc" select="."/>
											<xsl:text> </xsl:text>
										</fo:block>
									</xsl:for-each>
									<xsl:for-each select="ead:dimensions">
										<fo:block>
											<xsl:apply-templates mode="physDesc" select="."/>
											<xsl:text> </xsl:text>
										</fo:block>
									</xsl:for-each>
									<xsl:for-each select="ead:physfacet">
										<fo:block>
											<xsl:apply-templates mode="physDesc" select="."/>
											<xsl:text> </xsl:text>
										</fo:block>
									</xsl:for-each>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
					<xsl:for-each select="ead:langmaterial">
						<fo:table-row>
							<fo:table-cell column-number="1">
								<fo:block font-weight="bold">
									<!--<xsl:apply-templates select="@label"/>-->
									<xsl:text>Language(s) of Material: </xsl:text>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell column-number="2">
								<xsl:choose>
									<xsl:when test="ead:language">
										<xsl:for-each select="ead:language">
											<fo:block>
												<xsl:choose>
												<xsl:when test="@langcode = 'aar'">
												<xsl:text>Afar</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'aa'">
												<xsl:text>Afar</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'abk'">
												<xsl:text>Abkhazian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ab'">
												<xsl:text>Abkhazian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ace'">
												<xsl:text>Achinese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ach'">
												<xsl:text>Acoli</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ada'">
												<xsl:text>Adangme</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ady'">
												<xsl:text>Adyghe or Adygei</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'afa'">
												<xsl:text>Afro-Asiatic (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'afh'">
												<xsl:text>Afrihili</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'afr'">
												<xsl:text>Afrikaans</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'af'">
												<xsl:text>Afrikaans</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ain'">
												<xsl:text>Ainu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'aka'">
												<xsl:text>Akan</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ak'">
												<xsl:text>Akan</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'akk'">
												<xsl:text>Akkadian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'alb'">
												<xsl:text>Albanian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sqi'">
												<xsl:text>Albanian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sq'">
												<xsl:text>Albanian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ale'">
												<xsl:text>Aleut</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'alg'">
												<xsl:text>Algonquian languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'alt'">
												<xsl:text>Southern Altai</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'amh'">
												<xsl:text>Amharic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'am'">
												<xsl:text>Amharic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ang'">
												<xsl:text>English, Old (ca.450-1100)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'anp'">
												<xsl:text>Angika</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'apa'">
												<xsl:text>Apache languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ara'">
												<xsl:text>Arabic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ar'">
												<xsl:text>Arabic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'arc'">
												<xsl:text>Aramaic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'arg'">
												<xsl:text>Aragonese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'an'">
												<xsl:text>Aragonese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'arm'">
												<xsl:text>Armenian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hye'">
												<xsl:text>Armenian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hy'">
												<xsl:text>Armenian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'arn'">
												<xsl:text>Mapudungun or Mapuche</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'arp'">
												<xsl:text>Arapaho</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'art'">
												<xsl:text>Artificial (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'arw'">
												<xsl:text>Arawak</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'asm'">
												<xsl:text>Assamese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'as'">
												<xsl:text>Assamese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ast'">
												<xsl:text>Asturian or Bable</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ath'">
												<xsl:text>Athapascan languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'aus'">
												<xsl:text>Australian languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ava'">
												<xsl:text>Avaric</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'av'">
												<xsl:text>Avaric</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ave'">
												<xsl:text>Avestan</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ae'">
												<xsl:text>Avestan</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'awa'">
												<xsl:text>Awadhi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'aym'">
												<xsl:text>Aymara</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ay'">
												<xsl:text>Aymara</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'aze'">
												<xsl:text>Azerbaijani</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'az'">
												<xsl:text>Azerbaijani</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bad'">
												<xsl:text>Banda languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bai'">
												<xsl:text>Bamileke languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bak'">
												<xsl:text>Bashkir</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ba'">
												<xsl:text>Bashkir</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bal'">
												<xsl:text>Baluchi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bam'">
												<xsl:text>Bambara</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bm'">
												<xsl:text>Bambara</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ban'">
												<xsl:text>Balinese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'baq'">
												<xsl:text>Basque</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'eus'">
												<xsl:text>Basque</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'eu'">
												<xsl:text>Basque</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bas'">
												<xsl:text>Basa</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bat'">
												<xsl:text>Baltic (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bej'">
												<xsl:text>Beja</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bel'">
												<xsl:text>Belarusian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'be'">
												<xsl:text>Belarusian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bem'">
												<xsl:text>Bemba</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ben'">
												<xsl:text>Bengali</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bn'">
												<xsl:text>Bengali</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ber'">
												<xsl:text>Berber (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bho'">
												<xsl:text>Bhojpuri</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bih'">
												<xsl:text>Bihari</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bh'">
												<xsl:text>Bihari</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bik'">
												<xsl:text>Bikol</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bin'">
												<xsl:text>Bini or Edo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bis'">
												<xsl:text>Bislama</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bi'">
												<xsl:text>Bislama</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bla'">
												<xsl:text>Siksika</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bnt'">
												<xsl:text>Bantu (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bos'">
												<xsl:text>Bosnian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bs'">
												<xsl:text>Bosnian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bra'">
												<xsl:text>Braj</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bre'">
												<xsl:text>Breton</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'br'">
												<xsl:text>Breton</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'btk'">
												<xsl:text>Batak languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bua'">
												<xsl:text>Buriat</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bug'">
												<xsl:text>Buginese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bul'">
												<xsl:text>Bulgarian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bg'">
												<xsl:text>Bulgarian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bur'">
												<xsl:text>Burmese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mya'">
												<xsl:text>Burmese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'my'">
												<xsl:text>Burmese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'byn'">
												<xsl:text>Blin or Bilin</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cad'">
												<xsl:text>Caddo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cai'">
												<xsl:text>Central American Indian (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'car'">
												<xsl:text>Galibi Carib</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cat'">
												<xsl:text>Catalan or Valencian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ca'">
												<xsl:text>Catalan or Valencian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cau'">
												<xsl:text>Caucasian (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ceb'">
												<xsl:text>Cebuano</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cel'">
												<xsl:text>Celtic (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cha'">
												<xsl:text>Chamorro</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ch'">
												<xsl:text>Chamorro</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'chb'">
												<xsl:text>Chibcha</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'che'">
												<xsl:text>Chechen</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ce'">
												<xsl:text>Chechen</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'chg'">
												<xsl:text>Chagatai</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'chi'">
												<xsl:text>Chinese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'zho'">
												<xsl:text>Chinese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'zh'">
												<xsl:text>Chinese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'chk'">
												<xsl:text>Chuukese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'chm'">
												<xsl:text>Mari</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'chn'">
												<xsl:text>Chinook jargon</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cho'">
												<xsl:text>Choctaw</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'chp'">
												<xsl:text>Chipewyan</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'chr'">
												<xsl:text>Cherokee</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'chu'">
												<xsl:text>Church Slavic or Old Slavonic or Church Slavonic or Old Bulgarian or Old Church Slavonic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cu'">
												<xsl:text>Church Slavic or Old Slavonic or Church Slavonic or Old Bulgarian or Old Church Slavonic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'chv'">
												<xsl:text>Chuvash</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cv'">
												<xsl:text>Chuvash</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'chy'">
												<xsl:text>Cheyenne</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cmc'">
												<xsl:text>Chamic languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cop'">
												<xsl:text>Coptic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cor'">
												<xsl:text>Cornish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kw'">
												<xsl:text>Cornish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cos'">
												<xsl:text>Corsican</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'co'">
												<xsl:text>Corsican</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cpe'">
												<xsl:text>Creoles and pidgins, English based (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cpf'">
												<xsl:text>Creoles and pidgins, French-based (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cpp'">
												<xsl:text>Creoles and pidgins, Portuguese-based (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cre'">
												<xsl:text>Cree</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cr'">
												<xsl:text>Cree</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'crh'">
												<xsl:text>Crimean Tatar or Crimean Turkish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'crp'">
												<xsl:text>Creoles and pidgins (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'csb'">
												<xsl:text>Kashubian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cus'">
												<xsl:text>Cushitic (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cze'">
												<xsl:text>Czech</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ces'">
												<xsl:text>Czech</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cs'">
												<xsl:text>Czech</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'dak'">
												<xsl:text>Dakota</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'dan'">
												<xsl:text>Danish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'da'">
												<xsl:text>Danish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'dar'">
												<xsl:text>Dargwa</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'day'">
												<xsl:text>Land Dayak languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'del'">
												<xsl:text>Delaware</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'den'">
												<xsl:text>Slave (Athapascan)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'dgr'">
												<xsl:text>Dogrib</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'din'">
												<xsl:text>Dinka</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'div'">
												<xsl:text>Divehi or Dhivehi or Maldivian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'dv'">
												<xsl:text>Divehi or Dhivehi or Maldivian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'doi'">
												<xsl:text>Dogri</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'dra'">
												<xsl:text>Dravidian (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'dsb'">
												<xsl:text>Lower Sorbian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'dua'">
												<xsl:text>Duala</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'dum'">
												<xsl:text>Dutch, Middle (ca.1050-1350)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'dut'">
												<xsl:text>Dutch or Flemish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nld'">
												<xsl:text>Dutch or Flemish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nl'">
												<xsl:text>Dutch or Flemish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'dyu'">
												<xsl:text>Dyula</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'dzo'">
												<xsl:text>Dzongkha</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'dz'">
												<xsl:text>Dzongkha</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'efi'">
												<xsl:text>Efik</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'egy'">
												<xsl:text>Egyptian (Ancient)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'eka'">
												<xsl:text>Ekajuk</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'elx'">
												<xsl:text>Elamite</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'eng'">
												<xsl:text>English</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'en'">
												<xsl:text>English</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'enm'">
												<xsl:text>English, Middle (1100-1500)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'epo'">
												<xsl:text>Esperanto</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'eo'">
												<xsl:text>Esperanto</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'est'">
												<xsl:text>Estonian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'et'">
												<xsl:text>Estonian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ewe'">
												<xsl:text>Ewe</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ee'">
												<xsl:text>Ewe</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ewo'">
												<xsl:text>Ewondo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fan'">
												<xsl:text>Fang</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fao'">
												<xsl:text>Faroese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fo'">
												<xsl:text>Faroese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fat'">
												<xsl:text>Fanti</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fij'">
												<xsl:text>Fijian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fj'">
												<xsl:text>Fijian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fil'">
												<xsl:text>Filipino or Pilipino</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fin'">
												<xsl:text>Finnish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fi'">
												<xsl:text>Finnish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fiu'">
												<xsl:text>Finno-Ugrian (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fon'">
												<xsl:text>Fon</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fre'">
												<xsl:text>French</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fra'">
												<xsl:text>French</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fr'">
												<xsl:text>French</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'frm'">
												<xsl:text>French, Middle (ca.1400-1600)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fro'">
												<xsl:text>French, Old (842-ca.1400)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'frr'">
												<xsl:text>Northern Frisian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'frs'">
												<xsl:text>Eastern Frisian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fry'">
												<xsl:text>Western Frisian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fy'">
												<xsl:text>Western Frisian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ful'">
												<xsl:text>Fulah</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ff'">
												<xsl:text>Fulah</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fur'">
												<xsl:text>Friulian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gaa'">
												<xsl:text>Ga</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gay'">
												<xsl:text>Gayo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gba'">
												<xsl:text>Gbaya</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gem'">
												<xsl:text>Germanic (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'geo'">
												<xsl:text>Georgian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kat'">
												<xsl:text>Georgian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ka'">
												<xsl:text>Georgian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ger'">
												<xsl:text>German</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'deu'">
												<xsl:text>German</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'de'">
												<xsl:text>German</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gez'">
												<xsl:text>Geez</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gil'">
												<xsl:text>Gilbertese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gla'">
												<xsl:text>Gaelic or Scottish Gaelic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gd'">
												<xsl:text>Gaelic or Scottish Gaelic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gle'">
												<xsl:text>Irish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ga'">
												<xsl:text>Irish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'glg'">
												<xsl:text>Galician</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gl'">
												<xsl:text>Galician</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'glv'">
												<xsl:text>Manx</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gv'">
												<xsl:text>Manx</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gmh'">
												<xsl:text>German, Middle High (ca.1050-1500)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'goh'">
												<xsl:text>German, Old High (ca.750-1050)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gon'">
												<xsl:text>Gondi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gor'">
												<xsl:text>Gorontalo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'got'">
												<xsl:text>Gothic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'grb'">
												<xsl:text>Grebo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'grc'">
												<xsl:text>Greek, Ancient (to 1453)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gre'">
												<xsl:text>Greek, Modern (1453-)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ell'">
												<xsl:text>Greek, Modern (1453-)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'el'">
												<xsl:text>Greek, Modern (1453-)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'grn'">
												<xsl:text>Guarani</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gn'">
												<xsl:text>Guarani</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gsw'">
												<xsl:text>Swiss German or Alemannic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'guj'">
												<xsl:text>Gujarati</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gu'">
												<xsl:text>Gujarati</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'gwi'">
												<xsl:text>Gwich'in</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hai'">
												<xsl:text>Haida</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hat'">
												<xsl:text>Haitian or Haitian Creole</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ht'">
												<xsl:text>Haitian or Haitian Creole</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hau'">
												<xsl:text>Hausa</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ha'">
												<xsl:text>Hausa</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'haw'">
												<xsl:text>Hawaiian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'heb'">
												<xsl:text>Hebrew</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'he'">
												<xsl:text>Hebrew</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'her'">
												<xsl:text>Herero</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hz'">
												<xsl:text>Herero</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hil'">
												<xsl:text>Hiligaynon</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'him'">
												<xsl:text>Himachali</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hin'">
												<xsl:text>Hindi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hi'">
												<xsl:text>Hindi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hit'">
												<xsl:text>Hittite</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hmn'">
												<xsl:text>Hmong</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hmo'">
												<xsl:text>Hiri Motu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ho'">
												<xsl:text>Hiri Motu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hsb'">
												<xsl:text>Upper Sorbian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hun'">
												<xsl:text>Hungarian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hu'">
												<xsl:text>Hungarian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hup'">
												<xsl:text>Hupa</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'iba'">
												<xsl:text>Iban</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ibo'">
												<xsl:text>Igbo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ig'">
												<xsl:text>Igbo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ice'">
												<xsl:text>Icelandic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'isl'">
												<xsl:text>Icelandic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'is'">
												<xsl:text>Icelandic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ido'">
												<xsl:text>Ido</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'io'">
												<xsl:text>Ido</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'iii'">
												<xsl:text>Sichuan Yi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ii'">
												<xsl:text>Sichuan Yi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ijo'">
												<xsl:text>Ijo languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'iku'">
												<xsl:text>Inuktitut</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'iu'">
												<xsl:text>Inuktitut</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ile'">
												<xsl:text>Interlingue</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ie'">
												<xsl:text>Interlingue</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ilo'">
												<xsl:text>Iloko</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ina'">
												<xsl:text>Interlingua (International Auxiliary Language Association)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ia'">
												<xsl:text>Interlingua (International Auxiliary Language Association)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'inc'">
												<xsl:text>Indic (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ind'">
												<xsl:text>Indonesian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'id'">
												<xsl:text>Indonesian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ine'">
												<xsl:text>Indo-European (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'inh'">
												<xsl:text>Ingush</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ipk'">
												<xsl:text>Inupiaq</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ik'">
												<xsl:text>Inupiaq</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ira'">
												<xsl:text>Iranian (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'iro'">
												<xsl:text>Iroquoian languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ita'">
												<xsl:text>Italian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'it'">
												<xsl:text>Italian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'jav'">
												<xsl:text>Javanese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'jv'">
												<xsl:text>Javanese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'jbo'">
												<xsl:text>Lojban</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'jpn'">
												<xsl:text>Japanese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ja'">
												<xsl:text>Japanese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'jpr'">
												<xsl:text>Judeo-Persian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'jrb'">
												<xsl:text>Judeo-Arabic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kaa'">
												<xsl:text>Kara-Kalpak</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kab'">
												<xsl:text>Kabyle</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kac'">
												<xsl:text>Kachin or Jingpho</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kal'">
												<xsl:text>Kalaallisut or Greenlandic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kl'">
												<xsl:text>Kalaallisut or Greenlandic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kam'">
												<xsl:text>Kamba</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kan'">
												<xsl:text>Kannada</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kn'">
												<xsl:text>Kannada</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kar'">
												<xsl:text>Karen languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kas'">
												<xsl:text>Kashmiri</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ks'">
												<xsl:text>Kashmiri</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kau'">
												<xsl:text>Kanuri</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kr'">
												<xsl:text>Kanuri</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kaw'">
												<xsl:text>Kawi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kaz'">
												<xsl:text>Kazakh</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kk'">
												<xsl:text>Kazakh</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kbd'">
												<xsl:text>Kabardian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kha'">
												<xsl:text>Khasi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'khi'">
												<xsl:text>Khoisan (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'khm'">
												<xsl:text>Central Khmer</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'km'">
												<xsl:text>Central Khmer</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kho'">
												<xsl:text>Khotanese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kik'">
												<xsl:text>Kikuyu or Gikuyu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ki'">
												<xsl:text>Kikuyu or Gikuyu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kin'">
												<xsl:text>Kinyarwanda</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'rw'">
												<xsl:text>Kinyarwanda</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kir'">
												<xsl:text>Kirghiz or Kyrgyz</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ky'">
												<xsl:text>Kirghiz or Kyrgyz</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kmb'">
												<xsl:text>Kimbundu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kok'">
												<xsl:text>Konkani</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kom'">
												<xsl:text>Komi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kv'">
												<xsl:text>Komi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kon'">
												<xsl:text>Kongo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kg'">
												<xsl:text>Kongo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kor'">
												<xsl:text>Korean</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ko'">
												<xsl:text>Korean</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kos'">
												<xsl:text>Kosraean</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kpe'">
												<xsl:text>Kpelle</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'krc'">
												<xsl:text>Karachay-Balkar</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'krl'">
												<xsl:text>Karelian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kro'">
												<xsl:text>Kru languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kru'">
												<xsl:text>Kurukh</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kua'">
												<xsl:text>Kuanyama or Kwanyama</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kj'">
												<xsl:text>Kuanyama or Kwanyama</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kum'">
												<xsl:text>Kumyk</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kur'">
												<xsl:text>Kurdish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ku'">
												<xsl:text>Kurdish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'kut'">
												<xsl:text>Kutenai</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lad'">
												<xsl:text>Ladino</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lah'">
												<xsl:text>Lahnda</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lam'">
												<xsl:text>Lamba</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lao'">
												<xsl:text>Lao</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lo'">
												<xsl:text>Lao</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lat'">
												<xsl:text>Latin</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'la'">
												<xsl:text>Latin</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lav'">
												<xsl:text>Latvian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lv'">
												<xsl:text>Latvian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lez'">
												<xsl:text>Lezghian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lim'">
												<xsl:text>Limburgan or Limburger or Limburgish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'li'">
												<xsl:text>Limburgan or Limburger or Limburgish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lin'">
												<xsl:text>Lingala</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ln'">
												<xsl:text>Lingala</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lit'">
												<xsl:text>Lithuanian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lt'">
												<xsl:text>Lithuanian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lol'">
												<xsl:text>Mongo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'loz'">
												<xsl:text>Lozi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ltz'">
												<xsl:text>Luxembourgish or Letzeburgesch</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lb'">
												<xsl:text>Luxembourgish or Letzeburgesch</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lua'">
												<xsl:text>Luba-Lulua</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lub'">
												<xsl:text>Luba-Katanga</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lu'">
												<xsl:text>Luba-Katanga</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lug'">
												<xsl:text>Ganda</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lg'">
												<xsl:text>Ganda</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lui'">
												<xsl:text>Luiseno</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lun'">
												<xsl:text>Lunda</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'luo'">
												<xsl:text>Luo (Kenya and Tanzania)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'lus'">
												<xsl:text>Lushai</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mac'">
												<xsl:text>Macedonian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mkd'">
												<xsl:text>Macedonian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mk'">
												<xsl:text>Macedonian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mad'">
												<xsl:text>Madurese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mag'">
												<xsl:text>Magahi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mah'">
												<xsl:text>Marshallese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mh'">
												<xsl:text>Marshallese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mai'">
												<xsl:text>Maithili</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mak'">
												<xsl:text>Makasar</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mal'">
												<xsl:text>Malayalam</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ml'">
												<xsl:text>Malayalam</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'man'">
												<xsl:text>Mandingo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mao'">
												<xsl:text>Maori</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mri'">
												<xsl:text>Maori</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mi'">
												<xsl:text>Maori</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'map'">
												<xsl:text>Austronesian (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mar'">
												<xsl:text>Marathi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mr'">
												<xsl:text>Marathi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mas'">
												<xsl:text>Masai</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'may'">
												<xsl:text>Malay</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'msa'">
												<xsl:text>Malay</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ms'">
												<xsl:text>Malay</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mdf'">
												<xsl:text>Moksha</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mdr'">
												<xsl:text>Mandar</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'men'">
												<xsl:text>Mende</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mga'">
												<xsl:text>Irish, Middle (900-1200)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mic'">
												<xsl:text>Mi'kmaq or Micmac</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'min'">
												<xsl:text>Minangkabau</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mis'">
												<xsl:text>Miscellaneous languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mkh'">
												<xsl:text>Mon-Khmer (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mlg'">
												<xsl:text>Malagasy</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mg'">
												<xsl:text>Malagasy</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mlt'">
												<xsl:text>Maltese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mt'">
												<xsl:text>Maltese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mnc'">
												<xsl:text>Manchu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mni'">
												<xsl:text>Manipuri</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mno'">
												<xsl:text>Manobo languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'moh'">
												<xsl:text>Mohawk</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mol'">
												<xsl:text>Moldavian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mo'">
												<xsl:text>Moldavian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mon'">
												<xsl:text>Mongolian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mn'">
												<xsl:text>Mongolian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mos'">
												<xsl:text>Mossi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mun'">
												<xsl:text>Munda languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mus'">
												<xsl:text>Creek</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mwl'">
												<xsl:text>Mirandese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'mwr'">
												<xsl:text>Marwari</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'myn'">
												<xsl:text>Mayan languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'myv'">
												<xsl:text>Erzya</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nah'">
												<xsl:text>Nahuatl languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nai'">
												<xsl:text>North American Indian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nap'">
												<xsl:text>Neapolitan</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nau'">
												<xsl:text>Nauru</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'na'">
												<xsl:text>Nauru</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nav'">
												<xsl:text>Navajo or Navaho</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nv'">
												<xsl:text>Navajo or Navaho</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nbl'">
												<xsl:text>Ndebele, South or South Ndebele</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nr'">
												<xsl:text>Ndebele, South or South Ndebele</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nde'">
												<xsl:text>Ndebele, North or North Ndebele</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nd'">
												<xsl:text>Ndebele, North or North Ndebele</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ndo'">
												<xsl:text>Ndonga</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ng'">
												<xsl:text>Ndonga</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nds'">
												<xsl:text>Low German or Low Saxon or German, Low or Saxon, Low</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nep'">
												<xsl:text>Nepali</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ne'">
												<xsl:text>Nepali</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'new'">
												<xsl:text>Nepal Bhasa or Newari</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nia'">
												<xsl:text>Nias</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nic'">
												<xsl:text>Niger-Kordofanian (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'niu'">
												<xsl:text>Niuean</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nno'">
												<xsl:text>Norwegian Nynorsk or Nynorsk, Norwegian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nn'">
												<xsl:text>Norwegian Nynorsk or Nynorsk, Norwegian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nob'">
												<xsl:text>BokmÃ¥l, Norwegian or Norwegian BokmÃ¥l</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nb'">
												<xsl:text>BokmÃ¥l, Norwegian or Norwegian BokmÃ¥l</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nog'">
												<xsl:text>Nogai</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'non'">
												<xsl:text>Norse, Old</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nor'">
												<xsl:text>Norwegian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'no'">
												<xsl:text>Norwegian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nso'">
												<xsl:text>Pedi or Sepedi or Northern Sotho</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nub'">
												<xsl:text>Nubian languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nwc'">
												<xsl:text>Classical Newari or Old Newari or Classical Nepal Bhasa</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nya'">
												<xsl:text>Chichewa or Chewa or Nyanja</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ny'">
												<xsl:text>Chichewa or Chewa or Nyanja</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nym'">
												<xsl:text>Nyamwezi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nyn'">
												<xsl:text>Nyankole</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nyo'">
												<xsl:text>Nyoro</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nzi'">
												<xsl:text>Nzima</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'oci'">
												<xsl:text>Occitan (post 1500) or ProvenÃ§al</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'oc'">
												<xsl:text>Occitan (post 1500) or ProvenÃ§al</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'oji'">
												<xsl:text>Ojibwa</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'oj'">
												<xsl:text>Ojibwa</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ori'">
												<xsl:text>Oriya</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'or'">
												<xsl:text>Oriya</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'orm'">
												<xsl:text>Oromo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'om'">
												<xsl:text>Oromo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'osa'">
												<xsl:text>Osage</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'oss'">
												<xsl:text>Ossetian or Ossetic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'os'">
												<xsl:text>Ossetian or Ossetic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ota'">
												<xsl:text>Turkish, Ottoman (1500-1928)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'oto'">
												<xsl:text>Otomian languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'paa'">
												<xsl:text>Papuan (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pag'">
												<xsl:text>Pangasinan</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pal'">
												<xsl:text>Pahlavi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pam'">
												<xsl:text>Pampanga</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pan'">
												<xsl:text>Panjabi or Punjabi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pa'">
												<xsl:text>Panjabi or Punjabi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pap'">
												<xsl:text>Papiamento</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pau'">
												<xsl:text>Palauan</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'peo'">
												<xsl:text>Persian, Old (ca.600-400 B.C.)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'per'">
												<xsl:text>Persian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fas'">
												<xsl:text>Persian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'fa'">
												<xsl:text>Persian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'phi'">
												<xsl:text>Philippine (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'phn'">
												<xsl:text>Phoenician</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pli'">
												<xsl:text>Pali</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pi'">
												<xsl:text>Pali</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pol'">
												<xsl:text>Polish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pl'">
												<xsl:text>Polish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pon'">
												<xsl:text>Pohnpeian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'por'">
												<xsl:text>Portuguese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pt'">
												<xsl:text>Portuguese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pra'">
												<xsl:text>Prakrit languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pro'">
												<xsl:text>ProvenÃ§al, Old (to 1500)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'pus'">
												<xsl:text>Pushto</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ps'">
												<xsl:text>Pushto</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'que'">
												<xsl:text>Quechua</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'qu'">
												<xsl:text>Quechua</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'raj'">
												<xsl:text>Rajasthani</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'rap'">
												<xsl:text>Rapanui</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'rar'">
												<xsl:text>Rarotongan or Cook Islands Maori</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'roa'">
												<xsl:text>Romance (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'roh'">
												<xsl:text>Romansh</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'rm'">
												<xsl:text>Romansh</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'rom'">
												<xsl:text>Romany</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'rum'">
												<xsl:text>Romanian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ron'">
												<xsl:text>Romanian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ro'">
												<xsl:text>Romanian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'run'">
												<xsl:text>Rundi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'rn'">
												<xsl:text>Rundi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'rup'">
												<xsl:text>Aromanian or Arumanian or Macedo-Romanian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'rus'">
												<xsl:text>Russian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ru'">
												<xsl:text>Russian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sad'">
												<xsl:text>Sandawe</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sag'">
												<xsl:text>Sango</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sg'">
												<xsl:text>Sango</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sah'">
												<xsl:text>Yakut</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sai'">
												<xsl:text>South American Indian (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sal'">
												<xsl:text>Salishan languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sam'">
												<xsl:text>Samaritan Aramaic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'san'">
												<xsl:text>Sanskrit</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sa'">
												<xsl:text>Sanskrit</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sas'">
												<xsl:text>Sasak</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sat'">
												<xsl:text>Santali</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'scc'">
												<xsl:text>Serbian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'srp'">
												<xsl:text>Serbian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sr'">
												<xsl:text>Serbian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'scn'">
												<xsl:text>Sicilian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sco'">
												<xsl:text>Scots</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'scr'">
												<xsl:text>Croatian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hrv'">
												<xsl:text>Croatian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'hr'">
												<xsl:text>Croatian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sel'">
												<xsl:text>Selkup</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sem'">
												<xsl:text>Semitic (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sga'">
												<xsl:text>Irish, Old (to 900)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sgn'">
												<xsl:text>Sign Languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'shn'">
												<xsl:text>Shan</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sid'">
												<xsl:text>Sidamo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sin'">
												<xsl:text>Sinhala or Sinhalese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'si'">
												<xsl:text>Sinhala or Sinhalese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sio'">
												<xsl:text>Siouan languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sit'">
												<xsl:text>Sino-Tibetan (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sla'">
												<xsl:text>Slavic (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'slo'">
												<xsl:text>Slovak</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'slk'">
												<xsl:text>Slovak</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sk'">
												<xsl:text>Slovak</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'slv'">
												<xsl:text>Slovenian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sl'">
												<xsl:text>Slovenian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sma'">
												<xsl:text>Southern Sami</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sme'">
												<xsl:text>Northern Sami</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'se'">
												<xsl:text>Northern Sami</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'smi'">
												<xsl:text>Sami languages (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'smj'">
												<xsl:text>Lule Sami</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'smn'">
												<xsl:text>Inari Sami</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'smo'">
												<xsl:text>Samoan</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sm'">
												<xsl:text>Samoan</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sms'">
												<xsl:text>Skolt Sami</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sna'">
												<xsl:text>Shona</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sn'">
												<xsl:text>Shona</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'snd'">
												<xsl:text>Sindhi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sd'">
												<xsl:text>Sindhi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'snk'">
												<xsl:text>Soninke</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sog'">
												<xsl:text>Sogdian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'som'">
												<xsl:text>Somali</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'so'">
												<xsl:text>Somali</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'son'">
												<xsl:text>Songhai languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sot'">
												<xsl:text>Sotho, Southern</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'st'">
												<xsl:text>Sotho, Southern</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'spa'">
												<xsl:text>Spanish or Castilian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'es'">
												<xsl:text>Spanish or Castilian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'srd'">
												<xsl:text>Sardinian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sc'">
												<xsl:text>Sardinian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'srn'">
												<xsl:text>Sranan Tongo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'srr'">
												<xsl:text>Serer</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ssa'">
												<xsl:text>Nilo-Saharan (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ssw'">
												<xsl:text>Swati</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ss'">
												<xsl:text>Swati</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'suk'">
												<xsl:text>Sukuma</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sun'">
												<xsl:text>Sundanese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'su'">
												<xsl:text>Sundanese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sus'">
												<xsl:text>Susu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sux'">
												<xsl:text>Sumerian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'swa'">
												<xsl:text>Swahili</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sw'">
												<xsl:text>Swahili</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'swe'">
												<xsl:text>Swedish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'sv'">
												<xsl:text>Swedish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'syr'">
												<xsl:text>Syriac</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tah'">
												<xsl:text>Tahitian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ty'">
												<xsl:text>Tahitian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tai'">
												<xsl:text>Tai (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tam'">
												<xsl:text>Tamil</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ta'">
												<xsl:text>Tamil</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tat'">
												<xsl:text>Tatar</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tt'">
												<xsl:text>Tatar</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tel'">
												<xsl:text>Telugu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'te'">
												<xsl:text>Telugu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tem'">
												<xsl:text>Timne</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ter'">
												<xsl:text>Tereno</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tet'">
												<xsl:text>Tetum</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tgk'">
												<xsl:text>Tajik</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tg'">
												<xsl:text>Tajik</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tgl'">
												<xsl:text>Tagalog</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tl'">
												<xsl:text>Tagalog</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tha'">
												<xsl:text>Thai</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'th'">
												<xsl:text>Thai</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tib'">
												<xsl:text>Tibetan</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bod'">
												<xsl:text>Tibetan</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'bo'">
												<xsl:text>Tibetan</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tig'">
												<xsl:text>Tigre</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tir'">
												<xsl:text>Tigrinya</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ti'">
												<xsl:text>Tigrinya</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tiv'">
												<xsl:text>Tiv</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tkl'">
												<xsl:text>Tokelau</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tlh'">
												<xsl:text>Klingon or tlhIngan-Hol</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tli'">
												<xsl:text>Tlingit</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tmh'">
												<xsl:text>Tamashek</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tog'">
												<xsl:text>Tonga (Nyasa)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ton'">
												<xsl:text>Tonga (Tonga Islands)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'to'">
												<xsl:text>Tonga (Tonga Islands)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tpi'">
												<xsl:text>Tok Pisin</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tsi'">
												<xsl:text>Tsimshian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tsn'">
												<xsl:text>Tswana</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tn'">
												<xsl:text>Tswana</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tso'">
												<xsl:text>Tsonga</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ts'">
												<xsl:text>Tsonga</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tuk'">
												<xsl:text>Turkmen</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tk'">
												<xsl:text>Turkmen</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tum'">
												<xsl:text>Tumbuka</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tup'">
												<xsl:text>Tupi languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tur'">
												<xsl:text>Turkish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tr'">
												<xsl:text>Turkish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tut'">
												<xsl:text>Altaic (Other)</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tvl'">
												<xsl:text>Tuvalu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'twi'">
												<xsl:text>Twi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tw'">
												<xsl:text>Twi</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'tyv'">
												<xsl:text>Tuvinian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'udm'">
												<xsl:text>Udmurt</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'uga'">
												<xsl:text>Ugaritic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'uig'">
												<xsl:text>Uighur or Uyghur</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ug'">
												<xsl:text>Uighur or Uyghur</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ukr'">
												<xsl:text>Ukrainian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'uk'">
												<xsl:text>Ukrainian</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'umb'">
												<xsl:text>Umbundu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'und'">
												<xsl:text>Undetermined</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'urd'">
												<xsl:text>Urdu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ur'">
												<xsl:text>Urdu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'uzb'">
												<xsl:text>Uzbek</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'uz'">
												<xsl:text>Uzbek</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'vai'">
												<xsl:text>Vai</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ven'">
												<xsl:text>Venda</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 've'">
												<xsl:text>Venda</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'vie'">
												<xsl:text>Vietnamese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'vi'">
												<xsl:text>Vietnamese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'vol'">
												<xsl:text>VolapÃ¼k</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'vo'">
												<xsl:text>VolapÃ¼k</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'vot'">
												<xsl:text>Votic</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'wak'">
												<xsl:text>Wakashan languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'wal'">
												<xsl:text>Walamo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'war'">
												<xsl:text>Waray</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'was'">
												<xsl:text>Washo</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'wel'">
												<xsl:text>Welsh</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cym'">
												<xsl:text>Welsh</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'cy'">
												<xsl:text>Welsh</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'wen'">
												<xsl:text>Sorbian languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'wln'">
												<xsl:text>Walloon</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'wa'">
												<xsl:text>Walloon</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'wol'">
												<xsl:text>Wolof</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'wo'">
												<xsl:text>Wolof</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'xal'">
												<xsl:text>Kalmyk or Oirat</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'xho'">
												<xsl:text>Xhosa</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'xh'">
												<xsl:text>Xhosa</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'yao'">
												<xsl:text>Yao</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'yap'">
												<xsl:text>Yapese</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'yid'">
												<xsl:text>Yiddish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'yi'">
												<xsl:text>Yiddish</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'yor'">
												<xsl:text>Yoruba</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'yo'">
												<xsl:text>Yoruba</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'ypk'">
												<xsl:text>Yupik languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'zap'">
												<xsl:text>Zapotec</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'zen'">
												<xsl:text>Zenaga</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'zha'">
												<xsl:text>Zhuang or Chuang</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'za'">
												<xsl:text>Zhuang or Chuang</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'znd'">
												<xsl:text>Zande languages</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'zul'">
												<xsl:text>Zulu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'zu'">
												<xsl:text>Zulu</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'zun'">
												<xsl:text>Zuni</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'zxx'">
												<xsl:text>No linguistic content</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'nqo'">
												<xsl:text>N'Ko</xsl:text>
												</xsl:when>
												<xsl:when test="@langcode = 'zza'">
												<xsl:text>Zaza or Dimili or Dimli or Kirdki or Kirmanjki or Zazaki</xsl:text>
												</xsl:when>
												</xsl:choose>
												<!--                                        <xsl:apply-templates mode="langMaterial"/>-->
											</fo:block>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<fo:block>
											<xsl:apply-templates select="./text()"/>
										</fo:block>
									</xsl:otherwise>
								</xsl:choose>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
					<fo:table-row>
						<xsl:apply-templates mode="abstract" select="ead:abstract"/>
					</fo:table-row>
					<!-- RH: added physloc -->
					<xsl:for-each select="ead:physloc">
						<xsl:choose>
							<xsl:when test="@type = 'text'">
								<fo:table-row>
									<fo:table-cell column-number="1">
										<fo:block font-weight="bold">
											<!--<xsl:apply-templates select="@label"/>-->
											<xsl:text>Location: </xsl:text>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell column-number="2">
										<fo:block>
											<xsl:apply-templates mode="physloc"/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when
										test="
											not(preceding-sibling::ead:physloc[@type = 'text'] | following-sibling::ead:physloc[@type = 'text'])
											and @type = 'code' and matches(., '^mudd$')">
										<fo:table-row>
											<fo:table-cell column-number="1">
												<fo:block font-weight="bold">
												<!--<xsl:apply-templates select="@label"/>-->
												<xsl:text>Location: </xsl:text>
												</fo:block>
											</fo:table-cell>
											<fo:table-cell column-number="2">
												<fo:block>This collection is stored onsite at the
												Mudd Manuscript Library. </fo:block>
											</fo:table-cell>
										</fo:table-row>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when
												test="
													not(preceding-sibling::ead:physloc[@type = 'text'] | following-sibling::ead:physloc[@type = 'text'])
													and @type = 'code' and (matches(., '^rcpph$') or matches(., '^rcppf$') or matches(., '^rcpxg$') or matches(., '^rcpxm$')
													or matches(., '^rcpxr$') or matches(., '^rcppa$') or matches(., '^rcpxc$'))">
												<fo:table-row>
												<fo:table-cell column-number="1">
												<fo:block font-weight="bold">
												<!--<xsl:apply-templates select="@label"/>-->
												<xsl:text>Location: </xsl:text>
												</fo:block>
												</fo:table-cell>
												<fo:table-cell column-number="2">
												<fo:block>This collection is stored offsite at the
												ReCAP facility. </fo:block>
												</fo:table-cell>
												</fo:table-row>
											</xsl:when>
											<xsl:otherwise>
												<xsl:choose>
												<xsl:when
												test="
															not(preceding-sibling::ead:physloc[@type = 'text'] | following-sibling::ead:physloc[@type = 'text'])
															and @type = 'code' and (matches(., '^flm$') or matches(., '^flmp$') or matches(., '^wa$')
															or matches(., '^gax$') or matches(., '^mss$') or matches(., '^ex$') or matches(., '^flmm$')
															or matches(., '^ctsn$') or matches(., '^thx$'))">
												<fo:table-row>
												<fo:table-cell column-number="1">
												<fo:block font-weight="bold">
												<!--<xsl:apply-templates select="@label"/>-->
												<xsl:text>Location: </xsl:text>
												</fo:block>
												</fo:table-cell>
												<fo:table-cell column-number="2">
												<fo:block>This collection is stored onsite at
												Firestone Library. </fo:block>
												</fo:table-cell>
												</fo:table-row>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when
												test="
																	not(preceding-sibling::ead:physloc[@type = 'text'] | following-sibling::ead:physloc[@type = 'text'])
																	and @type = 'code' and (matches(., '^hsvc$') or matches(., '^hsvg$') or matches(., '^hsvm$') or matches(., '^hsvr$'))">
												<fo:table-row>
												<fo:table-cell column-number="1">
												<fo:block font-weight="bold">
												<!--<xsl:apply-templates select="@label"/>-->
												<xsl:text>Location: </xsl:text>
												</fo:block>
												</fo:table-cell>
												<fo:table-cell column-number="2">
												<fo:block>This collection is stored in special
												vault facilities at Firestone Library. </fo:block>
												</fo:table-cell>
												</fo:table-row>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when
												test="
																			not(preceding-sibling::ead:physloc[@type = 'text'] | following-sibling::ead:physloc[@type = 'text'])
																			and @type = 'code' and matches(., '^anxb$')">
												<fo:table-row>
												<fo:table-cell column-number="1">
												<fo:block font-weight="bold">
												<!--<xsl:apply-templates select="@label"/>-->
												<xsl:text>Location: </xsl:text>
												</fo:block>
												</fo:table-cell>
												<fo:table-cell column-number="2">
												<fo:block>This collection is stored offsite at
												Annex B (Fine Hall).</fo:block>
												</fo:table-cell>
												</fo:table-row>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when
												test="
																					not(preceding-sibling::ead:physloc[@type = 'text'] | following-sibling::ead:physloc[@type = 'text'])
																					and @type = 'code' and matches(., '^st$')">
												<fo:table-row>
												<fo:table-cell column-number="1">
												<fo:block font-weight="bold">
												<!--<xsl:apply-templates select="@label"/>-->
												<xsl:text>Location: </xsl:text>
												</fo:block>
												</fo:table-cell>
												<fo:table-cell column-number="2">
												<fo:block>This collection is stored onsite at the
												Engineering Library.</fo:block>
												</fo:table-cell>
												</fo:table-row>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when
												test="
																							not(preceding-sibling::ead:physloc[@type = 'text'] | following-sibling::ead:physloc[@type = 'text'])
																							and @type = 'code' and matches(., '^ppl$')">
												<fo:table-row>
												<fo:table-cell column-number="1">
												<fo:block font-weight="bold">
												<!--<xsl:apply-templates select="@label"/>-->
												<xsl:text>Location: </xsl:text>
												</fo:block>
												</fo:table-cell>
												<fo:table-cell column-number="2">
												<fo:block>This collection is stored onsite at the
												Plasma Physics Library.</fo:block>
												</fo:table-cell>
												</fo:table-row>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="not(@type)">
												<fo:table-row>
												<fo:table-cell column-number="1">
												<fo:block font-weight="bold">
												<!--<xsl:apply-templates select="@label"/>-->
												<xsl:text>Location: </xsl:text>
												</fo:block>
												</fo:table-cell>
												<fo:table-cell column-number="2">
												<fo:block>
												<xsl:apply-templates mode="physloc"/>
												</fo:block>
												</fo:table-cell>
												</fo:table-row>
												</xsl:when>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>
	<xsl:template mode="reference-code" match="ead:unitid">
		<fo:table-cell column-number="1">
			<fo:block font-weight="bold">
				<!--<xsl:apply-templates select="@label"/>-->
				<xsl:text>Call number: </xsl:text>
			</fo:block>
		</fo:table-cell>
		<fo:table-cell column-number="2">
			<fo:block>
				<!--        <xsl:apply-templates select="@countrycode"/>
	     <xsl:text> 
	     </xsl:text>
	     <xsl:apply-templates select="@repositorycode"/>
	     <xsl:text> 
	     </xsl:text>-->
				<xsl:apply-templates select="."/>
			</fo:block>
		</fo:table-cell>
	</xsl:template>
	<xsl:template mode="location" match="ead:repository">
		<fo:table-cell column-number="1">
			<fo:block space-before="0.25in" font-weight="bold">
				<!--<xsl:apply-templates select="@label"/>-->
				<xsl:text>Repository: </xsl:text>
			</fo:block>
		</fo:table-cell>
		<fo:table-cell column-number="2">
			<fo:block space-before="0.25in">
				<xsl:apply-templates select="ead:corpname"/>
			</fo:block>
			<xsl:for-each select="ead:subarea">
				<fo:block>
					<xsl:apply-templates select="(.)"/>
				</fo:block>
			</xsl:for-each>
			<fo:block>
				<xsl:apply-templates select="ead:address/ead:addressline[1]"/>
				<xsl:text> 
	</xsl:text>
				<xsl:apply-templates select="ead:address/ead:addressline[2]"/>
				<xsl:text> 
	</xsl:text>
				<xsl:apply-templates select="ead:address/ead:addressline[3]"/>
				<xsl:text> 
	</xsl:text>
			</fo:block>
		</fo:table-cell>
	</xsl:template>
	<xsl:template mode="unittitle" match="ead:unittitle">
		<fo:table-cell column-number="1">
			<fo:block space-before="0.25in" font-weight="bold">
				<!--<xsl:apply-templates select="@label"/>-->
				<xsl:text>Title and dates: </xsl:text>
			</fo:block>
		</fo:table-cell>
		<fo:table-cell column-number="2">
			<fo:block space-before="0.25in">
				<xsl:apply-templates select="."/>
			</fo:block>
		</fo:table-cell>
	</xsl:template>
	<xsl:template mode="physDesc" match="ead:physdesc">
		<fo:table-cell column-number="1">
			<fo:block space-before="0.25in" font-weight="bold">
				<!--<xsl:apply-templates select="@label"/>-->
				<xsl:text>Size: </xsl:text>
			</fo:block>
		</fo:table-cell>
		<fo:table-cell column-number="2">
			<fo:block space-before="0.25in">
				<xsl:apply-templates select="."/>
			</fo:block>
		</fo:table-cell>
	</xsl:template>
	<!--<xsl:template mode="langMaterial" match="ead:langmaterial">
        <fo:table-cell column-number="1">
            <fo:block space-before="0.25in" font-weight="bold">
                <!-\-<xsl:value-of select="@label"/>-\->
                <xsl:text>Language(s) of Material: </xsl:text>
            </fo:block>
        </fo:table-cell>
        <fo:table-cell column-number="2">
            <fo:block space-before="0.25in">
                <xsl:apply-templates select="."/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>-->
	<xsl:template mode="abstract" match="ead:abstract">
		<fo:table-cell column-number="1">
			<fo:block space-before="0.25in" font-weight="bold">
				<!--<xsl:value-of select="@label"/>-->
				<xsl:text>Abstract: </xsl:text>
			</fo:block>
		</fo:table-cell>
		<fo:table-cell column-number="2">
			<fo:block space-before="0.25in">
				<xsl:apply-templates select="."/>
			</fo:block>
		</fo:table-cell>
	</xsl:template>
	<!-- RH: added physloc -->
	<xsl:template mode="physloc" match="ead:physloc">
		<fo:table-cell column-number="1">
			<fo:block space-before="0.25in" font-weight="bold">
				<!--<xsl:value-of select="@label"/>-->
				<xsl:text>Location: </xsl:text>
			</fo:block>
		</fo:table-cell>
		<fo:table-cell column-number="2">
			<fo:block space-before="0.25in">
				<xsl:apply-templates select="."/>
			</fo:block>
		</fo:table-cell>
	</xsl:template>
	<!--<xsl:template match="ead:bioghist[ead:p]">
		<fo:block id="{generate-id(.)}">
			<!-\-<xsl:apply-templates select="ead:head"/>-\->
			<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
				text-align="center" background-color="#eee" color="black" padding-after=".10in"
				padding-before=".10in" border-style="solid" border-color="#666">
				<xsl:text>Biography/History</xsl:text>
			</fo:block>
			<xsl:apply-templates select="ead:p"/>
		</fo:block>
	</xsl:template>-->
	<!--<xsl:template match="ead:scopecontent">
		<fo:block id="{generate-id(.)}">
			<!-\-<xsl:apply-templates select="ead:head"/>-\->
			<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
				text-align="center" background-color="#eee" color="black" padding-after=".10in"
				padding-before=".10in" border-style="solid" border-color="#666">
				<xsl:text>Description</xsl:text>
			</fo:block>
			<xsl:apply-templates select="ead:p"/>
			<!-\-<xsl:apply-templates select="//ead:arrangement/ead:list" mode="CollectionDescriptions"/>-\->
		</fo:block>
	</xsl:template>-->
	<!--<xsl:template match="ead:arrangement">
		<fo:block id="{generate-id(.)}">
			<!-\-<xsl:apply-templates select="ead:head"/>-\->
			<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
				text-align="center" background-color="#eee" color="black" padding-after=".10in"
				padding-before=".10in" border-style="solid" border-color="#666">
				<xsl:text>Arrangement</xsl:text>
			</fo:block>
			<xsl:apply-templates select="ead:p"/>
			<!-\-            <xsl:apply-templates select="ead:list"/>-\->
			<xsl:for-each select="//ead:c[@level = 'series' or @level = 'subseries']">
				<fo:block>
					<xsl:if test="self::ead:*/@level = 'subseries'">
						<xsl:attribute name="start-indent">.5in</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="ead:did/ead:unittitle"/>
					<xsl:if test="ead:did/ead:unitdate">
						<xsl:text>, </xsl:text>
						<xsl:apply-templates select="ead:did/ead:unitdate"/>
					</xsl:if>
				</fo:block>
			</xsl:for-each>
		</fo:block>
	</xsl:template>-->
	<xsl:template match="ead:list">
		<xsl:choose>
			<xsl:when test="descendant::ead:ref[@altrender = 'series']">
				<xsl:for-each select="descendant::ead:ref">
					<xsl:if test="@altrender = 'series'">
						<!-- RH edit -->
						<fo:block>
							<xsl:choose>
								<xsl:when test="ead:unitdate">
									<xsl:for-each select="../ead:ref">
										<xsl:choose>
											<xsl:when test="ead:unittitle = ead:unitdate">
												<xsl:apply-templates select="ead:unitdate[1]"/>
												<xsl:if test="ead:unitdate[position() > 1]">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates
												select="ead:unitdate[position() > 1]"/>
												</xsl:if>
											</xsl:when>
											<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="ead:unittitle">
												<xsl:apply-templates select="ead:unittitle"/>
												<xsl:for-each select="ead:unitdate">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates select="current()"/>
												</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
												<xsl:apply-templates select="ead:unitdate[1]"/>
												<xsl:if test="ead:unitdate[position() > 1]">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates
												select="ead:unitdate[position() > 1]"/>
												</xsl:if>
												</xsl:otherwise>
												</xsl:choose>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="ead:unittitle"/>
								</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</xsl:if>
					<xsl:if test="@altrender = 'subseries'">
						<fo:block margin-left="25px">
							<xsl:choose>
								<xsl:when test="ead:unitdate">
									<xsl:for-each select="../ead:ref">
										<xsl:choose>
											<xsl:when test="ead:unittitle = ead:unitdate">
												<xsl:apply-templates select="ead:unitdate[1]"/>
												<xsl:if test="ead:unitdate[position() > 1]">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates
												select="ead:unitdate[position() > 1]"/>
												</xsl:if>
											</xsl:when>
											<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="ead:unittitle">
												<xsl:apply-templates select="ead:unittitle"/>
												<xsl:for-each select="ead:unitdate">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates select="current()"/>
												</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
												<xsl:apply-templates select="ead:unitdate[1]"/>
												<xsl:if test="ead:unitdate[position() > 1]">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates
												select="ead:unitdate[position() > 1]"/>
												</xsl:if>
												</xsl:otherwise>
												</xsl:choose>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="ead:unittitle"/>
								</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<!--                <xsl:for-each select="ead:head">
                    <fo:block space-before="0.10in" space-after=".10in" font-weight="bold">
                        <xsl:apply-templates/>
                    </fo:block>
                </xsl:for-each>-->
				<xsl:for-each select="ead:item">
					<fo:block margin-left="25px">
						<fo:inline font-weight="bold" font-size="16pt">
							<fo:character character="&#x00B7;"/>
						</fo:inline>
						<xsl:text>  
	    </xsl:text>
						<xsl:apply-templates/>
					</fo:block>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="collection_notes">
		<xsl:if test="ead:scopecontent">
			<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
				text-align="center" background-color="#eee" color="black" padding-after=".10in"
				padding-before=".10in" border-style="solid" border-color="#666">
				<xsl:text>Description</xsl:text>
			</fo:block>
			<xsl:for-each select="ead:scopecontent">
				<fo:block id="{generate-id(.)}">
					<!--<fo:block font-weight="bold">
			<xsl:apply-templates select="ead:head"/>
		</fo:block>-->
					<xsl:apply-templates select="ead:p"/>
				</fo:block>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="ead:bioghist">
			<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
				text-align="center" background-color="#eee" color="black" padding-after=".10in"
				padding-before=".10in" border-style="solid" border-color="#666">
				<xsl:text>Biography / History</xsl:text>
			</fo:block>
			<xsl:for-each select="ead:bioghist">
				<fo:block id="{generate-id(.)}">
					<!--<fo:block font-weight="bold">
			<xsl:apply-templates select="ead:head"/>
		</fo:block>-->
					<xsl:apply-templates select="ead:p"/>
				</fo:block>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="ead:arrangement">
			<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
				text-align="center" background-color="#eee" color="black" padding-after=".10in"
				padding-before=".10in" border-style="solid" border-color="#666">
				<xsl:text>Arrangement</xsl:text>
			</fo:block>
			<xsl:for-each select="ead:arrangement">
				<fo:block id="{generate-id(.)}">
					<!--<fo:block font-weight="bold">
			<xsl:apply-templates select="ead:head"/>
		</fo:block>-->
					<xsl:apply-templates select="ead:p"/>
				</fo:block>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="ead:accessrestrict | ead:userestrict | ead:phystech | ead:otherfindaid">
			<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
				text-align="center" background-color="#eee" color="black" padding-after=".10in"
				padding-before=".10in" border-style="solid" border-color="#666">
				<xsl:text>Access and Use</xsl:text>
			</fo:block>
			<xsl:for-each
				select="ead:accessrestrict | ead:userestrict | ead:phystech | ead:otherfindaid">
				<fo:block id="{generate-id(.)}">
					<fo:block font-weight="bold">
						<xsl:apply-templates select="ead:head"/>
					</fo:block>
					<xsl:apply-templates select="ead:p"/>
				</fo:block>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="ead:custodhist | ead:acqinfo | ead:appraisal | ead:accruals">
			<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
				text-align="center" background-color="#eee" color="black" padding-after=".10in"
				padding-before=".10in" border-style="solid" border-color="#666">
				<xsl:text>Acquisition and Appraisal</xsl:text>
			</fo:block>
			<xsl:for-each select="ead:custodhist | ead:acqinfo | ead:appraisal | ead:accruals">
				<fo:block id="{generate-id(.)}">
					<fo:block font-weight="bold">
						<xsl:apply-templates select="ead:head"/>
					</fo:block>
					<xsl:apply-templates select="ead:p"/>
				</fo:block>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="ead:originalsloc | ead:altformavail | ead:relatedmaterial | ead:bibliography">
			<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
				text-align="center" background-color="#eee" color="black" padding-after=".10in"
				padding-before=".10in" border-style="solid" border-color="#666">
				<xsl:text>Related Materials</xsl:text>
			</fo:block>
			<xsl:for-each
				select="ead:originalsloc | ead:altformavail | ead:relatedmaterial | ead:bibliography">
				<fo:block id="{generate-id(.)}">
					<fo:block font-weight="bold">
						<xsl:apply-templates select="ead:head"/>
					</fo:block>
					<xsl:apply-templates select="ead:p"/>
				</fo:block>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="ead:processinfo | ead:prefercite | ead:note">
			<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
				text-align="center" background-color="#eee" color="black" padding-after=".10in"
				padding-before=".10in" border-style="solid" border-color="#666">
				<xsl:text>Citation and Other Information</xsl:text>
			</fo:block>
			<xsl:for-each select="ead:prefercite | ead:note">
				<fo:block id="{generate-id(.)}">
					<fo:block font-weight="bold">
						<xsl:apply-templates select="ead:head"/>
					</fo:block>
					<xsl:apply-templates select="ead:p"/>
				</fo:block>
			</xsl:for-each>
		</xsl:if>
		<xsl:if
			test="ead:processinfo | //ead:profiledesc/ead:creation | //ead:profiledesc/ead:descrules">
			<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
				text-align="center" background-color="#eee" color="black" padding-after=".10in"
				padding-before=".10in" border-style="solid" border-color="#666">
				<xsl:text>Processing and Description</xsl:text>
			</fo:block>
			<xsl:for-each select="ead:processinfo">
				<fo:block id="{generate-id(.)}">
					<fo:block font-weight="bold">
						<xsl:apply-templates select="ead:head"/>
					</fo:block>
					<xsl:apply-templates select="ead:p"/>
				</fo:block>
			</xsl:for-each>
			<xsl:for-each select="//ead:profiledesc/ead:creation">
				<fo:block id="{generate-id(.)}">
					<fo:block font-weight="bold">
						<xsl:text>Encoding</xsl:text>
					</fo:block>
					<fo:block space-before="0.10in" space-after=".10in">
						<xsl:apply-templates select="//ead:profiledesc/ead:creation"/>
					</fo:block>
				</fo:block>
			</xsl:for-each>
			<xsl:for-each select="//ead:profiledesc/ead:descrules">
				<fo:block id="{generate-id(.)}">
					<fo:block font-weight="bold">
						<xsl:text>Descriptive Rules Used</xsl:text>
					</fo:block>
					<fo:block space-before="0.10in" space-after=".10in">
						<xsl:apply-templates select="//ead:profiledesc/ead:descrules"/>
					</fo:block>
				</fo:block>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template match="ead:note" mode="label">
		<fo:block space-after="0.10in" space-before="0.10in" font-weight="bold">
			<!--<xsl:apply-templates select=".[@label]"/>-->
			<xsl:text>Note: </xsl:text>
		</fo:block>
		<xsl:apply-templates select="ead:p"/>
	</xsl:template>
	<xsl:template match="ead:controlaccess">
		<fo:block id="{generate-id(.)}">
			<!--<xsl:apply-templates select="ead:head"/>-->
			<fo:block space-before="0.25in" space-after=".25in" font-weight="bold"
				text-align="center" background-color="#eee" color="black" padding-after=".10in"
				padding-before=".10in" border-style="solid" border-color="#666">
				<xsl:text>Subject Headings</xsl:text>
			</fo:block>
			<xsl:apply-templates select="ead:p"/>
			<xsl:apply-templates
				select="
					ead:persname | ead:famname | ead:corpname | ead:title |
					ead:subject | ead:geogname | ead:genreform | ead:occupation | ead:function"
				mode="subjectHeadings"/>
		</fo:block>
	</xsl:template>
	<!--<xsl:template match="ead:dsc">
		<fo:block id="{generate-id(.)}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>-->
	<!-- added by ws 6-22-->
	<xsl:template match="ead:c">
		<fo:block id="{generate-id(.)}">
			<xsl:call-template name="clevel"/>
			<xsl:for-each select="ead:c">
				<fo:block id="{generate-id(.)}">
					<xsl:call-template name="clevel"/>
					<xsl:for-each select="ead:c">
						<fo:block id="{generate-id(.)}">
							<xsl:call-template name="clevel"/>
							<xsl:for-each select="ead:c">
								<fo:block id="{generate-id(.)}">
									<xsl:call-template name="clevel"/>
									<xsl:for-each select="ead:c">
										<fo:block id="{generate-id(.)}">
											<xsl:call-template name="clevel"/>
											<xsl:for-each select="ead:c">
												<fo:block id="{generate-id(.)}">
												<xsl:call-template name="clevel"/>
												<xsl:for-each select="ead:c">
												<fo:block id="{generate-id(.)}">
												<xsl:call-template name="clevel"/>
												<xsl:for-each select="ead:c">
												<fo:block id="{generate-id(.)}">
												<xsl:call-template name="clevel"/>
												</fo:block>
												</xsl:for-each>
												</fo:block>
												</xsl:for-each>
												</fo:block>
											</xsl:for-each>
										</fo:block>
									</xsl:for-each>
								</fo:block>
							</xsl:for-each>
						</fo:block>
					</xsl:for-each>
				</fo:block>
			</xsl:for-each>
		</fo:block>
	</xsl:template>
	<!-- These are collection-level headings-do we ever use them?: -->
	<!--<xsl:template match="ead:abstract | ead:note/ead:p | ead:langmaterial | ead:materialspec"
        mode="CollectionNotes">-->
	<!--<xsl:apply-templates select="head" mode="subhead"/>-->
	<!--<xsl:if test="self::ead:abstract">
            <fo:block space-after="0.10in" space-before="0.10in" font-weight="bold">
                <xsl:text>Abstract </xsl:text>
            </fo:block>
        </xsl:if>
        <xsl:if test="self::ead:note">
            <fo:block space-after="0.10in" space-before="0.10in" font-weight="bold">
                <xsl:text>General Note </xsl:text>
            </fo:block>
        </xsl:if>
        <xsl:if test="self::ead:langmaterial">
            <fo:block space-after="0.10in" space-before="0.10in" font-weight="bold">
                <xsl:text>Language(s) of Material </xsl:text>
            </fo:block>
        </xsl:if>
        <xsl:if test="self::ead:materialspec">
            <fo:block space-after="0.10in" space-before="0.10in" font-weight="bold">
                <xsl:text>Material-Specific Details </xsl:text>
            </fo:block>
        </xsl:if>-->
	<!--       <xsl:apply-templates select="p"/>-->
	<!--  </xsl:template>-->
	<!-- The following are component-level headings: -->
	<xsl:template
		match="
			ead:scopecontent | ead:bioghist | ead:arrangement | ead:userestrict |
			ead:accessrestrict | ead:processinfo | ead:acqinfo | ead:custodhist |
			ead:controlaccess | ead:odd | ead:note | ead:origination |
			ead:langmaterial | ead:materialspec | ead:phystech | ead:bibliography |
			ead:physdesc | ead:unitid"
		mode="ComponentNoteWithHeader">
		<!--<xsl:apply-templates select="ead:head" mode="subhead"/>-->
		<xsl:if test="self::ead:unitid">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:choose>
					<xsl:when test="@type">
						<xsl:value-of select="./@type"/>
						<xsl:text>: </xsl:text>
						<xsl:apply-templates/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Identifier: </xsl:text>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
			</fo:block>
		</xsl:if>
		<!-- RH:added unitid -->
		<xsl:if test="self::ead:physdesc">
			<xsl:for-each select="./text()">
				<fo:block space-before="0.10in" start-indent=".1in">
					<xsl:text>Physical Characteristics: </xsl:text>
					<xsl:value-of select="."/>
				</fo:block>
			</xsl:for-each>
			<xsl:for-each select="./*">
				<xsl:if test="self::ead:extent[not(@type)]">
					<fo:block space-before="0.10in" start-indent=".1in">
						<xsl:text>Size: </xsl:text>
						<xsl:value-of select="."/>
					</fo:block>
				</xsl:if>
				<xsl:if test="self::ead:dimensions">
					<fo:block space-before="0.10in" start-indent=".1in">
						<xsl:text>Dimensions: </xsl:text>
						<xsl:value-of select="."/>
					</fo:block>
				</xsl:if>
				<xsl:if test="self::ead:physfacet">
					<fo:block space-before="0.10in" start-indent=".1in">
						<xsl:text>Physical Characteristics: </xsl:text>
						<xsl:value-of select="."/>
					</fo:block>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="self::ead:langmaterial">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Language(s) of Materials:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:language"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:materialspec">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Material-Specific Details:  </xsl:text>
				<xsl:apply-templates select="text()"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:scopecontent">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Description:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:bioghist">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Biography/History:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:arrangement">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Arrangement:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:userestrict">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Restrictions on Use and Copyright Information:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:accessrestrict">
			<fo:block space-before="0.10in" start-indent=".1in">
				<fo:block font-weight="bold">
					<xsl:text>Access:  </xsl:text>
				</fo:block>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:processinfo[@id = 'conservation']">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Conservation:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:processinfo[@id = 'processing']">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Processing Information:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:acqinfo">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Acquisition and Appraisal:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:custodhist">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Custodial History:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:controlaccess">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Subject Headings:  </xsl:text>
				<xsl:apply-templates
					select="ead:persname | ead:corpname | ead:famname | ead:geogname | ead:subject | ead:genreform"
					mode="subjectHeadings"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:odd">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Other Descriptive Data:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:note">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>General Note:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:phystech">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Physical Characteristics and Technical Requirements:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:otherfindaid">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Other Finding Aid(s):  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:appraisal">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Appraisal:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:accruals">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Accruals:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:originalsloc">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Location of Originals:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:altformavail">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Location of Copies or Alternate Formats:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:relatedmaterial">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Related Archival Material:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:bibliography">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Bibliography:  </xsl:text>
				<xsl:apply-templates select="ead:list | ead:bibref"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:prefercite">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Preferred Citation:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:origination">
			<fo:block space-before="0.10in" start-indent=".1in">
				<xsl:text>Creator:  </xsl:text>
				<xsl:apply-templates
					select="(ead:list | ead:persname | ead:corpname | ead:famname)[position() = 1]"> </xsl:apply-templates>
				<xsl:if
					test="(ead:list | ead:persname | ead:corpname | ead:famname)[position() > 1]">
					<xsl:for-each
						select="(ead:list | ead:persname | ead:corpname | ead:famname)[position() > 1]">
						<xsl:text>; </xsl:text>
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</xsl:if>
			</fo:block>
			<xsl:for-each select="ead:p">
				<fo:block space-before="0.05in" start-indent=".1in">
					<xsl:apply-templates select="." mode="componentNote"/>
				</fo:block>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template
		match="
			ead:scopecontent | ead:bioghist | ead:arrangement | ead:userestrict |
			ead:accessrestrict | ead:processinfo | ead:acqinfo | ead:custodhist |
			ead:controlaccess | ead:odd | ead:note | ead:origination |
			ead:langmaterial | ead:materialspec | ead:phystech | ead:bibliography |
			ead:physdesc | ead:unitid"
		mode="SeriesNoteWithHeader">
		<!--<xsl:apply-templates select="ead:head" mode="subhead"/>-->
		<xsl:if test="self::ead:unitid">
			<fo:block space-before="0.10in">
				<xsl:choose>
					<xsl:when test="@type">
						<xsl:value-of select="./@type"/>
						<xsl:text>: </xsl:text>
						<xsl:apply-templates/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Identifier: </xsl:text>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:phystech">
			<fo:block space-before="0.10in">
				<xsl:text>Physical Characteristics and Technical Requirements:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:accessrestrict">
			<fo:block space-before="0.10in">
				<fo:block font-weight="bold">
					<xsl:text>Access:  </xsl:text>
				</fo:block>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:physdesc">
			<xsl:for-each select="./text()">
				<fo:block space-before="0.10in">
					<xsl:text>Physical Characteristics:  </xsl:text>
					<xsl:value-of select="."/>
				</fo:block>
			</xsl:for-each>
			<xsl:for-each select="./*">
				<xsl:if test="self::ead:extent[not(@type)]">
					<fo:block space-before="0.10in">
						<xsl:text>Size: </xsl:text>
						<xsl:value-of select="."/>
					</fo:block>
				</xsl:if>
				<xsl:if test="self::ead:dimensions">
					<fo:block space-before="0.10in">
						<xsl:text>Dimensions: </xsl:text>
						<xsl:value-of select="."/>
					</fo:block>
				</xsl:if>
				<xsl:if test="self::ead:physfacet">
					<fo:block space-before="0.10in">
						<xsl:text>Physical Characteristics: </xsl:text>
						<xsl:value-of select="."/>
					</fo:block>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="self::ead:langmaterial">
			<fo:block space-before="0.10in">
				<xsl:text>Language(s) of Materials:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:materialspec">
			<fo:block space-before="0.10in">
				<xsl:text>Material-Specific Details:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:scopecontent">
			<fo:block space-before="0.10in">
				<xsl:text>Description:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:bioghist">
			<fo:block space-before="0.10in">
				<xsl:text>Biography/History:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:arrangement">
			<fo:block space-before="0.10in">
				<xsl:text>Arrangement:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:userestrict">
			<fo:block space-before="0.10in">
				<xsl:text>Restrictions on Use and Copyright Information:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:processinfo[@id = 'conservation']">
			<fo:block space-before="0.10in">
				<xsl:text>Conservation:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:processinfo[@id = 'processing']">
			<fo:block space-before="0.10in">
				<xsl:text>Processing Information:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:acqinfo">
			<fo:block space-before="0.10in">
				<xsl:text>Acquisition and Appraisal:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:custodhist">
			<fo:block space-before="0.10in">
				<xsl:text>Custodial History:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:controlaccess">
			<fo:block space-before="0.10in">
				<xsl:text>Subject Headings:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:odd">
			<fo:block space-before="0.10in">
				<xsl:text>Other Descriptive Data:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:note">
			<fo:block space-before="0.10in">
				<xsl:text>General Note:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:phystech">
			<fo:block space-before="0.10in">
				<xsl:text>Physical Characteristics and Technical Requirements:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:otherfindaid">
			<fo:block space-before="0.10in">
				<xsl:text>Other Finding Aid(s):  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:appraisal">
			<fo:block space-before="0.10in">
				<xsl:text>Appraisal:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:accruals">
			<fo:block space-before="0.10in">
				<xsl:text>Accruals:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:originalsloc">
			<fo:block space-before="0.10in">
				<xsl:text>Location of Originals:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:altformavail">
			<fo:block space-before="0.10in">
				<xsl:text>Location of Copies or Alternate Formats:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:relatedmaterial">
			<fo:block space-before="0.10in">
				<xsl:text>Related Archival Material:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:bibliography">
			<fo:block space-before="0.10in">
				<xsl:text>Bibliography:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:prefercite">
			<fo:block space-before="0.10in">
				<xsl:text>Preferred Citation:  </xsl:text>
				<xsl:apply-templates select="ead:list"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="self::ead:origination">
			<fo:block space-before="0.10in">
				<xsl:text>Creator:  </xsl:text>
				<xsl:apply-templates select="ead:list | ead:persname | ead:corpname | ead:famname"/>
				<xsl:apply-templates select="ead:p" mode="componentNote"/>
			</fo:block>
		</xsl:if>
	</xsl:template>
	<xsl:template name="clevel">
		<!-- Variables set width for table cells, dependant on which c0* leevel-->
		<!-- RH: changed count starting at 1 and going to 8 to count starting at 0 and going to 7 -->
		<xsl:variable name="spaceWidth">
			<xsl:if test="count(ancestor::ead:c) = 0">0in</xsl:if>
			<xsl:if test="count(ancestor::ead:c) = 1">.2in</xsl:if>
			<xsl:if test="count(ancestor::ead:c) = 2">.4in</xsl:if>
			<xsl:if test="count(ancestor::ead:c) = 3">.6in</xsl:if>
			<xsl:if test="count(ancestor::ead:c) = 4">.8in</xsl:if>
			<xsl:if test="count(ancestor::ead:c) = 5">1in</xsl:if>
			<xsl:if test="count(ancestor::ead:c) = 6">1.2in</xsl:if>
			<xsl:if test="count(ancestor::ead:c) = 7">1.4in</xsl:if>
		</xsl:variable>
		<xsl:variable name="titleWidth">
			<xsl:choose>
				<xsl:when test="count(ancestor::ead:c) = 0">6in</xsl:when>
				<xsl:when test="count(ancestor::ead:c) = 1">5.8in</xsl:when>
				<xsl:when test="count(ancestor::ead:c) = 2">5.6in</xsl:when>
				<xsl:when test="count(ancestor::ead:c) = 3">5.4in</xsl:when>
				<xsl:when test="count(ancestor::ead:c) = 4">5.2in</xsl:when>
				<xsl:when test="count(ancestor::ead:c) = 5">5in</xsl:when>
				<xsl:when test="count(ancestor::ead:c) = 6">4.8in</xsl:when>
				<xsl:when test="count(ancestor::ead:c) = 7">4.6in</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<!--Variables select the values of the first and second containers in the did-->
		<xsl:variable name="current" select="ead:did/ead:container"/>
		<!--selects each did, choose statment determines if c0* is a file, item, or otherlevel or not-->
		<xsl:for-each select="ead:did">
			<xsl:choose>
				<xsl:when
					test="../@level = 'file' or ../@level = 'item' or ../@level = 'otherlevel'">
					<!-- RH add @level='otherlevel' 9/6/2011-->
					<fo:table table-layout="fixed" space-before=".10in" space-after=".10in"
						width="7in">
						<fo:table-column column-number="1" column-width="{$spaceWidth}"/>
						<fo:table-column column-number="2" column-width="{$titleWidth}"/>
						<fo:table-column column-number="3" column-width="1.6in"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell column-number="1">
									<fo:block> </fo:block>
								</fo:table-cell>
								<fo:table-cell column-number="2">
									<fo:block>
										<!-- RH edit -->
										<xsl:choose>
											<xsl:when test="ead:unitdate">
												<xsl:for-each select="../ead:did">
												<xsl:choose>
												<xsl:when test="ead:unittitle = ead:unitdate">
												<xsl:apply-templates select="ead:unitdate[1]"/>
												<xsl:if test="ead:unitdate[position() > 1]">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates
												select="ead:unitdate[position() > 1]"/>
												</xsl:if>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="ead:unittitle">
												<xsl:apply-templates select="ead:unittitle"/>
												<xsl:for-each select="ead:unitdate">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates select="current()"/>
												</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
												<xsl:apply-templates select="ead:unitdate[1]"/>
												<xsl:if test="ead:unitdate[position() > 1]">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates
												select="ead:unitdate[position() > 1]"/>
												</xsl:if>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:apply-templates select="ead:unittitle"/>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:apply-templates select="ead:unitid"
											mode="ComponentNoteWithHeader"/>
										<xsl:text> </xsl:text>
										<!-- RH:added unitid -->
										<!-- this puts in the component-level notes: -->
										<xsl:apply-templates
											select="
												../ead:scopecontent | ../ead:bioghist |
												../ead:arrangement | ../ead:userestrict | ../ead:processinfo | ../ead:acqinfo
												| ../ead:custodhist | ../ead:controlaccess | ../ead:odd |
												../ead:note | ../ead:bibliography | ead:origination | ead:langmaterial | ead:materialspec |
												../ead:accessrestrict | ../ead:phystech | ead:physdesc"
											mode="ComponentNoteWithHeader"/>
										<!-- RH: added bibliography -->
									</fo:block>
								</fo:table-cell>
								<xsl:if test="$current">
									<fo:table-cell column-number="3" padding-left=".10in">
										<xsl:if test="count($current) = 1">
											<xsl:for-each select="$current">
												<fo:block>
												<xsl:value-of
												select="
															concat(functx:capitalize-first(./@type), ': ',
															./text())
															"
												/>
												</fo:block>
											</xsl:for-each>
										</xsl:if>
										<xsl:if test="count($current) > 1">
											<xsl:for-each select="$current[position() mod 2 = 1]">
												<xsl:choose>
												<xsl:when
												test="not(./following-sibling::ead:container)">
												<xsl:choose>
												<xsl:when
												test="
																	./@type != ./preceding-sibling::ead:container[1
																	and @type = preceding-sibling::ead:container/@type]/@type">
												<fo:block>
												<xsl:value-of
												select="
																			concat(functx:capitalize-first(./preceding-sibling::ead:container[1]/@type), ': ',
																			./preceding-sibling::ead:container[1]/text(), ' ',
																			functx:capitalize-first(./@type), ': ',
																			./text())
																			"
												/>
												</fo:block>
												</xsl:when>
												<xsl:otherwise>
												<fo:block>
												<xsl:value-of
												select="
																			concat(functx:capitalize-first(./@type), ': ',
																			./text()), ' '
																			"
												/>
												</fo:block>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:when>
												<!-- odd but not last: -->
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when
												test="./@type != ./following-sibling::ead:container[1]/@type">
												<fo:block>
												<xsl:value-of
												select="
																			concat(functx:capitalize-first(./@type), ': ',
																			./text(), ' ',
																			functx:capitalize-first(./following-sibling::ead:container[1]/@type), ': ',
																			./following-sibling::ead:container[1]/text())
																			"
												/>
												</fo:block>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when
												test="
																			./following-sibling::ead:container[1]/@type !=
																			./following-sibling::ead:container[2]/@type">
												<fo:block>
												<xsl:value-of
												select="
																					concat(functx:capitalize-first(./@type), ': ',
																					./text()), ' '
																					"
												/>
												</fo:block>
												</xsl:when>
												<xsl:otherwise>
												<fo:block>
												<xsl:value-of
												select="
																					concat(functx:capitalize-first(./@type), ': ',
																					./text()), ' '
																					"
												/>
												</fo:block>
												<fo:block>
												<xsl:value-of
												select="
																					concat(
																					functx:capitalize-first(./following-sibling::ead:container[1]/@type), ': ',
																					./following-sibling::ead:container[1]/text())
																					"
												/>
												</fo:block>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
											</xsl:for-each>
										</xsl:if>
									</fo:table-cell>
								</xsl:if>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</xsl:when>
				<xsl:when
					test="
						../@level = 'subcollection' or ../@level = 'subgrp' or ../@level = 'series' or
						../@level = 'subseries'">
					<fo:table table-layout="fixed" space-before=".10in" space-after=".10in"
						width="7in">
						<fo:table-column column-number="1" column-width="{$spaceWidth}"/>
						<fo:table-column column-number="2"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell column-number="1">
									<fo:block> </fo:block>
								</fo:table-cell>
								<fo:table-cell column-number="2">
									<fo:marker marker-class-name="series-title">
										<!-- RH increased line hight of the horizontal rule -->
										<fo:block color="gray" space-after="0.10in"
											space-before="0.10in" font-weight="bold"
											border-bottom="solid" border-bottom-color="gray"
											padding-before=".05in" padding-after=".05in"
											line-height=".08in">
											<xsl:value-of select="substring(ead:unittitle, 0, 60)"/>
											... (Continued) </fo:block>
									</fo:marker>
									<fo:block space-after="0.10in" space-before="0.10in"
										font-weight="bold" border-top="solid" border-bottom="solid"
										padding-before=".05in" padding-after=".05in">
										<!-- RH edit -->
										<xsl:choose>
											<xsl:when test="ead:unitdate">
												<xsl:for-each select="../ead:did">
												<xsl:choose>
												<xsl:when test="ead:unittitle = ead:unitdate">
												<xsl:apply-templates select="ead:unitdate[1]"/>
												<xsl:if test="ead:unitdate[position() > 1]">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates
												select="ead:unitdate[position() > 1]"/>
												</xsl:if>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="ead:unittitle">
												<xsl:apply-templates select="ead:unittitle"/>
												<xsl:for-each select="ead:unitdate">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates select="current()"/>
												</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
												<xsl:apply-templates select="ead:unitdate[1]"/>
												<xsl:if test="ead:unitdate[position() > 1]">
												<xsl:text>, </xsl:text>
												<xsl:apply-templates
												select="ead:unitdate[position() > 1]"/>
												</xsl:if>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:apply-templates select="ead:unittitle"/>
											</xsl:otherwise>
										</xsl:choose>
									</fo:block>
									<xsl:apply-templates select="ead:unitid"
										mode="SeriesNoteWithHeader"/>
									<xsl:text> </xsl:text>
									<!-- RH:added unitid -->
									<!-- this puts in the series-level notes -->
									<!-- need headers here? possibly not for accessrestrict?-->
									<xsl:apply-templates
										select="
											../ead:scopecontent | ../ead:bioghist |
											../ead:arrangement | ../ead:userestrict | ../ead:processinfo | ../ead:acqinfo |
											../ead:custodhist | ../ead:controlaccess | ../ead:odd |
											../ead:note | ../ead:bibliography | ead:origination | ead:langmaterial | ead:materialspec |
											ead:physdesc | ../ead:phystech | ../ead:accessrestrict"
										mode="SeriesNoteWithHeader"/>
									<!-- RH:added bibliography -->
									<!--                                 <xsl:apply-templates
                                        select="../ead:abstract | ../ead:note/ead:p |
			      ../ead:langmaterial | ../ead:materialspec"
                                        mode="CollectionNotes"/>-->
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
					<xsl:if
						test="../child::ead:*[@level = 'file' or @level = 'item' or @level = 'otherlevel']">
						<!-- RH add otherlevel 9/6/2011 -->
						<fo:table table-layout="fixed" space-before=".10in" space-after=".10in"
							width="7.5in">
							<fo:table-column column-number="1" column-width="{$spaceWidth}"/>
							<fo:table-column column-number="2" column-width="{$titleWidth}"/>
							<fo:table-column column-number="3" column-width=".75in"/>
							<fo:table-column column-number="4" column-width=".75in"/>
							<fo:table-body>
								<fo:table-row>
									<fo:table-cell column-number="1">
										<fo:block> </fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes">There was a problem with the container list.
						Container is not level: file, item, otherlevel, subcollection, subgrp,
						series or subseries.</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="ead:index">
		<!--        <xsl:apply-templates select="ead:head"/>-->
		<fo:block space-before="0.25in" space-after=".25in" font-weight="bold" text-align="center"
			background-color="#eee" color="black" padding-after=".10in" padding-before=".10in"
			border-style="solid" border-color="#666">
			<xsl:text>Index</xsl:text>
			<!-- again, if we go this route, we may lose information -->
		</fo:block>
		<xsl:apply-templates select="ead:indexentry"/>
	</xsl:template>
	<xsl:template match="ead:indexentry">
		<fo:table table-layout="fixed" space-before=".10in" space-after=".10in">
			<fo:table-column column-number="1" column-width="2in"/>
			<fo:table-column column-number="2"/>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell column-number="1">
						<fo:block font-style="italic">
							<xsl:apply-templates select="ead:persname" mode="indexName"/>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell column-number="2">
						<fo:block>
							<xsl:apply-templates select="ref"/>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<!--for subject headings-->
	<xsl:template
		match="
			ead:persname | ead:famname | ead:corpname | ead:title | ead:subject |
			ead:geogname | ead:genreform | ead:occupation | ead:function"
		mode="subjectHeadings">
		<fo:block text-indent="25px">
			<fo:inline font-weight="bold" font-size="16pt">
				<fo:character character="&#x00B7;"/>
			</fo:inline>
			<xsl:text>  
      </xsl:text>
			<xsl:choose>
				<xsl:when test="current()/@source = 'local'">
					<xsl:choose>
						<xsl:when test="current()/(@authfilenumber | @id) = 't1'">
							<xsl:text>Africa</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="(@authfilenumber | @id) = 't2'">
									<xsl:text>American history</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="(@authfilenumber | @id) = 't3'">
											<xsl:text>American history/20th century</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't4'">
												<xsl:text>American history/Civil War and Reconstruction</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't5'">
												<xsl:text>American history/Colonial</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't6'">
												<xsl:text>American history/Early national</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't7'">
												<xsl:text>American history/Gilded Age, Populism, Progressivism</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't8'">
												<xsl:text>American history/Revolution</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't9'">
												<xsl:text>American literature</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't10'">
												<xsl:text>American politics and government</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't11'">
												<xsl:text>Ancient history</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't12'">
												<xsl:text>Antiquities</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't13'">
												<xsl:text>Architecture</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't14'">
												<xsl:text>Art history</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't15'">
												<xsl:text>Book history and arts</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't16'">
												<xsl:text>British literature</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't17'">
												<xsl:text>Cartography</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't18'">
												<xsl:text>Children's books</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't19'">
												<xsl:text>Classical literature</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't20'">
												<xsl:text>Cold War</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't21'">
												<xsl:text>Demography</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't22'">
												<xsl:text>Diplomacy</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't23'">
												<xsl:text>East Asian studies</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't24'">
												<xsl:text>Economic history</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't25'">
												<xsl:text>Education</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't26'">
												<xsl:text>Environmental studies</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't27'">
												<xsl:text>European history</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't28'">
												<xsl:text>European literature</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't29'">
												<xsl:text>Games and recreation</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't30'">
												<xsl:text>Hellenic studies</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't31'">
												<xsl:text>History of science</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't32'">
												<xsl:text>International organizations</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't33'">
												<xsl:text>Islamic manuscripts</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't34'">
												<xsl:text>Journalism</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't35'">
												<xsl:text>Latin American history</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't36'">
												<xsl:text>Latin American literature</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't37'">
												<xsl:text>Latin American studies</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't38'">
												<xsl:text>Legal history</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't39'">
												<xsl:text>Literature</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't40'">
												<xsl:text>Medieval and Renaissance manuscripts</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't41'">
												<xsl:text>Middle East</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't42'">
												<xsl:text>Music</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't43'">
												<xsl:text>Native American history</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't44'">
												<xsl:text>New Jerseyana</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't45'">
												<xsl:text>Philosophy</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't46'">
												<xsl:text>Photography</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't47'">
												<xsl:text>Political cartoons</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't48'">
												<xsl:text>Princeton University</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't49'">
												<xsl:text>Public policy/20th century</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't50'">
												<xsl:text>Publishing history</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't51'">
												<xsl:text>Religion</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't52'">
												<xsl:text>Russia</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't53'">
												<xsl:text>Theater/Film</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't54'">
												<xsl:text>Travel</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't55'">
												<xsl:text>Western Americana</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't56'">
												<xsl:text>Women's studies</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't57'">
												<xsl:text>World War I</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:choose>
												<xsl:when test="(@authfilenumber | @id) = 't58'">
												<xsl:text>World War II</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:apply-templates select="current()"/>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="current()"/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>
	<!-- Low-level elements -->
	<!--    <xsl:template match="ead:head">
        <fo:block space-before="0.25in" space-after=".25in" font-weight="bold" text-align="center"
            background-color="#eee" color="black" padding-after=".10in" padding-before=".10in"
            border-style="solid" border-color="#666">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>-->
	<!--<xsl:template match="ead:head" mode="subhead">
		<fo:block space-after="0.10in" space-before="0.10in" font-weight="bold">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>-->
	<xsl:template match="ead:p">
		<fo:block space-before="0.1in" space-after="0.1in">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="ead:p" mode="componentNote">
		<xsl:for-each select=".">
			<xsl:apply-templates/>
			<fo:block/>
		</xsl:for-each>
	</xsl:template>
	<!--<xsl:template match="ead:list">
      <xsl:for-each select="ead:item">
      <fo:block margin-left="25px">
      <fo:inline font-weight="bold" font-size="16pt">         
      <fo:character character="&#x00B7;"/>
      </fo:inline>
      <xsl:text>  
      </xsl:text>
      <xsl:apply-templates/>
      </fo:block>
      </xsl:for-each>
      </xsl:template>
  -->
	<xsl:template
		match="ead:ead//ead:title[@render = 'italic'] | ead:ead//ead:emph[@render = 'italic']">
		<fo:inline font-style="italic">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<xsl:template
		match="ead:ead//ead:title[@render = 'underline'] | ead:ead//ead:emph[@render = 'underline']">
		<fo:inline text-decoration="underline">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<xsl:template match="ead:ead//ead:title[@render = 'bold'] | ead:ead//ead:emph[@render = 'bold']">
		<fo:inline font-weight="bold">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<xsl:template match="ead:ead//ead:extref">
		<fo:basic-link color="darkorange">
			<!--  show-destination="new" -->
			<xsl:attribute name="external-destination">
				<xsl:value-of select="@xlink:href"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</fo:basic-link>
	</xsl:template>
	<!-- RH: build in support for bibref-->
	<xsl:template match="ead:bibref">
		<xsl:for-each select="current()">
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</xsl:for-each>
	</xsl:template>
	<!-- RH: insert "bulk" for bulk dates -->
	<xsl:template match="ead:unitdate[@type = 'bulk']">
		<xsl:text>bulk </xsl:text>
		<xsl:apply-templates/>
	</xsl:template>
</xsl:stylesheet>
