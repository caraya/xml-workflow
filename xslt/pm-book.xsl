<?xml version="1.1" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:epub="http://www.idpf.org/2007/ops"

  exclude-result-prefixes="epub xs xsl #default"
  version="2.0">

  <xsl:import href="book.xsl"/>

  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="*:pre *:code"/>

  <!-- Define the output for this and all document children -->
  <xsl:output
    name="xhtml-out"
    method="xml"
    indent="yes"
    encoding="UTF-8"
    omit-xml-declaration="yes" />

  <!-- Root template matching book -->
  <xsl:template match="book">
    <html class="no-js" lang="en">
      <head>
        <meta charset="utf-8"/>
        <xsl:element name="meta">
          <xsl:attribute name="generator">
            <xsl:value-of select="system-property('xsl:product-name')"/>
            <xsl:value-of select="system-property('xsl:product-version')"/>
          </xsl:attribute>
        </xsl:element>
        <xsl:element name="title">
          <xsl:value-of select="metadata/title"/>
        </xsl:element>
        <!-- Paged Media Styles -->
        <link rel="stylesheet" href="css/pm-style.css" />
        <link rel="stylesheet" href="css/paged-media.css"/>
        <link rel="stylesheet" href="css/styles/github.css" />
        <!-- 
          We add object-key-polyfill to fix an issue with PrinceXML
        -->
        <!--<script src="js/object-key-polyfill.js"/>-->
        <!-- Load and initialize highlight.js -->
        <script src="lib/highlight.pack.js"/>
        <script>
          hljs.initHighlighting();
        </script>
        <!-- <script src="js/script.js"/> -->
      </head>
      <body>
        <xsl:attribute name="data-type">book</xsl:attribute>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>

  <!-- Override of the section template.

    In this particular situation we need to:

      * Remove filename variable. It's not needed
      * Remove the result document element (it's all one file)
      * Change the test for type attribute so it'll terminate
        if it fails (type attribute is required)
      * Add the element that will build our running footer
        (p class="rh") and assign the value of title to it
      * Rework the metadata template so it'll match the spec on the CSS

    All other templates remain unchanged and are used from the base stylesheet.

    Only the templates defined in this stilesheet are overriden or created.
  -->
  <xsl:template match="section">
    <section>
      <xsl:choose>
        <xsl:when test="string(@type)">
          <xsl:attribute name="data-type">
            <xsl:value-of select="@type"/>
          </xsl:attribute>
          <xsl:attribute name="epub:type">
            <xsl:value-of select="@type"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">
            Type attribute is required for paged media.
            Check your section tags for missing type attributes
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="string(@class)">
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="string(@id)">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <!-- Running header paragraph -->
      <xsl:element name="p">
        <xsl:attribute name="class">rh</xsl:attribute>
        <xsl:value-of select="title"/>
      </xsl:element>
      <xsl:apply-templates/>
    </section>
  </xsl:template>

  <!-- Metadata -->
  <xsl:template match="metadata">
    <xsl:element name="section">
      <xsl:attribute name="data-type">titlepage</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- Create Table of Contents ... work in progress -->
  <xsl:template match="toc">
    <section data-type="toc">
      <h1>Table of Contents</h1>
      <nav>
        <ol>
          <xsl:for-each select="//section">
            <xsl:element name="li">
              <xsl:element name="a">
                <xsl:attribute name="href">
                  <xsl:value-of select="concat('#', generate-id(.))"/>
                </xsl:attribute>
                <xsl:value-of select="title"/>
              </xsl:element>
            </xsl:element>
          </xsl:for-each>
        </ol>
      </nav>
    </section>
  </xsl:template>

  <xsl:template match="title">
    <xsl:element name="h1">
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id(..)"/>
      </xsl:attribute>
      <xsl:if test="string(@align)">
        <xsl:attribute name="align">
          <xsl:value-of select="@align"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="string(@class)">
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
