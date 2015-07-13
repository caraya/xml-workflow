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

