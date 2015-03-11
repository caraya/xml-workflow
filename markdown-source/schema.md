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

* Revision number (cast as a string)
* Date (using the pubdate element defined earlier)
* Author's initials (short 255 character string)
* Revision description/notes (short 255 character string)

The revhistory element is a set of one or more revisions. We'll use XSLT to put them in na div tag or inside a table structure.

```xml
&lt;xs:element name="revision">
  &lt;xs:complexType mixed="true">
    &lt;xs:all>
      &lt;xs:element name="revnumber" type="xs:string"/>
      &lt;xs:element ref="pubdate"/>
      &lt;xs:element name="authorinitials" type="token255"/>
      &lt;xs:element name="revnotes" type="token255"/>
    &lt;/xs:all>
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

Links are essential to the web. They allow us to connect our content to other elements inside and outside the pages we create. We add class and ID from `genericPropertiesGroup` and two new elements:

* `href` indicates the URL (local or relative) we are linking to
* `label` used as the text of the link and also the label attribute created for accessibility

```xml
&lt;!-- Links -->
&lt;xs:element name="link">
  &lt;xs:complexType>
    &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
    &lt;xs:attribute name="href" type="xs:anyURI" use="required"/>
    &lt;xs:attribute name="label" type="xs:string" use="required"/>
  &lt;/xs:complexType>
&lt;/xs:element>
```

### About the xs:anyURI data type

> Some information and examples for this section taken from [http://www.datypic.com/sc/xsd/t-xsd_anyURI.html](http://www.datypic.com/sc/xsd/t-xsd_anyURI.html)


Unti I used the value xs:anyURI I wasn't sure what it did and how much work it would actually save me. I thought it was just another name for URLs but they are much more and the amount of work they save is significant.

URI (uniform resource indicator) are a superset of the web's URL. There are two main types of URIs: absolute and relative.

Absolute URIs provide the entire context for locating the resources, such as **http://datypic.com/prod.html**.

Relative URIs are specified as the difference from a base URI, such as **../prod.html**. It is also possible to specify a fragment identifier, using the # character, such as **../prod.html#shirt**. Note that when relative URI references such as "../prod" are used as values of xsd:anyURI there is no attempt at tracking what the base of the URI is.

The three previous examples happen to be HTTP URLs (Uniform Resource Locators), but URIs also encompass URLs of other schemes (e.g., FTP, gopher, telnet), as well as URNs (Uniform Resource Names). URIs doen't have to exist to be valid; there is no need for a resource to live at http://datypic.com/prod.html for the URI pointing to it to validate.

URIs require that some characters be escaped with their hexadecimal Unicode code point preceded by the % character. This includes non-ASCII characters and some ASCII characters, namely control characters, spaces, and the following characters (unless they are used as deliimiters in the URI): &lt;>#%{}|\^`. For example, **../édition.html** must be represented instead as **../%C3%A9dition.html**, with the é escaped as %C3%A9. However, the anyURI type will accept these characters either escaped or unescaped. With the exception of the characters % and #, it will assume that unescaped characters are intended to be escaped when used in an actual URI, although the schema processor will do nothing to alter them. It is valid for an anyURI value to contain a space, but this practice is strongly discouraged. Spaces should instead be escaped using %20.

The schema processor is not required to parse the contents of an xsd:anyURI value to determine whether it is valid according to any particular URI scheme. Since the bare minimum rules for valid URI references are fairly generic, the schema processor will accept most character strings, including an empty value. The only values that are not accepted are ones that make inappropriate use of reserved characters, such as ones that contain multiple # characters or have % characters that are not followed by two hexadecimal digits.

For more information on URIs, see [RFC 2396, Uniform Resource Identifiers (URI): Generic Syntax](https://www.ietf.org/rfc/rfc2396.txt).

**Valid URI matching xs:anyURI**

* http://datypic.com **absolute URI (also a URL)**
* mailto:info@datypic.com **absolute URI**
* ../%C3%A9dition.html	**relative URI containing escaped non-ASCII character**
* ../édition.html	**relative URI containing unescaped non-ASCII character**
* http://datypic.com/prod.html#shirt **URI with fragment identifier**
* ../prod.html#shirt **relative URI with fragment identifier**
* urn:example:org **URN**
* an empty value is allowed

## Div and spanxx

Div and Span are subcontainers for block level elements (div) and inline elements (span). As containers I have to decide what elements are allowed as children and that's not always easy; any time we add a new element to the schema we have to decide if we're using it as a block element (that can be used inside a div) and/or an inline element (and whether that inline element can be used inside a span.)

The only special thing about div and span is the additional attribute `type`. We use type to build `data-type` and `epub:type` attributes. ePub and Edupub have lists of allowed values for the attribute and it's a good starting point for work with Javascript or additional functionality.

Div is a subsection of our section elements. Most of the elements that we can add to a section are also valid inside a div, including other div elements.

Span is used mostly to hold styles that apply to part of a paragraph and can be nested to build more elaborate effects and styles using class and id attributes.

```xml
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

Figure and image are the two ways the schema provides for working with images. Rather than make several elements and attributes optional and make the image elements brittle we allow both a figure element with caption and image children and an image without caption.

Most of the time I will use the figure/caption/image combination to give a numbering schema when performing the transformations.

Captions are made of a single paragraph with all the children available to paragraphs elsewhere. This way we can add links and styles to the captions.

One last thing to note about figures and images: Since figure and image have the same attributes we can combine them in different combinations. For example: we can have a left centered figure and caption with a right-aligned image inside.

```xml
&lt;xs:element name="figure">
  &lt;xs:complexType mixed="true">
    &lt;xs:all>
      &lt;xs:element ref="image"/>
      &lt;xs:element ref="figcaption"/>
    &lt;/xs:all>
    &lt;xs:attribute name="height" type="xs:nonNegativeInteger" use="optional"/>
    &lt;xs:attribute name="width" type="xs:nonNegativeInteger" use="optional"/>
    &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
    &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
  &lt;/xs:complexType>
&lt;/xs:element>

&lt;xs:element name="figcaption">
  &lt;xs:complexType>
    &lt;xs:sequence>
      &lt;xs:element ref="para"/>
    &lt;/xs:sequence>
  &lt;/xs:complexType>
&lt;/xs:element>

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

Video is a rather complex subject. According to the [specification](http://www.w3.org/html/wg/drafts/html/master/semantics.html#the-video-element) there are two ways to create video elements. I've chosen to adopt the multi-source element rather than a single src attribute to the video tag itself.

We use two children element: source and track.

The `source` element is for the actual video content. The element contains two attributes: `src` indicates the location of the video source. Type indicates the mimetype of the video and, optionally the codecs that were used to encode the video. This is particularly important with MP4 video as there are muliple "profiles" that may or may not be supported in all devices.

At least one of source element is required.


The track element is used to provide additional information to the video using the [VTT community specification](http://dev.w3.org/html5/webvtt/). You can use VTT to provide captioning and subtitles in multiple languages allowing the user to decide what language and what type of track they want to use with the video.

There are other uses for VTT tracks discussed in the HTML5 video captioning article listed in resources.

### Attributes for video tag

* width — Horizontal dimension
* height — Vertical dimension
* poster — Poster frame to show prior to video playback
* preload — Hints how much buffering the media resource will likely need
* autoplay — Hint that the media resource can be started automatically when the page is loaded
* loop — Whether to loop the media resource
* muted — Whether to mute the media resource by default
* controls — Show user agent controls

### Additional Resources

* [HTML5 video specification](http://www.w3.org/html/wg/drafts/html/master/semantics.html#the-video-element)
* [WebVTT Draft Community Specification](http://dev.w3.org/html5/webvtt/)
* [Video in ePub](http://publishing-project.rivendellweb.net/video-in-epub/) discusses HTML5 video. While written for ePub it is also applicable to HTML5 content in general
* [HTML5 video captioning using VTT](http://publishing-project.rivendellweb.net/html5-video-captioning-using-vtt/) discusses captioning video using VTT tracks


```xml
    &lt;!-- Video and multimedia -->
    &lt;xs:element name="video">
      &lt;xs:complexType mixed="true">
        &lt;xs:choice>
          &lt;xs:element ref="source" minOccurs="1" maxOccurs="unbounded"/>
          &lt;xs:element ref="track" minOccurs="0" maxOccurs="unbounded"/>
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

Styles are hints for the transformation engine to apply rules and classes to the enclosed elements. We allow for nested styles by indetifying what styles can nest inside each of our four basic styles.

Emphasis is the only style that can be nested in itself. The idea is that if an emphasis element is nested inside another emphasis it will display as normal text.

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

When I originally conceived the schema I had only one list element that, based on a type attribute, would generate the correct type of list (numbered or bulleted.) as I was implementing this I trealized it was too brittle and hard to work with and hard to maintain.

So I broke the element into two separate list elements; one for bulleted (`ulist`) and one for numbered (`olist`) lists. They can also nest other list elements (of either tupe) inside.

They share a common `item` element that contains a reduced subset of the paragraph element content. We don't want a full paragraph in each item because they'll mess up the display when we convert them to HTML or PDF. We do want the ability to style the content, link or provide span and quotes elements.

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

I love the way Github displays fenced code blocks and wanted to get my HTML and, if possible, the PDF generated from XML to look similar to it. After researching the issue I found out code highlighting libraries for the web. The one I chose ([highlight.js](https://highlightjs.org/)) also works with PrinceXML (with some extra work.)

The schema defines the container for the code, the XSLT transformations, discussed in a later chapter, add the appropriate HTML tags and scripts to highlight the code and PrinceXML will honor the code highlight in the HTML and display it in the resulting PDF.

```xml
    &lt;!-- Fenced code blocks -->
    &lt;xs:element name="code">
        &lt;xs:complexType mixed="true">
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="language" use="required"/>
        &lt;/xs:complexType>
    &lt;/xs:element>
```

## Blockquotes, asides and marginalia

> Element descriptions taken from the [HTML5 nightly specification](http://www.w3.org/html/wg/drafts/html/master/semantics.html)

Blockquotes, asides and quotes provide related or parenthetical content.

The blockquote element represents content that is quoted from another source, optionally with a citation which must be within a footer or cite element, and optionally with in-line changes such as annotations and abbreviations.

The aside element represents a section of a page that consists of content that is tangentially related to the content around the aside element, and which could be considered separate from that content. Such sections are often represented as sidebars in printed typography. It can be used for typographical effects like pull quotes or sidebars, for advertising, for groups of nav elements, and for other content that is considered separate from the main content of the page.

It's not appropriate to use the aside element just for parentheticals, since those are part of the main flow of the document.

Attribution corresponds
```xml
&lt;!-- Blockquotes, asides and marginalia -->
&lt;xs:element name="attribution">
  &lt;xs:complexType mixed="true">
    &lt;xs:choice  minOccurs="0" maxOccurs="unbounded">
      &lt;xs:element ref="para"/>
    &lt;/xs:choice>
    &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
  &lt;/xs:complexType>
&lt;/xs:element>

&lt;xs:element name="blockquote">
  &lt;xs:complexType mixed="true">
    &lt;xs:choice>
      &lt;xs:element ref="language" minOccurs="0"/>
      &lt;xs:element ref="anchor"/>
      &lt;xs:element ref="attribution"/>
      &lt;xs:element ref="para" minOccurs="1"/>
    &lt;/xs:choice>
    &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
  &lt;/xs:complexType>
&lt;/xs:element>

&lt;xs:element name="aside">
  &lt;xs:complexType mixed="true">
    &lt;xs:sequence>
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

The quote element represents some inline content quoted from another source.

Content inside a quote element must be quoted from another source, whose address, if it has one, may be cited in the cite attribute. The source may be fictional, as when quoting characters in a novel or screenplay.

If the cite attribute is present, it must be a valid URL potentially surrounded by spaces. To obtain the corresponding citation link, the value of the attribute must be resolved relative to the element. User agents may allow users to follow such citation links, but they are primarily intended for private use (e.g. by server-side scripts collecting statistics about a site's use of quotations), not for readers.

The quote element must not be used in place of quotation marks that do not represent quotes; for example, it is inappropriate to use the quote element for marking up sarcastic statements.

```xml
&lt;xs:element name="quote">
  &lt;xs:complexType mixed="true">
    &lt;xs:all>
      &lt;xs:element ref="language"/>
    &lt;/xs:all>
    &lt;xs:attribute name="cite" type="xs:anyURI" use="optional"/>
    &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
  &lt;/xs:complexType>
&lt;/xs:element>
```

## Paragraphs

The paragraph is our main unit of content and where we do most, if not all, our inline styling of elements (indicated by what children elements are allowed to the paragraph)

In addition to the genericPropertiesGroup attributes, we also use align to control the horizontal alignment of the paragraph. This is useful when the paragraph is inside an attribution and I'd like the attribution to be right aligned while keeping the paragraph aligned to the left.

```xml
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

Headins should be self explainatory. They are used to indicate headings and structure in the document. While we only show the level 1 heading, the other levels (h2 thought h6) share the same structure.

```xml
&lt;xs:element name="h1">
  &lt;xs:complexType mixed="true">
    &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
    &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
  &lt;/xs:complexType>
&lt;/xs:element>
```

## Metadata element

The metadata element contains all the elements for our publication that are not content. Information such as copyright, legal notices, publisher, author and staff information.

I placed it in a separate element rather than incorporate it in a section with the appropriate type because keeping it separate makes it easier to transfor and pick the order and the types of elements we'll use for each type of document we generate.

Having a separate metadata element makes it easier to add or take away elements as needed.

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
      &lt;xs:element ref="para"/>
    &lt;/xs:choice>
  &lt;/xs:complexType>
&lt;/xs:element>
```

## Section element

Sections are the primary container for our documents. It is at this level that we will create separate files when I start looking at multiple output.

I also use the `type` attribute here to indicate the type of section it is. The default value for it is chapter since it's the one I use most often.  I've been thinking whether I want to create an enumeration of all the different values for type (based on epub and edupub profiles) to make it easier to create (oXygen gives me a list of all possible values for type and it currently only shows the default.)

Other than the title element, defined as a string schema type, all other elements reference reference other elements in the schema.

It derives class and id from our genericPropertiesGroup and the type attribute.

```xml
&lt;!-- Section element -->
&lt;xs:element name="section">
  &lt;xs:complexType mixed="true">
    &lt;xs:sequence>
      &lt;xs:element name="title" type="xs:string" minOccurs="0" maxOccurs="1"/>
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
    &lt;xs:attribute name="type" type="xs:token" use="optional" default="chapter"/>
  &lt;/xs:complexType>
&lt;/xs:element>
```

## Table of contents placeholder

Even though we're generating the table of contents in the transformation stage of the process I still need an element to tell the script where to place the generated table of contents.

Since this is a placeholder element we don't assign attributes or children elemetns.

```xml
&lt;xs:element name="toc"/>
```

## Puting it al together: The book element

The last thing to do is to put the structure of the book together. As currently outlined, the structure is metadata, followed by the table of contents placeholder and 1 or more sections where only 1 section element is required.

The idea for making 1 section required and nothing else is that, sometimes, we're writing something quick where I don't really want metadata information or a table of contents. Since the section element already has a title I can get away with using only that for the document.

```xml
&lt;!-- Base book element -->
&lt;xs:element name="book">
  &lt;xs:complexType mixed="true">
    &lt;xs:choice>
      &lt;xs:element ref="metadata" minOccurs="0" maxOccurs="1"/>
      &lt;xs:element ref="toc" minOccurs="0" maxOccurs="1"/>
      &lt;xs:element ref="section" minOccurs="1" maxOccurs="unbounded"/>
    &lt;/xs:choice>
    &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
  &lt;/xs:complexType>
&lt;/xs:element>
&lt;/xs:schema>
```
