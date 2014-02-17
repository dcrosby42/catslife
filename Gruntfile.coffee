# (Croz note: I borrowed this config from https://github.com/shiwano/node-example/blob/master/Gruntfile.coffee)
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: '<json:package.json>'

    coffee:
      client_dev:
        expand: true
        cwd: "src"
        src: ["**/*.coffee"]
        dest: "public/js"
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

    shell:
      jasmine:
        command: "node_modules/jasmine-node/bin/jasmine-node --noStack --coffee spec/"
        options:
          stdout: true

    # https://github.com/jasmine-contrib/grunt-jasmine-node
    jasmine_node:
      specFolders: ["./spec"]
      specNameMatcher: ["./spec"]
      projectRoot: "."
      requirejs: false
      forceExit: true
      useCoffee: true
      # jUnit: 
      #   report: false
      #   savePath: "./build/reports/jasmine/"
      #   useDotNotation: true
      #   consolidate: true
    # grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-jasmine-node'
  grunt.loadNpmTasks 'grunt-shell'

  # grunt.registerTask 'test', 'simplemocha'
  # grunt.registerTask 'default', ['coffee', 'simplemocha']
  grunt.registerTask 'default', ['coffee:client_dev']
  # grunt.registerTask 'test', 'jasmine_node'
  grunt.registerTask 'test', 'shell:jasmine'

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

