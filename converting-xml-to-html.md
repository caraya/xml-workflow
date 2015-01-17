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

1. match the root element to create the skeleton for our HTML content
2. In the title we insert the content of the `metadata/title` element
3. In the body we 'apply' the templates that match the content inside our document (more on this later)

```xml
<?xml version="1.0" ?>
<!-- Define stylesheet root and namespaces we'll work with -->
<xsl:stylesheet
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xml:lang="en-US"
  version="2.0">

  <xsl:template match="/">
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
```

We could build the CSS stylesheet as part of our root element. 

Working with the stylesheet as part of the XSLT stylesheet allows the XSLT stylesheet designer to embed the style and parameterize the stylesheet, thus making the stylesheet customizable from the command line. 

For all advantages, this method ties the styles for the project to the XSLT stylesheet and requires the XSLT stylesheet designer to be involved in all CSS updates. 

By linking to external CSS and Javascript files we can leverage expertise independent of the Schema and XSLT stylesheets. Book designers can work on the CSS, UX and experience designers can work on Javascript and additional CSS areas, book designers can work on the Paged Media stylesheets and authors can just write.

Furthermore we can reuse our CSS and Javascript on multiple documents.

## Working on content with XSLT

Once we have defined the structure of the document structure we can start building the rendering of our content. 

The first thing we'll do is to define the output for our master document and all the files that will be generated from our style sheet. 

```xml
  <!-- Define the output for this and all document children -->
  <xsl:output name="xhtml-out" method="xhtml" indent="yes"
    encoding="UTF-8" omit-xml-declaration="yes" />
```

We will being with the major areas of the document, `metadata` and `section`. The metadata is a container for all the elements inside. As such we just create the div that will hold the content and call `xsl:apply-templates` to process the content inside the metadata element.

```xml

  <xsl:template match="metadata" mode="content">
    <div class="metadata">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
```

The `section` element is hardest to wrap your head around

```xml
  <xsl:template match="section" mode="content">
  <!--
    Each section element will generate its own file

    We create the file name by concatenating the type attribute for the section, the count of how many sections of that type there are and the .xhtml extension
  -->
    <xsl:variable name="fileName"
      select="concat(section/@type, count(section/@type),'.xhtml')"/>
    <!-- An example result of the variable above would be introduction1.xhtml -->
    <xsl:apply-templates/>
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
    <xsl:result-document href='${fileName}' format="xhtml-out">
        <section>
          <xsl:apply-templates/>
        </section>
      </xsl:result-document>
  </xsl:template>
```

```xml

```
