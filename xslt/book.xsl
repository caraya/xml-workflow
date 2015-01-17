<?xml version="1.0" ?>
<!-- Define stylesheet root and namespaces we'll work with -->
<xsl:stylesheet
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:epub="http://www.idpf.org/2007/opf"
  xml:lang="en-US"
  version="2.0">
  <!-- Define the output for this and all document children -->
  <xsl:output name="xhtml-out" method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" />
  <!-- Root template, matching / -->
  <xsl:template match="/">
    <html>
    <head>
      <xsl:element name="title">
        <xsl:value-of select="book/metadata/title"/>
      </xsl:element>
      <link rel="stylesheet" href="css/style.css" />
      <!-- Still not sure if we need the scripts fro highlightjs here -->
      <!--
      <script src="http://yastatic.net/highlightjs/8.0/highlight.min.js"></script>
      <script>hljs.initHighlightingOnLoad();</script>
      -->
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


  <xsl:template match="isbn">
    <p>ISBN: <xsl:value-of select="."/></p>
  </xsl:template>

  <xsl:template match="edition">
    <p>Edition: <xsl:value-of select="."/></p>
  </xsl:template>

  <xsl:template match="section">
  <!--
    Each section element will generate its own file

    We create the file name by concatenating the type attribute for the section, the count of how many sections of that type there are and the .xhtml extension
  -->
    <xsl:variable name="fileName"
      select="concat(@type, position(),'.xhtml')"/>
    <!-- An example result of the variable above would be introduction1.xhtml -->
    <xsl:result-document href='{$fileName}' format="xhtml-out">
      <html>
        <head>
          <link rel="stylesheet" href="css/style.css" />
          <xsl:if test="(code)">
            <!--
              We use the github style by default

              Other styles are available in the css/style directory
            -->
            <style src="css/github.css"/>
            <!-- Load highlight.js -->
            <script src="../js/highlight.pack.js"></script>
            <!-- Initialize highlighter -->
            <script>hljs.initHighlightingOnLoad();</script>
          </xsl:if>
          <!-- Load local script -->
          <script src="js/script.js"></script>
        </head>
        <body>
          <section>
            <xsl:if test="@type">
              <xsl:attribute name="data-type">
                <xsl:value-of select="@type"/>
              </xsl:attribute>
              <xsl:attribute name="epub:type">
                <xsl:value-of select="@type"/>
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
            <xsl:apply-templates/>
          </section>
        </body>
      </html>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="metadata/title">
    <h1> <xsl:value-of select="."/> </h1>
  </xsl:template>

  <xsl:template match="metadata/authors">
    <h2>Authors</h2>
    <ul class="no-bullet">
      <xsl:for-each select="author">
        <li>
          <xsl:value-of select="first-name"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="surname"/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="metadata/editors">
    <h2>Editorial Team</h2>
    <ul class="no-bullet">
      <xsl:for-each select="editor">
        <li>
          <xsl:value-of select="first-name"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="surname"/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="metadata/otherRoles">
    <h2>Production team</h2>
    <ul class="no-bullet">
      <xsl:for-each select="otherRoles">
        <li>
          <xsl:value-of select="first-name" />
          <xsl:text>-</xsl:text>
          <xsl:value-of select="surname" />
          <xsl:text> - </xsl:text>
          <xsl:value-of select="role" />
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="para">
    <xsl:element name="p">
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
      <xsl:apply-templates/>
    </xsl:element>
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

  <xsl:template match="link">
      <xsl:element name="a">
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
        <xsl:attribute name="href">
          <xsl:value-of select="@href"/>
        </xsl:attribute>
        <xsl:attribute name="label">
          <xsl:value-of select="@label"/>
        </xsl:attribute>/
        <xsl:value-of select="@label"/>
      </xsl:element>
  </xsl:template>

  <xsl:template match="image">
    <xsl:element name="img">
      <xsl:attribute name="src">
        <xsl:value-of select="@src"/>
      </xsl:attribute>
      <xsl:attribute name="alt">
        <xsl:value-of select="@alt"/>
      </xsl:attribute>
    <xsl:if test="(@width)">
      <xsl:attribute name="width">
        <xsl:value-of select="@width"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="(@height)">
      <xsl:attribute name="height">
        <xsl:value-of select="@height"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="(@align)">
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
    </xsl:element>
  </xsl:template>

  <xsl:template match="code">
    <xsl:element name="pre">
      <xsl:element name="code">
        <xsl:attribute name="class">
          <xsl:value-of select="@language"/>
        </xsl:attribute>
        <xsl:value-of select="."/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="item">
    <xsl:element name="li">
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
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="ulist">
    <xsl:element name="ul">
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
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="olist">
    <xsl:element name="ol">
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
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
