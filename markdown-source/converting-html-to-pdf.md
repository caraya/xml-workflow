---
title: Converting From XML to PDF: Part 1: Special Transformation
date: 2015-01-13
category: Technology
status: draft
---
# From XML to PDF: Part 1: Special Transformation

Rather than having to deal with [XSL-FO](http://www.w3.org/TR/2006/REC-xsl11-20061205/), another XML based vocabulary to create PDF content, we'll use XSLT to create another HTML file and process it with [CSS Paged Media](http://dev.w3.org/csswg/css-page-3/) and the companion [Generated Content for Paged Media](http://www.w3.org/TR/css-gcpm-3/) specifications to create PDF content. 

I'm not against XSL-FO but the structure of document is not the easiest or most intuitive. An example of XSL-FO looks like this:

```xml
&lt;?xml version="1.0" encoding="iso-8859-1"?> (1)

&lt;fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format"> (2)
  &lt;fo:layout-master-set> (3)
    &lt;fo:simple-page-master master-name="my-page">
      &lt;fo:region-body margin="1in"/>
    &lt;/fo:simple-page-master>
  &lt;/fo:layout-master-set>

  &lt;fo:page-sequence master-reference="my-page"> (4)
    &lt;fo:flow flow-name="xsl-region-body"> (5)
      &lt;fo:block>Hello, world!&lt;/fo:block> (6)
    &lt;/fo:flow>
  &lt;/fo:page-sequence>
&lt;/fo:root>
```

1. This is an XML declaration. XSL FO (XSLFO) belongs to XML family, so this is obligatory.
2. Root element. The obligatory namespace attribute declares the XSL Formatting Objects namespace.
3. Layout master set. This element contains one or more declarations of page masters and page sequence masters — elements that define layouts of single pages and page sequences. In the example, I have defined a rudimentary page master, with only one area in it. The area should have a 1 inch margin from all sides of the page.
4. Page sequence. Pages in the document are grouped into sequences; each sequence starts from a new page. Master-reference attribute selects an appropriate layout scheme from masters listed inside `&lt;fo:layout-master-set>`. Setting master-reference to a page master name means that all pages in this sequence will be formatted using this page master.
5. Flow. This is the container object for all user text in the document. Everything contained in the flow will be formatted into regions on pages generated inside the page sequence. Flow name links the flow to a specific region on the page (defined in the page master); in our example, it is the body region.
6. Block. This object roughly corresponds to `&lt;div>` in HTML, and normally includes a paragraph of text. I need it here, because text cannot be placed directly into a flow.

Rather than define a flow of content and then the content CSS Paged Media uses a combination of new and existing CSS elements to format the content. For example, to define default page size and then add elements to chapter pages looks like this:

```css
@page {
  size: 8.5in 11in;
  margin: 0.5in 1in;
  /* Footnote related attributes */
  counter-reset: footnote;
  @footnote {
    counter-increment: footnote;
    float: bottom;
    column-span: all;
    height: auto;
    }
  }

@page chapter {
  @bottom-center {
    vertical-align: middle;
    text-align: center;
    content: element(heading);
  }
}
```

The only problem with the code above is that there is no native broser support. For our demonstration we'll use Prince XML to tanslate our HTML/CSS file to PDF. In the not so distant future we will be able to do this transformation in the browser and print the PDF directly. Until then it's a two step process: Modifying the HTML we get from the XML file and running the HTML through Prince to get the PDF. 

## Modifying the HTML results

We'll use this opportunity to create an xslt customization layer to make changes only to the templates where we need to. 

We create a customization layer by importing the original stylesheet and making any necessary changes in the new stylesheet. Imported stylesheets have a lower precedence order than the local version so the local version will win if there is conflict.

In this particular situation we want to:

* Add the data-type=book attribute to the body of the document
* Convert the multiple file book into a single file by eliminating the result-document element
* Remove filename variable. It's not needed
* Change the test for type attribute so it'll terminate
  if it fails (type attribute is required for our implementation of the Paged Media style sheet)
* Add the element that will build our running footer
  (p class="rh" with the same value as the chapter title)
* Remove the toc mode apply-template call from the book template.
  It's not needed, we may move it to a separate template for navigation
* Rework the metadata template so it'll match the spec on the CSS  (it's a section with data-type = title page)
* Insert a link to the paged media CSS style sheet in the head of the document to make the Prince command easier (and so I won't forget it during testing and development)

Only the templates defined in this stilesheet are overriden

The style sheet is shown below (with large comments removed)

```xml
&lt;?xml version="1.0" encoding="UTF-8"?>
&lt;xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  &lt;!--
    XSLT Paged Media Customization Layer

    Makes the necessary changes to the content to work with the Paged Media CSS stylesheet
  -->
  &lt;!-- First import the base stylesheet -->
  &lt;xsl:import href="book.xsl"/>

  &lt;!-- Define the output for this and all document children -->
  &lt;xsl:output name="xhtml-out" method="xhtml"
    indent="yes" encoding="UTF-8" omit-xml-declaration="yes" />

  &lt;xsl:template match="book">
    &lt;html>
      &lt;head>
        &lt;xsl:element name="title">
          &lt;xsl:value-of select="metadata/title"/>
        &lt;/xsl:element>
        &lt;link rel="stylesheet" href="css/pm-style.css" />
        &lt;!-- Just so I won't forget it again -->
        &lt;link rel="stylesheet" href="css/paged-media.css"/>
        &lt;!--
              Use highlight.js and docco style
        -->
        &lt;link rel="stylesheet" href="css/styles/docco.css" />
        &lt;!-- Load highlight.js -->
        &lt;script src="lib/highlight.pack.js">&lt;/script>
        &lt;script>
          hljs.initHighlightingOnLoad();
        &lt;/script>
        &lt;script src="js/script.js">&lt;/script>
      &lt;/head>

      &lt;body>
        &lt;xsl:attribute name="data-type">book&lt;/xsl:attribute>
          &lt;xsl:element name="meta">
            &lt;xsl:attribute name="generator">
              &lt;xsl:value-of select="system-property('xsl:product-name')"/>
              &lt;xsl:value-of select="system-property('xsl:product-version')"/>
            &lt;/xsl:attribute>
          &lt;/xsl:element>
          &lt;xsl:element name="meta">
            &lt;xsl:attribute name="vendor">
              &lt;xsl:value-of select="system-property('xsl:vendor')" />
            &lt;/xsl:attribute>
          &lt;/xsl:element>
          &lt;xsl:element name="meta">
            &lt;xsl:attribute name="vendor-URL">
              &lt;xsl:value-of select="system-property('xsl:vendor-url')" />
            &lt;/xsl:attribute>
          &lt;/xsl:element>
        &lt;xsl:apply-templates/>
      &lt;/body>
    &lt;/html>
  &lt;/xsl:template>

  &lt;xsl:template match="book/section">
    &lt;section>
      &lt;xsl:choose>
        &lt;xsl:when test="@type">
          &lt;xsl:attribute name="data-type">
            &lt;xsl:value-of select="@type"/>
          &lt;/xsl:attribute>
        &lt;/xsl:when>
        &lt;xsl:otherwise>
          &lt;xsl:message terminate="yes">
            Type attribute is required for paged media
          &lt;/xsl:message>
        &lt;/xsl:otherwise>
      &lt;/xsl:choose>
      &lt;xsl:if test="(@class)">
        &lt;xsl:attribute name="class">
          &lt;xsl:value-of select="@class"/>
        &lt;/xsl:attribute>
      &lt;/xsl:if>
      &lt;xsl:if test="(@id)">
        &lt;xsl:attribute name="id">
          &lt;xsl:value-of select="@id"/>
        &lt;/xsl:attribute>
      &lt;/xsl:if>
      &lt;xsl:element name="p">
        &lt;xsl:attribute name="class">rh&lt;/xsl:attribute>
        &lt;xsl:value-of select="title"/>
      &lt;/xsl:element>
      &lt;xsl:apply-templates/>
    &lt;/section>
  &lt;/xsl:template>

  &lt;!-- Metadata -->
  &lt;xsl:template match="metadata">
    &lt;xsl:element name="section">
      &lt;xsl:attribute name="data-type">titlepage&lt;/xsl:attribute>
      &lt;xsl:apply-templates/>
    &lt;/xsl:element>
  &lt;/xsl:template>

  &lt;xsl:template match="book" mode="toc"/>
&lt;/xsl:stylesheet>
```
