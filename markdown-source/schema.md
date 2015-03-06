---
title: XML workflows: The XML Schema
category: Technology
status: draft
---

# The XML Schema

> This version of the documentation is based on commit 542178fb21 to the Github repository. Any differences between this document and the repository should be resolved in favor of the repository (repo is always right)

The idea behind the schema is to create as clean a document as possible. The base document uses classes and IDs to avoid having to add styles directy to the document and leaving all the styling to CSS. There are 2 exceptions for addresses (discussed when we look at the XML to XHTML conversion.)

We cover all the content for the schema but will only detail the things I belive are important to understand the choices I made and why the schema was created this way.


## Why a schema

There are many ways to define a schema. There is the original [XML Schema](http://www.w3.org/XML/Schema) from W3C, there is RelaxNG initially developed by OASIS in a [technical committee](https://www.oasis-open.org/committees/relax-ng/) and [Schematron](http://www.schematron.com/) defined as an ISO standard.

With all these choices why did I stick with Schema?

* It's the most widely supported
* It can be converted to RelaxNG or Schematron (an experimental conversion to RelaxNG is available in the rng directory of the repository)


You can work with either the Schema or RelaxNG version. This document will refer to the Schema.

## Getting started

As with all XML document the schema needs to define the XML Prologue (`&lt;?xml version="1.0" encoding="UTF-8"?>`), the root element (`&lt;xs:schema`), the namespaces we'll use for the project and the default forms for elements (`elementFormDefault="qualified"`) and attributes (`attributeFormDefault="unqualified"`)

```xml
&lt;?xml version="1.0" encoding="UTF-8"?>
&lt;xs:schema
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    elementFormDefault="qualified"
    attributeFormDefault="unqualified">
```

Form defaults refer to whether we need to add the namespace prefix to our default elements. To avoid confusion I've chosen to add namespace prefixes to all our elements (using `xs:` as the namespace prefix for the schema name space.) Doing that for attributes is unnecessary; it may not always be the case.

We begin the actual work in the schema by defining some basic types that will be the basis of elements and complex types later in the schema.

Most of the simeType elements are created by restriction. We base the element in one of the default Schema data types.

For example: token255 is based on the toke schema element and is restricted to a maximum length of 255 characters. When this length is not enough we can use strings or other data types.

```xml
&lt;!-- Simple types to use in the content -->
&lt;xs:simpleType name="token255">
  &lt;xs:restriction base="xs:token">
    &lt;xs:maxLength value="255"/>
  &lt;/xs:restriction>
&lt;/xs:simpleType>
```
ISBN-type10 uses string as its base and creates a regular expression to match the format of [ISBN](http://www.isbn.org/) codes used to identify books worldwide.

The ISBN element only matches one format. There are many formats that could match an ISBN record depending on where the book was published and which country it was registered in. There is a simple type element for ISBN numbers worldwide available at [XFront](http://xfront.com/isbn.html). The code can be incorporated to the schema at a later time.

```xml
&lt;xs:simpleType name="ISBN-type10">
  &lt;xs:restriction base="xs:string">
    &lt;xs:pattern value="0-[0-1][0-9]-\d{6}-[0-9x]"/>
  &lt;/xs:restriction>
&lt;/xs:simpleType>
```

the align simple type is an enumeration. We list all the possible values for align attribute so we can reference them later without having to type them all the time.

```xml
&lt;xs:simpleType name="align">
  &lt;xs:restriction base="xs:token">
    &lt;xs:enumeration value="left"/>
    &lt;xs:enumeration value="center"/>
    &lt;xs:enumeration value="right"/>
    &lt;xs:enumeration value="justify"/>
  &lt;/xs:restriction>
&lt;/xs:simpleType>
```

Languages are handled using an element types as the language primitive (`xs:language`.) We can use it anywhere in the schema where we are allowed to use children elements.

Another possibility is to convert it to an attribute and move it to the generic properties attribute group discussed below.

```xml
&lt;xs:element name="language" type="xs:language"/>
```

The attribute group element adds all the attributs with one statement. As it currently set up, it adds id and class attributes to the elements it's been added to. A future enhancement may be to add the language element as an attribute.

```xml
&lt;xs:attributeGroup name="genericPropertiesGroup">
  &lt;xs:attribute name="id" type="xs:ID" use="optional"/>
  &lt;xs:attribute name="class" type="xs:token" use="optional"/>
&lt;/xs:attributeGroup>
```

## Organization and children


Initially there was no organization element until the question came up: *What happens when an author is not a person but a company or group?*

We keep the organization element as generic as possible to make sure we can use it in different instances. The only thing we know we'll need is the organization's name... everything else can be added when we build elements on top of organization (like publisher, discussed below.)

Address is one of those additional elements we add to organization. Addresses are string based and use the U.S. model.

Finally we build a publisher element by putting together our organization and address elements. Notice how the complex type and the element are called differently.

```xml
&lt;xs:complexType name="organization">
  &lt;xs:all>
    &lt;xs:element name='name' type="xs:string"/>
  &lt;/xs:all>
&lt;/xs:complexType>

&lt;xs:element name="address">
  &lt;xs:complexType>
    &lt;xs:sequence>
      &lt;xs:element name="recipient" type="xs:string"/>
      &lt;xs:element name="street" type="xs:string"/>
      &lt;xs:element name="city" type="xs:string"/>
      &lt;xs:element name="state" type="xs:string"/>
      &lt;xs:element name="postcode" type="xs:string"/>
      &lt;xs:element name="country" type="xs:token"/>
    &lt;/xs:sequence>
  &lt;/xs:complexType>
&lt;/xs:element>

&lt;xs:element name="publisher">
  &lt;xs:complexType mixed="true">
    &lt;xs:all>
      &lt;xs:element name="name" type="organization"/>
      &lt;xs:element ref="address"/>
    &lt;/xs:all>
    &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
  &lt;/xs:complexType>
&lt;/xs:element>
```


## Person and children elements

We now move to define individuals and their roles.

The base class is person where we define a first-name and surname. We'll use this to create the roles for our different users with additional elements and attributes where necessary.

```xml
&lt;!-- complex types to create groups of similar person items -->
&lt;xs:complexType name="person">
  &lt;xs:sequence>
    &lt;xs:element name="first-name" type="xs:string"/>
    &lt;xs:element name="surname" type="xs:string"/>
  &lt;/xs:sequence>
&lt;/xs:complexType>
```

Author, editor and otherRole use person as the base and then add additional elements to expand the person based on the type of editor (for the editor element) or the role they play in the book (for otherRole.)

During initial develpment I thought I'd just only work with plural elements (authors, editors and otherRoles) but soon realized that it took a lot of flexibility out of the schema since there may be other places where we need this information. For example, we may have an edited volume where each chapter has one or more authors.

So we have individual author (directly based on person), editor (with a `type` attribute to indicate what kind of editor the person is) and otherRole (for roles other than editor we use this with the `role` attribute)

```xml
&lt;xs:complexType name="author">
  &lt;xs:complexContent>
    &lt;xs:extension base="person"/>
  &lt;/xs:complexContent>
&lt;/xs:complexType>

&lt;xs:complexType name="editor">
  &lt;xs:complexContent>
    &lt;xs:extension base="person">
      &lt;xs:choice>
        &lt;xs:element name="type" type="xs:string"/>
      &lt;/xs:choice>
    &lt;/xs:extension>
  &lt;/xs:complexContent>
&lt;/xs:complexType>

&lt;xs:complexType name="otherRole">
  &lt;xs:complexContent>
    &lt;xs:extension base="person">
      &lt;xs:sequence minOccurs="1" maxOccurs="1">
        &lt;xs:element name="role" type="xs:string"/>
      &lt;/xs:sequence>
    &lt;/xs:extension>
  &lt;/xs:complexContent>
&lt;/xs:complexType>
```

With individual roles created we can now create elements for multiple individuals.

Authors can have 1 or more author elements. At least 1 author is required for the document to validate, whether we choose to use it or not. Remember that the transformation (using XSLT) doesn't have to use all the elements on the XML source.

Editors and otherRoles wrap around individual elements (editor and otherRole) to provide an easier way to work with them in XSLT later on.

Also note that we require 0 or more instances of the base type, rather than 1. This is my way of making the element optional: either we have zero, one or more than one children.

```xml
&lt;!-- Wrappers around complext types -->
&lt;xs:element name="authors">
  &lt;xs:complexType mixed="true">
    &lt;xs:choice minOccurs="1" maxOccurs="unbounded">
      &lt;xs:element name="author" type="author"/>
    &lt;/xs:choice>
  &lt;/xs:complexType>
&lt;/xs:element>

&lt;xs:element name="editors">
  &lt;xs:complexType mixed="true">
    &lt;xs:sequence minOccurs="0" maxOccurs="unbounded">
      &lt;xs:element name="editor" type="editor"/>
    &lt;/xs:sequence>
  &lt;/xs:complexType>
&lt;/xs:element>

&lt;xs:element name="otherRoles">
  &lt;xs:complexType mixed="true">
    &lt;xs:sequence minOccurs="0" maxOccurs="unbounded">
      &lt;xs:element name="otherRole" type="otherRole"/>
    &lt;/xs:sequence>
  &lt;/xs:complexType>
&lt;/xs:element>
```

## Metadata and publishing information

In order to acommodate publishing information, we add multiple publishing related elements to account for publishing and publishing related information.

Most of these elements (except pubdate) are made of 1 or more paragraphs.

```xml
&lt;xs:element name="releaseinfo">
  &lt;xs:complexType mixed="true">
    &lt;xs:choice minOccurs="1" maxOccurs="unbounded">
      &lt;xs:element ref="para"/>
    &lt;/xs:choice>
  &lt;/xs:complexType>
&lt;/xs:element>

&lt;xs:element name="copyright">
  &lt;xs:complexType mixed="true">
    &lt;xs:choice minOccurs="1" maxOccurs="unbounded">
      &lt;xs:element ref="para"/>
    &lt;/xs:choice>
  &lt;/xs:complexType>
&lt;/xs:element>

&lt;xs:element name="legalnotice">
  &lt;xs:complexType mixed="true">
    &lt;xs:choice minOccurs="1" maxOccurs="unbounded">
      &lt;xs:element ref="para"/>
    &lt;/xs:choice>
  &lt;/xs:complexType>
&lt;/xs:element>

&lt;xs:element name="abstract">
  &lt;xs:complexType mixed="true">
      &lt;xs:choice minOccurs="1" maxOccurs="unbounded">
          &lt;xs:element ref="para"/>
      &lt;/xs:choice>
  &lt;/xs:complexType>
&lt;/xs:element>
```


The date is different as it's based on the date schema type which in turn it's based on the [ISO 8601](http://www.wikiwand.com/en/ISO_8601) standard.

An example of a valid ISO 8601 date is: `2015-02-28`

This is also the standard that handles time so, in theory, we could build a date/time structure including a date formated like the example above plus time and timezone offset but, unless we're required to we will avoid that much level of detail.

```xml
&lt;xs:element name="pubdate" type="xs:date"/>
```

The idea behind revision and revhistory is to provide an accountability chain for the publication's history. We can have one or more paragraphs where we outline the following information:

* Revision number
* Date
* Author's name
* Revision description/notes

In a future release we'll make these elements explicit. Until then paragraphs seem a flexible enouh solution

```xml
&lt;xs:element name="revision">
  &lt;xs:complexType mixed="true">
    &lt;xs:choice minOccurs="1" maxOccurs="unbounded">
      &lt;xs:element ref="para"/>
    &lt;/xs:choice>
  &lt;/xs:complexType>
&lt;/xs:element>

&lt;xs:element name="revhistory">
  &lt;xs:complexType mixed="true">
    &lt;xs:sequence minOccurs="1" maxOccurs="unbounded">
      &lt;xs:element ref="revision"/>
    &lt;/xs:sequence>
  &lt;/xs:complexType>
&lt;/xs:element>
```

## Links and related elements

```xml
    &lt;!-- Links -->
    &lt;xs:element name="link">
        &lt;/xs:annotation>
        &lt;xs:complexType>
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="href" type="xs:anyURI" use="required"/>
            &lt;xs:attribute name="label" type="xs:token" use="required"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;!-- Named Anchor -->
    &lt;xs:element name="anchor">
        &lt;xs:complexType>
            &lt;xs:attributeGroup ref="genericPropertiesGroup" />
        &lt;/xs:complexType>
    &lt;/xs:element>
```

## Div and span

```xml
    &lt;!-- Div and Span elements -->
    &lt;xs:element name="div">
      &lt;xs:complexType mixed="true">
        &lt;xs:sequence>
          &lt;xs:choice minOccurs="0" maxOccurs="unbounded">
            &lt;xs:element ref="language"/>
            &lt;xs:element ref="anchor"/>
            &lt;xs:element ref="code"/>
            &lt;xs:element ref="para"/>
            &lt;xs:element ref="ulist"/>
            &lt;xs:element ref="olist"/>
            &lt;xs:element ref="figure"/>
            &lt;xs:element ref="image"/>
            &lt;xs:element ref="div"/>
            &lt;xs:element ref="span"/>
            &lt;xs:element ref="blockquote"/>
            &lt;xs:element ref="video"/>
            &lt;xs:element ref="aside"/>
            &lt;xs:element ref="h1"/>
            &lt;xs:element ref="h2"/>
            &lt;xs:element ref="h3"/>
            &lt;xs:element ref="h4"/>
            &lt;xs:element ref="h5"/>
            &lt;xs:element ref="h6"/>
          &lt;/xs:choice>
        &lt;/xs:sequence>
        &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
        &lt;xs:attribute name="type" type="xs:token" use="optional"/>
      &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="span">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Allows for inline content using span

                class and id attributes from genericPropertiesGroup

                type is use to create data-type and/or epub:type annotations
            &lt;/xs:documentation>
        &lt;/xs:annotation>
      &lt;xs:complexType mixed="true">
        &lt;xs:choice  minOccurs="0" maxOccurs="unbounded">
         &lt;xs:element ref="language"/>
          &lt;xs:element ref="strong"/>
          &lt;xs:element ref="emphasis"/>
          &lt;xs:element ref="underline"/>
          &lt;xs:element ref="strike"/>
          &lt;xs:element ref="link"/>
          &lt;xs:element ref="span"/>
          &lt;xs:element ref="quote"/>
        &lt;/xs:choice>
          &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
          &lt;xs:attribute name="type" type="xs:token" use="optional"/>
      &lt;/xs:complexType>
    &lt;/xs:element>
```

## Figure and image

```xml
    &lt;!-- Figure and related elements -->
    &lt;!--
        The schema accepts both images and figures as children of section to
        accomodate images with and without captions
    -->
    &lt;xs:element name="figure">
        &lt;xs:complexType mixed="true">
            &lt;xs:all>
                &lt;xs:element ref="anchor"/>
                &lt;xs:element ref="image"/>
                &lt;xs:element ref="figcaption"/>
            &lt;/xs:all>
            &lt;xs:attribute name="height" type="xs:nonNegativeInteger" use="optional"/>
            &lt;xs:attribute name="width" type="xs:nonNegativeInteger" use="optional"/>
            &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
          &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="figcaption"/>

    &lt;xs:element name="image">
        &lt;xs:complexType>
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="src" type="xs:token" use="required"/>
            &lt;xs:attribute name="height" type="xs:nonNegativeInteger" use="required"/>
            &lt;xs:attribute name="width" type="xs:nonNegativeInteger" use="required"/>
            &lt;xs:attribute name="alt" type="token255" use="required"/>
            &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
        &lt;/xs:complexType>
    &lt;/xs:element>
```

## Video

```xml
    &lt;!-- Video and multimedia -->
    &lt;xs:element name="video">
      &lt;xs:complexType mixed="true">
        &lt;xs:choice minOccurs="1" maxOccurs="unbounded">
          &lt;xs:element ref="source"/>
          &lt;xs:element ref="track"/>
        &lt;/xs:choice>
        &lt;xs:attribute name="height" type="xs:nonNegativeInteger"/>
        &lt;xs:attribute name="width" type="xs:nonNegativeInteger"/>
        &lt;xs:attribute name="controls" type='xs:string' use="optional"/>
        &lt;xs:attribute name="poster" type="xs:anyURI" use="optional"/>
        &lt;xs:attribute name="autoplay" type="xs:string" use="optional"/>
        &lt;xs:attribute name="preload" type="xs:string" use="optional" default="none"/>
        &lt;xs:attribute name="loop" type="xs:string" use="optional"/>
        &lt;xs:attribute name="muted" type="xs:string" use="optional"/>
      &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="source">
      &lt;xs:complexType>
        &lt;xs:attribute name="src" type='xs:string' use="required"/>
        &lt;xs:attribute name="type" type='xs:string' use="optional"/>
      &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="track">
      &lt;xs:complexType>
        &lt;xs:attribute name="src" type='xs:string' use="required"/>
        &lt;xs:attribute name="label" type='xs:string' use="required"/>
        &lt;xs:attribute name="kind" type='xs:string'/>
        &lt;xs:attribute name="srclang" type='xs:string' default='en'/>
      &lt;/xs:complexType>
    &lt;/xs:element>
```

## Styles

```xml
    &lt;!-- Style elements -->
    &lt;xs:element name="strong">
        &lt;xs:annotation>
            &lt;xs:documentation>
                The strong element can have 0 or more children chosen form: emphasis, underline and span

                Nested strong elements are not allowed
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:choice minOccurs="0" maxOccurs="unbounded">
                &lt;xs:element ref="emphasis"/>
                &lt;xs:element ref="underline"/>
                &lt;xs:element ref="strike"/>
            &lt;/xs:choice>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="emphasis">
        &lt;xs:complexType mixed="true">
            &lt;xs:choice minOccurs="0" maxOccurs="unbounded">
                &lt;xs:element ref="strong"/>
                &lt;xs:element ref="emphasis"/>
                &lt;xs:element ref="underline"/>
                &lt;xs:element ref="strike"/>
            &lt;/xs:choice>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="underline">
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:choice minOccurs="0" maxOccurs="unbounded">
                &lt;xs:element ref="strong"/>
                &lt;xs:element ref="emphasis"/>
                &lt;xs:element ref="strike"/>
            &lt;/xs:choice>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="strike">
        &lt;xs:complexType mixed="true">
            &lt;xs:choice minOccurs="0" maxOccurs="unbounded">
                &lt;xs:element ref="strong"/>
                &lt;xs:element ref="emphasis"/>
                &lt;xs:element ref="underline"/>
            &lt;/xs:choice>
        &lt;/xs:complexType>
    &lt;/xs:element>
```

## Lists

```
    &lt;!-- Lists -->
    &lt;xs:element name="ulist">
        &lt;xs:complexType mixed="true">
            &lt;xs:choice minOccurs="1" maxOccurs="unbounded">
              &lt;xs:element ref="item"/>
              &lt;xs:element ref="olist"/>
              &lt;xs:element ref="ulist"/>
            &lt;/xs:choice>
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="olist">
        &lt;xs:complexType mixed="true">
            &lt;xs:choice minOccurs="1" maxOccurs="unbounded">
                &lt;xs:element ref="item"/>
                &lt;xs:element ref="olist"/>
                &lt;xs:element ref="ulist"/>
            &lt;/xs:choice>
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="item">
      &lt;xs:complexType mixed="true">
        &lt;xs:choice  minOccurs="0" maxOccurs="unbounded">
          &lt;xs:element ref="strong"/>
          &lt;xs:element ref="emphasis"/>
          &lt;xs:element ref="underline"/>
          &lt;xs:element ref="strike"/>
          &lt;xs:element ref="link"/>
          &lt;xs:element ref="span"/>
          &lt;xs:element ref="quote"/>
        &lt;/xs:choice>
        &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
      &lt;/xs:complexType>
    &lt;/xs:element>
```

## Fenced code blocks

```xml
    &lt;!-- Fenced code blocks -->
    &lt;xs:element name="code">
        &lt;xs:complexType mixed="true">
            &lt;xs:sequence minOccurs="0" maxOccurs="1">
              &lt;xs:element ref="anchor"/>
            &lt;/xs:sequence>
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="language" use="required"/>
        &lt;/xs:complexType>
    &lt;/xs:element>
```

## Blockquotes, asides and marginalia

```xml
    &lt;!-- Blockquotes, asides and marginalia -->
    &lt;xs:element name="attribution">
      &lt;xs:annotation>
        &lt;xs:documentation>
          Who said it
        &lt;/xs:documentation>
      &lt;/xs:annotation>
      &lt;xs:complexType mixed="true">
        &lt;xs:choice  minOccurs="0" maxOccurs="unbounded">
          &lt;xs:element ref="para"/>
        &lt;/xs:choice>
        &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
      &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="blockquote">
      &lt;xs:annotation>
        &lt;xs:documentation>
          We use blockquote for longer, block level, quotations
        &lt;/xs:documentation>
      &lt;/xs:annotation>
      &lt;xs:complexType mixed="true">
        &lt;xs:choice maxOccurs="unbounded">
            &lt;xs:element ref="language" minOccurs="0"/>
          &lt;xs:element ref="anchor"/>
          &lt;xs:element ref="attribution"/>
          &lt;xs:element ref="para"/>
        &lt;/xs:choice>
        &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
      &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="quote">
    &lt;xs:annotation>
      &lt;xs:documentation>
        Shorter, inline, quotations
      &lt;/xs:documentation>
    &lt;/xs:annotation>
    &lt;xs:complexType mixed="true">
      &lt;xs:all>
          &lt;xs:element ref="language"/>
      &lt;/xs:all>
      &lt;xs:attribute name="cite" type="xs:anyURI" use="optional"/>
      &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
    &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="aside">
    &lt;xs:annotation>
    &lt;xs:documentation>
      Asides, smaller pieces of content not directly related to the main text
    &lt;/xs:documentation>
    &lt;/xs:annotation>
    &lt;xs:complexType mixed="true">
    &lt;xs:sequence>
      &lt;xs:annotation>
        &lt;xs:documentation>At least one paragraph &lt;/xs:documentation>
      &lt;/xs:annotation>
      &lt;xs:choice minOccurs="0" maxOccurs="unbounded">
        &lt;xs:element ref="code"/>
        &lt;xs:element ref="para" minOccurs="1" maxOccurs="unbounded"/>
        &lt;xs:element ref="ulist"/>
        &lt;xs:element ref="olist"/>
        &lt;xs:element ref="figure"/>
        &lt;xs:element ref="image"/>
        &lt;xs:element ref="div"/>
        &lt;xs:element ref="span"/>
        &lt;xs:element ref="blockquote"/>
        &lt;xs:element ref="h1"/>
        &lt;xs:element ref="h2"/>
        &lt;xs:element ref="h3"/>
        &lt;xs:element ref="h4"/>
        &lt;xs:element ref="h5"/>
        &lt;xs:element ref="h6"/>
      &lt;/xs:choice>
    &lt;/xs:sequence>
    &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
    &lt;xs:attribute name="type" type="xs:token" use="optional"/>
    &lt;/xs:complexType>
    &lt;/xs:element>
```

## Paragraphs

```xml
    &lt;!-- Paragraphs -->
    &lt;xs:element name="para">
      &lt;xs:complexType mixed="true">
        &lt;xs:choice  minOccurs="0" maxOccurs="unbounded">
          &lt;xs:element ref="language"/>
          &lt;xs:element ref="strong"/>
          &lt;xs:element ref="emphasis"/>
          &lt;xs:element ref="underline"/>
          &lt;xs:element ref="strike"/>
          &lt;xs:element ref="link"/>
          &lt;xs:element ref="span"/>
          &lt;xs:element ref="quote"/>
        &lt;/xs:choice>
        &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
        &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
      &lt;/xs:complexType>
    &lt;/xs:element>
```

## Headings

```xml
    &lt;!-- Headings -->
    &lt;xs:element name="h1">
        &lt;xs:complexType mixed="true">
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="h2">
        &lt;xs:complexType mixed="true">
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="h3">
        &lt;xs:complexType mixed="true">
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="h4">
        &lt;xs:complexType mixed="true">
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="h5">
        &lt;xs:complexType mixed="true">
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="h6">
        &lt;xs:complexType mixed="true">
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
        &lt;/xs:complexType>
    &lt;/xs:element>
```

## Metadata element

```xml
    &lt;!-- Metadata element -->
    &lt;xs:element name="metadata">
        &lt;xs:complexType>
            &lt;xs:choice minOccurs="0" maxOccurs="unbounded">
                &lt;xs:element name="isbn" type="ISBN-type10"/>
                &lt;xs:element name="edition" type="xs:string"/>
                &lt;xs:element ref="authors"/>
                &lt;xs:element ref="editors"/>
                &lt;xs:element ref="otherRoles"/>
                &lt;xs:element ref="publisher"/>
                &lt;xs:element ref="releaseinfo"/>
                &lt;xs:element ref="copyright"/>
                &lt;xs:element ref="legalnotice"/>
                &lt;xs:element name="title" type="xs:string"/>
                &lt;xs:element name="subtitle" type="xs:string"/>
                &lt;xs:element ref="language"/>
                &lt;xs:element ref="revhistory" minOccurs="0"/>
                &lt;!--
                    We allow para here to make sure  we can write
                    text as for the metadata
                -->
                &lt;xs:element ref="para"/>
            &lt;/xs:choice>
        &lt;/xs:complexType>
    &lt;/xs:element>
```

## Section element

```xml
    &lt;!-- Section element -->
    &lt;xs:element name="section">
        &lt;xs:complexType mixed="true">
            &lt;xs:sequence>
                &lt;xs:element name="title" type="xs:token" minOccurs="0" maxOccurs="1"/>
                &lt;xs:choice minOccurs="0" maxOccurs="unbounded">
                    &lt;xs:element ref="anchor"/>
                    &lt;xs:element ref="code"/>
                    &lt;xs:element ref="para" minOccurs="1" maxOccurs="unbounded"/>
                    &lt;xs:element ref="ulist"/>
                    &lt;xs:element ref="olist"/>
                    &lt;xs:element ref="figure"/>
                    &lt;xs:element ref="image"/>
                    &lt;xs:element ref="div"/>
                    &lt;xs:element ref="span"/>
                    &lt;xs:element ref="blockquote"/>
                    &lt;xs:element ref="video"/>
                    &lt;xs:element ref="aside"/>
                    &lt;xs:element ref="h1"/>
                    &lt;xs:element ref="h2"/>
                    &lt;xs:element ref="h3"/>
                    &lt;xs:element ref="h4"/>
                    &lt;xs:element ref="h5"/>
                    &lt;xs:element ref="h6"/>
                &lt;/xs:choice>
            &lt;/xs:sequence>
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="type" type="xs:token" use="optional" default="chapter">
            &lt;/xs:attribute>
        &lt;/xs:complexType>
    &lt;/xs:element>
```

## Table of  contents placeholder

```xml
    &lt;!-- Testing to see if we really need a separate toc element -->
    &lt;xs:element name="toc">
      &lt;xs:annotation>
        &lt;xs:documentation>
          Placeholder for generated table of contents
        &lt;/xs:documentation>
      &lt;/xs:annotation>
    &lt;/xs:element>
```

## Puting it al together: The book element

```xml
    &lt;!-- Base book element -->
    &lt;xs:element name="book">
        &lt;xs:complexType mixed="true">
            &lt;xs:choice maxOccurs="unbounded">
                &lt;xs:element ref="metadata" minOccurs="0" maxOccurs="1"/>
                &lt;xs:element ref="toc" minOccurs="0" maxOccurs="1"/>
                &lt;xs:element ref="section" minOccurs="1" maxOccurs="unbounded"/>
            &lt;/xs:choice>
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
        &lt;/xs:complexType>
    &lt;/xs:element>
&lt;/xs:schema>
```
