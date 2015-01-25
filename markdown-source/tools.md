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

## The Gruntfile

Grunt has its own configuration file (`Gruntfile.js`) one of which is provided as a model for the example application. 

The Goals of the grunt file are to provide the following functionality:

* Clean build files
* Convert SASS files to CSS and copy the result to the CSS directory
* Automatically prpefix CSS files as needed
* Lint Javascript files using JSHint to make sure they are correct
* Concatenate and minify all Javascript files and copy them to the appropriate directories
* Make a ***build*** directory and copy all necessary files and directories to it
* During development watch Sass and Javascript directories and recompile/process files when they change

```javascript
(function () {
  'use strict';
  var module, require; // Do I really need this?
  module.exports = function (grunt) {
    // require it at the top and pass in the grunt instance
    // it will measure how long things take for performance
    //testing
    require('time-grunt')(grunt);

    // load-grunt will read the package file and automatically
    // load all our packages configured there.
    // Yay for laziness
    require('load-grunt-tasks')(grunt);

    grunt.initConfig({

      // Hint the grunt file and all files under js/
      // and one directory below
      jshint: {
        files: ['Gruntfile.js', 'js/{,*/}*.js'],
        options: {
          reporter: require('jshint-stylish')
          // options here to override JSHint defaults
        }
      },

      // Can't seem to make the copy task create the directory
      // if it doesn't exist so we go to another task to create
      // the fn directory

      mkdir: {
        build: {
          options: {
            create: ['build']
          }
        }
      },

      'copy': {
        build: {
          files: [
            {
              expand: true,
              src: [ 'app/**/*' ],
              dest: 'build/'
            }
          ]
        }
      },

      clean: {
        production: [ 'build/']
      },

      'gh-pages': {
        options: {
          message: 'Content committed from Grunt gh-pages',
          base: './build/app',
          dotfiles: true
        },
        // These files will get pushed to the `
        // gh-pages` branch (the default)
        // We have to specifically remove node_modules
        src: ['**/*']
      },

      watch: {
        options: {
          nospawn: true
        },
        // Watch all javascript files and hint them
        js: {
          files: ['js/{,*/}*.js'],
          tasks: ['jshint']
        }
      }
    }); // closes initConfig

    grunt.task.registerTask(
      'publish',
      [
        'clean:production',
        'mkdir:build',
        'jshint',
        'copy:build',
        'gh-pages'
      ]
    );
  }; // closes module.exports
}()); // closes the use strict function
```

We wrap the Gruntfile with a self executing function as a deffensive coding strategy. 

When concatenating Javascript files there may be some that use strict Javascript and some that don't; With Javascript [variable hoisting](http://code.tutsplus.com/tutorials/javascript-hoisting-explained--net-15092) the use stric declaration would be placed at the very top of the concatenated file making all the scripts underneat use the strict declaration.

The function wrap prevents this by making the use strict declaration local to the file where it was written. None of the other files will be affected. 

## Apache Ant build file

Because we use Java applications to do most of the heavy lifting I've built an [Apache Ant](http://ant.apache.org) build file rather than do it manually every time. This will also allow us to use the Grunt targets from within the Java build/conversion process.

The Java build files performs the following tasks:

* Convert the XML file to either HTML files or a single HTML file (for Paged Media Processing)
* Run PrinceXML to convert the single HTML file to PDF
* Execute Grunt tasks as needed


```xml
<project name="workflow" default="createHtml" basedir=".">
<description>
    Build file for xml-based workflow.
</description>
  <target name="createHtml">
    <description>
      Creates HTML from XML and XSLT
    </description>
      <xslt classpath="jlib/saxon.jar"
        in="book1.xml" 
        out="index.html" 
        style="./xslt/book.xsl">
        <factory name="net.sf.saxon.TransformerFactoryImpl"/>
      </xslt>
  </target>
  
  <target name="createPagedMedia">
    <description>
      Converts the HTML to use with the Paged Media Style sheets
    </description>
    <xslt classpath="jlib/saxon.jar"
      in="book1.xml" 
      out="book.html" 
      style="./xslt/book.xsl">
      <factory name="net.sf.saxon.TransformerFactoryImpl"/>
    </xslt>
  </target>
 
  <target name="createPdf">
    <description>
      Uses Prince to convert the HTML file to PDF
    </description>
    <exec executable="prince">
      <arg value="--verbose"/>
      <arg value="book.html"/>
      <arg value="test-book.pdf"/>
    </exec>
  </target>
  
  <target name="PdfProcess">
    <description>
      Runs the conversion from XML to HTML and then from HTML to PDF
    </description>
    <antcall target="createPagedMedia"/>
    <antcall target="createPdf"/>
  </target>
  
  <target name="jshint">
    <description>
      Runs Grunt's jshint task 
    </description>
    <exec executable="grunt">
      <arg value="--verbose"/>
      <arg value="jshint"/>
    </exec>
  </target>
</project>
```

