/*global module */
/*global require */
(function () {
  'use strict';
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

      // JAVASCRIPT TASKS
      // Hint the grunt file and all files under js/
      // and one directory below
      jshint: {
        files: ['Gruntfile.js', 'js/{,*/}*.js'],
        options: {
          reporter: require('jshint-stylish')
            // options here to override JSHint defaults
        }
      },

      // Takes all the files under js/ and selected files under lib
      // and concatenates them together. I've chosen not to mangle
      // the compressed file
      uglify: {
        dist: {
          options: {
            mangle: false,
            sourceMap: true,
            sourceMapName: 'css/script.min.map'
          },
          files: {
            'js/script.min.js': ['js/video.js', 'lib/highlight.pack.js']
          }
        }
      },

      jscs: {
        options: {
          'standard': 'Idiomatic'
        },
        all: ['js/']
      },

      // SASS RELATED TASKS
      // Converts all the files under scss/ ending with .scss
      // into the equivalent css file on the css/ directory
      sass: {
        dev: {
          options: {
            style: 'expanded'
          },
          files: [{
            expand: true,
            cwd: 'scss',
            src: ['*.scss'],
            dest: 'css',
            ext: '.css'
          }]
        },
        production: {
          options: {
            style: 'compact'
          },
          files: [{
            expand: true,
            cwd: 'scss',
            src: ['*.scss'],
            dest: 'css',
            ext: '.css'
          }]
        }
      },

      // This task requires the scss-lint ruby gem to be installed on your system
      // If you choose not to install it, comment out this task and the prep-css
      // and work-lint tasks below
      //
      // I've chosen not to fail on errors or warnings.
      scsslint: {
        allFiles: [
          'scss/*.scss',
          'scss/modules/_mixins.scss',
          'scss/modules/_variables.scss',
          'scss/partials/*.scss'
        ],
        options: {
          config: '.scss-lint.yml',
          force: true,
          colorizeOutput: true
        }
      },


      autoprefixer: {
        options: {
          // We need to `freeze` browsers versions for testing purposes.
          browsers: ['last 2']
        },

        files: {
          expand: true,
          flatten: true,
          src: 'scss/*.scss',
          dest: 'css/'
        }
      },

      // CSS TASKS TO RUN AFTER CONVERSION
      // Cleans the CSS based on what's used in the specified files
      // See https://github.com/addyosmani/grunt-uncss for more
      // information
      uncss: {
        dist: {
          files: {
            'css/tidy.css': ['*.html', '!docs.html']
          }
        }
      },

      // FILE MANAGEMENT
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

      // Copy the files from our repository into the build directory
      copy: {
        build: {
          files: [{
            expand: true,
            src: ['app/**/*'],
            dest: 'build/'
          }]
        }
      },

      // Clean the build directory
      clean: {
        production: ['build/']
      },

      // GH-PAGES TASK
      // Push the specified content into the repositories gh-pages branch
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

      // WATCH TASK
      // Watch for changes on the js and scss files and perform
      // the specified task
      watch: {
        options: {
          nospawn: true
        },
        // Watch all javascript files and hint them
        js: {
          files: ['Gruntfile.js', 'js/{,*/}*.js'],
          tasks: ['jshint']
        },
        sass: {
          files: ['scss/*.scss'],
          tasks: ['sass']
        }
      },

      // COMPILE AND EXECUTE TASKS
      // rather than using Ant, I've settled on Grunt's shell
      // task to run the compilation steps to create HTML and PDF.
      // This reduces teh number of dependecies for our project
      shell: {
        options: {
          failOnError: true,
          stderr: false
        },
        html: {
          command: 'java -jar /usr/local/java/saxon.jar -xsl:xslt/book.xsl docs.xml -o:index.html'
        },
        single: {
          command: 'java -jar /usr/local/java/saxon.jar -xsl:xslt/pm-book.xsl docs.xml -o:docs.html'
        },
        prince: {
          command: 'prince --verbose --javascript docs.html -o docs.pdf'
        }
      }


    }); // closes initConfig

    // CUSTOM TASKS
    // Usually a combination of one or more tasks defined above
    grunt.task.registerTask(
      'lint',
      [
        'scsslint',
        'jshint'
      ]
    );

    // Prep CSS starting with SASS, autoprefix et. al
    grunt.task.registerTask(
      'prep-css',
      [
        'scsslint',
        'sass:dev',
        'autoprefixer'
      ]
    );

    grunt.task.registerTask(
      'prep-js',
      [
        'jshint',
        'uglify'
      ]
    );

    // This task should run last, after all the other tasks are completed
    grunt.task.registerTask(
      'generate-pdf',
      [
        'shell:single',
        'shell:prince'
      ]
    );

    grunt.task.registerTask(
      'generate-all',
      [
        'shell'
      ]
    );


  }; // closes module.exports
}()); // closes the use strict function
