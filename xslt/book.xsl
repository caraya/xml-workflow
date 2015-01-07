<?xml version="1.0"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="/hello-world">
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
</xsl:stylesheet>
