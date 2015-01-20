---
title: Converting HTML to PDF
date: 2015-01-13
category: Technology
status: draft
---
# Concerting HTML to PDF

Rather than having to deal with [XSL-FO](http://www.w3.org/TR/2006/REC-xsl11-20061205/), another XML based vocabulary to create PDF content, we'll use XSLT to create another HTML file and process it with [CSS Paged Media](http://dev.w3.org/csswg/css-page-3/) and the companion [Generated Content for Paged Media](http://www.w3.org/TR/css-gcpm-3/) specifications to create PDF content. 

I'm not against XSL-FO but the structure of document is not the easiest or most intuitive. An example of XSL-FO looks like this:

```xml
<?xml version="1.0" encoding="iso-8859-1"?> (1)

<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format"> (2)
  <fo:layout-master-set> (3)
    <fo:simple-page-master master-name="my-page">
      <fo:region-body margin="1in"/>
    </fo:simple-page-master>
  </fo:layout-master-set>

  <fo:page-sequence master-reference="my-page"> (4)
    <fo:flow flow-name="xsl-region-body"> (5)
      <fo:block>Hello, world!</fo:block> (6)
    </fo:flow>
  </fo:page-sequence>
</fo:root>
```

1. This is an XML declaration. XSL FO (XSLFO) belongs to XML family, so this is obligatory.
2. Root element. The obligatory namespace attribute declares the XSL Formatting Objects namespace.
3. Layout master set. This element contains one or more declarations of page masters and page sequence masters — elements that define layouts of single pages and page sequences. In the example, I have defined a rudimentary page master, with only one area in it. The area should have a 1 inch margin from all sides of the page.
4. Page sequence. Pages in the document are grouped into sequences; each sequence starts from a new page. Master-reference attribute selects an appropriate layout scheme from masters listed inside `<fo:layout-master-set>`. Setting master-reference to a page master name means that all pages in this sequence will be formatted using this page master.
5. Flow. This is the container object for all user text in the document. Everything contained in the flow will be formatted into regions on pages generated inside the page sequence. Flow name links the flow to a specific region on the page (defined in the page master); in our example, it is the body region.
6. Block. This object roughly corresponds to `<div>` in HTML, and normally includes a paragraph of text. I need it here, because text cannot be placed directly into a flow.

Rather than define a flo of content and then the content CSS Paged Media uses a combination of new and existing CSS elements to format the content. For example, to define default page size and then add elements to chapter pages looks like this:

```css
@page {
  size: 8.5in 11in;
  margin: 0.5in 1in;
  /* Footnote related attributes */
  counter-reset: footnote;
  @footnote {
    counter-increment: footnote;
    float: bottom;
    column-span: all;
    height: auto;
    }
  }

@page chapter {
  @bottom-center {
    vertical-align: middle;
    text-align: center;
    content: element(heading);
  }
}
```