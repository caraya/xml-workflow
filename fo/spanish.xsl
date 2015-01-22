<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="1.0">

<xsl:output method="xml" indent="yes"/>
<xsl:template match="html">
<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">

	<fo:layout-master-set>
		<fo:simple-page-master master-name="cover"
			page-height="12cm"
			page-width="12cm"
			margin-top="0.5cm"
			margin-bottom="0.5cm"
			margin-left="1cm"
			margin-right="0.5cm">
			<fo:region-body
				margin-top="3cm" />
		</fo:simple-page-master>

		<fo:simple-page-master master-name="leftPage"
			page-height="12cm"
			page-width="12cm"
			margin-left="0.5cm"
			margin-right="1cm"
			margin-top="0.5cm"
			margin-bottom="0.5cm">
			<fo:region-before extent="1cm"/>
			<fo:region-after extent="1cm"/>
			<fo:region-body
				margin-top="1.1cm"
				margin-bottom="1.1cm" />
		</fo:simple-page-master>

		<fo:simple-page-master master-name="rightPage"
			page-height="12cm"
			page-width="12cm"
			margin-left="1cm"
			margin-right="0.5cm"
			margin-top="0.5cm"
			margin-bottom="0.5cm">
			<fo:region-before extent="1cm"/>
			<fo:region-after extent="1cm"/>
			<fo:region-body
				margin-top="1.1cm"
				margin-bottom="1.1cm" />
		</fo:simple-page-master>

		<!-- Set up the sequence of pages -->
		<fo:page-sequence-master master-name="contents">
			<fo:repeatable-page-master-alternatives>
				<fo:conditional-page-master-reference
					master-name="leftPage"
					odd-or-even="even"/>
				<fo:conditional-page-master-reference
					master-name="rightPage"
					odd-or-even="odd"/>
			</fo:repeatable-page-master-alternatives>
		</fo:page-sequence-master>
	</fo:layout-master-set>

	<xsl:apply-templates/>
</fo:root>
</xsl:template>

<xsl:template match="head/title">
	<fo:page-sequence master-name="cover">
	<fo:flow flow-name="xsl-region-body">
		<fo:block font-family="Helvetica" font-size="18pt"
			text-align="end">
			<xsl:value-of select="."/>
		</fo:block>
		<fo:block font-family="Helvetica" font-size="12pt"
			text-align="end" space-after="36pt">
			Copyright &copy; 2001 J. David Eisenberg
		</fo:block>
		<fo:block text-align="end">
			<fo:external-graphic src="file:images/catcode_logo.jpg"
				width="99px" height="109px"/>
		</fo:block>
		<fo:block text-align="end">
			A Catcode Production
		</fo:block>
	</fo:flow>
	</fo:page-sequence>

</xsl:template>

<xsl:template match="body">
	<fo:page-sequence master-name="contents" initial-page-number="2">
	<fo:static-content flow-name="xsl-region-before">
		<fo:block font-family="Helvetica" font-size="10pt"
			text-align="center">
			<xsl:value-of select="/html/head/title"/>
		</fo:block>
	</fo:static-content>

	<fo:static-content flow-name="xsl-region-after">
		<fo:block font-family="Helvetica" font-size="10pt"
			text-align="center">
			P&aacute;gina <fo:page-number />
		</fo:block>
	</fo:static-content>
	<fo:flow flow-name="xsl-region-body">
	<xsl:apply-templates/>
	</fo:flow>
	</fo:page-sequence>
</xsl:template>

<xsl:template match="blockquote">
	<fo:block
		space-before="6pt" space-after="6pt"
		start-indent="1em" end-indent="1em">
	<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="h3">
<fo:block font-size="14pt" font-family="sans-serif"
	font-weight="bold" color="green"
	space-before="6pt" space-after="6pt">
<xsl:apply-templates/>
</fo:block>
</xsl:template>


<xsl:template match="div">
	<fo:block>
	<xsl:if test="@class='bordered'">
		<xsl:attribute name="border-width">1pt</xsl:attribute>
		<xsl:attribute name="border-style">solid</xsl:attribute>
	</xsl:if>
	<xsl:choose>
	<xsl:when test="@align='center'">
		<xsl:attribute name="text-align">center</xsl:attribute>
	</xsl:when>
	<xsl:when test="@align='right'">
		<xsl:attribute name="text-align">end</xsl:attribute>
	</xsl:when>
	</xsl:choose>
	<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="p">
	<fo:block
		text-indent="1em"
		font-family="sans-serif" font-size="12pt"
		space-before.minimum="2pt"
		space-before.maximum="6pt"
		space-before.optimum="4pt"
		space-after.minimum="2pt"
		space-after.maximum="6pt"
		space-after.optimum="4pt">
	<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="b">
	<fo:inline font-weight="bold"><xsl:apply-templates/></fo:inline>
</xsl:template>

<xsl:template match="i">
	<fo:inline font-style="italic"><xsl:apply-templates/></fo:inline>
</xsl:template>

<xsl:template match="u">
	<fo:inline text-decoration="underline"><xsl:apply-templates/></fo:inline>
</xsl:template>

<xsl:template match="ol">
	<fo:list-block
	  space-before="0.25em" space-after="0.25em">
		<xsl:apply-templates/>
	</fo:list-block>
</xsl:template>

<xsl:template match="ol/li">
	<fo:list-item>
		<fo:list-item-label start-indent="1em">
			<fo:block>
				<xsl:number/>.
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
	<fo:list-block
	  space-before="0.25em" space-after="0.25em">
		<xsl:apply-templates/>
	</fo:list-block>
</xsl:template>

<xsl:template match="ul/li">
	<fo:list-item>
		<fo:list-item-label start-indent="1em">
			<fo:block>
				&#x2022;
			</fo:block>
		</fo:list-item-label>
		<fo:list-item-body>
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:list-item-body>
	</fo:list-item>
</xsl:template>

<xsl:template match="dl">
	<fo:block space-before="0.25em" space-after="0.25em">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="dt">
	<fo:block><xsl:apply-templates/></fo:block>
</xsl:template>

<xsl:template match="dd">
	<fo:block start-indent="2em">
	<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<!-- when table-and-caption is supported, that will be the
   wrapper for this template -->
<xsl:template match="table">
	<xsl:apply-templates/>
</xsl:template>

<!--
	find the width= attribute of all the <th> and <td>
	elements in the first <tr> of this table. They are
	in pixels, so divide by 72 to get inches
-->
<xsl:template match="tbody">
<fo:table>
	<xsl:for-each select="tr[1]/th|tr[1]/td">
		<fo:table-column>
		<xsl:attribute name="column-width"><xsl:value-of
				select="floor(@width div 72)"/>in</xsl:attribute>
		</fo:table-column>
	</xsl:for-each>

<fo:table-body>
	<xsl:apply-templates />
</fo:table-body>

</fo:table>
</xsl:template>

<!-- this one's easy; <tr> corresponds to <fo:table-row> -->
<xsl:template match="tr">
<fo:table-row> <xsl:apply-templates/> </fo:table-row>
</xsl:template>

<!--
	Handle table header cells. They should be bold
	and centered by default. Look back at the containing
	<table> tag to see if a border width was specified.
-->
<xsl:template match="th">
<fo:table-cell font-weight="bold" text-align="center">
	<xsl:if test="ancestor::table[1]/@border &gt; 0">
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-width">1pt</xsl:attribute>
	</xsl:if>
	<fo:block>
	<xsl:apply-templates/>
	</fo:block>
</fo:table-cell>
</xsl:template>

<!--
	Handle table data cells.  Look back at the containing
	<table> tag to see if a border width was specified.
-->
<xsl:template match="td">
<fo:table-cell>
	<xsl:if test="ancestor::table/@border &gt; 0">
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-width">1pt</xsl:attribute>
	</xsl:if>
	<fo:block>
	<!-- set alignment to match that of <td> tag -->
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
	<xsl:apply-templates/>
	</fo:block>
</fo:table-cell>
</xsl:template>

<xsl:template match="br">
<fo:block><xsl:text></xsl:text></fo:block>
</xsl:template>

</xsl:stylesheet>
