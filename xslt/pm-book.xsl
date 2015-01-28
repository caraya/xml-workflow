<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  <!--
    XSLT Paged Media Customization Layer

    Makes the necessary changes to the content to work with the Paged Media CSS stylesheet
  -->
  <!-- First import the base stylesheet -->
  <xsl:import href="book.xsl"/>

  <!-- Define the output for this and all document children -->
  <xsl:output
    name="xhtml-out"
    method="xhtml"
    indent="yes"
    encoding="UTF-8"
    omit-xml-declaration="yes" />

  <!-- Root template matching book -->
  <xsl:template match="book">
    <html>
      <head>
        <xsl:element name="title">
          <xsl:value-of select="metadata/title"/>
        </xsl:element>
        <!-- Load Typekit Font -->
        <script src="https://use.typekit.net/qcp8nid.js"></script>
        <script>try{Typekit.load();}catch(e){}</script>
        <!-- Paged Media Styles -->
        <link rel="stylesheet" href="css/pm-style.css" />
        <!--
          Load Paged Media definitions just so I won't forget it again
        -->
        <link rel="stylesheet" href="css/paged-media.css"/>
        <!--
              Use highlight.js and docco style
        -->
        <link rel="stylesheet" href="css/styles/docco.css" />
        <!-- Load highlight.js -->
        <script src="lib/highlight.pack.js"></script>
        <script>
          hljs.initHighlightingOnLoad();
        </script>
        <!-- <script src="js/script.js"></script> -->
      </head>
      <body>
        <xsl:attribute name="data-type">book</xsl:attribute>
          <xsl:element name="meta">
            <xsl:attribute name="generator">
              <xsl:value-of select="system-property('xsl:product-name')"/>
              <xsl:value-of select="system-property('xsl:product-version')"/>
            </xsl:attribute>
          </xsl:element>
        <xsl:apply-templates/>
        <!-- <xsl:apply-templates select="book" mode="toc"/> -->
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
        (p class="rh")
      * Rework the metadata template so it'll match the spec on the CSS

    All other templates remain unchanged and are used from the base stylesheet.

    Only the templates defined in this stilesheet are overriden or created.
  -->
  <xsl:template match="book/section">
    <section>
      <xsl:choose>
        <xsl:when test="@type">
          <xsl:attribute name="data-type">
            <xsl:value-of select="@type"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">
            Type attribute is required for paged media
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="(@class)">
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="(@id)">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:element name="a">
        <xsl:attribute name="name">
          <xsl:value-of select="concat('ch', position())"/>
        </xsl:attribute>
      </xsl:element>
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
  <xsl:template match="book" mode="toc">
    <xsl:variable name="fileName" select="concat('#', (@type), (position()-1))"/>
    <section data-type="toc">
      <h2>Table of Contents</h2>
      <nav>
        <ol>
          <li><a href="${filename}"><xsl:value-of select="section/title"/></a>
          </li>
        </ol>
      </nav>
    </section>
  </xsl:template>
  <!--
    <xsl:template match="h1">
    <xsl:element name="h1">
      <xsl:if test="@align">
        <xsl:attribute name="align">
          <xsl:value-of select="@align"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="(@class)">
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="(@id)">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:element name="a">
        <xsl:attribute name="name">
          <xsl:value-of select="concat('ch', position())"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>
  -->
</xsl:stylesheet>
