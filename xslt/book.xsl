<?xml version="1.0" ?>
<!-- Define stylesheet root and namespaces we'll work with -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xml:lang="en-US"
  version="2.0">
  <!-- Strip whitespace from the listed elements -->
  <xsl:preserve-space elements="code"/>
  <xsl:strip-space elements="*"/>
  <!-- Define the output for this and all document children -->
  <xsl:output name="xhtml-out" method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" />
  <!-- Root template, matching / -->
  <xsl:template match="/" priority="1">
    <html>
    <head>
      <xsl:element name="title">
        <xsl:value-of select="book/metadata/title"/>
      </xsl:element>
      <link href='http://fonts.googleapis.com/css?family=Roboto:400,300,300italic,700,700italic' rel='stylesheet' type='text/css'/>
      <link href='http://fonts.googleapis.com/css?family=Roboto+Slab' rel='stylesheet' type='text/css'/>
      <link href='http://fonts.googleapis.com/css?family=Source+Code+Pro' rel='stylesheet' type='text/css'/>
      <link rel="stylesheet" href="../css/style.css" />
      <xsl:if test="(code)">
        <!--
              Use highlight.js and github style
            -->
        <link rel="stylesheet" href="../css/styles/railscasts.css" />
        <!-- Load highlight.js -->
        <script src="../js/highlight.pack.js"></script>
        <script>
          hljs.initHighlightingOnLoad();
        </script>
      </xsl:if>
      <!--
        Comment this out for now. It'll become relevant when we add video
        <script src="../js/script.js"></script>
      -->
    </head>

    <body>
      <xsl:apply-templates/>
      <xsl:apply-templates mode="toc"/>
    </body>
    </html>
  </xsl:template>

  <xsl:template match="book" mode="toc">
    <div class="toc">
      <h2>Table of Contents</h2>
      <ol>
        <xsl:for-each select="section">
          <xsl:element name="li">
            <xsl:element name="a">
              <xsl:attribute name="href">
                <xsl:value-of select="concat((@type), position(),'.html')"/>
              </xsl:attribute>
              <xsl:value-of select="title"/>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
      </ol>
    </div>
  </xsl:template>
  <!-- Metadata element and children -->
  <xsl:template match="metadata">
    <div class="metadata">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="isbn">
    <p>ISBN: <xsl:value-of select="."/></p>
  </xsl:template>

  <xsl:template match="edition">
    <p class="no-margin-left">Edition: <xsl:value-of select="."/></p>
  </xsl:template>

  <!-- Headings -->
  <!--
    Note that the headings use mostly the same code.

    We could have coded them with just one template but that would have made it
    harder to style with CSS.

    Our goal is to create as simple a markup as we can so we can better leverage
    CSS to style and make our content display as intended
  -->
  <xsl:template match="h1 | title | section/title">
    <!--
      We want to treat the title of the book and each section's title the
      same as our h1 headings. We do this by matching all on the same template.

      If we need to style the titles differently we can create a separate
      template to match it to
    -->
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
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h2">
    <xsl:element name="h2">
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
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h3">
    <xsl:element name="h3">
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
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h4">
    <xsl:element name="h4">
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
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h5">
    <xsl:element name="h5">
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
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h6">
    <xsl:element name="h6">
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
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <!-- Section and children -->
  <xsl:template match="book/section">
    <!-- Variable to create section file names -->
    <xsl:variable name="fileName" select="concat((@type), (position()-1),'.html')"/>
    <!-- An example result of the variable above would be introduction1.xhtml -->
    <xsl:result-document href='{$fileName}' format="xhtml-out">
      <html>
        <head>
          <link href='http://fonts.googleapis.com/css?family=Roboto:400,300,300italic,700,700italic' rel='stylesheet' type='text/css'/>
          <link href='http://fonts.googleapis.com/css?family=Roboto+Slab' rel='stylesheet' type='text/css'/>
          <link href='http://fonts.googleapis.com/css?family=Source+Code+Pro' rel='stylesheet' type='text/css'/>
          <link rel="stylesheet" href="../css/style.css" />
          <xsl:if test="(code)">
            <!--
              Use highlight.js and github style
            -->
            <link rel="stylesheet" href="../css/styles/railscasts.css" />
            <!-- Load highlight.js -->
            <script src="../js/highlight.pack.js"></script>
            <script>
              hljs.initHighlightingOnLoad();
            </script>
            </xsl:if>
          <!--
            Comment this out for now. It'll become relevant when we add video
            <script src="../js/script.js"></script>
          -->
        </head>
        <body>
          <section>
            <xsl:if test="@type">
              <xsl:attribute name="data-type">
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
          <xsl:text> </xsl:text>
          <xsl:value-of select="concat('- ', type, ' ', 'editor')"></xsl:value-of>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="metadata/otherRoles">
    <h2>Production team</h2>
    <ul class="no-bullet">
      <xsl:for-each select="otherRole">
        <li>
          <xsl:value-of select="first-name" />
          <xsl:text> </xsl:text>
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

  <xsl:template match="figure">
    <xsl:number level="any"/>
  </xsl:template>
</xsl:stylesheet>
