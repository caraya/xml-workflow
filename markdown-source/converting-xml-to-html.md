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

In the XSLT template below, we do the following:

1. Declare the file to be an XML document
2. Define the root element of the stylesheet (xsl:stylesheet)
3. Indicate the namespaces that we'll use in the document and, in this case, tell the processor to excluse the given namespaces
4. Strip whitespaces from all elements and preserve it in the code elements
5. Create the default output we'll use for the main document and all generated pages (discussed later)
6. Create a default template to warn us if we missed anything


```xml
&lt;?xml version="1.0" ?>
&lt;!-- Define stylesheet root and namespaces we'll work with -->
&lt;xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:epub="http://www.idpf.org/2007/opf"
  exclude-result-prefixes="dc epub"
  xml:lang="en-US"
  version="2.0">
  &lt;!-- Strip whitespace from the listed elements -->
  &lt;xsl:strip-space elements="*"/>
  &lt;!-- And preserve it from the elements below -->
  &lt;xsl:preserve-space elements="code"/>
  &lt;!-- Define the output for this and all document children -->
  &lt;xsl:output name="xhtml-out" method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" />

  &lt;!--
    Default template taken from http://bit.ly/1sXqIL8

    This will tell us of any unmatched elements rather than
    failing silently
  -->
  &lt;xsl:template match="*">
    &lt;xsl:message terminate="no">
      WARNING: Unmatched element: &lt;xsl:value-of select="name()"/>
    &lt;/xsl:message>

    &lt;xsl:apply-templates/>
  &lt;/xsl:template>
  
  &lt;!-- More content to be added -->
&lt;/xsl:stylesheet>
```

This is a lot of work before we start creating our XSLT content. But it's worth doing the work up front. We'll see what are the advantages of doint it this way as we move down the style sheet.

Now onto our root templates. The first one is the entry point to our document. It performs the following tasks:

1. Match the root element to create the skeleton for our HTML content
2. In the title we insert the content of the `metadata/title` element
3. In the body we 'apply' the templates that match the content inside our document (more on this later)

```xml
&lt;!-- Root template, matching / -->
&lt;xsl:template match="book">
  &lt;html>
  &lt;head>
    &lt;xsl:element name="title">
      &lt;xsl:value-of select="metadata/title"/>
    &lt;/xsl:element>
    &lt;xsl:element name="meta">
      &lt;xsl:attribute name="generator">
        &lt;xsl:value-of select="system-property('xsl:product-name')"/>
        &lt;xsl:value-of select="system-property('xsl:product-version')"/>
      &lt;/xsl:attribute>
    &lt;/xsl:element>
    &lt;xsl:element name="meta">
      &lt;xsl:attribute name="vendor">
        &lt;xsl:value-of select="system-property('xsl:vendor-url')" />
      &lt;/xsl:attribute>
    &lt;/xsl:element>
    &lt;xsl:element name="meta">
      &lt;xsl:attribute name="vendor-URL">
        &lt;xsl:value-of select="system-property('xsl:vendor-url')" />
      &lt;/xsl:attribute>
    &lt;/xsl:element>
    &lt;link rel="stylesheet" href="css/style.css" />
    &lt;xsl:if test="(code)">
      &lt;!--
            Use highlight.js and docco style
          -->
      &lt;link rel="stylesheet" href="css/styles/docco.css" />
      &lt;!-- Load highlight.js -->
      &lt;script src="lib/highlight.pack.js">&lt;/script>
      &lt;script>
        hljs.initHighlightingOnLoad();
      &lt;/script>
    &lt;/xsl:if>
    &lt;!--
      Comment this out for now. It'll become relevant when we add video
      &lt;script src="js/script.js">&lt;/script>
    -->
  &lt;/head>
  &lt;body>
    &lt;xsl:apply-templates/>
    &lt;xsl:apply-templates select="/" mode="toc"/>
  &lt;/body>
  &lt;/html>
&lt;/xsl:template>
```
We could build the CSS stylesheet and Javascript files as part of our root template but we chose not to.. 

Working with the stylesheet as part of the XSLT stylesheet allows the XSLT stylesheet designer to embed the style and parameterize the stylesheet, thus making the stylesheet customizable from the command line. 

For all advantages, this method ties the styles for the project to the XSLT stylesheet and requires the XSLT stylesheet designer to be involved in all CSS and Javascript updates. 

By linking to external CSS and Javascript files we can leverage expertise independent of the Schema and XSLT stylesheets. Book designers can work on the CSS, UX and experience designers can work on Javascript and additional CSS areas, book designers can work on the Paged Media stylesheets and authors can just write.

Furthermore we can reuse our CSS and Javascript on multiple documents.

### Table of contents

> The table of content template is under active development and will be different depending on the desired output. I document it here as it is right now but will definitely change as it's further developed.

There is a second template matching the root element of our document to create a table of content. At first thought this looks like the wrong approach 

We leverage XSLT modes that allow us to create templates for the same element to perform different tasks. In `toc mode` we want the root template to do the following:

1. Create the section and nav and ol elements
2. Add the title for the table of contents
3. For each section element that is a child of root create these elements
    1. The `li` element
    2. The a element with the corresponding href element
    3. The value of the href element (a concatenation of the section's type attribute, the position within the document and the .html string)
    4. The title of the section as the 'clickable' portion of the link

```xml
&lt;xsl:template match="/" mode="toc">
  &lt;section data-type="toc"> (1)
    &lt;nav class="toc"> (1)
      &lt;h2>Table of Contents&lt;/h2>
      &lt;ol>
        &lt;xsl:for-each select="book/section">
          &lt;xsl:element name="li"> (3.1)
            &lt;xsl:element name="a"> (3.2)
              &lt;xsl:attribute name="href"> (3.2)
                &lt;xsl:value-of select="concat((@type), position(),'.html')"/> (3.3)
              &lt;/xsl:attribute>
              &lt;xsl:value-of select="title"/> (3.4)
            &lt;/xsl:element>
          &lt;/xsl:element>
        &lt;/xsl:for-each>
      &lt;/ol>
    &lt;/nav>
  &lt;/section>
&lt;/xsl:template>
```
<!-- current location -->

### Metadata and Section

With these templates in place we can now start writing the major areas of the document, `metadata` and `section`. 

#### Metadata

The metadata is a container for all the elements inside. As such we just create the div that will hold the content and call `xsl:apply-templates` to process the children inside the metadata element using the apply-template XSLT instruction. The template looks like this

```xml
&lt;xsl:template match="metadata">
  &lt;xsl:element name="div">
    &lt;xsl:attribute name="class">metadata&lt;/xsl:attribute>
    &lt;xsl:apply-templates/>
  &lt;/xsl:element>
&lt;/xsl:template>
```
#### Section

The section container on the other hand is a lot more complex because it has a lot of work to do. It is our primary unit for generating files, takes most of the same attributes as the root template and then processes the rest of the content. 

Inside the template we first create a vairable to hold the name of the file we'll generate. The file name is a concatenation of the following elements:

* The type attribute
* The position in the document
* the string "html"

The result-document element takes two parameters: the value of the file name variable we just defined and the xhtml-out format we defined at the top of the document. The XHTML format may look like overkill right now but it makes sense when we consider moving the generated content to ePub or other fomats where strict XHTML conformance is a requirement. 

We start generating the skeleton of the page, we add the default style sheet and  do the first conditional test of the document. Don't want to add stylesheets to the page unless they are needed so we test if there is a code element on the page and only add highlight.js related stylesheets and scripts. 

In the body element we see the first of many times we'll conditionally add attributes to the element. We use only add a data-type attribute to body if there is a type attribute in the source document. We do the same thing for id and class.

```xml
&lt;xsl:template match="section">
  &lt;!-- Variable to create section file names -->
  &lt;xsl:variable name="fileName" select="concat((@type), (position()-1),'.html')"/>
  &lt;!-- An example result of the variable above would be introduction1.xhtml -->
  &lt;xsl:result-document href='{$fileName}' format="xhtml-out">
    &lt;html>
      &lt;head>
        &lt;link rel="stylesheet" href="css/style.css" />
        &lt;xsl:if test="(code)">
          &lt;!--
            Use highlight.js and github style
          -->
          &lt;link rel="stylesheet" href="css/styles/docco.css" />
          &lt;!-- Load highlight.js -->
          &lt;script src="lib/highlight.pack.js">&lt;/script>
          &lt;script>
            hljs.initHighlightingOnLoad();
          &lt;/script>
        &lt;/xsl:if>
        &lt;!--
          Comment this out for now. It'll become relevant when we add video
          &lt;script src="js/script.js">&lt;/script>
        -->
      &lt;/head>
      &lt;body>
        &lt;section>
          &lt;xsl:if test="@type">
            &lt;xsl:attribute name="data-type">
              &lt;xsl:value-of select="@type"/>
            &lt;/xsl:attribute>
          &lt;/xsl:if>
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
          &lt;xsl:apply-templates/>
        &lt;/section>
      &lt;/body>
    &lt;/html>
  &lt;/xsl:result-document>
&lt;/xsl:template>
```
<!-- CURRENT SECTION -->
### Metadata content



#### Publication information
```xml
&lt;xsl:template match="isbn">
  &lt;p>ISBN: &lt;xsl:value-of select="."/>&lt;/p>
&lt;/xsl:template>
```

```xml
&lt;xsl:template match="edition">
  &lt;p class="no-margin-left">Edition: &lt;xsl:value-of select="."/>&lt;/p>
&lt;/xsl:template>
```

#### Individuals

```xml
&lt;!-- complex types to create groups of similar person items -->
&lt;xs:complexType name="person">
    &lt;xs:annotation>
        &lt;xs:documentation>
            Generic element to denote an individual involved in creating the book
        &lt;/xs:documentation>
    &lt;/xs:annotation>
    &lt;xs:sequence>
        &lt;xs:element name="first-name" type="xs:token"/>
        &lt;xs:element name="surname" type="xs:token"/>
    &lt;/xs:sequence>
    &lt;xs:attribute name="id" type="xs:ID" use="optional"/>
&lt;/xs:complexType>

&lt;xs:complexType name="author">
    &lt;xs:annotation>
        &lt;xs:documentation>
            Author person
        &lt;/xs:documentation>
    &lt;/xs:annotation>
    &lt;xs:complexContent>
        &lt;xs:extension base="person">
        &lt;/xs:extension>
    &lt;/xs:complexContent>
&lt;/xs:complexType>

&lt;xs:complexType name="editor">
    &lt;xs:annotation>
        &lt;xs:documentation>extension to person to indicate editor and his/her role&lt;/xs:documentation>
    &lt;/xs:annotation>
    &lt;xs:complexContent>
        &lt;xs:extension base="person">
            &lt;xs:choice>
                &lt;xs:element name="type" type="xs:token"/>
            &lt;/xs:choice>
        &lt;/xs:extension>
    &lt;/xs:complexContent>
&lt;/xs:complexType>

&lt;xs:complexType name="otherRole">
    &lt;xs:annotation>
        &lt;xs:documentation>extension to person to accomodate roles other than author and editor&lt;/xs:documentation>
    &lt;/xs:annotation>
    &lt;xs:complexContent>
        &lt;xs:extension base="person">
            &lt;xs:sequence minOccurs="1" maxOccurs="1">
                &lt;xs:element name="role" type="xs:token"/>
            &lt;/xs:sequence>
        &lt;/xs:extension>
    &lt;/xs:complexContent>
&lt;/xs:complexType>
```

#### People groups
```xml
&lt;xsl:template match="metadata/authors">
  &lt;h2>Authors&lt;/h2>
  &lt;ul>
    &lt;xsl:for-each select="author">
      &lt;li>
        &lt;xsl:value-of select="first-name"/>
        &lt;xsl:text> &lt;/xsl:text>
        &lt;xsl:value-of select="surname"/>
      &lt;/li>
    &lt;/xsl:for-each>
  &lt;/ul>
&lt;/xsl:template>

&lt;xsl:template match="metadata/editors">
  &lt;h2>Editorial Team&lt;/h2>
  &lt;ul class="no-bullet">
    &lt;xsl:for-each select="editor">
      &lt;li>
        &lt;xsl:value-of select="first-name"/>
        &lt;xsl:text> &lt;/xsl:text>
        &lt;xsl:value-of select="surname"/>
        &lt;xsl:value-of select="concat(' - ', type, ' ', 'editor')">&lt;/xsl:value-of>
      &lt;/li>
    &lt;/xsl:for-each>
  &lt;/ul>
&lt;/xsl:template>

&lt;xsl:template match="metadata/otherRoles">
  &lt;h2>Production team&lt;/h2>
  &lt;ul class="no-bullet">
    &lt;xsl:for-each select="otherRole">
      &lt;li>
        &lt;xsl:value-of select="first-name" />
        &lt;xsl:text> &lt;/xsl:text>
        &lt;xsl:value-of select="surname" />
        &lt;xsl:text> - &lt;/xsl:text>
        &lt;xsl:value-of select="role" />
      &lt;/li>
    &lt;/xsl:for-each>
  &lt;/ul>
&lt;/xsl:template>
```

#### Titles and headings

Titles and headings use mostly the same code. We've put them in separate templates to make it possible and easier to generate different code for each heading. It's not the same as using CSS where you can declare rules for the same attribute multiple times (with the last one winning); when writing transformations you can only have one per element otherwise you will get an error.

The goal is to create as simple a markup as we can so we can better leverage CSS to style and make our content display as intended.

```xml
&lt;xsl:template match="title ">
  &lt;xsl:element name="h1">
    &lt;xsl:if test="@align">
      &lt;xsl:attribute name="align">
        &lt;xsl:value-of select="@align"/>
      &lt;/xsl:attribute>
    &lt;/xsl:if>
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
    &lt;xsl:value-of select="."/>
  &lt;/xsl:element>
&lt;/xsl:template>

&lt;xsl:template match="h1">
  &lt;xsl:element name="h1">
    &lt;xsl:if test="@align">
      &lt;xsl:attribute name="align">
        &lt;xsl:value-of select="@align"/>
      &lt;/xsl:attribute>
    &lt;/xsl:if>
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
    &lt;xsl:value-of select="."/>
  &lt;/xsl:element>
&lt;/xsl:template>
```

#### Blockquotes, quotes and asides

```xml
&lt;xsl:template match="blockquote">
  &lt;xsl:element name="blockquote">
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
    &lt;xsl:apply-templates />
  &lt;/xsl:element>
&lt;/xsl:template>

&lt;!-- BLOCKQUOTE ATTRIBUTION-->
&lt;xsl:template match="attribution">
  &lt;xsl:element name="cite">
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
    &lt;xsl:apply-templates/>
  &lt;/xsl:element>
&lt;/xsl:template>
```

```xml
&lt;xsl:template match="quote">
  &lt;q>&lt;xsl:value-of select="."/>&lt;/q>
&lt;/xsl:template>
```

```xml
&lt;xsl:template match="aside">
  &lt;aside>
    &lt;xsl:if test="type">
      &lt;xsl:attribute name="data-type">
        &lt;xsl:value-of select="@align"/>
      &lt;/xsl:attribute>
    &lt;/xsl:if>
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
    &lt;xsl:apply-templates/>
  &lt;/aside>
&lt;/xsl:template>
```

#### Div and Span
```xml
&lt;xsl:template match="div">
  &lt;xsl:element name="div">
    &lt;xsl:if test="@align">
      &lt;xsl:attribute name="align">
        &lt;xsl:value-of select="@align"/>
      &lt;/xsl:attribute>
    &lt;/xsl:if>
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
    &lt;xsl:apply-templates/>
  &lt;/xsl:element>
&lt;/xsl:template>
```

```xml
&lt;xsl:template match="span">
  &lt;xsl:element name="span">
    &lt;xsl:if test="@type">
      &lt;xsl:attribute name="data-type">
        &lt;xsl:value-of select="@type"/>
      &lt;/xsl:attribute>
    &lt;/xsl:if>
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
    &lt;xsl:value-of select="."/>
  &lt;/xsl:element>
&lt;/xsl:template>
```
#### Paragraphs
```xml
&lt;xsl:template match="para">
  &lt;xsl:element name="p">
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
    &lt;xsl:apply-templates/>
  &lt;/xsl:element>
&lt;/xsl:template>
```
#### Styles

```xml
&lt;xsl:template match="strong">
  &lt;strong>&lt;xsl:apply-templates />&lt;/strong>
&lt;/xsl:template>

&lt;xsl:template match="emphasis">
  &lt;em>&lt;xsl:apply-templates/>&lt;/em>
&lt;/xsl:template>

&lt;xsl:template match="strike">
  &lt;strike>&lt;xsl:apply-templates/>&lt;/strike>
&lt;/xsl:template>

&lt;xsl:template match="underline">
  &lt;u>&lt;xsl:apply-templates/>&lt;/u>
&lt;/xsl:template>
```

### Links and anchors

One of the 

```xml
&lt;xsl:template match="link">
  &lt;xsl:element name="a">
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
    &lt;xsl:attribute name="href">
      &lt;xsl:value-of select="@href"/>
    &lt;/xsl:attribute>
    &lt;xsl:attribute name="label">
      &lt;xsl:value-of select="@label"/>
    &lt;/xsl:attribute>
    &lt;xsl:value-of select="@label"/>
  &lt;/xsl:element>
&lt;/xsl:template>
```

When working with links there are times when we want to link to sections within the same document or to specific sections in another document. To do this we need anchors that will resolve to the following HTML:

```html
&lt;a name="target">&lt;a>
```

The transformation element looks like this:

```xml
&lt;xsl:template match="anchor">
  &lt;xsl:element name="a">
    &lt;xsl:attribute name="name">
    &lt;/xsl:attribute>
  &lt;/xsl:element>
&lt;/xsl:template>
```

Not sure if I want to make this an empty element or not

Empty element &lt;anchor name="home"/> appeals to my ease of use paradigm but it may not be as easy to understand for peope who are not familiar with XML empty elements

### Code blocks

Code elements create [fenced code blocks](https://help.github.com/articles/github-flavored-markdown/#fenced-code-blocks) like the ones from [Github Flavored Markdown](https://help.github.com/articles/github-flavored-markdown/). 

We use [Adobe Source Code Pro](https://www.google.com/fonts/specimen/Source+Code+Pro) font. It's a clean and readable font designed specifically for source code display.

We highlight our code with [Highlight.js](https://highlightjs.org/). 

> Note that the syntax higlighting only works for HTML. Although PrinceXML supports Highlight.js it is not working. I've asked on the Prince support forums and am waiting for an answer.

```xml
&lt;xsl:template match="code">
  &lt;xsl:element name="pre">
    &lt;xsl:element name="code">
      &lt;xsl:attribute name="class">
        &lt;xsl:value-of select="@language"/>
      &lt;/xsl:attribute>
      &lt;xsl:value-of select="."/>
    &lt;/xsl:element>
  &lt;/xsl:element>
&lt;/xsl:template>
```

### Lists and list items

When I first conceptualized this project I had designed a single list element and attributes to produce bulleted and numbered lists. This proved to difficult to implement so I went back to two separate elements: `ulist` for bulleted lists and `olist` for  numbered lists. 

Both elements share the `item` element to indicates the items inside the list. At least one item is required a list.

```xml
&lt;xsl:template match="ulist">
  &lt;xsl:element name="ul">
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
    &lt;xsl:apply-templates/>
  &lt;/xsl:element>
&lt;/xsl:template>

&lt;xsl:template match="olist">
  &lt;xsl:element name="ol">
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
    &lt;xsl:apply-templates/>
  &lt;/xsl:element>
&lt;/xsl:template>

&lt;xsl:template match="item">
  &lt;xsl:element name="li">
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
    &lt;xsl:value-of select="."/>
  &lt;/xsl:element>
&lt;/xsl:template>
```

### Figures and Images

Figures, captions and the images inside present a few challenges. Because we allow authors to set height and width on both figure and the imageg inside we may find situations where the figure container is narrower than the image inside. 

To avoid this issue we test whether the figure width value is smaller than the width of the image inside. If it is, we use the width of the image as the width of the figure, ootherwise we use the width of the image inside. 

We didn't do the same thing for the height. It may be changed in a future iteration. 

The data model for our content allows both figures and images to be used in the document. This is so we don't have to insert empty captions to figures just so we can add an image... If we don't want a caption we can insert the image directly on our document. 

```xml
&lt;xsl:template match="figure">
  &lt;xsl:element name="figure">
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
    &lt;!-- 
      If the width of the figure is smaller than the width of the containing image 
      we may have display problems. 

      If the width of the containging figure is smaller than the width of the image, 
      make the figure width equal to the width of hthe image, otherwise use the width
      of the figure element
    -->
    &lt;xsl:choose>
      &lt;xsl:when test="@width lt image/@width">
        &lt;xsl:attribute name="width">
          &lt;xsl:value-of select="@width"/>
        &lt;/xsl:attribute>
      &lt;/xsl:when>
      &lt;xsl:otherwise>
        &lt;xsl:attribute name="width">
          &lt;xsl:value-of select="image/@width"/>
        &lt;/xsl:attribute>
      &lt;/xsl:otherwise>
    &lt;/xsl:choose>
    &lt;!-- 
      We don't care about height as much as we do width, the caption 
      and image are contained inside the figure. 

      We only test if it exists. It's up to the author to make sure
      there are no conflicts
    -->
    &lt;xsl:if test="(@height)">
      &lt;xsl:attribute name="height">
        &lt;xsl:value-of select="@height"/>
      &lt;/xsl:attribute>
    &lt;/xsl:if>
    &lt;!-- 
      Alignment can be different. We can have a centered image inside a 
      left aligned figure
    -->
    &lt;xsl:if test="(@align)">
      &lt;xsl:attribute name="align">
        &lt;xsl:value-of select="@align"/>
      &lt;/xsl:attribute>
    &lt;/xsl:if>
    &lt;xsl:apply-templates select="image"/>
    &lt;xsl:apply-templates select="figcaption"/>
  &lt;/xsl:element>
&lt;/xsl:template>

&lt;xsl:template match="figcaption">
  &lt;figcaption>&lt;xsl:apply-templates/>&lt;/figcaption>
&lt;/xsl:template>

&lt;xsl:template match="image">
  &lt;xsl:element name="img">
    &lt;xsl:attribute name="src">
      &lt;xsl:value-of select="@src"/>
    &lt;/xsl:attribute>
    &lt;xsl:attribute name="alt">
      &lt;xsl:value-of select="@alt"/>
    &lt;/xsl:attribute>
    &lt;xsl:if test="(@width)">
      &lt;xsl:attribute name="width">
        &lt;xsl:value-of select="@width"/>
      &lt;/xsl:attribute>
    &lt;/xsl:if>
    &lt;xsl:if test="(@height)">
      &lt;xsl:attribute name="height">
        &lt;xsl:value-of select="@height"/>
      &lt;/xsl:attribute>
    &lt;/xsl:if>
    &lt;xsl:if test="(@align)">
      &lt;xsl:attribute name="align">
        &lt;xsl:value-of select="@align"/>
      &lt;/xsl:attribute>
    &lt;/xsl:if>
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
  &lt;/xsl:element>
&lt;/xsl:template>
```
