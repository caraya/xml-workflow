---
title: XML Workflow: CSS Styles for Paged Media
date: 2015-02-10
category: Technology
status: draft
---

# CSS Styles for Paged Media

This is the generated CSS from the SCSS style sheets (see the scss/ directory for the source material.) I've chosen to document the resulting stylesheet here and document the SCSS source in another document to make life simpler for people who don't want to deal with SASS or who want to see what the style sheets look like. 

Typography derived from work done at this URL: [http://bit.ly/16N6Y2Q](http://bit.ly/16N6Y2Q)

The following scale (also using minor third progression) may also help: [http://bit.ly/1DdVbqK](http://bit.ly/1DdVbqK)


Feel free to play with these and use them as starting point for your own work :)

The project currently uses these fonts:

* Roboto Slab for headings
* Roboto for body copy
* Source Code Pro for code blocks and preformated text

## Font Imports

Even though SCSS Lint throws a fit when I put font imports in a stylesheet because they stop asynchronous operations, I'm doing it to keep the HTML files clean and because we are not loading the CSS on the page, we're just using it to process the PDF file. 

Eventually I'll switch to locally hosted fonts using bulletproof font syntax ([discussed here](http://www.paulirish.com/2009/bulletproof-font-face-implementation-syntax/) and available for use at [Font Squirrel](http://www.fontsquirrel.com/tools/webfont-generator).

At this point we are not dealing with [font subsetting](http://bit.ly/1ul3XBx) but we may in case we need to.


```css
@import url(http://fonts.googleapis.com/css?family=Roboto:100italic,100,400italic,700italic,300,700,300italic,400);
@import url(http://fonts.googleapis.com/css?family=Roboto+Slab:400,700);
@import url(http://fonts.googleapis.com/css?family=Source+Code+Pro:300,400);
```

## Defaults

Now that we've loaded the fonts

```css
html {
  overflow-y: scroll;
  -ms-text-size-adjust: 100%;
  -webkit-text-size-adjust: 100%;
}

body {
  background-color: #fff;
  color: #554c4d;
  font-family: 'Roboto Thin', 'Helvetica Neue', Helvetica, sans-serif;
  font-size: 1em;
  font-weight: 100;
  line-height: 1.1;
  orphans: 4;
  padding-left: 0;
  padding-right: 0;
  widows: 2;
}

## Blockquotes, Pullquotes and Marginalia

It's fairly easy to create sidebars in HTML so I've played a lot with pull quotes, blockquotes and asides as a way to move the content around with basic CSS. We can do further work by tuning the CSS

```css
aside {
  border-bottom: 3px double #ddd;
  border-top: 3px double #ddd;
  color: #666;
  line-height: 1.4em;
  padding-bottom: .5em;
  padding-top: .5em;
  width: 100%;
}

aside .pull {
  margin-bottom: .5em;
  margin-left: -20%;
  margin-top: .2em;
}
```

The `magin-notes*` and `content*` move the content to the corresponding side of the page without having to create specific CSS to do so. The downside is that, as with many things in CSS, you are stuck with the provided values and will have to modify them to suit your needs.

```css
.margin-notes,
.content-left {
  font-size: .75em;
  margin-left: -230px;
  margin-right: 20px;
  text-align: right;
  width: 230px;
}

.margin-notes-right,
.content-right {
  font-size: .75em;
  margin-left: 760px;
  margin-right: -20px;
  position: absolute;
  text-align: left;
  width: 230px;
}

.content-right {
  font-size: .75em;
  margin-left: 760px;
  margin-right: -20px;
  position: absolute;
  text-align: left;
  width: 230px;
}

.content-right ul,
.content-left ul {
  list-style: none;
}
```


The opening class

```css
.opening {
  border-bottom: 3px double #ddd;
  border-top: 3px double #ddd;
  font-size: 2em;
  margin-bottom: 10em;
  padding-bottom: 2em;
  padding-top: 2em;
  text-align: center;
}
```

```css
blockquote {
  border-left: 5px solid #ccc;
  color: #222023;
  font-size: 1.5em;
  font-style: italic;
  font-weight: 100;
  margin-bottom: 2em;
  margin-left: 4em;
  margin-right: 4em;
  margin-top: 2em;
}
blockquote p {
  padding-left: .5em;
}

.pullquote {
  border-bottom: 18px solid #000;
  border-top: 18px solid #000;
  font-size: 36px;
  font-weight: 700;
  letter-spacing: -.02em;
  line-height: 38px;
  margin-right: 100px;
  padding: 20px 0;
  position: relative;
  width: 200px;
}
.pullquote p {
  color: #00298a;
  font-weight: 700;
  position: relative;
  text-transform: uppercase;
  z-index: 1;
}
.pullquote p:last-child {
  line-height: 20px;
  padding-top: 2px;
}
.pullquote cite {
  color: #333;
  font-size: 18px;
  font-weight: 400;
}
```

## Paragraphs

```css
p {
  font-size: 1em;
  margin-bottom: 1.3em;
}
p + p {
  text-indent: 2em;
}

.first-line {
  font-size: 1.1em;
  text-indent: 0;
  text-transform: uppercase;
}

.first-letter {
  float: left;
  font-size: 7em;
  line-height: .8em;
  margin-bottom: -.1em;
  padding-right: .1em;
}
```

## Lists

```css
ul li {
  list-style: square;
}

ol li {
  list-style: decimal;
}
```

## Figures and captions

```css
figure {
  counter-increment: figure_count;
  margin-bottom: 1em;
  margin-top: 1em;
}
figure figcaption {
  font-weight: 700;
  padding-bottom: 1em;
  padding-top: .2em;
}

figure figcaption::before {
  content: "Figure " counter(figure_count) ": ";
}
```

## Headings

```css
h1,
h2,
h3,
h4,
h5,
h6 {
  font-family: 'Roboto Slab', sans-serif;
  font-weight: 400;
  hyphens: none;
  line-height: 1.2;
  margin: 1.414em 0 .5em;
  text-transform: uppercase;
}

h1 {
  font-size: 3.157em;
  margin-top: 0;
}

h2 {
  font-size: 2.369em;
}

h3 {
  font-size: 1.777em;
}

h4 {
  font-size: 1.333em;
  text-transform: uppercase;
}

h4,
h5,
h6 {
  text-align: inherit;
}
```

## Different parts of the book

```css
section[data-type='bibliography'] p {
  text-align: left;
}
section[data-type='bibliography'] p + p {
  text-indent: 0 !important;
}

section[data-type='titlepage'] h1,
section[data-type='titlepage'] h2 {
  text-align: center;
}
section[data-type='titlepage'] p {
  text-align: center;
}

section[data-type='dedication'] h1,
section[data-type='dedication'] h2 {
  text-align: center;
}
section[data-type='dedication'] p {
  text-align: left;
}
section[data-type='dedication'] p + p {
  text-indent: 0 !important;
}
```

## Preformatted code blocks

```css
pre {
  background-color: #efeff2;
  overflow-wrap: break-word;
  white-space: pre-line !important;
  word-wrap: break-word;
}
pre code {
  font-family: 'Source Code Pro', monospace;
  font-size: 1em;
  line-height: 1.2em;
  page-break-inside: avoid;
}
```

## Columns and miscelaneous classes

```css
.justified {
  text-align: justify;
}

.code {
  background-color: #e6e6e7;
  opacity: .75;
}

.columns2 {
  column-count: 2;
  column-gap: 3em;
  column-fill: balance;
  column-span: none;
  line-height: 1.25em;
  width: 100%;
}
.columns2 p:first-of-type {
  margin-top: 0;
}
.columns2 p + p {
  text-indent: 2em;
}
.columns2 p:last-of-type {
  margin-bottom: 1.25em;
}

.columns3 {
  column-count: 3;
  column-gap: 10px;
  column-fill: balance;
  column-span: none;
  width: 100%;
}
.columns3 p:first-of-type {
  margin-top: 0;
}
.columns3 p:not:first-of-type {
  text-indent: 2em;
}
.columns3 p:last-of-type {
  margin-bottom: 1.25em;
}
```
