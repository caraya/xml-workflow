<?xml version="1.1" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:pls="http://www.w3.org/2005/01/pronunciation-lexicon"
  xmlns:ssml="http://www.w3.org/2001/10/synthesis"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:file="http://expath.org/ns/file"

exclude-result-prefixes=" xsl xs m pls ssml svg opf ncx file"
  version="2.0">
  <!-- Waiting to see what namespaces we need to remove -->
  <!-- First import the base stylesheet -->
  <xsl:import href="book.xsl"/>

  <!-- Define the output children document -->
  <xsl:output name="xhtml-out"
    method="xhtml"
    indent="yes"
    encoding="UTF-8"
    omit-xml-declaration="yes"
  />

  <!-- Define text output for text files -->
  <xsl:output name="text-out" method="text" media-type="application/epub+zip" indent='no' />

  <!-- Define XML output for XML docs other than xhtml -->
  <xsl:output name="xml-out" method="xml" indent="yes" omit-xml-declaration="no"/>

  <!-- VARIABLES-->

  <!-- XHTML FILE EXTENSION -->
  <xsl:variable name="html.ext" select="'.xhtml'"/>
  <!-- XHTML OUTPUT DIRECTORY -->
  <xsl:variable name="epub.oebps.dir" select="'OEBPS'"/>
  <xsl:param name="epub.version" select="'3.0'"/>
  <!-- INCLUDE NCX IN PACKAGE FOR BACKWARDS COMPATIBILITY? -->
  <xsl:param name="epub.include.ncx" select="0"/>
  <!-- NAME OF PACKAGE.OPF File -->
  <xsl:param name="epub.package.filename" select="'package.opf'"/>
  <xsl:param name="epub.full.package.path" select="concat($epub.oebps.dir, '/', $epub.package.filename)" />
  <xsl:param name="epub.cover.filename" select="'cover.xhtml'"/>
  <!-- names of id attributes used in package files -->
  <xsl:param name="epub.meta.identifier.id">meta-identifier</xsl:param>
  <xsl:param name="epub.dc.identifier.id">pub-identifier</xsl:param>
  <xsl:param name="epub.meta.title.id">meta-title</xsl:param>
  <xsl:param name="epub.dc.title.id">pub-title</xsl:param>
  <xsl:param name="epub.meta.language.id">meta-language</xsl:param>
  <xsl:param name="epub.dc.language.id">pub-language</xsl:param>
  <xsl:param name="epub.meta.creator.id">meta-creator</xsl:param>
  <xsl:param name="epub.dc.creator.id">pub-creator</xsl:param>
  <xsl:param name="epub.ncx.toc.id">ncxtoc</xsl:param>
  <xsl:param name="epub.ncx.manifest.id">ncx</xsl:param>
  <xsl:param name="epub.cover.filename.id" select="'cover'"/>
  <xsl:param name="epub.cover.image.id" select="'cover-image'"/>
  <!-- We add fonts separately as they are optional -->
  <xsl:param name="epub.embedded.fonts"/>
  <!-- prefix generated ids in package elements so they differ from content ids -->
  <xsl:param name="epub.package.id.prefix">id-</xsl:param>
  <!-- editor is either a creator or contributor defined in the schema as otherRole -->
  <xsl:param name="editor.property">contributor</xsl:param>

  <!-- Generate full output path -->
  <xsl:param name="epub.package.dir" select="'../content/'"/>

  <!-- Inserted when a title is blank to avoid epubcheck error -->
  <xsl:param name="toc.entry.default.text">&#xA0;</xsl:param>

  <xsl:template name="generate.cover">
    <xsl:result-document href='OEBPS/cover.xhtml' format="xhtml-out">
      <html class="no-js" lang="en"
        xmlns="http://www.w3.org/1999/xhtml">
        <head>
          <meta charset="utf-8"/>
          <link rel="stylesheet" href="css/epub-styles.css" />
          <!-- Load Normalize library -->
          <link rel="stylesheet" href="css/normalize.css"/>
          <xsl:if test="(code)">
            <!--
              Use highlight.js and github style
            -->
            <link rel="stylesheet" href="css/styles/railscasts.css" />
            <!-- Load highlight.js -->
            <script src="lib/highlight.pack.js"></script>
            <script>
              hljs.initHighlightingOnLoad();
            </script>
          </xsl:if>
          <!--
            Comment this out for now. It'll become relevant when we add video
            <script src="js/script.js"></script>
          -->
        </head>
        <body>
          <section>
            <xsl:attribute name="epub:type" select="'cover'"/>
            <xsl:apply-templates/>
          </section>
        </body>
      </html>
    </xsl:result-document>
  </xsl:template>

  <!-- When called this will generate the mimetype file. I hope in the right format :-) -->
  <xsl:template name="generate.mime">
    <xsl:result-document href="mimetype" format="text-out">
      <xsl:text>application/epub+zip</xsl:text>
    </xsl:result-document>
  </xsl:template>

  <!-- When called this will generate the container.xml and the containing directory -->
  <xsl:template name="generate.meta-inf">
    <xsl:result-document href="../content/META-INF/container.xml" format="xml-out">
      <xsl:element name="container" namespace="urn:oasis:names:tc:opendocument:xmlns:container">
        <xsl:attribute name="version" select="'1.0'"/>
        <xsl:element name="rootfiles">
          <xsl:element name="rootfile">
            <xsl:attribute name="full-path">
              <xsl:value-of select="concat($epub.oebps.dir, 'package.opf')"/>
            </xsl:attribute>
            <xsl:attribute name="media-type">
              <xsl:value-of select="'application/oebps-package+xml'"/>
            </xsl:attribute>
        </xsl:element>
      </xsl:element>
      </xsl:element>
    </xsl:result-document>
  </xsl:template>

  <xsl:template name="epub.generate.opf.spine">
    <spine>
      <xsl:for-each select="manifest/item">
        <xsl:if test="ends-with(self, '.xhtml')">
          <xs:element name="itemref">
            <xsl:value-of select="@id"/>
          </xs:element>
        </xsl:if>
      </xsl:for-each>
    </spine>
  </xsl:template>


  <!-- USE THE MODEL ABOVE TO CREATE THE OTHER FILES IN THE META-INF DIRECTORY IF NEEDED-->

  <xsl:template name="generate.package.opf">
    <xsl:variable name="full.path" select="file:resolve-path('/Users/carlos/code/xml-workflow/content/OEBPS')"/>
    <xsl:variable name="files" select="file:list($full.path)" />
    <xsl:variable name="this" select="."/>

    <xsl:result-document href="OEBPS/package.opf">
      <xsl:element name="package" xml:lang="en" namespace="http://www.idpf.org/2007/opf">
        <xsl:attribute name="version" select="3.0"/>
        <xsl:attribute name="unique-identifier" select="$epub.dc.identifier.id"/>

        <xsl:element name="metadata">

          <xsl:element name="dc:identifier">
            <xsl:attribute name='id'>
              <xsl:value-of select="$epub.dc.identifier.id"/>
            </xsl:attribute>
            <xsl:value-of select="metadata/isbn"/>
          </xsl:element>

          <xsl:element name="dc:title">
            <xsl:attribute name="id">
              <xsl:value-of select="$epub.dc.title.id"/>
            </xsl:attribute>
            <xsl:value-of select="title"/>
          </xsl:element>

          <xsl:element name="dc:language">
            <xsl:attribute name="id" select="$epub.dc.language.id"/>
            <xsl:value-of select="language"/>
          </xsl:element>

          <xsl:element name="dc:date">
            <xsl:value-of select="current-dateTime()"/>
          </xsl:element>

          <xsl:element name="meta">
            <xsl:attribute name="dcterms:modified"/>
            <xsl:value-of select="format-dateTime(current-dateTime(), '[Y]-[M,02]-[D,02]T[H,02]:[m,02][Z]')"/>
          </xsl:element>

          <xsl:for-each select="authors">
            <xsl:element name="dc:creator">
              <xsl:attribute name="id">
                <xsl:value-of select="concat($epub.dc.creator.id, generate-id())"/>
               </xsl:attribute>
              <xsl:value-of select="concat(author/first-name, ' ', author/surname)"/>
            </xsl:element>
          </xsl:for-each>

          <xsl:for-each select="editors | otherRoles">
            <xsl:element name="dc:collaborator">
              <xsl:value-of select="concat(first-name, ' ', surname)"/>
            </xsl:element>
          </xsl:for-each>
        </xsl:element>

        <manifet>
          <xsl:for-each select="file:list($full.path)">
            <item>
              <xsl:attribute name="href" select="."/>
            </item>
          </xsl:for-each>
        </manifet>

        <!-- DO we need to call generate spine from here? -->
        <xsl:call-template name="epub.generate.opf.spine"/>
      </xsl:element>
    </xsl:result-document>
  </xsl:template>

  <xsl:template name="generate.toc">
    <xsl:result-document href='OEBPS/toc.xhtml' format="xhtml-out">
    <html class="no-js" lang="en"
      xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <link rel="stylesheet" href="css/epub-styles.css" />
        <!-- Load Normalize library -->
        <link rel="stylesheet" href="css/normalize.css"/>
      </head>
      <body>
        <section epub:type="toc">
          <h2>Table of Contents</h2>
          <nav>
            <ol>
              <xsl:for-each select="//section">
                <xsl:element name="li">
                  <xsl:element name="a">
                    <xsl:attribute name="href">
                      <xsl:value-of select="concat(@type, position(),'.xhtml')"/>
                    </xsl:attribute>
                    <xsl:value-of select="title"/>
                  </xsl:element>
                </xsl:element>
              </xsl:for-each>
            </ol>
          </nav>
        </section>
      </body>
    </html>
  </xsl:result-document>
  </xsl:template>

  <!-- Section -->
  <xsl:template match="section">
    <!-- Variable to create section file names -->
    <xsl:variable name="fileName" select="concat(@type, position()-2,'.xhtml')"/>
    <!-- An example result of the variable above would be introduction1.xhtml -->
    <xsl:result-document href='OEBPS/{$fileName}' format="xhtml-out">
      <html class="no-js" lang="en"
        xmlns="http://www.w3.org/1999/xhtml">
        <head>
          <meta charset="utf-8"/>
          <link rel="stylesheet" href="css/epub-styles.css"/>
          <!-- Load Normalize library -->
          <link rel="stylesheet" href="css/normalize.css"/>
          <xsl:if test="(code)">
            <!--
              Use highlight.js and github style
            -->
            <link rel="stylesheet" href="css/styles/github.css" />
            <!-- Load highlight.js -->
            <script src="lib/highlight.pack.js"></script>
            <script>
              hljs.initHighlightingOnLoad();
            </script>
          </xsl:if>
          <!--
            Comment this out for now. It'll become relevant when we add video
            <script src="js/script.js"></script>
          -->
        </head>
        <body>
          <section>
            <xsl:if test="string(@type)">
              <xsl:attribute name="epub:type">
                <xsl:value-of select="@type"/>
              </xsl:attribute>
            </xsl:if>
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
            <xsl:apply-templates/>
          </section>
        </body>
      </html>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="toc">
    <!-- We want this template to remain blank so it overrides the toc template in the book stylesheet-->
  </xsl:template>

  <!-- Metadata -->
  <xsl:template match="metadata">
    <xsl:call-template name="generate.mime"/>
    <xsl:call-template name="generate.meta-inf"/>
    <xsl:call-template name="generate.cover"/>
    <xsl:call-template name="generate.toc"/>
    <xsl:call-template name="generate.package.opf"/>

    <xsl:result-document href="OEBPS/titlepage.xhtml">
      <html class="no-js" lang="en">
        <head>
          <link rel="stylesheet" href="css/epub-styles.css"/>
          <!-- Load Normalize library -->
          <link rel="stylesheet" href="css/normalize.css"/>
        </head>
        <body>
          <xsl:element name="section">
            <xsl:attribute name="epub:type" select="'titlepage'"/>
            <xsl:apply-templates/>
          </xsl:element>
        </body>
      </html>
    </xsl:result-document>

  </xsl:template>

</xsl:stylesheet>
