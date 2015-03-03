<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/xhtml"
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

  exclude-result-prefixes="#all"
  version="2.0">
  <!-- Waiting to see what namespaces we need to remove -->
  <!-- First import the base stylesheet -->
  <xsl:import href="book.xsl"/>

  <!-- Define the output children document -->
  <xsl:output name="xhtml-out" method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>

  <!-- Define text output for text files -->
  <xsl:output name="text-out" method="text" media-type="application/epub+zip" indent='no' />

  <!-- Define XML output for XML docs other than xhtml -->
  <xsl:output name="xml-out" method="xml" indent="yes" omit-xml-declaration="no" />

  <!-- VARIABLES-->

  <!-- XHTML FILE EXTENSION -->
  <xsl:variable name="html.ext" select="'.xhtml'"/>
  <!-- XHTML OUTPUT DIRECTORY -->
  <xsl:variable name="epub.oebps.dir" select="'OEBPS'"/>
  <xsl:param name="epub.version">3.0</xsl:param>
  <!-- INCLUDE NCX IN PACKAGE FOR BACKWARDS COMPATIBILITY? -->
  <xsl:param name="epub.include.ncx" select="0"/>
  <!-- NAME OF PACKAGE.OPF File -->
  <xsl:param name="epub.package.filename" select="'package.opf'"/>
  <xsl:param name="epub.full.package.path" select="concat($epub.oebps.dir, $epub.package.filename)" />
  <xsl:param name="epub.cover.filename" select="concat('cover', '.xhtml')"/>
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
    <xsl:result-document href='cover.xhtml' format="xhtml-out">
      <xsl:message terminate="yes">
        <xsl:text>Generate cover template is not complete. eBook will not pass validation</xsl:text>
      </xsl:message>
    </xsl:result-document>
  </xsl:template>

  <!-- When called this will generate the mimetype file. I hope in the right format :-) -->
  <xsl:template name="generate.mime">
    <xsl:result-document href='concat("$oebps.package.dir", "$epub.oebps.dir", "mimetype")' format="text-out">
      <xsl:text>application/epub+zip</xsl:text>
    </xsl:result-document>
  </xsl:template>

  <!-- When called this will generate the container.xml and the containing directory -->
  <xsl:template name="generate.meta-inf">
    <xsl:result-document href="META-INF/container.xml" format="xml-out">
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

  <!-- USE THE MODEL ABOVE TO CREATE THE OTHER FILES IN THE META-INF DIRECTORY IF NEEDED-->

  <xsl:template name="generate.package.opf">
    <xsl:result-document href="$epub.full.package.path">
      <xsl:element name="package" xml:lang="en" namespace="http://www.idpf.org/2007/opf">
        <xsl:attribute name="version" select="3.0"/>
        <xsl:attribute name="unique-identifier" select="$epub.dc.identifier.id"/>

        <xsl:element name="metadata">

          <xsl:element name="dc:identifier">
            <xsl:attribute name='id'>
              <xsl:value-of select="$epub.dc.identifier.id"/>
            </xsl:attribute>
            <xsl:value-of select="isbn"/>
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
              <xsl:value-of select="concat(author/first-name, author/surname)"/>
            </xsl:element>
          </xsl:for-each>

          <xsl:for-each select="editors | otherRoles">
            <xsl:element name="dc:collaborator">
              <xsl:value-of select="concat(first-name, surname)"/>
            </xsl:element>
          </xsl:for-each>
        </xsl:element>

        <manifet>
          <xsl:for-each select="file:list('../content/OEBPS', recursive='true')">
            <item>
              <xsl:attribute name="href" select="."/>
            </item>
          </xsl:for-each>
          <xsl:choose>
            <!-- If the file ends with .html or .xhtml we treat it as xhtml -->
            <xsl:when test="ends-with(item/@href,'.xhtml') or ends-with(item/@href,'.html')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'application/xhtml+xml'"/>
            </xsl:when>

            <!-- CSS style sheets -->
            <xsl:when test="ends-with(item/@href,'.css') or ends-with(item/@href,'.CSS')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'text/css'"/>
            </xsl:when>

            <!-- JavaScript files-->
            <xsl:when test="ends-with(item/@href,'.js') or ends-with(item/@href,'.JS')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'text/javascript'"/>
            </xsl:when>

            <!-- Images -->
            <xsl:when test="ends-with(item/@href,'.jpg') or ends-with(item/@href,'.JPG')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'image/jpeg'"/>
            </xsl:when>
            <xsl:when test="ends-with(item/@href,'.png') or ends-with(item/@href,'.PNG')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'image/png'"/>
            </xsl:when>
            <xsl:when test="ends-with(item/@href, '.gif') or ends-with(item/@href, '.GIF')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'image/gif'"/>
            </xsl:when>
            <!-- SVG is considered an image type for epub-->
            <xsl:when test="ends-with(item/@href,'.svg') or ends-with(item/@href, '.SVG')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'image/svg+xml'"/>
            </xsl:when>

            <!-- NCX -->
            <xsl:when test="ends-with(item/@href,'.ncx')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'application/x-dtbncx+xml'"/>
            </xsl:when>

            <!-- SMIL -->
            <xsl:when test="ends-with(item/@href, '.smil')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'application/smil+xml'"/>
            </xsl:when>

            <!-- PLS -->
            <xsl:when test="ends-with(item/@href, '.pls')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'application/pls+xml'"/>
            </xsl:when>

            <!-- FONTS -->
            <xsl:when test="ends-with(item/@href, '.woff')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-font-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'application/font-woff'"/>
            </xsl:when>
            <!--
          The official mimetype for otf fonts is application/x-font-otf but the epub spec says otherwise

          Will stick with IDPF's definition for now
        -->
            <xsl:when test="ends-with(item/@href, '.otf')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-font-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'application/vnd.ms-opentype'"/>
            </xsl:when>
            <xsl:when test="ends-with(item/@href, '.otf')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-font-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'application/vnd.ms-opentype'"/>
            </xsl:when>

            <!-- AUDIO FORMATS -->
            <xsl:when test="ends-with(item/@href, '.mp3')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'audio/mpeg'"/>
            </xsl:when>
            <xsl:when test="ends-with(item/@href, '.m4a')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'audio/mp4'"/>
            </xsl:when>

            <!-- VIDEO, MP4 ONLY FOR NOW -->
            <!-- DON'T FORGET THAT IF YOU USE VIDEO YOU MUST USE A POSTER IMAGE -->
            <xsl:when test="ends-with(item/@href,'.mp4') or ends-with(item/@href,'.MP4')
              or ends-with(item/@href,'.m4v') or ends-with(item/@href,'.M4V')">
              <xsl:attribute name="id" select="concat($epub.package.id.prefix, '-', generate-id(.))"/>
              <xsl:attribute name="media-type" select="'video/mp4'"/>
            </xsl:when>

            <xsl:otherwise>
              <xsl:message terminate="yes">
                No matching value for <xsl:value-of select="."/>
                File type either not supported or not yet added to the system
              </xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </manifet>

        <xsl:if test="$epub.include.ncx">
          <spine>
            <xsl:for-each select="manifest/item">
              <xsl:if test="ends-with(self, '.xhtml')">
                <xs:element name="itemref">
                  <xsl:value-of select="@id"/>
                </xs:element>
              </xsl:if>
            </xsl:for-each>
          </spine>
        </xsl:if>
      </xsl:element> <!-- CLOSES PACKAGE DEFINITION -->


    </xsl:result-document>
  </xsl:template>



  <xsl:template match="toc">
    <xsl:result-document href='toc.xhtml' format="xhtml-out">
    <html>
      <head>
        <link rel="stylesheet" href="css/style.css" />
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
                      <xsl:value-of select="concat(@type, position(),'.html')"/>
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

  <!-- Metadata -->
  <xsl:template match="metadata">
    <xsl:call-template name="generate.cover"/>
    <xsl:call-template name="generate.meta-inf"/>
    <xsl:call-template name="generate.mime"/>
    <xsl:call-template name="generate.package.opf"/>

    <xsl:element name="section">
      <xsl:attribute name="epub:type" select="'titlepage'"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- Section -->
  <xsl:template match="section">
    <!-- Variable to create section file names -->
    <xsl:variable name="fileName" select="concat(@type, (position()-1),'.xhtml')"/>
    <!-- An example result of the variable above would be introduction1.xhtml -->
    <xsl:result-document href='{$fileName}' format="xhtml-out">
      <html class="no-js" lang="en">
        <head>
          <meta charset="utf-8"/>
          <link rel="stylesheet" href="css/style.css" />
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
            <xsl:if test="string(@type)">
              <xsl:attribute name="data-type">
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
</xsl:stylesheet>
