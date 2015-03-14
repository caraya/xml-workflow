<?xml version="1.0" ?>
<!--
  Define stylesheet root and namespaces we'll work with
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:epub="http://www.idpf.org/2007/opf"
  xml:lang="en-US"
  version="2.0">
  <!-- Define the output for this and all document children -->
  <xsl:output name="xhtml-out" method="xhtml" indent="no" encoding="UTF-8" omit-xml-declaration="yes" />
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="pre code"/>
  <!--
    Default template taken from http://bit.ly/1sXqIL8

    This will tell us of any unmatched elements rather than
    failing silently
  -->
  <xsl:template match="*">
    <xsl:message terminate="no">
      WARNING: Unmatched element: <xsl:value-of select="name()"/>
    </xsl:message>

    <xsl:apply-templates/>
  </xsl:template>

  <!-- Root template, matching / -->
  <xsl:template match="book">
    <html class="no-js" lang="en">
    <head>
      <meta charset="utf-8"/>
      <xsl:element name="title">
        <xsl:value-of select="metadata/title"/>
      </xsl:element>
      <xsl:element name="meta">
        <xsl:attribute name="generator">
          <xsl:value-of select="system-property('xsl:product-name')"/>
          <xsl:value-of select="system-property('xsl:product-version')"/>
        </xsl:attribute>
      </xsl:element>
      <!-- Load Normalize library -->
      <link rel="stylesheet" href="css/normalize.css"/>
      <link rel="stylesheet" href="css/style.css" />
      <xsl:if test="code">
        <script src="js/object-key-polyfill.js"/>
        <script src="lib/highlight.pack.js"/>
        <script>
          hljs.initHighlighting();
        </script>
      </xsl:if>
    </head>
    <body>
      <xsl:apply-templates select="/" mode="toc"/>
      <xsl:apply-templates/>
    </body>
    </html>
  </xsl:template>

  <xsl:template match="/" mode="toc">
    <xsl:result-document href='toc.xhtml' format="xhtml-out">
      <html>
        <head>
          <link rel="stylesheet" href="css/style.css" />
          <!-- Load Normalize library -->
          <link rel="stylesheet" href="css/normalize.css"/>
        </head>
        <body>
          <section data-type="toc">
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
    <xsl:element name="section">
      <xsl:attribute name="data-type">titlepage</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- Section -->
  <xsl:template match="section">
    <!-- Variable to create section file names -->
    <xsl:variable name="fileName" select="concat(@type, (position()-1),'.html')"/>
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

  <!-- Metadata Children-->
  <xsl:template match="isbn">
    <p>ISBN: <xsl:value-of select="."/></p>
  </xsl:template>

  <xsl:template match="edition">
    <p>Edition: <xsl:value-of select="."/></p>
  </xsl:template>

  <!-- PEOPLE GROUPS -->
  <xsl:template match="authors">
      <xsl:for-each select="author">
        <h2 class="author">
          <xsl:value-of select="first-name"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="surname"/>
        </h2>
      </xsl:for-each>

  </xsl:template>

  <xsl:template match="editors">
    <h2>Editorial Team</h2>
    <ul class="no-bullet">
      <xsl:for-each select="editor">
        <li>
          <xsl:value-of select="first-name"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="surname"/>
          <xsl:value-of select="concat(' - ', type, ' ', 'editor')"/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="otherRoles">
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

  <xsl:template match="publisher">
    <xsl:element name="div">
      <xsl:choose>
        <xsl:when test="string(@class)">
          <xsl:attribute name="class" select="@class"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class" select="'publisher'"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="string(@id)">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
        <xsl:value-of select="name"/>
        <xsl:apply-templates select="address"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="address">
    <xsl:element name="div">
      <xsl:choose>
        <xsl:when test="string(@class)">
          <xsl:attribute name="class" select="@class"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class" select="'address'"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:element name="p"><xsl:value-of select="recipient"/></xsl:element>
      <xsl:element name="p"><xsl:value-of select="street"/></xsl:element>
      <xsl:element name="p"><xsl:value-of select="city"/></xsl:element>
      <xsl:element name="p"><xsl:value-of select="state"/></xsl:element>
      <xsl:element name="p"><xsl:value-of select="postcode"/></xsl:element>
      <xsl:element name="p"><xsl:value-of select="country"/></xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="releaseinfo | copyright | legalnotice | pubdate | abstract">
    <xsl:element name="div">
      <xsl:choose>
        <xsl:when test="string(@class)">
          <xsl:attribute name="class" select="@class"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class" select="name()"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="revhistory">
    <xsl:element name="div">
      <xsl:choose>
        <xsl:when test="string(@class)">
          <xsl:attribute name="class" select="@class"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class" select="'revhistory'"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="revision"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="revision">
    <xsl:element name="div">
      <xsl:attribute name="class" select="'revision'"/>
      <p><xsl:value-of select="revnumber"/></p>
      <p><xsl:value-of select="pubdate"/></p>
      <p><xsl:value-of select="authorinitials"/></p>
      <p><xsl:value-of select="revnotes"/></p>
    </xsl:element>
  </xsl:template>


  <!-- Headings -->
  <!--
    Note that the headings use mostly the same code.

    THe goal is to create as simple a markup as we can so we can better leverage
    CSS to style and make our content display as intended

    We want to treat the title of each section the same as our h1 headings. We do
    this by matching all on the same template.

    If we need to style the titles differently we can create a separate
    template to match it to
  -->
  <xsl:template match="title ">
    <xsl:element name="h1">
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
      <xsl:if test="string(@id)">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h1">
    <xsl:element name="h1">
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
      <xsl:if test="string(@id)">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
        <xsl:value-of select="."/>
    </xsl:element> <!-- closes h1 -->
  </xsl:template>

  <xsl:template match="h2">
    <xsl:element name="h2">
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
      <xsl:if test="string(@id)">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h3">
    <xsl:element name="h3">
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
      <xsl:if test="string(@id)">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h4">
    <xsl:element name="h4">
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
      <xsl:if test="string(@id)">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h5">
    <xsl:element name="h5">
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
      <xsl:if test="string(@id)">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h6">
    <xsl:element name="h6">
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
      <xsl:if test="string(@id)">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <!-- BLOCKQUOTES, QUOTES AND ASIDES -->
  <!-- BLOCKQUOTE-->
  <xsl:template match="blockquote">
    <xsl:element name="blockquote">
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
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>

  <!-- BLOCKQUOTE ATTRIBUTION-->
  <xsl:template match="attribution">
    <xsl:element name="cite">
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
    </xsl:element>
  </xsl:template>

  <!-- INLINE QUOTATION -->
  <xsl:template match="quote">
    <q><xsl:value-of select="."/></q>
  </xsl:template>

  <!-- ASIDE ELEMENT -->
  <xsl:template match="aside">
    <aside>
      <xsl:if test="string(@align)">
        <xsl:attribute name="data-type">
          <xsl:value-of select="@align"/>
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
    </aside>
  </xsl:template>

  <!-- DIV ELEMENT -->
  <xsl:template match="div">
    <xsl:element name="div">
      <xsl:if test="string(@align)">
        <xsl:attribute name="data-type">
          <xsl:value-of select="@align"/>
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
    </xsl:element>
  </xsl:template>

  <!-- SPAN ELEMENT-->
  <xsl:template match="span">
    <xsl:element name="span">
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
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <!-- VIDEO AND TRACKS -->
  <xsl:template match="video">
    <xsl:element name='video'>
      <!-- Poster, Height and Width are required -->
      <xsl:attribute name="height" select="@height"/>
      <xsl:attribute name="width" select="@width"/>
      <!-- All other attributes are optional -->
      <xsl:if test="string(@poster)">
        <xsl:attribute name="poster" select="@poster"/>
      </xsl:if>
      <xsl:if test="string(@src)">
        <xsl:attribute name="src" select="@src"/>
      </xsl:if>
      <xsl:if test="string(@controls)">
        <xsl:attribute name="controls">controls</xsl:attribute>
      </xsl:if>
      <xsl:if test="string(@autoplay)">
        <xsl:attribute name="controls">controls</xsl:attribute>
      </xsl:if>
      <xsl:if test="string(@preload)">
        <xsl:attribute name="preload">preload</xsl:attribute>
      </xsl:if>
      <xsl:if test="string(@loop)">
        <xsl:attribute name="poster">loop</xsl:attribute>
      </xsl:if>
      <xsl:if test="string(@looped)">
        <xsl:attribute name="looped">looped</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="source">
    <xsl:element name="source">
      <xsl:attribute name="src">
        <xsl:value-of select="@src"/>
      </xsl:attribute>
      <xsl:if test="string(@type)">
        <xsl:attribute name="type" select="@type"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="track">
    <xsl:element name="track">
      <xsl:attribute name="src">
        <xsl:value-of select="@src"/>
      </xsl:attribute>
      <xsl:attribute name="label">
        <xsl:value-of select="@label"/>
      </xsl:attribute>
      <xsl:if test="string(@kind)">
        <xsl:attribute name="kind" select="@kind"/>
      </xsl:if>
      <xsl:if test="string(@srclang)">
        <xsl:attribute name="srclang" select="@srclang"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <!-- PARAGRAPHS -->
  <xsl:template match="para">
    <xsl:element name="p">
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
    </xsl:element>
  </xsl:template>

  <!-- STYLES -->
  <xsl:template match="strong">
    <strong><xsl:apply-templates /></strong>
  </xsl:template>

  <xsl:template match="emphasis">
    <em><xsl:apply-templates/></em>
  </xsl:template>

  <xsl:template match="strike">
    <strike><xsl:apply-templates/></strike>
  </xsl:template>

  <xsl:template match="underline">
    <u><xsl:apply-templates/></u>
  </xsl:template>

  <!-- LINKS AND ANCHORS -->
  <xsl:template match="link">
      <xsl:element name="a">
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
        <xsl:attribute name="href">
          <xsl:value-of select="@href"/>
        </xsl:attribute>
        <xsl:attribute name="label">
          <xsl:value-of select="@label"/>
        </xsl:attribute>
        <xsl:value-of select="@label"/>
      </xsl:element>
  </xsl:template>

  <!--
    The anchor element has been removed as unnecessary
  -->

  <!-- FENCED CODE FRAGMENTS -->
  <!--
    Until we get highlight.js working we're wrapping code blocks
    on a div with class = code.

    When highlight.js works we can remove the exta wrapper
  -->
  <xsl:template match="code">
     <pre>
       <code>
        <xsl:attribute name="class">
          <xsl:value-of select="concat(@language, ' ', 'hljs')"/>
        </xsl:attribute>
        <xsl:value-of select="."/>
     </code>
   </pre>
 </xsl:template>

  <!-- LIST AND LIST ITEMS -->
  <xsl:template match="ulist">
    <xsl:element name="ul">
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
    </xsl:element>
  </xsl:template>

  <xsl:template match="olist">
    <xsl:element name="ol">
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
    </xsl:element>
  </xsl:template>

  <xsl:template match="item">
    <xsl:element name="li">
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
    </xsl:element>
  </xsl:template>

  <!-- FIGURES -->
  <!--
    Note that according to spec you can also use figure to create code blocks,
    that we create with the code tag.

    We may create conditional branches to match the spec but I don't think
    it's really useful as we already have something that performs that task
  -->
  <xsl:template match="figure">
    <xsl:element name="figure">
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
      <!--
        If the width of the figure is smaller than the width of the containing image
        we may have display problems.

        If the width of the containging figure is smaller than the width of the image,
        make the figure width equal to the width of hthe image, otherwise use the width
        of the figure element
      -->
      <xsl:choose>
        <xsl:when test="(string(@width) and (@width gt image/@width))">
          <xsl:attribute name="width">
            <xsl:value-of select="concat(@width, 'px')"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="width">
            <xsl:value-of select="concat(image/@width, 'px')"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <!--
        If the height of the figure is smaller than the height of the containing image
        we may have display problems.

        If the height of the containging figure is smaller than the height of the image,
        make the figure height equal to the height of hthe image, otherwise use the height
        of the figure element
      -->
      <xsl:choose>
        <xsl:when test="(string(@height) and (@height gt image/@height))">
          <xsl:attribute name="height">
            <xsl:value-of select="concat(@height, 'px')"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="height">
            <xsl:value-of select="concat(image/@height, 'px')"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <!--
        Alignment can be different. We can have a centered image inside a
        left aligned figure
      -->
      <xsl:if test="string(@align)">
        <xsl:attribute name="align">
          <xsl:value-of select="@align"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="image"/>
      <xsl:apply-templates select="figcaption"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="figcaption">
    <figcaption><xsl:apply-templates/></figcaption>
  </xsl:template>

  <xsl:template match="image">
    <xsl:element name="img">
      <xsl:attribute name="src">
        <xsl:value-of select="@src"/>
      </xsl:attribute>
      <xsl:attribute name="alt">
        <xsl:value-of select="@alt"/>
      </xsl:attribute>
      <xsl:if test="string(@width)">
        <xsl:attribute name="width">
          <xsl:value-of select="concat(@width, 'px')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="string(@height)">
        <xsl:attribute name="height">
          <xsl:value-of select="concat(@height, 'px')"/>
        </xsl:attribute>
      </xsl:if>
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
      <xsl:if test="string(@id)">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
