---
title: XML workflows: The XML Schema
category: Technology
status: draft
---

# XML Schema
&lt;?xml version="1.0" encoding="UTF-8"?>
&lt;xs:schema
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    elementFormDefault="qualified"
    attributeFormDefault="unqualified">

    &lt;!-- Simple types to use in the content -->
    &lt;xs:simpleType name="token255">
        &lt;xs:annotation>
            &lt;xs:documentation>Defines a token of no more than 255 characters&lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:restriction base="xs:token">
            &lt;xs:maxLength value="255"/>
        &lt;/xs:restriction>
    &lt;/xs:simpleType>

    &lt;xs:simpleType name="ISBN-type10">
        &lt;xs:annotation>
            &lt;xs:documentation>
                A much longer and tedious type definition available at http://xfront.com/isbn.html

                It includes country specific ISBN derivations
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:restriction base="xs:string">
            &lt;xs:pattern value="0-[0-1][0-9]-\d{6}-[0-9x]">
                &lt;xs:annotation>
                    &lt;xs:documentation>
                        group/country ID = 0 (hyphen after the 1st digit)
                        Publisher ID = 00...19 (hyphen after the 3rd digit)
                        Block size = 1,000,000 (requires 6 digits)
                        check digit is 0-9 or 'x'
                    &lt;/xs:documentation>
                &lt;/xs:annotation>
            &lt;/xs:pattern>
        &lt;/xs:restriction>
    &lt;/xs:simpleType>

    &lt;xs:simpleType name="align">
        &lt;xs:annotation>
            &lt;xs:documentation>Attribute ennumeration for elements that can be aligned&lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:restriction base="xs:token">
            &lt;xs:enumeration value="left"/>
            &lt;xs:enumeration value="center"/>
            &lt;xs:enumeration value="right"/>
            &lt;xs:enumeration value="justify"/>
        &lt;/xs:restriction>
    &lt;/xs:simpleType>

    &lt;xs:element name="language" type="xs:language">
        &lt;xs:annotation>
            &lt;xs:documentation>
                book primary language or language for specific sections of the book
            &lt;/xs:documentation>
        &lt;/xs:annotation>
    &lt;/xs:element>

    &lt;xs:attributeGroup name="genericPropertiesGroup">
        &lt;xs:attribute name="id" type="xs:ID" use="optional">
            &lt;xs:annotation>
                &lt;xs:documentation>ID for the paragraph if any&lt;/xs:documentation>
            &lt;/xs:annotation>
        &lt;/xs:attribute>
        &lt;xs:attribute name="class" type="xs:token" use="optional">
            &lt;xs:annotation>
                &lt;xs:documentation>Class for the paragraph if any&lt;/xs:documentation>
            &lt;/xs:annotation>
        &lt;/xs:attribute>
    &lt;/xs:attributeGroup>

    &lt;!-- complex types to create groups of similar person items -->
    &lt;xs:complexType name="person">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Generic element to denote an individual involved in creating the book
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:sequence>
            &lt;xs:element name="first-name" type="xs:string"/>
            &lt;xs:element name="surname" type="xs:string"/>
        &lt;/xs:sequence>
        &lt;xs:attribute name="id" type="xs:ID" use="optional"/>
    &lt;/xs:complexType>

    &lt;xs:complexType name="organization">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Base organization structure to create corporate authors/editors and other places where an organization can take the place of a person
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:all>
            &lt;xs:element name='name' type="xs:string"/>
        &lt;/xs:all>
    &lt;/xs:complexType>
    
    &lt;xs:element name="address">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Complex type for address
            &lt;/xs:documentation>
        &lt;/xs:annotation>
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

    &lt;xs:complexType name="author">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Author person
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexContent>
            &lt;xs:extension base="person"/>
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

    &lt;xs:element name="publisher">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Derived from organization
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:all>
                &lt;xs:element name="name" type="organization"/>
                &lt;xs:element ref="address"/>
            &lt;/xs:all>
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
        &lt;/xs:complexType>
    &lt;/xs:element>
    &lt;!-- Wrappers around complext types -->
    &lt;xs:element name="authors">
        &lt;xs:annotation>
            &lt;xs:documentation>
                One or more authors
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:choice minOccurs="1" maxOccurs="unbounded">
                &lt;xs:element name="author" type="author"/>
            &lt;/xs:choice>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="editors">
        &lt;xs:annotation>
            &lt;xs:documentation>
                One or more editors
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:sequence minOccurs="0" maxOccurs="unbounded">
                &lt;xs:element name="editor" type="editor"/>
            &lt;/xs:sequence>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="otherRoles">
        &lt;xs:annotation>
            &lt;xs:documentation>
                One or more people in other roles
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:sequence minOccurs="0" maxOccurs="unbounded">
                &lt;xs:element name="otherRole" type="otherRole">&lt;/xs:element>
            &lt;/xs:sequence>
        &lt;/xs:complexType>
    &lt;/xs:element>

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

    &lt;xs:element name="pubdate" type="xs:date"/>

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

    &lt;xs:element name="abstract">
        &lt;xs:complexType mixed="true">
            &lt;xs:choice minOccurs="1" maxOccurs="unbounded">
                &lt;xs:element ref="para"/>
            &lt;/xs:choice>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;!-- Links -->
    &lt;xs:element name="link">
        &lt;xs:annotation>
            &lt;xs:documentation>
                links...

                What's the difference between supporting IRI and URI
                other than URI are supposed to work only with ASCII characters
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType>
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="href" type="xs:anyURI" use="required">
                &lt;xs:annotation>
                    &lt;xs:documentation>
                        Link destination. Attribute is required
                    &lt;/xs:documentation>
                &lt;/xs:annotation>
            &lt;/xs:attribute>
            &lt;xs:attribute name="label" type="xs:token" use="required">
                &lt;xs:annotation>
                    &lt;xs:documentation>Text provided for accessibility&lt;/xs:documentation>
                &lt;/xs:annotation>
            &lt;/xs:attribute>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;!-- Named Anchor -->
    &lt;xs:element name="anchor">
        &lt;xs:annotation>
            &lt;xs:documentation>
                The receiving end of an anchor link within the same document
                (the link is something like "#test") and the location of the
                test anchor has something like id="test"

                because we're using IDs each anchor has to be unique and
                must contain no whitespaces
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType>
            &lt;xs:attributeGroup ref="genericPropertiesGroup" />
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;!-- Div and Span elements -->
    &lt;xs:element name="div">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Allows for block level content using div

                class and id attributes from genericPropertiesGroup

                type is use to create data-type and/or epub:type annotations
            &lt;/xs:documentation>
        &lt;/xs:annotation>
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
          &lt;xs:annotation>
            &lt;xs:documentation>
              Style, Link and Span Elements.

              We use strong and emphasis rather than bold and italics
              to try and stay in synch with HTML and HTML5. We may add additional tags
              later in the process.

              We can use any of these elements inside paragraph in no particular order
              0 or more times (no maximum)

              Researching how to handle nested styles and whether the model below
              would handle nested children
            &lt;/xs:documentation>
          &lt;/xs:annotation>
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

    &lt;!-- Figure and related elements -->
    &lt;!--
        The schema accepts both images and figures as children of section to accomodate
        images with and without captions
    -->
    &lt;xs:element name="figure">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Figure is a wrapper for an image and a caption.

                Because we accept either
                figure or image as part of our content model we keep most of the attributes
                on the image and duplicate those that are needed in the figure element.

                Unlike the image all attributes of figure are optional
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:all>
                &lt;xs:element ref="anchor"/>
                &lt;xs:element ref="image"/>
                &lt;xs:element ref="figcaption"/>
            &lt;/xs:all>
            &lt;xs:attribute name="height" type="xs:nonNegativeInteger" use="optional">
              &lt;xs:annotation>
                &lt;xs:documentation>
                  Height for the image expressed as a positive integer
                &lt;/xs:documentation>
              &lt;/xs:annotation>
            &lt;/xs:attribute>
            &lt;xs:attribute name="width" type="xs:nonNegativeInteger" use="optional">
              &lt;xs:annotation>
                &lt;xs:documentation>
                  Width for the image expressed as a positive integer
                &lt;/xs:documentation>
              &lt;/xs:annotation>
            &lt;/xs:attribute>
            &lt;xs:attribute name="align" type="align" use="optional" default="left">
              &lt;xs:annotation>
                &lt;xs:documentation>
                  Optional alignment
                &lt;/xs:documentation>
              &lt;/xs:annotation>
            &lt;/xs:attribute>
          &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="figcaption">
        &lt;xs:annotation>
            &lt;xs:documentation>
                caption for the image in the figure. Because it's only used as
                a child of figure, we don't need to assign attributes to it
            &lt;/xs:documentation>
        &lt;/xs:annotation>
    &lt;/xs:element>

    &lt;xs:element name="image">
        &lt;xs:annotation>
            &lt;xs:documentation>image and image-related attributes&lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType>
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="src" type="xs:token" use="required">
                &lt;xs:annotation>
                    &lt;xs:documentation>
                        Source for the image. We may want to create a restriction
                        to account for both local and remote addresses
                    &lt;/xs:documentation>
                &lt;/xs:annotation>
            &lt;/xs:attribute>
            &lt;xs:attribute name="height" type="xs:nonNegativeInteger" use="required">
                &lt;xs:annotation>
                    &lt;xs:documentation>
                        Height for the image expressed as a positive integer
                    &lt;/xs:documentation>
                &lt;/xs:annotation>
            &lt;/xs:attribute>
            &lt;xs:attribute name="width" type="xs:nonNegativeInteger" use="required">
                &lt;xs:annotation>
                    &lt;xs:documentation>
                        Width for the image expressed as a positive integer
                    &lt;/xs:documentation>
                &lt;/xs:annotation>
            &lt;/xs:attribute>
            &lt;xs:attribute name="alt" type="token255" use="required">
                &lt;xs:annotation>
                    &lt;xs:documentation>
                        Alternate text contstained to 255 characters
                    &lt;/xs:documentation>
                &lt;/xs:annotation>
            &lt;/xs:attribute>
            &lt;xs:attribute name="align" type="align" use="optional" default="left">
                &lt;xs:annotation>
                    &lt;xs:documentation>
                        Optional alignment
                    &lt;/xs:documentation>
                &lt;/xs:annotation>
            &lt;/xs:attribute>
        &lt;/xs:complexType>
    &lt;/xs:element>

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
      &lt;xs:annotation>
        &lt;xs:documentation>
          Source track for video, can be used instead of the src attribute in the video itself
        &lt;/xs:documentation>
      &lt;/xs:annotation>
      &lt;xs:complexType>
        &lt;xs:attribute name="src" type='xs:string' use="required"/>
        &lt;xs:attribute name="type" type='xs:string' use="optional"/>
        &lt;xs:anyAttribute/>&lt;!-- There's got to be more attributes -->
      &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="track">
      &lt;xs:annotation>
        &lt;xs:documentation>
          VTT track for accessibility and additional payloads
        &lt;/xs:documentation>
      &lt;/xs:annotation>
      &lt;xs:complexType>
        &lt;xs:attribute name="src" type='xs:string' use="required"/>
        &lt;xs:attribute name="label" type='xs:string' use="required"/>
        &lt;xs:attribute name="kind" type='xs:string'/>
        &lt;xs:attribute name="srclang" type='xs:string' default='en'/>
        &lt;xs:anyAttribute/> &lt;!-- Not sure hot to handle the deafult attribute -->
      &lt;/xs:complexType>
    &lt;/xs:element>

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
        &lt;xs:annotation>
            &lt;xs:documentation>
                The emphasis element can have 0 or more children chosen form: strong, emphasis, underline and span

                Nested emphasis elements ARE allowed. Emphasis inside emphasis cancels out and displays as normal text

            &lt;/xs:documentation>
        &lt;/xs:annotation>
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
        &lt;xs:annotation>
            &lt;xs:documentation>
                The underline element can have 0 or more children chosen form: strong, emphasis, underline and span

                Nested underline elements are not allowed
            &lt;/xs:documentation>
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
        &lt;xs:annotation>
            &lt;xs:documentation>
                The strike element can have 0 or more children chosen form: strong, emphasis, underline and span

                Nested strike elements are not allowed.
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:choice minOccurs="0" maxOccurs="unbounded">
                &lt;xs:element ref="strong"/>
                &lt;xs:element ref="emphasis"/>
                &lt;xs:element ref="underline"/>
            &lt;/xs:choice>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;!-- Lists -->
    &lt;xs:element name="ulist">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Unordered list
            &lt;/xs:documentation>
        &lt;/xs:annotation>
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
        &lt;xs:annotation>
            &lt;xs:documentation>
                Ordered list
            &lt;/xs:documentation>
        &lt;/xs:annotation>
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
          &lt;xs:annotation>
            &lt;xs:documentation>
              Style, Link and Span Elements.

              We use strong and emphasis rather than bold and italics
              to try and stay in synch with HTML and HTML5. We may add
              additional tags later in the process.

              We can use any of these elements inside paragraph in no
              particular order 0 or more times (no maximum)

              Researching how to handle nested styles and whether the model below
              would handle nested children
            &lt;/xs:documentation>
          &lt;/xs:annotation>
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

    &lt;!-- Fenced code blocks -->
    &lt;xs:element name="code">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Code is used to generate fenced code blocks (see Github rendered markdown code
                for an idea of how I want this to look).

                When using CSS we'll generate a &lt;code>&lt;pre>&lt;/pre>&lt;/code> block with a language
                attribute that will be formated with Highlight.js (the chosen package will be
                a part of the tool chain)

                Because of the intended use, the language attribute is required.

                Class and ID (from genericPropertiesGroup) are optional
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:sequence minOccurs="0" maxOccurs="1">
              &lt;xs:element ref="anchor"/>
            &lt;/xs:sequence>
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="language" use="required"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

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

    &lt;!-- Paragraphs -->
    &lt;xs:element name="para">
      &lt;xs:annotation>
        &lt;xs:documentation>Para is the essential text content element. It'll get hairy because we
          have a lot of possible attributes we can use on it&lt;/xs:documentation>
      &lt;/xs:annotation>
      &lt;xs:complexType mixed="true">
        &lt;xs:choice  minOccurs="0" maxOccurs="unbounded">
          &lt;xs:annotation>
            &lt;xs:documentation>
              Style, Link and Span Elements.

              We use strong and emphasis rather than bold and italics
              to try and stay in synch with HTML and HTML5. We may add additional tags
              later in the process.

              We can use any of these elements inside paragraph in no particular order
              0 or more times (no maximum)

              Researching how to handle nested styles and whether the model below
              would handle nested children
            &lt;/xs:documentation>
          &lt;/xs:annotation>
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

    &lt;!-- Headings -->
    &lt;xs:element name="h1">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Level 1 heading. Name taken form html

                The element has the following attributes:

                * Class
                * ID
                * Align (center, left, right)
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="h2">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Level 3 heading. Name taken form html

                The element has the following attributes:

                * Class
                * ID
                * Align (center, left, right)
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="h3">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Level 3 heading. Name taken form html

                The element has the following attributes:

                * Class
                * ID
                * Align (center, left, right)
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="h4">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Level 4 heading. Name taken form html

                The element has the following attributes:

                * Class
                * ID
                * Align (center, left, right)
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="h5">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Level 5 heading. Name taken form html

                The element has the following attributes:

                * Class
                * ID
                * Align (center, left, right)
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;xs:element name="h6">
        &lt;xs:annotation>
            &lt;xs:documentation>
                Level 6 heading. Name taken form html

                The element has the following attributes:

                * Class
                * ID
                * Align (center, left, right)
            &lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
            &lt;xs:attribute name="align" type="align" use="optional" default="left"/>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;!-- Metadata element -->
    &lt;xs:element name="metadata">
        &lt;xs:annotation>
            &lt;xs:documentation>Metadata section of the content. Still debating whether to move it inside section or leave it as a separate part.&lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType>
            &lt;xs:choice minOccurs="0" maxOccurs="unbounded">
                &lt;xs:annotation>
                    &lt;xs:documentation>Metadata choice using ISBN, Edition, Title, Authors, Editors and Other Roles defined using simple and complex type definitions defined earlier&lt;/xs:documentation>
                &lt;/xs:annotation>
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

    &lt;!-- Section element -->
    &lt;xs:element name="section">
        &lt;xs:annotation>
            &lt;xs:documentation>section structure&lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:sequence>
                &lt;xs:annotation>
                    &lt;xs:documentation>A title and at least one paragraph &lt;/xs:documentation>
                &lt;/xs:annotation>
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
                &lt;xs:annotation>
                    &lt;xs:documentation>
                        The type or role for the paragraph asn in data-role or epub:type.

                        We make it optional but provide a default of chapter to make it
                        easier to add.
                    &lt;/xs:documentation>
                &lt;/xs:annotation>
            &lt;/xs:attribute>
        &lt;/xs:complexType>
    &lt;/xs:element>

    &lt;!-- Testing to see if we really need a separate toc element -->
    &lt;xs:element name="toc">
      &lt;xs:annotation>
        &lt;xs:documentation>
          Testing to see whether we actually need a toc element.

          This is different than an index, we'll work on that next
        &lt;/xs:documentation>
      &lt;/xs:annotation>
    &lt;/xs:element>
    &lt;!-- Base book element -->
    &lt;xs:element name="book">
        &lt;xs:annotation>
            &lt;xs:documentation>The main book element and it's children&lt;/xs:documentation>
        &lt;/xs:annotation>
        &lt;xs:complexType mixed="true">
            &lt;xs:annotation>
                &lt;xs:documentation>A sequence of one metadata section followed by 1 or more sections&lt;/xs:documentation>
            &lt;/xs:annotation>
            &lt;xs:choice maxOccurs="unbounded">
                &lt;xs:element ref="anchor" minOccurs="0" maxOccurs="1"/> &lt;!-- To create things like anchors to the beginning of the document -->
                &lt;xs:element ref="metadata" minOccurs="0" maxOccurs="1"/>
                &lt;xs:element ref="toc" minOccurs="0" maxOccurs="1"/>
                &lt;xs:element ref="section" minOccurs="1" maxOccurs="unbounded"/>
            &lt;/xs:choice>
            &lt;xs:attributeGroup ref="genericPropertiesGroup"/>
        &lt;/xs:complexType>
    &lt;/xs:element>
&lt;/xs:schema>
