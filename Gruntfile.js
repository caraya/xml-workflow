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

      // Hint the grunt file and all files under js/
      // and one directory below
      jshint: {
        files: ['Gruntfile.js', 'js/{,*/}*.js'],
        options: {
          reporter: require('jshint-stylish')
            // options here to override JSHint defaults
        }
      },

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

      // Copy the files from our repository into the build directory
      'copy': {
        build: {
          files: [
            {
              expand: true,
              src: ['app/**/*'],
              dest: 'build/'
            }
          ]
        }
      },

      // Clean the build directory
      clean: {
        production: ['build/']
      },

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
