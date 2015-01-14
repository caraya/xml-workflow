<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <!-- Define the output for this and all document children -->
  <xsl:output name="xhtmlOutput" method="xhtml" indent="yes" encoding="UTF-8" />
  <!-- Root template, matching / -->
  <xsl:template match="/">
    <html>
    <head>
      <title>
        <xsl:value-of select="metadata/title" />
      </title>
      <link rel="stylesheet" href="css/style.css" />
      <script src="js/script.js"></script>
    </head>

    <body>
      <xsl:apply-templates/>
    </body>

    </html>
  </xsl:template>

  <xsl:template match="metadata">
    <div class="metadata">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="section">
    <section>
      <xsl:apply-templates/>
    </section>
  </xsl:template>

  <xsl:template match="metadata/title">
    <h1> <xsl:value-of select="."/> </h1>
  </xsl:template>

  <xsl:template match="metadata/authors">
    <xsl:for-each select="metadata/authors/author">
      <xsl:value-of select="first_name" />
      <xsl:value-of select="surname" />
      <xsl:if test="position()!=last()">,</xsl:if>
      <xsl:if test="position()-1">and</xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="metadata/editors">
    <h2>Editorial Team</h2>
    <ul class="no-bullet">
      <xsl:for-each select="metadata/editors/editor">
        <p>
          <xsl:value-of select="first_name" />
          <xsl:value-of select="surname" />
          <xsl:text>-</xsl:text>
          <xsl:value-of select="typeOfEditor" />
        </p>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="metadata/otherRolea">
    <xsl:for-each select="metadata/otherRoles/otherRoles">
      <xsl:value-of select="first_name" />
      <xsl:value-of select="surname" />
      <xsl:text>-</xsl:text>
      <xsl:value-of select="role" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="strong">
    <strong></strong>
  </xsl:template>

  <xsl:template match="emphasis">
    <emphasis></emphasis>
  </xsl:template>

  <xsl:template match="strike">
    <strike></strike>
  </xsl:template>

  <xsl:template match="underline">
    <u></u>
  </xsl:template>

  <xsl:template match="para">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

</xsl:stylesheet>
