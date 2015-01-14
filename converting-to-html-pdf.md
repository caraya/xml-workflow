# Converting our content into other formats

One of the biggest advantages of working with XML is that we can convert the abstract tags into other markups. For the purposes of this project we'll convert the XML created to match the schema we just created to HTML and then we'll convert it to [XSL Formating Objects](http://www.xml.com/pub/a/2002/03/20/xsl-fo.html) and then using tools like [Apache FOP](http://xmlgraphics.apache.org/fop/) or [RenderX](http://www.renderx.com/tools/xep.html) we'll conver the XSL-FO into PDF

## Why HTML

## Why PDF


# Creating our conversion stylesheets

To convert our XML into other formats we will use XSL Transformations (also known as XSLT) [version 2](http://www.w3.org/TR/xslt) (a W3C standard) and [version 3](http://www.w3.org/TR/xslt-30/) (a W3C last call draft recommendation) where appropriate.

XSLT is a functional language designer to transform XML into other markup vocabularies. It defines template rules that match elements in your source document and processing them to convert them to the target vocabulary. 

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

Once we have defined the structure of the document structure we can start building the rendering of our content. 