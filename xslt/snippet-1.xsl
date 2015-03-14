<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  <xsl:template name="epub.generate.opf.manifest">
    <manifet>
      <xsl:for-each select="file:list('OEBPS', recursive='true')">
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
</xsl:stylesheet>
