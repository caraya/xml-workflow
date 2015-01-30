---
title: From XML to PDF: Part 2: CSS
date: 2015-01-13
category: Technology
status: draft
---


Once we have the HTML file ready we can run it through PrinceXML to get our PDF using another CSS stylesheet formatted for Paged Media. The command to run the conversion for a book.html file is:

```bash
$ prince --verbose book.html test-book.pdf
```

Because we added the stylesheet link directly to the HTML document we can skip declaring it in the conversion itself. This is always a cause of errors and frustratoins for me so I thought I'd save everyone else the hassle. 

