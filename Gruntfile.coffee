# (Croz note: I borrowed this config from https://github.com/shiwano/node-example/blob/master/Gruntfile.coffee)
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: '<json:package.json>'

    coffee:
      client_dev:
        expand: true
        cwd: "src/client"
        src: ["**/*.coffee"]
        dest: "public/js/client"
        ext: ".js"
        #flatten: true
        # options:
        #   sourceMap: true
        #   sourceMapDir: 'sourcemaps/'
          
    watch:
      files: [
        'Gruntfile.coffee'
        'src/**/*.coffee'
      ]
      tasks: 'default'

  # grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  # grunt.registerTask 'test', 'simplemocha'
  # grunt.registerTask 'default', ['coffee', 'simplemocha']
  grunt.registerTask 'default', ['coffee:client_dev']

    # uglify:
    #   options:
    #     banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
    #   build:
    #     src: 'src/<%= pkg.name %>.js',
    #     dest: 'build/<%= pkg.name %>.min.js'

  # Load the plugin that provides the "uglify" task.
  #grunt.loadNpmTasks('grunt-contrib-uglify')

  # Default task(s).
  #grunt.registerTask('default', ['uglify'])

