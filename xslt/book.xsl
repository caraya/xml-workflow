<?xml version="1.0" ?>
<!-- Define stylesheet root and namespaces we'll work with -->
<xsl:stylesheet
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xml:lang="en-US"
  version="2.0">
  <!-- Define the output for this and all document children -->
  <xsl:output name="xhtml-out" method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" />
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

  <xsl:template match="metadata" mode="content">
    <div class="metadata">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="section" mode="content">
  <!--
    Each section element will generate its own file

    We create the file name by concatenating the type attribute for the section, the count of how many sections of that type there are and the .xhtml extension
  -->
    <xsl:variable name="fileName"
      select="concat(section/@type, count(section/@type),'.xhtml')"/>
    <!-- An example result of the variable above would be introduction1.xhtml -->
    <xsl:apply-templates/>
    <xsl:result-document href='${fileName}' format="xhtml-out">
        <section>
          <xsl:apply-templates/>
        </section>
      </xsl:result-document>
  </xsl:template>

  <xsl:template match="metadata" mode="metadata">
    <div class="metadata">
      <xsl:apply-templates mode="metadata"/>
    </div>
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

  <xsl:template match="metadata/otherRoles">
    <xsl:for-each select="metadata/otherRoles/otherRoles">
      <xsl:value-of select="first_name" />
      <xsl:value-of select="surname" />
      <xsl:text>-</xsl:text>
      <xsl:value-of select="role" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="para">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="strong">
    <strong><xsl:apply-templates/></strong>
  </xsl:template>

  <xsl:template match="emphasis">
    <emphasis><xsl:apply-templates/></emphasis>
  </xsl:template>

  <xsl:template match="strike">
    <strike><xsl:apply-templates/></strike>
  </xsl:template>

  <xsl:template match="underline">
    <u> <xsl:apply-templates/></u>
  </xsl:template>


</xsl:stylesheet>
