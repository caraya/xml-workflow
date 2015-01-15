# Converting our content to HTML

One of the biggest advantages of working with XML is that we can convert the abstract tags into other markups. For the purposes of this project we'll convert the XML created to match the schema we just created to HTML and then use tools like [PrinceXML](http://www.princexml.com) or [AntenaHouse](http://www.antennahouse.com) we'll convert the HTML/CSS files to PDF

## Why HTML

HTML is the default format for the web and for most web/html based content such as ePub and Kindle. As such it makes a perfect candidate to explore how to generate it programatically from a single source file. 

HTML will also act as our source for using CSS paged media to create PDF cotnent.

## Why PDF

Rather than having to deal with [XSL-FO](http://www.w3.org/TR/2006/REC-xsl11-20061205/), another XML based vocabulary to create PDF content, we'll use XSLT to create another HTML file and process it with [CSS Paged Media](http://dev.w3.org/csswg/css-page-3/) and the companion [Generated Content for Paged Media](http://www.w3.org/TR/css-gcpm-3/) specifications to create PDF content. 

In this document we'll concentrated on the XSLT to HTML conversion and will defer the conversion from HTML to PDF to a different document.

# Creating our conversion stylesheets

To convert our XML into other formats we will use XSL Transformations (also known as XSLT) [version 2](http://www.w3.org/TR/xslt) (a W3C standard) and [version 3](http://www.w3.org/TR/xslt-30/) (a W3C last call draft recommendation) where appropriate.

XSLT is a functional language designed to transform XML into other markup vocabularies. It defines template rules that match elements in your source document and processing them to convert them to the target vocabulary. 

In the XSLT example below, we do the following:

1. match the root element to create the skeleton for our HTML content
2. In the title we insert the content of the `metadata/title` element
3. In the body we 'apply' the templates that match the content inside our document (more on this later)

```xml
<?xml version="1.0"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
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

We could build the stylesheet as part of our root element. 

Working with the stylesheet as part of the XSLT stylesheet allows the XSLT stylesheet designer to embed the style and parameterize the stylesheet, thus making the stylesheet customizable from the command line. 

For all advantages, this method ties the styles for the project to the XSLT stylesheet and requires the XSLT stylesheet designer to be involved in all CSS updates. 

By linking to external CSS and Javascript files we can leverage expertise independent of the Schema and XSLT stylesheets. Book designers can work on the CSS, UX and experience designers can work on Javascript and additional CSS areas, book designers can work on the Paged Media stylesheets and authors can just write.

Once we have defined the structure of the document structure we can start building the rendering of our content. 

## Working on content with XSLT



