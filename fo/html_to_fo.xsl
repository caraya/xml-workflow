<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="1.0">

<xsl:output method="xml" indent="yes"/>
<xsl:variable name="pagewidth" select="21.5"/>
<xsl:variable name="bodywidth" select="19"/>
<xsl:template match="html">
<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">

	<fo:layout-master-set>
		<fo:simple-page-master master-name="leftPage"
			page-height="27.9cm"
			page-width="{$pagewidth}cm"
			margin-left="1cm"
			margin-right="2cm"
			margin-top="1cm"
			margin-bottom="1cm">
			<fo:region-before extent="1cm"/>
			<fo:region-after extent="1cm"/>
			<fo:region-body
				margin-top="1cm"
				margin-bottom="1cm" />
		</fo:simple-page-master>

		<fo:simple-page-master master-name="rightPage"
			page-height="27.9cm"
			page-width="{$pagewidth}cm"
			margin-left="2cm"
			margin-right="1cm"
			margin-top="0.5cm"
			margin-bottom="0.5cm">
			<fo:region-before extent="1cm"/>
			<fo:region-after extent="1cm"/>
			<fo:region-body
				margin-top="1cm"
				margin-bottom="1cm" />
		</fo:simple-page-master>

		<!-- Set up the sequence of pages -->
		<fo:page-sequence-master master-name="contents">
			<fo:repeatable-page-master-alternatives>
				<fo:conditional-page-master-reference
					master-name="leftPage"
					odd-or-even="odd"/>
				<fo:conditional-page-master-reference
					master-name="rightPage"
					odd-or-even="even"/>
			</fo:repeatable-page-master-alternatives>
		</fo:page-sequence-master>
	</fo:layout-master-set>

	<fo:page-sequence master-name="contents" initial-page-number="1">
		<xsl:apply-templates />
	</fo:page-sequence>
</fo:root>
</xsl:template>

<xsl:template match="head/title">
	<fo:static-content flow-name="xsl-region-before">
		<fo:block font-family="Helvetica" font-size="10pt"
			text-align="center">
			<xsl:value-of select="."/>
		</fo:block>
	</fo:static-content>

	<fo:static-content flow-name="xsl-region-after">
		<fo:block font-family="Helvetica" font-size="10pt"
			text-align="center">
			Page <fo:page-number />
		</fo:block>
	</fo:static-content>
</xsl:template>

<xsl:template match="body">
	<fo:flow flow-name="xsl-region-body">
	<xsl:apply-templates/>
	</fo:flow>
</xsl:template>

<xsl:template match="blockquote">
	<fo:block
		space-before="6pt" space-after="6pt"
		start-indent="1em" end-indent="1em">
	<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="h2">
	<fo:block font-size="18pt" color="green">
	<xsl:call-template name="set-alignment"/>
	<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="h3">
<fo:block font-size="14pt" font-weight="bold"
	space-before="6pt">
	<xsl:call-template name="set-alignment"/>
	<xsl:apply-templates/>
</fo:block>
</xsl:template>

<xsl:template match="h4">
<fo:block font-weight="bold" space-before="1mm">
	<xsl:call-template name="set-alignment"/>
	<xsl:apply-templates/>
</fo:block>
</xsl:template>

<xsl:template name="set-alignment">
	<xsl:choose>
	<xsl:when test="@align='left'">
		<xsl:attribute name="text-align">start</xsl:attribute>
	</xsl:when>
	<xsl:when test="@align='center'">
		<xsl:attribute name="text-align">center</xsl:attribute>
	</xsl:when>
	<xsl:when test="@align='right'">
		<xsl:attribute name="text-align">end</xsl:attribute>
	</xsl:when>
	</xsl:choose>
</xsl:template>


<xsl:template match="div">
	<fo:block>
	<xsl:if test="@class='bordered'">
		<xsl:attribute name="border-width">1pt</xsl:attribute>
		<xsl:attribute name="border-style">solid</xsl:attribute>
	</xsl:if>
	<xsl:call-template name="set-alignment"/>
	<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="p">
	<fo:block text-indent="1em"
		space-before="4pt" space-after="4pt">
	<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="ol">
	<fo:list-block provisional-distance-between-starts="10mm"
	  provisional-label-separation="1mm"
	  space-before="6pt" space-after="6pt">
		<xsl:apply-templates/>
	</fo:list-block>
</xsl:template>

<xsl:template match="ol/li">
	<fo:list-item space-after="1mm">
		<fo:list-item-label>
			<fo:block>
			<xsl:choose>
			<xsl:when test="../@type != ''">
				<xsl:number format="{../@type}"/>.
			</xsl:when>
			<xsl:otherwise>
				<xsl:number format="1"/>.
			</xsl:otherwise>
			</xsl:choose>
			</fo:block>
		</fo:list-item-label>
		<fo:list-item-body>
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:list-item-body>
	</fo:list-item>
</xsl:template>

<xsl:template match="ul">
	<fo:list-block provisional-distance-between-starts="10mm"
	  provisional-label-separation="1mm"
	  space-before="6pt" space-after="6pt">
		<xsl:apply-templates/>
	</fo:list-block>
</xsl:template>

<xsl:template match="ul/li">
	<fo:list-item space-after="1mm">
		<fo:list-item-label start-indent="5mm">
			<xsl:choose>
			<xsl:when test="../@type ='disc'">
				<fo:block>&#x2022;</fo:block>
			</xsl:when>
			<xsl:when test="../@type='square'">
				<fo:block font-family="ZapfDingbats">&#110;</fo:block>
			</xsl:when>
			<xsl:when test="../@type='circle'">
				<fo:block font-family="ZapfDingbats">&#109;</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
				<xsl:when test="count(ancestor::ul) = 1">
					<fo:block>&#x2022;</fo:block>
				</xsl:when>
				<xsl:when test="count(ancestor::ul) = 2">
					<fo:block font-family="ZapfDingbats">&#109;</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<fo:block font-family="ZapfDingbats">&#110;</fo:block>
				</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
			</xsl:choose>
		</fo:list-item-label>
		<fo:list-item-body>
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:list-item-body>
	</fo:list-item>
</xsl:template>

<xsl:template match="dl">
	<fo:block space-before="6pt" space-after="6pt">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="dt">
	<fo:block><xsl:apply-templates/></fo:block>
</xsl:template>

<xsl:template match="dd">
	<fo:block start-indent="5mm">
	<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="table">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="caption">
	<fo:caption><fo:block>
		<xsl:apply-templates />
	</fo:block></fo:caption>
</xsl:template>

<xsl:template match="tbody">
<fo:table>
	<xsl:for-each select="tr[1]/th|tr[1]/td">
		<fo:table-column>
		<xsl:attribute name="column-width">
		<xsl:choose>
			<xsl:when test="contains(@width, '%')"><xsl:value-of
				select="floor(number(translate(@width,'%','')) div 100
					* $bodywidth)"/>cm</xsl:when>
			<xsl:otherwise><xsl:value-of
				select="floor(@width div 72)"/>in</xsl:otherwise>
		</xsl:choose>
		</xsl:attribute>
		</fo:table-column>
	</xsl:for-each>
<fo:table-body>
	<xsl:apply-templates />
</fo:table-body>
</fo:table>
</xsl:template>

<xsl:template match="tr">
<fo:table-row> <xsl:apply-templates/> </fo:table-row>
</xsl:template>

<xsl:template match="th">
<fo:table-cell font-weight="bold" text-align="center">
	<xsl:if test="ancestor::table/@border &gt; 0">
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-width">1pt</xsl:attribute>
	</xsl:if>
<fo:block>
<xsl:apply-templates/>
</fo:block></fo:table-cell>
</xsl:template>

<xsl:template match="td">
<fo:table-cell>
	<xsl:if test="ancestor::table/@border &gt; 0">
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-width">1pt</xsl:attribute>
	</xsl:if>
	<fo:block>
		<xsl:call-template name="set-alignment"/>
		<xsl:apply-templates/>
	</fo:block>
</fo:table-cell>
</xsl:template>

<xsl:template match="tt">
	<fo:inline font-family="monospace"><xsl:apply-templates/></fo:inline>
</xsl:template>

<xsl:template match="img">
	<fo:external-graphic>
	<xsl:attribute name="src">file:<xsl:value-of
		select="@src"/></xsl:attribute>
	<xsl:attribute name="width"><xsl:value-of
		select="@width"/>px</xsl:attribute>
	<xsl:attribute name="height"><xsl:value-of
		select="@height"/>px</xsl:attribute>
	</fo:external-graphic>
</xsl:template>

<xsl:template match="pre">
	<fo:block white-space-collapse="false"><xsl:apply-templates/></fo:block>
</xsl:template>

<xsl:template match="b">
	<fo:inline font-weight="bold"><xsl:apply-templates/></fo:inline>
</xsl:template>

<xsl:template match="i">
	<fo:inline font-style="italic"><xsl:apply-templates/></fo:inline>
</xsl:template>

<xsl:template match="hr">
<fo:block>
<fo:leader
	leader-pattern="rule" leader-length.optimum="100%"
	rule-style="double" rule-thickness="1pt"/>
</fo:block>
</xsl:template>

<xsl:template match="br">
<fo:block><xsl:text>&#xA;</xsl:text></fo:block>
</xsl:template>
</xsl:stylesheet>
