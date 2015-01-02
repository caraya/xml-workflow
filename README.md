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

The root element is `book` the book has exactly 1 `metadata` section and 1 or more (at least 1 with no upper limit) `section`. I thought about including the metadata at the section level but it would add too much repetitive markup in places where it may not be necessary. 

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
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<xs:schema 
           xmlns:xs="http://www.w3.org/2001/XMLSchema" 
           elementFormDefault="qualified" 
           attributeFormDefault="unqualified">

  <!-- Simple types to use in the content -->
  <xs:simpleType name="string255">
    <xs:annotation>
      <xs:documentation>Defines a string of no more than 255 characters</xs:documentation>
    </xs:annotation>
    <xs:restriction base="xs:token">
      <xs:maxLength value="255" />
    </xs:restriction>
  </xs:simpleType>

  <xs:simpleType name="isbn">
    <xs:annotation>
      <xs:documentation>Defines a regular expression to match an ISBN number. Regex needs to be refined</xs:documentation>
    </xs:annotation>
    <xs:restriction base="xs:unsignedLong">
      <xs:totalDigits value="10" />
      <xs:pattern value="\d{10}" />
    </xs:restriction>
  </xs:simpleType>

  <xs:simpleType name="align">
    <xs:annotation>
      <xs:documentation>Attribute ennumeration for elements that can be aligned</xs:documentation>
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
        <xs:documentation>ID for the paragraph if any</xs:documentation>
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


## Converting our content into HTML

One of the biggest advantages of working with XML 

## Is HTML the only option?

