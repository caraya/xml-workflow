# Tools

Because we use XML we can't just dump our code in the browser or the PDF viewer we need to prepare our content for conversion to PDF before we can view it.  There are also front-end web development best practices to follow. 

This chapter will discuss tools to accomplish both tasks from one  build file. 

## What software we need

For this to work you need the following software installed:

* Java (version 1.7 or later)
* Node.js (0.10.35 or later)

Once you have java installed, you can install the following Java packages

* [Apache Ant](http://ant.apache.org/bindownload.cgi)
* [Saxon](http://sourceforge.net/projects/saxon/files/latest/download?source=files) (9.0.6.4 for Java)

A note about Saxon: OxygenXML comes with a version of Saxon Enterprise Edition. We'll use a different version to make it easier to use outside the editor. 

Node packages are handled through NPM, the Node Package Manager. On the Node side we need at least the `grunt-cli` package installed globally. TO do so we use this command:

```bash
$ npm install -g grunt-cli
```

The -g flag will install this globally, as opposed to installing it in the project director. 

Now that we have the required sotfware installed we can move ahead and create our configiuration files. 

## Grunt first

Grunt is a Node.js based task runner. It's a declarative version of Make and other 