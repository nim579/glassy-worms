module.exports = (grunt)->

    grunt.initConfig
        pkg: grunt.file.readJSON('./package.json')
        jqConfig: grunt.file.readJSON('./glassyWorms.jquery.json')

        meta:
            banner: '// Plugin <%= pkg.name %>. <%= jqConfig.description %>\n' +
                    '// Aunthor: <%= pkg.author %>. Sorced 17 May 2014\n' +
                    '// Promo: http://dev.nim579.ru/<%= pkg.name %>\n' +
                    '// Version: <%= pkg.version %> (<%= grunt.template.today() %>)\n'

        concat:
            options:
                banner: '<%= meta.banner %>'

            plugin:
                src: ['./src/*.js']
                dest: './builds/<%= jqConfig.name %>-<%= pkg.version %>.js'

        uglify:
            plugin:
                options:
                    banner: '<%= meta.banner %>'

                files:
                    './builds/<%= jqConfig.name %>.min-<%= pkg.version %>.js': ['./builds/<%= jqConfig.name %>-<%= pkg.version %>.js']

        coffee:
            plugin:
                files: [
                    expand: true
                    cwd: './src'
                    src: ['*.coffee']
                    dest: './src'
                    ext: '.js'
                ]

        watch:
            coffee:
                files: ['./src/*.coffee']
                tasks: ['coffee']

        zip:
            app:
                cwd: './builds'
                src: ['./builds/<%= jqConfig.name %>.min-<%= pkg.version %>.js', './builds/<%= jqConfig.name %>-<%= pkg.version %>.js', 'README.md']
                dest: './builds/<%= jqConfig.name %>-<%= pkg.version %>.zip'

        srv:
            demo:
                port: 8001
                root: './'
                index: './demos/index.html'


    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-concat'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-zip'
    grunt.loadNpmTasks 'node-srv'


    coffee = require 'coffee-script'
    path = require 'path'

    grunt.registerMultiTask 'coffee', 'Compile coffee', ()->
        @files.forEach (file)->
            coffeeCode = grunt.file.read file.src[0]

            jsCode = coffee.compile grunt.util._.template coffeeCode, grunt.config.get('pkg')
            
            grunt.file.write file.dest, jsCode
            grunt.log.ok 'Compiled coffee file: ' + file.src[0] + ' at ' + grunt.template.today()


    grunt.registerTask 'build', 'Build project', (test)->
        grunt.log.write 'Run build...'

        pkg = grunt.config.get('pkg')
        jqConfig = grunt.config.get('jqConfig')

        jqConfig.version = pkg.version

        grunt.file.write './glassyWorms.jquery.json', JSON.stringify jqConfig, null, 2

        grunt.task.run ['coffee', 'concat:plugin', 'uglify', 'zip', 'cleadBuilds']


    grunt.registerTask 'cleadBuilds', 'Clean builds folder', ()->
        files = grunt.file.expand './builds/*.js'
        files.forEach (file)->
            try
                grunt.file.delete file
                grunt.log.ok 'Removed file: ' + file
            catch e
                grunt.log.error 'File' + file + ' not removed'

        grunt.log.ok 'Files cleared at ' + grunt.template.today()
