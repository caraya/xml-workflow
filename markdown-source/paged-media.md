---
title: Paged Media Extension and Stylesheet
date: 2015-01-13
category: Technology
status: draft
---

# Paged Media Extension and Stylesheet

Now that we have converted the XML file to HTML we'll change the transformation to create the additional material we need and then use PrinceXML to convert the HTML to PDF using CSS Paged Media and Generated Content for Paged media.

None of the software to generate PDF from CSS are free; however, Prince allows for unmarked development documents. The competitor, Antenna House, produces large watermarks that cover the document's text which is sad because I much prefer AH than Prince. 

## Modifications to XSLT stylesheet

We'll use this opportunity to create an xslt customization layer to make changes only to the templates where we need to. 

We create a customization layer by importing the original stylesheet and making any necessary changes in the new stylesheet. Imported stylesheets have a lower precedence order than the local version so the local version will win if there is conflict.

For this customization layer we want to:

* Remove filename variable. It's not needed
* Remove the result document element (it's all one file)
* Change the test for data type so it'll terminate if it fails 
  (type attribute is required)
* Add the element that will build our running header

```xml

```
## CSS Paged Media Stylesheet

```css
@import url(http://fonts.googleapis.com/css?family=Roboto:700italic,300,700,300italic,400);
@import url(http://fonts.googleapis.com/css?family=Roboto+Slab);
@import url(http://fonts.googleapis.com/css?family=Source+Code+Pro);

body {
  background-color: white;
  color: #333;
  font-family: 'Roboto', 'Helvetica Neue', Helvetica, sans-serif;
  font-size: 16px;
  font-weight: 300;
  line-height: 1.45; }

@page {
  size: 8.5in 11in;
  margin: 0.5in 1in;
  /* Footnote related attributes */
  counter-reset: footnote;
  @footnote {
    counter-increment: footnote;
    float: bottom;
    column-span: all;
    height: auto; }
 }

@page chapter {
  @bottom-center {
    vertical-align: middle;
    text-align: center;
    content: element(heading); }
 }

body[data-type="book"] {
  color: cmyk(0%, 0%, 100%, 100%);
  hyphens: auto; }

/* page counters are tricky */
body[data-type="book"] > div[data-type="part"]:first-of-type, 
body[data-type="book"] > section[data-type="chapter"]:first-of-type {
  counter-reset: page 1; }

body[data-type="book"] > section[data-type="part"] + div[data-type="chapter"] {
  counter-reset: none; }

/* Title Page*/
section[data-type="titlepage"] {
  page: titlepage; }

section[data-type="titlepage"] * {
  text-align: center; }

h1.bookTitle {
  font-size: 200%; }

h2.author {
  font-size: 150%;
  font-style: italic; }

/* Copyright page */
section[data-type="copyright"] {
  page: copyright; }

/* Dedication */
section[data-type="dedication"] {
  page: dedication; }

section[data-type="dedication"] p {
  font-style: italic; }

section[data-type="dedication"] * {
  text-align: center; }

/* TOC */
nav[data-type="toc"] {
  page: toc; }

nav[data-type="toc"] ol {
  list-style-type: none; }

/* TESTING LEADER CONTENT */
nav[data-type="toc"] ol li a:after {
  content: leader(dotted) " " target-counter(attr(href, url), page); }

/* Comon Front Mater Page Numbering in lowercase ROMAN numerals*/
/* Right Side */
@page toc:right {
  @bottom-right-corner {
    content: counter(page, lower-roman); }

  @bottom-left-corner {
    content: normal; }
 }

@page foreword:right {
  @bottom-right-corner {
    content: counter(page, lower-roman); }

  @bottom-left-corner {
    content: normal; }
 }

@page preface:right {
  @bottom-right-corner {
    content: counter(page, lower-roman); }

  @bottom-left-corner {
    content: normal; }
 }

/* Left Side*/
@page toc:left {
  @bottom-left-corner {
    content: counter(page, lower-roman); }

  @bottom-right-corner {
    content: normal; }
 }

@page foreword:left {
  @bottom-left-corner {
    content: counter(page, lower-roman); }

  @bottom-right-corner {
    content: normal; }
 }

@page preface:left {
  @bottom-left-corner {
    content: counter(page, lower-roman); }

  @bottom-right-corner {
    content: normal; }
 }

/* Foreword  */
section[data-type="foreword"] {
  page: foreword; }

/* Preface*/
section[data-type="preface"] {
  page: preface; }

/* Part */
div[data-type="part"] {
  page: part; }

/* Chapter */
section[data-type="chapter"] {
  page: chapter;
  page-break-before: always; }

/* Appendix */
section[data-type="appendix"] {
  page: appendix;
  page-break-before: always; }

/* Glossary*/
section[data-type="glossary"] {
  page: glossary;
  page-break-before: always; }

/* Bibliography */
section[data-type="bibliography"] {
  page: bibliography;
  page-break-before: always; }

/* Index */
section[data-type="index"] {
  page: index;
  page-break-before: always; }

/* Colophon */
section[data-type="colophon"] {
  page: colophon;
  page-break-before: always; }

/* Common Content Page Numbering  in Arabic numerals 1... 199 */
@page titlepage {
  /* Need this to clean up page numbers in titlepage in Prince*/
  @bottom-right-corner {
    content: normal; }

  @bottom-left-corner {
    content: normal; }
 }

@page chapter:blank {
  /* Need this to clean up page numbers in titlepage in Prince*/
  @bottom-left-corner {
    content: normal; }

  @bottom-right-corner {
    content: normal; }
 }

/* Right Side*/
@page chapter:right {
  @bottom-right-corner {
    content: counter(page); }

  @bottom-left-corner {
    content: normal; }
 }

@page appendix:right {
  @bottom-right-corner {
    content: counter(page); }

  @bottom-left-corner {
    content: normal; }
 }

@page glossary:right {
  @bottom-right-corner {
    content: counter(page); }

  @bottom-left-corner {
    content: normal; }
 }

@page bibliography:right {
  @bottom-right-corner {
    content: counter(page); }

  @bottom-left-corner {
    content: normal; }
 }

@page index:right {
  @bottom-right-corner {
    content: counter(page); }

  @bottom-left-corner {
    content: normal; }
 }

/* Left Side */
@page chapter:left {
  @bottom-left-corner {
    content: counter(page); }

  @bottom-right-corner {
    content: normal; }
 }

@page appendix:left {
  @bottom-left-corner {
    content: counter(page); }

  @bottom-right-corner {
    content: normal; }
 }

@page glossary:left {
  @bottom-left-corner {
    content: counter(page); }

  @bottom-right-corner {
    content: normal; }
 }

@page bibliography:left {
  @bottom-left-corner {
    content: counter(page); }

  @bottom-right-corner {
    content: normal; }
 }

@page index:left {
  @bottom-left-corner {
    content: counter(page); }

  @bottom-right-corner {
    content: normal; }
 }

/*  Block Elements*/
h1, h2, h3, h4, h5, h6 {
  hyphens: none;
  text-align: left; }

figure {
  border: 1px solid #f00; }

  figure caption {
    font-size: 80%; }

  figure img {
    max-width: 100%; }

code {
  font-family: "Source Code Pro", monospace; }

/* Widows and orphans */
p {
  orphans: 4;
  /* min number of lines of a paragraph left at bottom of a page */
  widows: 2;
  /* min number of lines of a paragraph that left at top of a page.*/ }

p.rh {
  position: running(heading);
  text-align: center;
  font-style: italic; }

span.footnote {
  float: footnote; }

/*
  Footnotes
*/
::footnote-marker {
  content: counter(footnote);
  list-style-position: inside; }

::footnote-marker::after {
  content: '. '; }

::footnote-call {
  content: counter(footnote);
  vertical-align: super;
  font-size: 65%; }

/* XReferences */
a.xref[href]::after {
  content: " [See page " target-counter(attr(href), page) "]"; }

/*
  PDF Bookmarks
*/
section[data-type="chapter"] h1 {
  -ah-bookmark-level: 1;
  -ah-bookmark-state: open;
  -ah-bookmark-label: content();
  prince-bookmark-level: 1;
  prince-bookmark-state: closed;
  prince-bookmark-label: content(); }

section[data-type="chapter"] h2 {
  -ah-bookmark-level: 2;
  -ah-bookmark-state: closed;
  -ah-bookmark-label: content();
  prince-bookmark-level: 2;
  prince-bookmark-state: closed;
  prince-bookmark-label: content(); }

section[data-type="chapter"] h3 {
  -ah-bookmark-level: 3;
  -ah-bookmark-state: closed;
  -ah-bookmark-label: content();
  prince-bookmark-level: 3;
  prince-bookmark-state: closed;
  prince-bookmark-label: content(); }

section[data-type="chapter"] h4 {
  -ah-bookmark-level: 4;
  prince-bookmark-level: 4; }

section[data-type="chapter"] h5 {
  -ah-bookmark-level: 5;
  prince-bookmark-level: 5; }

section[data-type="chapter"] h6 {
  -ah-bookmark-level: 6;
  prince-bookmark-level: 6; }


/*# sourceMappingURL=paged-media.css.map */
```

## Examples and additional information

* [http://alistapart.com/article/building-books-with-css3](http://alistapart.com/article/building-books-with-css3)
* [https://github.com/oreillymedia/HTMLBook/blob/master/stylesheets/pdf/pdf.css](https://github.com/oreillymedia/HTMLBook/blob/master/stylesheets/pdf/pdf.css)
* W3C specification: [http://www.w3.org/TR/css3-page/](http://www.w3.org/TR/css3-page/)
* Antenna House Formatter Onine Manual: [http://antennahouse.com/XSLsample/help/V62/AHFormatterV62.en.pdf](http://antennahouse.com/XSLsample/help/V62/AHFormatterV62.en.pdf)
* Prince XML User Guide: [http://www.princexml.com/doc/9.0/](http://www.princexml.com/doc/9.0/)


