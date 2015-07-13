<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fo='http://www.w3.org/1999/XSL/Format'
  xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
  xmlns:rx="http://www.renderx.com/XSL/Extensions"
  exclude-result-prefixes="xs"
  version="2.0">

<xsl:variable name='base-font-size' select='12'/>
<xsl:variable name='title-font-size' select='$base-font-size * 1.5'/>
<xsl:variable name='head-font-size' select='$base-font-size * 1.2'/>
<xsl:variable name='small-font-size' select='$base-font-size div 2'/>

<xsl:variable name='base-sz' select= 'concat ($base-font-size,"pt")'/>
<xsl:variable name='title-sz' select= 'concat ($title-font-size,"pt")'/>
<xsl:variable name='head-sz' select= 'concat ($head-font-size,"pt")'/>
<xsl:variable name='small-sz' select= 'concat ($small-font-size,"pt")'/>

  <xsl:attribute-set name='font'> <!-- Font family -->
    <xsl:attribute
      name='font-family'>'Arial' 'Helvetica' Serif
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name='page-attributes'>
    <xsl:attribute name='margin'>1in 1in 1in 1in</xsl:attribute>
    <xsl:attribute name='page-height'>11in</xsl:attribute>
    <xsl:attribute name='page-width'>8.5in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="paragraph-attributes">
    <xsl:attribute name="text-indent">1in</xsl:attribute>
    <xsl:attribute name="space-before">1in</xsl:attribute>
    <xsl:attribute name="space-after">0.5in</xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="keep-together.within-page">always</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="title"
    use-attribute-sets="font ">
    <xsl:attribute name="font-size">
      <xsl:value-of select="$title-sz"/>
    </xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-style">normal</xsl:attribute>
    <xsl:attribute name="space-before.optimum">
      <xsl:value-of select="$title-sz"/>
    </xsl:attribute>
    <xsl:attribute
      name="space-before.conditionality">retain</xsl:attribute>
    <xsl:attribute name="space-after.optimum">
      <xsl:value-of select="$small-sz"/>
    </xsl:attribute>
    <xsl:attribute name="keep-with-next">true</xsl:attribute>
    <xsl:attribute name="page-break-inside">avoid</xsl:attribute>
    <xsl:attribute name="text-align">center</xsl:attribute>
    <xsl:attribute name="background-color">white</xsl:attribute>
  </xsl:attribute-set>

  <!-- This template will catch all elements that don't have a matching template -->
  <xsl:template match="*">
    <fo:block color="red">
      Element <xsl:value-of
        select="name(..)"/>/ <xsl:value-of
          select="name(  )"/> found, with no template.
    </fo:block>
  </xsl:template>
  <xsl:template name='generate-page-masters'>
    <!--
      We'll define all the  simple page masters here

      We'll also define the flow sequence for the document.
    -->
    <fo:simple-page-master xsl:use-attribute-sets='page-attributes'>
      <xsl:attribute name='master-name'>PageMaster-Cover</xsl:attribute>
      <fo:region-body margin="0in 0in 0in 0in"/>
    </fo:simple-page-master>

    <fo:simple-page-master xsl:use-attribute-sets='page-attributes'>
      <xsl:attribute name="master-name">pageMaster-front</xsl:attribute>
    </fo:simple-page-master>

    <fo:simple-page-master xsl:use-attribute-sets='page-attributes'>
      <xsl:attribute name="master-name">pageMaster-body-odd</xsl:attribute>
    </fo:simple-page-master>

    <fo:simple-page-master xsl:use-attribute-sets='page-attributes'>
      <xsl:attribute name="master-name">pageMaster-body-even</xsl:attribute>
    </fo:simple-page-master>

    <fo:simple-page-master xsl:use-attribute-sets='page-attributes'>
      <xsl:attribute name="master-name">pageMaster-back</xsl:attribute>
    </fo:simple-page-master>

    <fo:page-sequence>
      <!-- Waiting to have all the elements I need to have before I go ahead and change the sequence and page pasters -->
    </fo:page-sequence>
  </xsl:template>


  <xsl:template match="section[@role='chapter']">
    <fo:page-sequence
      master-reference="chaps"
      initial-page-label="1"
      format="1">

      <fo:static-content
        flow-name="xsl-region-before">
        <fo:block text-align="center">
          <xsl:value-of select="metadata/title"></xsl:value-of>
        </fo:block>
      </fo:static-content>

      <fo:static-content flow-name="xsl-region-after">
        <fo:block>

        </fo:block>
      </fo:static-content>

      <fo:flow flow-name="xsl-region-body">
        <fo:block  xsl:use-attribute-sets='font paragraph-attributes'>
          <xsl:apply-templates />
        </fo:block>
      </fo:flow>
    </fo:page-sequence>
  </xsl:template>
</xsl:stylesheet>
