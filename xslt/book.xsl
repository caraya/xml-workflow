<?xml version="1.0"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <!-- Define the output for this and all document children -->
  <xsl:output  name="xhtmlOutput" method="xhtml" indent="yes" encoding="UTF-8"/>
  <!-- Root template, matching / -->
  <xsl:template match="/">
    <html>
      <head>
        <title><xsl:value-of select="metadata/title"/></title>
        <link rel="stylesheet" href="css/style.css"/>
        <script src="js/script.js"></script>
      </head>
      <body>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="metadata">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="section">
    <xsl:value-of select="."/>
    <xsl:if
      test="section/@class">class="<value-of select="/book/section/@class"/>
    </xsl:if>
    <xsl:if
      test="not(section/@class)"></xsl:if>
    <xsl:if
      test="section/@id">class="<value-of select="/book/section/@id"/>
    </xsl:if>
    <xsl:if
      test="not(section/@id)"></xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="metadata/title">
    <h1> <xsl:value-of select="."/> </h1>
  </xsl:template>

  <xsl:template match="metadata/authors">
    <xsl:for-each select="metadata/authors/author">
      <xsl:value-of select="first_name"/>
      <xsl:value-of select="surname"/>
      <xsl:if test="position()!=last()">, </xsl:if>
      <xsl:if test="position()-1">and </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="metadata/editors">
    <xsl:for-each select="metadata/editors/editor">
      <xsl:value-of select="first_name"/>
      <xsl:value-of select="surname"/> <xsl:text> - </xsl:text>
      <xsl:value-of select="typeOfEditor"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="metadata/editors">
    <xsl:for-each select="metadata/editors/editor">
      <xsl:value-of select="first_name"/>
      <xsl:value-of select="surname"/> <xsl:text> - </xsl:text>
      <xsl:value-of select="typeOfEditor"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="para">
    <p> <xsl:apply-templates/> </p>
  </xsl:template>
</xsl:stylesheet>
