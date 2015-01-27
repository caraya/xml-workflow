---
title: Converting our content to HTML
date: 2015-01-13
category: Technology
status: draft
---

# Converting our content to HTML

One of the biggest advantages of working with XML is that we can convert the abstract tags into other markups. For the purposes of this project we'll convert the XML created to match the schema we just created to HTML and then use tools like [PrinceXML](http://www.princexml.com) or [AntenaHouse](http://www.antennahouse.com) we'll convert the HTML/CSS files to PDF

## Why HTML

HTML is the default format for the web and for most web/html based content such as ePub and Kindle. As such it makes a perfect candidate to explore how to generate it programatically from a single source file. 

HTML will also act as our source for using CSS paged media to create PDF cotnent.

## Why PDF

Rather than having to deal with [XSL-FO](http://www.w3.org/TR/2006/REC-xsl11-20061205/), another XML based vocabulary to create PDF content, we'll use XSLT to create another HTML file and process it with [CSS Paged Media](http://dev.w3.org/csswg/css-page-3/) and the companion [Generated Content for Paged Media](http://www.w3.org/TR/css-gcpm-3/) specifications to create PDF content. 

In this document we'll concentrate on the XSLT to HTML conversion and will defer the conversion from HTML to PDF to a later article.

# Creating our conversion stylesheets

To convert our XML into other formats we will use XSL Transformations (also known as XSLT) [version 2](http://www.w3.org/TR/xslt) (a W3C standard) and [version 3](http://www.w3.org/TR/xslt-30/) (a W3C last call draft recommendation) where appropriate.

XSLT is a functional language designed to transform XML into other markup vocabularies. It defines template rules that match elements in your source document and processing them to convert them to the target vocabulary. 

In the XSLT example below, we do the following:

1. Declare the file to be an XML document
2. Define the root element of the stylesheet (xsl:stylesheet)
3. Indicate the namespaces that we'll use in the document and, in this case, tell the processor to excluse the given namespaces
4. Strip whitespaces from all elements and preserve it in the code elements
5. Create the default output we'll use for the main document and all generated pages (discussed later)
6. Create a default template to warn us if we missed anything

```xml
<?xml version="1.0" ?>
<!-- Define stylesheet root and namespaces we'll work with -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:epub="http://www.idpf.org/2007/opf"
  exclude-result-prefixes="dc epub"
  xml:lang="en-US"
  version="2.0">
  <!-- Strip whitespace from the listed elements -->
  <xsl:strip-space elements="*"/>
  <!-- And preserve it from the elements below -->
  <xsl:preserve-space elements="code"/>
  <!-- Define the output for this and all document children -->
  <xsl:output name="xhtml-out" method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" />

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
  
  <!-- More content to be added -->
</xsl:stylesheet>
```

This is a lot of work before we start creating our XSLT content. But it's worth doing the work up front. We'll see what are the advantages of doint it this way as we move down the style sheet.

Now onto our root templates. The first one is the entry point to our document. It performs the following tasks:

1. Match the root element to create the skeleton for our HTML content
2. In the title we insert the content of the `metadata/title` element
3. In the body we 'apply' the templates that match the content inside our document (more on this later)

```xml
  <!-- Root template, matching / -->
  <xsl:template match="book">
    <html>
    <head>
      <xsl:element name="title">
        <xsl:value-of select="metadata/title"/>
      </xsl:element>
      <xsl:element name="meta">
        <xsl:attribute name="generator">
          <xsl:value-of select="system-property('xsl:product-name')"/>
          <xsl:value-of select="system-property('xsl:product-version')"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:element name="meta">
        <xsl:attribute name="vendor">
          <xsl:value-of select="system-property('xsl:vendor-url')" />
        </xsl:attribute>
      </xsl:element>
      <xsl:element name="meta">
        <xsl:attribute name="vendor-URL">
          <xsl:value-of select="system-property('xsl:vendor-url')" />
        </xsl:attribute>
      </xsl:element>
      <link rel="stylesheet" href="css/style.css" />
      <xsl:if test="(code)">
        <!--
              Use highlight.js and docco style
            -->
        <link rel="stylesheet" href="css/styles/docco.css" />
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
      <xsl:apply-templates/>
      <xsl:apply-templates select="/" mode="toc"/>
    </body>
    </html>
  </xsl:template>
```
We could build the CSS stylesheet and Javascript files as part of our root template but we chose not to.. 

Working with the stylesheet as part of the XSLT stylesheet allows the XSLT stylesheet designer to embed the style and parameterize the stylesheet, thus making the stylesheet customizable from the command line. 

For all advantages, this method ties the styles for the project to the XSLT stylesheet and requires the XSLT stylesheet designer to be involved in all CSS and Javascript updates. 

By linking to external CSS and Javascript files we can leverage expertise independent of the Schema and XSLT stylesheets. Book designers can work on the CSS, UX and experience designers can work on Javascript and additional CSS areas, book designers can work on the Paged Media stylesheets and authors can just write.

Furthermore we can reuse our CSS and Javascript on multiple documents.

There is a second template matching the root element of our document to create a table of content. At first thought this looks like the wrong approach 


We leverage XSLT modes that allow us to create templates for the same element to perform different tasks. In `toc mode` we want the root template to do the following:

1. Create the section and nav and ol elements
2. Add the title for the table of contents
2. For each section element that is a child of root create these elements
    1. The `li` element
    2. The a element with the corresponding href element
    3. The value of the href element (a concatenation of the section's type attribute, the position within the document and the .html string)
    4. The title of the section as the 'clickable' portion of the link

```xml
<xsl:template match="/" mode="toc">
  <section data-type="toc"> (1)
    <nav class="toc"> (1)
      <h2>Table of Contents</h2>
      <ol>
        <xsl:for-each select="book/section">
          <xsl:element name="li"> (3.1)
            <xsl:element name="a"> (3.2)
              <xsl:attribute name="href"> (3.2)
                <xsl:value-of select="concat((@type), position(),'.html')"/> (3.3)
              </xsl:attribute>
              <xsl:value-of select="title"/> (3.4)
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
      </ol>
    </nav>
  </section>
</xsl:template>
```

With these templates in place we can now 

We will being with the major areas of the document, `metadata` and `section`. The metadata is a container for all the elements inside. As such we just create the div that will hold the content and call `xsl:apply-templates` to process the children inside the metadata element.



```xml

  <!-- Metadata -->
  <xsl:template match="metadata">
    <xsl:element name="div">
      <xsl:attribute name="class">metadata</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- Section -->
  <xsl:template match="section">
    <!-- Variable to create section file names -->
    <xsl:variable name="fileName" select="concat((@type), (position()-1),'.html')"/>
    <!-- An example result of the variable above would be introduction1.xhtml -->
    <xsl:result-document href='{$fileName}' format="xhtml-out">
      <html>
        <head>
          <link rel="stylesheet" href="css/style.css" />
          <xsl:if test="(code)">
            <!--
              Use highlight.js and github style
            -->
            <link rel="stylesheet" href="css/styles/docco.css" />
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
  
  <!-- Metadata Children-->
  <xsl:template match="isbn">
    <p>ISBN: <xsl:value-of select="."/></p>
  </xsl:template>

  <xsl:template match="edition">
    <p class="no-margin-left">Edition: <xsl:value-of select="."/></p>
  </xsl:template>

  <!-- PEOPLE GROUPS -->
  <xsl:template match="metadata/authors">
    <h2>Authors</h2>
    <ul>
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
          <xsl:value-of select="concat(' - ', type, ' ', 'editor')"></xsl:value-of>
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

  <!-- Create Table of Contents ... work in progress -->
  <xsl:template match="book" mode="toc">
    <xsl:variable name="fileName" select="concat('#', (@type), (position()-1))"/>
    <section data-type="toc">
      <h2>Table of Contents</h2>
      <nav>
        <ol>
          <xsl:for-each select="section">
            <li>
              <a href="${filename}"><xsl:value-of select="title"/></a>
            </li>
          </xsl:for-each>
        </ol>
      </nav>
    </section>
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
  
  <!-- BLOCKQUOTES, QUOTES AND ASIDES -->
  <!-- BLOCKQUOTE-->
  <xsl:template match="blockquote">
    <xsl:element name="blockquote">
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
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>
  
  <!-- BLOCKQUOTE ATTRIBUTION-->
  <xsl:template match="attribution">
    <xsl:element name="cite">
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
  
  <!-- INLINE QUOTATION -->
  <xsl:template match="quote">
    <q><xsl:value-of select="."/></q>
  </xsl:template>

  <!-- ASIDE ELEMENT -->
  <xsl:template match="aside">
    <aside>
      <xsl:if test="type">
        <xsl:attribute name="data-type">
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
      <xsl:apply-templates/>
    </aside>
  </xsl:template>

  <!-- DIV ELEMENT -->
  <xsl:template match="div">
    <xsl:element name="div">
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
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- SPAN ELEMENT-->
  <xsl:template match="span">
    <xsl:element name="span">
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
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <!-- PARAGRAPHS -->
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
        </xsl:attribute>
        <xsl:value-of select="@label"/>
      </xsl:element>
  </xsl:template>

  <xsl:template match="anchor">
    <!--
    Not sure if I want to make this an empty element or not

    Empty element <anchor name="home"/> appeals to my ease
    of use paradigm but it may not be as easy to understand
    for peope who are not familiar with XML empty elements
  -->
    <xsl:element name="a">
      <xsl:attribute name="name">
        <xsl:apply-templates/>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <!-- FENCED CODE FRAGMENTS -->
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

  <!-- LIST AND LIST ITEMS -->
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

  <!-- FIGURES -->
  <xsl:template match="figure">
    <xsl:element name="figure">
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
      <!-- 
        If the width of the figure is smaller than the width of the containing image 
        we may have display problems. 
        
        If the width of the containging figure is smaller than the width of the image, 
        make the figure width equal to the width of hthe image, otherwise use the width
        of the figure element
      -->
      <xsl:choose>
        <xsl:when test="@width lt image/@width">
          <xsl:attribute name="width">
            <xsl:value-of select="@width"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="width">
            <xsl:value-of select="image/@width"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <!-- 
        We don't care about height as much as we do width, the caption 
        and image are contained inside the figure. 
        
        We only test if it exists. It's up to the author to make sure
        there are no conflicts
      -->
      <xsl:if test="(@height)">
        <xsl:attribute name="height">
          <xsl:value-of select="@height"/>
        </xsl:attribute>
      </xsl:if>
      <!-- 
        Alignment can be different. We can have a centered image inside a 
        left aligned figure
      -->
      <xsl:if test="(@align)">
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
```
