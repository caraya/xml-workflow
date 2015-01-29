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

### Optional: Ruby and SASS

The only external dependencies you need to worry about are Ruby and SASS. Ruby comes installe in most (if not all) Macintosh and Linux systems; an [installer for Windows](http://rubyinstaller.org/) is also available.

To install SASS, open a terminal/command window and type:

```bash
$ gem install sass
```

Note that on Mac and Linux you may need to run the command as a superuser:

```bash
$ sudo gem install sass
```

And enter your password when/if prompter to do so.

> Ruby and SASS are only necessary if you plan to change the SCSS/SASS files. If you don't you can skip the Ruby install and work directly with the CSS files
>
> If you want to peek at the SASS source look at the files under the scss directory. 

## Installing Node packages

Grunt is a Node.js based task runner. It's a declarative version of Make and similar tools in other languages. Since Grunt and it's associated plugins are Node Packages we need to configure Node. 

At the root of the project there's a `package.json` file where all the files necessary for the project have already been configured. All that is left is to run the install command. 

```bash
npm install
```

This will install all the packages indicated in configuration file and all their dependencies; go get a cup of coffee as this may take a while in slower machines.

As it installs the software it'll display a list of what it installed and when it's done you'll have all the packages. 

The final step of the node installation is to run bower, a front end package manager. It is not configured by default but you can use it to manage packages such as jQuery, Highlight.JS, Polymer web components and others.

## Grunt &amp; Front End Development best practices

Developing the workflow has given me the chance to research and implement front end development best practices. Decreasing the size of the files requested when accessing the site


Grunt has its own configuration file (`Gruntfile.js`) one of which is provided as a model for the example application. 

The Grunt file provides the following functionality:

* Prefix CSS files automatically
* Clean files and folders
* Copy files as neeed
* Validate all Javascript files
* Compile Sass to CSS
* Minify Javascript files
* Run predefined tasks whenever watched files change
* Publish to gh-pages
* Make directories as needed
* Validate SCSS files
* Remove unused CSS based on what rules are used in specified files

we will discuss each portion of the file and its purpose as we move down the file

We wrap the Gruntfile with a self executing function as a deffensive coding strategy. 

When concatenating Javascript files there may be some that use strict Javascript and some that don't; With Javascript [variable hoisting](http://code.tutsplus.com/tutorials/javascript-hoisting-explained--net-15092) the use stric declaration would be placed at the very top of the concatenated file making all the scripts underneat use the strict declaration.

The function wrap prevents this by making the use strict declaration local to the file where it was written. None of the other templates will be affected and they will still execute from the master stylesheet. 

