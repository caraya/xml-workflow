---
title: XML workflows: The Schema
category: Technology
status: draft
---

One of the biggest limitations of markup languages, in my opinion, is how confining they are. Even large vocabularies like [Docbook](http://docbook.org) are limited in what they can do out of the box. HTML4 is non-extensible and HTML5 is limited in how you can extend it (web components are the only way to extend HTML5 I'm aware of that doesn't require an update to the HTML specification.)

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
    <title>The adventures of SHerlock Holmes</title>
    <author>
      <first-name>Arthur</first-name>
      <surname>Connan Doyle</surname>
    </author>
    </metadata>
  <section type="chapter">
    <para>Lorem Ipsum</para>
    <para>Lorem Ipsum</para>
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
<!-- Simple types to use in the content -->
<xs:simpleType name="token255">
    <xs:annotation>
        <xs:documentation>
          Defines a token of no more than 255 characters
        </xs:documentation>
    </xs:annotation>
    <xs:restriction base="xs:token">
        <xs:maxLength value="255"/>
    </xs:restriction>
</xs:simpleType>

<xs:simpleType name="isbn">
    <xs:annotation>
        <xs:documentation>
          Defines a regular expression to match an ISBN number. Regex needs to be refined and we need to figure out a way to account for ISBN10 and ISBN13 numbers, maybe by creating a compound element
        </xs:documentation>
    </xs:annotation>
    <xs:restriction base="xs:unsignedLong">
        <xs:totalDigits value="10"/>
        <xs:pattern value="d{10}"/>
    </xs:restriction>
</xs:simpleType>

<xs:simpleType name="align">
  <xs:annotation>
    <xs:documentation>Attribute ennumeration for elements that can be aligned</xs:documentation>
  </xs:annotation>
  <xs:restriction base="xs:token">
    <xs:enumeration value="left"/>
    <xs:enumeration value="center"/>
    <xs:enumeration value="right"/>
    <xs:enumeration value="justify"/>
  </xs:restriction>
</xs:simpleType>

<xs:attributeGroup name="genericPropertiesGroup">
    <xs:attribute name="id" type="xs:ID" use="optional">
        <xs:annotation>
            <xs:documentation>ID for the paragraph if any</xs:documentation>
        </xs:annotation>
    </xs:attribute>
    <xs:attribute name="class" type="xs:token" use="optional">
        <xs:annotation>
            <xs:documentation>Class for the paragraph if any</xs:documentation>
        </xs:annotation>
    </xs:attribute>
</xs:attributeGroup> 
```

After I had finished my first version of the schema I discovered a problem. I was not able to nest style elements that are childre of paragraph. The following markup was not allowed in my book document:

```xml
<para>This is an example of <strong><emphasis>bold and italics together</emphasis></strong>.</para>
```

In order to acommodate nesting of the four basic styles available to our documents: `strong`, `emphasis`, `strike` and `underline` we had to do some juryriging of the elements to tell the schema what children are allowed for each element.  The schema look like this:

```xml
<xs:element name="strong">
    <xs:complexType mixed="true">
        <xs:choice minOccurs="0" maxOccurs="unbounded">
            <xs:element ref="emphasis"/>
            <xs:element ref="underline"/>
            <xs:element ref="strike"/>
        </xs:choice>
    </xs:complexType>
</xs:element>
    
<xs:element name="emphasis">
  <xs:complexType mixed="true">
      <xs:choice minOccurs="0" maxOccurs="unbounded">
          <xs:element ref="strong"/>
          <xs:element ref="emphasis"/>
          <xs:element ref="underline"/>
          <xs:element ref="strike"/>
      </xs:choice>
  </xs:complexType>
</xs:element>
```

The `emphasis` element is the only one that allows the same element to be nested. When nesting emphasis elements they cancel each other 

The next stage is to define elements to create our 'people' types.  We create a base person element and then create three role elements based on person. We will use this next to define groups for each role.

```xml
<!-- complex types to create groups of similar person items -->
<xs:complexType name="person">
    <xs:annotation>
        <xs:documentation>
            Generic element to denote an individual involved in creating the book
        </xs:documentation>
    </xs:annotation>
    <xs:sequence>
        <xs:element name="first-name" type="xs:token"/>
        <xs:element name="surname" type="xs:token"/>
    </xs:sequence>
    <xs:attribute name="id" type="xs:ID" use="optional"/>
</xs:complexType>

<xs:complexType name="author">
  <xs:annotation>
    <xs:documentation>Wrapper to get more than one author</xs:documentation>
  </xs:annotation>
  <xs:choice minOccurs="1" maxOccurs="unbounded">
    <xs:element name="author" type="person"/>
  </xs:choice>
</xs:complexType>

<xs:complexType name="editor">
  <xs:annotation>
    <xs:documentation>extension to person to indicate editor and his/her role</xs:documentation>
  </xs:annotation>
  <xs:complexContent>
    <xs:extension base="person">
      <xs:sequence>
        <xs:element name="type" type="xs:token"/>
      </xs:sequence>
    </xs:extension>
  </xs:complexContent>
</xs:complexType>

<xs:complexType name="otherRole">
  <xs:annotation>
    <xs:documentation>extension to person to accomodate roles other than author and editor</xs:documentation>
  </xs:annotation>
  <xs:complexContent>
    <xs:extension base="person">
      <xs:sequence minOccurs="1" maxOccurs="1">
        <xs:element name="role" type="xs:token"/>
      </xs:sequence>
    </xs:extension>
  </xs:complexContent>
</xs:complexType>
```

Two of the derived types add attributes or elements to the base person element to make the generic person more appropriate to their role rather than repeat the content of person each time that an author, editor or other role appear. 

Author is the most straight forward and only wraps person in the author element. 


Editor takes the base person element and adds a `type` child to indicate the type of editor (some that come to mind are acquisition, production and managing.) The editor elements looks like this:

```xml
<editor>
  <first-name>Carlos</first-name>
  <surname>Araya</surname>
  <type>Managing</type>
</editor>
```

OtherRoles takes all other roles that are not author or editor and adds a role element to specify what role they play, for example: Illustrator, Indexer, Research Assistant, among others. The element looks like this:

```xml
<otherRole>
  <first-name>Sherlock</first-name>
  <surname>Holmes</surname>
  <role>Researcher</role>
</otherRole>
```

Next we create wrappers for each group as `authors`, `editors` and `otherRoles` so we can provide easier styling with XSLT and CSS later on.

```xml
<xs:complexType name="authors">
    <xs:annotation>
        <xs:documentation>Wrapper to get more than one author</xs:documentation>
    </xs:annotation>
    <xs:sequence>
        <xs:element name="author" type="person"/>
    </xs:sequence>
</xs:complexType>

<xs:complexType name="editors">
    <xs:annotation>
        <xs:documentation>
          extension to person to indicate editor and his/her role
        </xs:documentation>
    </xs:annotation>
    <xs:complexContent>
        <xs:extension base="person">
            <xs:sequence>
                <xs:element name="type" type="xs:token"/>
            </xs:sequence>
        </xs:extension>
    </xs:complexContent>
</xs:complexType>

<xs:complexType name="otherRoles">
    <xs:annotation>
        <xs:documentation>
          extension to person to accomodate roles other than author and editor
        </xs:documentation>
    </xs:annotation>
    <xs:complexContent>
        <xs:extension base="person">
            <xs:sequence>
                <xs:element name="role" type="xs:token"/>
            </xs:sequence>
        </xs:extension>
    </xs:complexContent>
</xs:complexType>
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

As I was working on further ideas for the project I realized that we forgot to create inline and block level inner containers for the content, important if you're going to style smaller portions of content within a paragraph or witin a section. Taking the names from HTML we define section (inline) and div (block) elements. They are both lightweight with three attributes: `class`, `id` and `type`

Type is used in these two elements and in our sections to create data-type and epub:type attributes. These are used in the Paged Media stylesheet to decide how will the content be formated.

```xml
<xs:element name="div">
  <xs:annotation>
    <xs:documentation>
      Allows for inline content using span

      class and id attributes from genericPropertiesGroup

      type is use to create data-type and/or epub:type annotations
    </xs:documentation>
  </xs:annotation>
  <xs:complexType>
    <xs:attributeGroup ref="genericPropertiesGroup"/>
    <xs:attribute name="type" type="xs:token" use="optional" default="chapter"/>
  </xs:complexType>
</xs:element>

<xs:element name="span">
  <xs:annotation>
    <xs:documentation>
        Allows for inline content using span

        class and id attributes from genericPropertiesGroup

        type is use to create data-type and/or epub:type annotations
    </xs:documentation>
  </xs:annotation>
  <xs:complexType>
    <xs:attributeGroup ref="genericPropertiesGroup"/>
    <xs:attribute name="type" type="xs:token" use="optional" default="chapter"/>
  </xs:complexType>
</xs:element>
```

Next are images and figures where we borrow from HTML, again, for the name of attribute names and their functionality. We define 3 elements for the image-related tags: `figure`, `figcaption` and the image itself. 

`Figure` is the wrapper around a `figcaption` caption and the `image` element itself. The `figcaption` is a text-only element that will contain the caption for the associated image

```xml
!-- Figure and related elements -->
<!-- 
    Note that the schema accepts both images and figures as 
    children of section to accomodate images with and without 
    captions
-->
<xs:element name="figure">
  <xs:annotation>
    <xs:documentation>
      Figure is a wrapper for an image and a caption. Because we 
      accept either figure or image as part of our content model  
      keep most of the attributes on the image 
    </xs:documentation>
  </xs:annotation>
  <xs:complexType mixed="true">
    <xs:all>
      <xs:element ref="image"/>
      <xs:element ref="figcaption"/>
    </xs:all>
    <xs:attributeGroup ref="genericPropertiesGroup"/>
  </xs:complexType>
</xs:element>
```

The caption child only uses text and, because it's only used as a child of figure, we don't need to assign attributes to it. It will inherit from the image or the surrounding figure.
      
```xml
<xs:element name="figcaption">
  <xs:annotation>
    <xs:documentation>
      caption for the image in the figure. Because it's only used
      as a child of figure, we don't need to assign attributes to
      it
    </xs:documentation>
  </xs:annotation>
</xs:element>
```
When working with the start with `genericPropertiesGroup` to define `class` and `id`.

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

The `code` element wraps code and works as higlighted, fenced code blocks (think Github Flavored Markdown.)

When using CSS we'll generate a &lt;code>&lt;pre>&lt;/pre>&lt;/code> block with a language attribute that will be formated with either Google Code Prettify or Highlight.js (the chosen package will be a part of the project tool chain)

Because of the intended use, the `language` attribute is required. 

Class and ID (from `genericPropertiesGroup`) are optional

```xml
<xs:element name="code">
    <xs:complexType mixed="true">
        <xs:attributeGroup ref="genericPropertiesGroup"/>
        <xs:attribute name="language" use="required"/>
    </xs:complexType>
</xs:element>
```

Lists provide bulleted and numbered lists as a block element inside a section. Rather than create elements (like `<ol>` and `<ul>` in HTML) we create a single list type and we add a `listType` attribute to indicate the type of list. 

It also requires at least 1 `item` child. If it's going to be left empty why bother having the list to begin with. 

It inherits class and ID from `genreicPropertiesGroup`.

```xml
<xs:element name="list">
    <xs:complexType mixed="true">
        <xs:sequence minOccurs="1" maxOccurs="unbounded">
            <xs:element name="item">
                <xs:complexType>
                    <xs:attributeGroup ref="genericPropertiesGroup"/>
                </xs:complexType>
            </xs:element>
        </xs:sequence>
        <xs:attribute name="listType" type="xs:token" default="unordered"/>
        <xs:attributeGroup ref="genericPropertiesGroup"/>
    </xs:complexType>
</xs:element>
```

Paragraphs (`para` in our documents) are the essential unit of content for our books. The paragraph is where most content will happen, text, styles and additional elements that we may add as we go along (inline code comes to mind). 

We include 3 different groups of properties in the paragraph declaration: Styles (`strong`, `emphasis`, `underline` and `strike` to do bold, italics, underline (outside links) and strikethrough text); Organization (`span` and `link`) and our `genericPropertiesGroup` (class and id). 

This model barely begins to scratch the surface of what we can do with our paragraph model. I decided to go for simplicity rather than completeness. This will definitely change in future versions of the schema. 

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

The metadata section tells us more about the book itself and can be used to build a `package.opf` manifest using XSLT as part of our transformation process. We include basic information such as `isbn` (validated as an ISBN type defined earlier in the schema), an `edition` (integer indicating what edition of the book it is) and `title`.

```xml
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
                <xs:documentation>
                Metadata sequence using ISBN, Edition, Title, Authors, Editors and Other Roles defined using simple and complex type definitions defined earlier
                
                We also support paragraphs to add content that is not one of the items listed above
                </xs:documentation>
            </xs:annotation>
            <xs:element name="isbn" type="isbn"/>
            <xs:element name="edition" type="xs:integer"/>
            <xs:element name="title" type="token255"/>
            <xs:element name="authors" type="authors" minOccurs="1" maxOccurs="unbounded"/>
            <xs:element name="editors" type="editors" minOccurs="0" maxOccurs="unbounded"/>
            <xs:element name="otherRoles" type="otherRoles" minOccurs="0" maxOccurs="unbounded"/>
            <!-- 
                We allow para here to make sure  we can write 
                text as for the metadata
            -->
            <xs:element ref="para"/>

        </xs:sequence>
    </xs:complexType>
</xs:element>
```

Section is our primary container for paragraphs and associated content. Some of the items exclusive to sections are:

The `title` element is required to appear exactly one time. 

We can have 1 or more `para` elements. 

We can use 0 or more of the following elements:

* `code` fenced code blocks elements
* `ulist` unordered list
* `olist` ordered (numbered) lists
* `figure` for captioned images
* `image` without captions
* `div` block level containers
* `span` inline level container

The element inherits `class` and `ID` from genericPropertiesGroup.

Finally we add the `type` to create data-type and/or epub:type attributes. I chose to make it option and default it to chapter. We want to make it easier for authors to create content; where possible. I'd rather have the wrong value than no value at all.

```xml
<!-- Section element -->
<xs:element name="section">
  <xs:annotation>
    <xs:documentation>section structure</xs:documentation>
  </xs:annotation>
  <xs:complexType mixed="true">
    <xs:sequence>
      <xs:annotation>
        <xs:documentation>
          A title and at least one paragraph
        </xs:documentation>
      </xs:annotation>
      <xs:element name="title" type="xs:string" minOccurs="1" maxOccurs="1"/>
      <xs:choice maxOccurs="unbounded">
        <xs:element ref="code"/>
        <xs:element ref="para" minOccurs="1" maxOccurs="unbounded"/>
        <xs:element ref="ulist"/>
        <xs:element ref="olist"/>
        <xs:element ref="figure"/>
        <xs:element ref="image"/>
        <xs:element ref="div"/>
        <xs:element ref="span"/>
      </xs:choice>
    </xs:sequence>
    <xs:attributeGroup ref="genericPropertiesGroup"/>
    <xs:attribute name="type" type="xs:token" use="optional" default="chapter">
      <xs:annotation>
        <xs:documentation>
          The type or role for the paragraph asn in data-role or epub:type. 
          
          We make it optional but provide a default of chapter to make it 
          easier to add.
        </xs:documentation>
      </xs:annotation>
    </xs:attribute>
  </xs:complexType>
</xs:element>
```
Now that we have defined our elements, we'll define the core structure of the document by defining the structure of the `book` element. 

After all the work we've done defininf the content the definition of book is almost anticlimatic. We define the `book` element as the sequence of exactly 1 `metadata` element and 1 or more `section` elements.

As with all our elements we add `class` and `ID` from our genericPropertiesGroup. 


```xml
<xs:element name="book">
    <xs:annotation>
        <xs:documentation>The main book element and it's children</xs:documentation>
    </xs:annotation>
    <xs:complexType mixed="true">
        <xs:annotation>
            <xs:documentation>
              A sequence of one metadata element followed by 1 or more sections
            </xs:documentation>
        </xs:annotation>
        <xs:sequence>
            <xs:element ref="metadata" minOccurs="1" maxOccurs="1"/>
            <xs:element ref="section" minOccurs="1" maxOccurs="unbounded"/>
        </xs:sequence>
        <xs:attributeGroup ref="genericPropertiesGroup"/>
    </xs:complexType>
</xs:element>
```

This covers the schema for our document type. It is not completed by any stretch of the imagination. It can be further customized to suit individual needs. The current version represents a very basic text heavy document type. 

There are definitely more elements to add like video, audio and others both with equivalent elements in HTML and compound elements based on your needs.