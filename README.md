---
title: XML workflows: From XML to PDF and how to get there
date: 2014-10-22
category: Technology
status: draft
---

# XML workflows: From XML to PDF and how to get there

One of the biggest limitations of markup languages, in my opinion, is how limiting they are. Even large vocabularies like [Docbook](http://docbook.org) are limited in what they can do out of the box. HTML4 is non-extensible and HTML5 is limited in how you can extend it (web components are the only way to extend HTML5 I'm aware of that doesn't require an update to the HTML specification.)

By creating our own markup vocabulary we can be as expressive as we need to be without adding additional complexity for writers and users and without adding unecessary complexity for the developers building the tools to interact with the markup.

## Why create our own markup

I have a few answers to that question:

In creating your own xml-based markup you enforce separation of content and style. The XML document provides the basic content of the document and the hints to use elsewhere. XSLT stylesheets allow you to structure the base document and associated hints into any number of formats (for the purposes of this document we'll concentrate on XHTML, PDF created through Paged Media CSS and PDF created using XSL formatting Objects)

Creating a domain specific markup vocabulary allows you think about structure and complexity for yourself as the editor/typesetter and for your authors. It makes you think about elements and attributes and which one is better for the given experience you want and what, if any, restrictions you want to impose on your makeup.

By creating our own vocabulary we make it easier for authors to write clean and simple content. XML provides a host of validation tools to enforce the structure and format of the XML document.

## Options for defining the markup

For the rest of this post, we'll use a ***book-like*** structure. It'll look something like this:

```xml
<book 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:noNamespaceSchemaLocation="xsd/book-schema-draft.xsd">
  <metadata>
    <isbn>0123456789</isbn>
    <edition>1</edition>
    <title>title0</title>
    <author>
      <first-name>first-name0</first-name>
      <surname>surname0</surname>
    </author>
    </metadata>
  <section type="chapter">
    <para></para>
    <para></para>
  </section>
</book>
```

There are additional elements and attributes defined inside the XML Schema for our documents, we'll discuss some of those elements as they appear and then talk about the rationales for the implementation. 

### XML Schema

The schema is defined from most general to most specific elements. We'll follow the same process to explain what the schema does and how we arrived to the choices we made. 

At the beginning of the schema we define some custom types that will be used throughout the document. 

The first one, `string255` is a string that is limited to 255 characters in length. We do this to prevent overtly long strings.

The second one, `isbn` is a regular expression to match 10 digits ISBN numbers. We'll have to modify it to handle ISBN-13 as well as 10.

The third custom type is an enumeration of all possible values for the `align` attribute acording to CSS and HTML. Rather than manually type each of these we will reference this enumeration and include all its values for "free".

We also allow the optional use of `class` and `id` attributes for the book by assigning `genericPropertiesGroup` attribute group as attributes to the group. We'll see this assigned to other elements so I decided to make it reusable rather than have to duplicate the attributes in every element I want to use them in.


```xml
  <xs:simpleType name="string255">
    <xs:annotation>
      <xs:documentation>
        Defines a string of no more than 255 characters
      </xs:documentation>
    </xs:annotation>
    <xs:restriction base="xs:token">
      <xs:maxLength value="255" />
    </xs:restriction>
  </xs:simpleType>

  <xs:simpleType name="isbn">
    <xs:annotation>
      <xs:documentation>
        Defines a regular expression to match an ISBN number. Regex needs to be refined
      </xs:documentation>
    </xs:annotation>
    <xs:restriction base="xs:unsignedLong">
      <xs:totalDigits value="10" />
      <xs:pattern value="\d{10}" />
    </xs:restriction>
  </xs:simpleType>

  <xs:simpleType name="align">
    <xs:annotation>
      <xs:documentation>
        Attribute ennumeration for elements that can be aligned
      </xs:documentation>
    </xs:annotation>
    <xs:restriction base="xs:string">
      <xs:enumeration value="left" />
      <xs:enumeration value="center" />
      <xs:enumeration value="right" />
      <xs:enumeration value="justify" />
    </xs:restriction>
  </xs:simpleType>

  <xs:attributeGroup name="genericPropertiesGroup">
    <xs:attribute name="id" type="xs:ID" use="optional">
      <xs:annotation>
        <xs:documentation>
          ID for the paragraph if any
        </xs:documentation>
      </xs:annotation>
    </xs:attribute>
    <xs:attribute name="class" type="xs:string" use="optional">
      <xs:annotation>
        <xs:documentation>
          Class for the paragraph if any
        </xs:documentation>
      </xs:annotation>
    </xs:attribute>
  </xs:attributeGroup>
```

We now look at the elements that we can put inside a section. Some of these elements are overtly complex and deliberately so since they have to acommodate a lot of possible parameters. 

We'll look at links first as it is the simplest of our content structures. We borrow the `href` attribute from HTML to indicate the destination for the link and make it required. 

We also incoporate a `label` so we can later build the link and for accessibility purposes. It also uses our `genericPropertiesGroup` attribute set to add class and ID as attributes for our links.

```xml 
<!-- Elements inside section -->
<xs:element name="link">
  <xs:annotation>
    <xs:documentation>links...</xs:documentation>
  </xs:annotation>
  <xs:complexType>
    <xs:attributeGroup ref="genericPropertiesGroup" />
    <xs:attribute name="href" type="xs:string" use="required">
      <xs:annotation>
        <xs:documentation>
          Link destination
        </xs:documentation>
      </xs:annotation>
    </xs:attribute>
    <xs:attribute name="label" type="xs:string" use="required">
      <xs:annotation>
        <xs:documentation>
          Text provided for accessibility
        </xs:documentation>
      </xs:annotation>
    </xs:attribute>
  </xs:complexType>
</xs:element>
```
The link in our resulting book will look like this:

```xml
<link href="http://google.com" label="link to google"></link>
```

and with the optional attributes it will look like this

```xml
<link class="external" id="ex01" href="http://google.com" label="link to google"></link>
```

Next are images where again borrow from HTML for the name of attribute names and their functionality. We start with `genericPropertiesGroup` to define `class` and `id`.


Then we require a `src` attribute to tell where the image is located. We need to be careful because we haven't told the schema the different types of images. We have at least three different locations for the image files. All three of these are valid locations for our image.png file.

```xml
image.png
directory/image.png
http://mysite.org/images/image.png
```

We could create branches of our schema to deal with the different locations but I've chosen to let the XSLT style sheets deal with this particular situation

`width` and `height` are expressed as integer and are left as optional to account for the possibility that the CSS or XSLT stylesheets modify the image dimensions. Making these dimensions mandatory may affect how the element interact with the styles later on. 

The `alt` attribute indicates alternative text for the image. It is not meant as a full description so we've constrained it to 255 characters. 

`align` uses our align enumeration to indicae the image's alignment. It is not essential to the XML but will be useful to the XSLT stylesheets we'll create later as part of the process.

```xml
<xs:element name="image">
  <xs:annotation>
    <xs:documentation>image and image-related attributes</xs:documentation>
  </xs:annotation>
  <xs:complexType>
    <xs:attributeGroup ref="genericPropertiesGroup" />
    <xs:attribute name="src" type="xs:string" use="required">
      <xs:annotation>
        <xs:documentation>
          Source for the image. We may want to create a 
          restriction to account for both local and remote 
          addresses
        </xs:documentation>
      </xs:annotation>
    </xs:attribute>
    <xs:attribute name="height" type="xs:integer" use="optional">
      <xs:annotation>
        <xs:documentation>
          Height for the image expressed as an integer
        </xs:documentation>
      </xs:annotation>
    </xs:attribute>
    <xs:attribute name="width" type="xs:integer" use="optional">
      <xs:annotation>
        <xs:documentation>
          Width for the image expressed as an integer
        </xs:documentation>
      </xs:annotation>
    </xs:attribute>
    <xs:attribute name="alt" type="string255" use="required">
      <xs:annotation>
        <xs:documentation>
          Alternate text contstained to 255 characters
        </xs:documentation>
      </xs:annotation>
    </xs:attribute>
    <xs:attribute name="align" type="align" use="optional" default="left">
      <xs:annotation>
        <xs:documentation>
          Optional alignment
        </xs:documentation>
      </xs:annotation>
    </xs:attribute>

  </xs:complexType>
</xs:element>
```

```xml
<xs:element name="para">
  <xs:annotation>
    <xs:documentation>
      Para is the essential text content element. It'll get
      hairy because we have a lot of possible attributes we
      can use on it
    </xs:documentation>
  </xs:annotation>
  <xs:complexType mixed="true">
    <xs:sequence>
      <!-- 
        Style Elements. 

        We use strong and emphasis rather than bold and italics
        to try and stay in synch with HTML and HTML5. We may
        add additional tags later in the process.
      -->
      <xs:element name="strong" type="xs:string" minOccurs="0" maxOccurs="unbounded" />
      <xs:element name="emphasis" type="xs:string" minOccurs="0" maxOccurs="unbounded" />
      <xs:element name="underline" type="xs:string" minOccurs="0" maxOccurs="unbounded" />
      <xs:element name="strike" type="xs:string" minOccurs="0" maxOccurs="unbounded" />
      <!-- 
        Organization Elements 
      -->
      <xs:element name="span" type="xs:string" minOccurs="0" maxOccurs="unbounded" />
      <xs:element ref="link" minOccurs="0" maxOccurs="unbounded">
        <xs:annotation>
          <xs:documentation>
            Links should happen inside paragraphs and it's an optional element.
          </xs:documentation>
        </xs:annotation>
      </xs:element>
    </xs:sequence>
    <xs:attributeGroup ref="genericPropertiesGroup" />
  </xs:complexType>
</xs:element>
```

```xml
  <xs:element name="book">
    <xs:annotation>
      <xs:documentation>
        The main book element and its children
      </xs:documentation>
    </xs:annotation>
    <xs:complexType mixed="true">
      <xs:annotation>
        <xs:documentation>
          A sequence of one metadat section followed by 1 or more sections
        </xs:documentation>
      </xs:annotation>
      <xs:sequence>
        <xs:element ref="metadata" minOccurs="1" maxOccurs="1" />
        <xs:element ref="section" minOccurs="1" maxOccurs="unbounded" />
      </xs:sequence>
      <xs:attributeGroup ref="genericPropertiesGroup" />
    </xs:complexType>
  </xs:element>
```

The root element is `book` the book has exactly 1 `metadata` section and 1 or more (at least 1 with no upper limit) `section`. I thought about including the metadata at the section level but it would add too much repetitive markup in places where it may not be necessary. 

Why the name section? I thought about using specific names for preface, introduction, chapter, glossary and the like. I decided against it because it would mean too much code duplication without much return of investment. 

I may reconsider this option when developing glossary and index-specific elements. 



The complete schema document looks like this:

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<xs:schema 
           xmlns:xs="http://www.w3.org/2001/XMLSchema" 
           elementFormDefault="qualified" 
           attributeFormDefault="unqualified">

  <!-- Simple types to use in the content -->
  <xs:simpleType name="string255">
    <xs:annotation>
      <xs:documentation>
        Defines a string of no more than 255 characters
      </xs:documentation>
    </xs:annotation>
    <xs:restriction base="xs:token">
      <xs:maxLength value="255" />
    </xs:restriction>
  </xs:simpleType>

  <xs:simpleType name="isbn">
    <xs:annotation>
      <xs:documentation>
        Defines a regular expression to match an ISBN number. Regex needs to be refined
      </xs:documentation>
    </xs:annotation>
    <xs:restriction base="xs:unsignedLong">
      <xs:totalDigits value="10" />
      <xs:pattern value="\d{10}" />
    </xs:restriction>
  </xs:simpleType>

  <xs:simpleType name="align">
    <xs:annotation>
      <xs:documentation>
        Attribute ennumeration for elements that can be aligned
      </xs:documentation>
    </xs:annotation>
    <xs:restriction base="xs:string">
      <xs:enumeration value="left" />
      <xs:enumeration value="center" />
      <xs:enumeration value="right" />
      <xs:enumeration value="justify" />
    </xs:restriction>
  </xs:simpleType>

  <xs:attributeGroup name="genericPropertiesGroup">
    <xs:attribute name="id" type="xs:ID" use="optional">
      <xs:annotation>
        <xs:documentation>
          ID for the paragraph if any
        </xs:documentation>
      </xs:annotation>
    </xs:attribute>
    <xs:attribute name="class" type="xs:string" use="optional">
      <xs:annotation>
        <xs:documentation>
          Class for the paragraph if any
        </xs:documentation>
      </xs:annotation>
    </xs:attribute>
  </xs:attributeGroup>

  <!-- Elements inside section -->
  <xs:element name="link">
    <xs:annotation>
      <xs:documentation>links...</xs:documentation>
    </xs:annotation>
    <xs:complexType>
      <xs:attributeGroup ref="genericPropertiesGroup" />
      <xs:attribute name="href" type="xs:string" use="required">
        <xs:annotation>
          <xs:documentation>Link destination</xs:documentation>
        </xs:annotation>
      </xs:attribute>
      <xs:attribute name="label" type="xs:string" use="required">
        <xs:annotation>
          <xs:documentation>Text provided for accessibility</xs:documentation>
        </xs:annotation>
      </xs:attribute>
    </xs:complexType>
  </xs:element>

  <xs:element name="image">
    <xs:annotation>
      <xs:documentation>image and image-related attributes</xs:documentation>
    </xs:annotation>
    <xs:complexType>
      <xs:attributeGroup ref="genericPropertiesGroup" />
      <xs:attribute name="src" type="xs:string" use="required">
        <xs:annotation>
          <xs:documentation>
            Source for the image. We may want to create a restriction to account for both local and remote addresses
          </xs:documentation>
        </xs:annotation>
      </xs:attribute>
      <xs:attribute name="height" type="xs:integer" use="optional">
        <xs:annotation>
          <xs:documentation>
            Height for the image expressed as an integer
          </xs:documentation>
        </xs:annotation>
      </xs:attribute>
      <xs:attribute name="width" type="xs:integer" use="optional">
        <xs:annotation>
          <xs:documentation>
            Width for the image expressed as an integer
          </xs:documentation>
        </xs:annotation>
      </xs:attribute>
      <xs:attribute name="alt" type="string255" use="required">
        <xs:annotation>
          <xs:documentation>
            Alternate text contstained to 255 characters
          </xs:documentation>
        </xs:annotation>
      </xs:attribute>
      <xs:attribute name="align" type="align" use="optional" default="left">
        <xs:annotation>
          <xs:documentation>
            Optional alignment
          </xs:documentation>
        </xs:annotation>
      </xs:attribute>

    </xs:complexType>
  </xs:element>

  <xs:element name="para">
    <xs:annotation>
      <xs:documentation>Para is the essential text content element. It'll get hairy because we have a lot of possible attributes we can use on it</xs:documentation>
    </xs:annotation>
    <xs:complexType mixed="true">
      <xs:sequence>
        <!-- 
          Style Elements. 

          We use strong and emphasis rather than bold and italics
          to try and stay in synch with HTML and HTML5. We may add additional tags
          later in the process.
        -->
        <xs:element name="strong" type="xs:string" minOccurs="0" maxOccurs="unbounded" />
        <xs:element name="emphasis" type="xs:string" minOccurs="0" maxOccurs="unbounded" />
        <xs:element name="underline" type="xs:string" minOccurs="0" maxOccurs="unbounded" />
        <xs:element name="strike" type="xs:string" minOccurs="0" maxOccurs="unbounded" />
        <!-- 
          Organization Elements 
        -->
        <xs:element name="span" type="xs:string" minOccurs="0" maxOccurs="unbounded" />
        <xs:element ref="link" minOccurs="0" maxOccurs="unbounded">
          <xs:annotation>
            <xs:documentation>
              Links should happen inside paragraphs and it's an optional element.
            </xs:documentation>
          </xs:annotation>
        </xs:element>
      </xs:sequence>
      <xs:attributeGroup ref="genericPropertiesGroup" />
    </xs:complexType>
  </xs:element>

<!-- Metadata element -->
  <xs:element name="metadata">
    <xs:annotation>
      <xs:documentation>
        Metadata section of the content. Still debating whether to move it inside section or leave it as a separate part.
      </xs:documentation>
    </xs:annotation>
    <xs:complexType>
      <xs:sequence>
        <xs:annotation>
          <xs:documentation>First three elements in the metadata sequence: isbn, edition and title</xs:documentation>
        </xs:annotation>
        <xs:element name="isbn" type="isbn" />
        <xs:element name="edition" type="xs:integer" />
        <xs:element name="title" type="string255" />

        <xs:element name="author" minOccurs="1" maxOccurs="unbounded">
          <xs:annotation>
            <xs:documentation>Authors create the content. Element is required and you should have at least one author to valdate the doc.</xs:documentation>
          </xs:annotation>
          <xs:complexType>
            <xs:sequence>
              <xs:element name="first-name" type="xs:string" />
              <xs:element name="surname" type="xs:string" />
            </xs:sequence>
            <xs:attribute name="id" type="xs:ID" />
          </xs:complexType>
        </xs:element>

        <xs:element name="editor" minOccurs="0" maxOccurs="unbounded">
          <xs:annotation>
            <xs:documentation>Editors can have several responsabilities. We define them using the typeOfEditor child element. The element is optional. If it's used we can have as many editors as we need</xs:documentation>
          </xs:annotation>
          <xs:complexType>
            <xs:sequence>
              <xs:element name="first-name" type="xs:string" />
              <xs:element name="surname" type="xs:string" />
              <xs:element name="typeOfEditor" type="xs:string" />
            </xs:sequence>
            <xs:attribute name="id" type="xs:ID" />
          </xs:complexType>
        </xs:element>

        <xs:element name="otherRole" minOccurs="0" maxOccurs="unbounded">
          <xs:annotation>
            <xs:documentation>
            We define otherRole to indicate roles in the publishing process that are not editors or authors. These can be reviewers, illustrators
            </xs:documentation>
          </xs:annotation>
          <xs:complexType>
            <xs:sequence>
              <xs:element name="first-name" type="xs:string" />
              <xs:element name="last-name" type="xs:string" />
            </xs:sequence>
            <xs:attribute name="id" type="xs:ID" />
          </xs:complexType>
        </xs:element>
      </xs:sequence>
    </xs:complexType>
  </xs:element>

  <xs:element name="section">
    <xs:annotation>
      <xs:documentation>section structure</xs:documentation>
    </xs:annotation>
    <xs:complexType mixed="true">
      <xs:sequence>
        <xs:annotation>
          <xs:documentation>At least one paragraph</xs:documentation>
        </xs:annotation>
        <xs:element ref="para" minOccurs="1" maxOccurs="unbounded" />
      </xs:sequence>
      <xs:attributeGroup ref="genericPropertiesGroup" />
      <xs:attribute name="type" type="xs:string" use="optional" default="chapter">
        <xs:annotation>
          <xs:documentation>
            The type or role for the paragraph as in data-role or epub:type
          </xs:documentation>
        </xs:annotation>
      </xs:attribute>
    </xs:complexType>
  </xs:element>

  <xs:element name="book">
    <xs:annotation>
      <xs:documentation>
        The main book element and its children
      </xs:documentation>
    </xs:annotation>
    <xs:complexType mixed="true">
      <xs:annotation>
        <xs:documentation>
          A sequence of one metadat section followed by 1 or more sections
        </xs:documentation>
      </xs:annotation>
      <xs:sequence>
        <xs:element ref="metadata" minOccurs="1" maxOccurs="1" />
        <xs:element ref="section" minOccurs="1" maxOccurs="unbounded" />
      </xs:sequence>
      <xs:attributeGroup ref="genericPropertiesGroup" />
    </xs:complexType>
  </xs:element>
</xs:schema>
```


## Converting our content into other formats

One of the biggest advantages of working with XML is that we can convert the abstract tags into other markups. For the purposes of this project we'll convert the XML created to match the schema we just created to HTML and then we'll convert it to [XSL Formating Objects](http://www.xml.com/pub/a/2002/03/20/xsl-fo.html) and then using tools like [Apache FOP](http://xmlgraphics.apache.org/fop/) or [RenderX](http://www.renderx.com/tools/xep.html) we'll conver the XSL-FO into PDF

### Why HTML

### Why PDF


## Creating our conversion stylesheets

```xml
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
```