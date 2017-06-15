module.exports = (grunt)->

    grunt.initConfig
        pkg: grunt.file.readJSON('./package.json')
        bowerConfig: grunt.file.readJSON('./bower.json')
        jqConfig: grunt.file.readJSON('./glassyWorms.jquery.json')

        meta:
            banner: '// Plugin <%= pkg.name %>. <%= jqConfig.description %>\n' +
                    '// Author: <%= pkg.author %>. Sorced 17 May 2014\n' +
                    '// Site: http://dev.nim579.ru/<%= pkg.name %>\n' +
                    '// Version: <%= pkg.version %> (<%= grunt.template.today() %>)\n'

        concat:
            options:
                banner: '<%= meta.banner %>'

            plugin:
                src: ['./lib/*.js']
                dest: './builds/<%= jqConfig.name %>.js'

        uglify:
            plugin:
                options:
                    banner: '<%= meta.banner %>'

                files:
                    './builds/<%= jqConfig.name %>.min.js': ['./builds/<%= jqConfig.name %>.js']

        coffee:
            plugin:
                options:
                    join: false
                    sourceMap: false
                    bare: false

                expand: true
                cwd: 'src'
                src: ['**/*.coffee']
                dest: './lib'
                ext: '.js'

        watch:
            coffee:
                files: ['./src/*.coffee']
                tasks: ['coffee']

        zip:
            app:
                cwd: './builds'
                src: ['./builds/<%= jqConfig.name %>.min.js', './builds/<%= jqConfig.name %>.js', 'README.md']
                dest: './builds/<%= jqConfig.name %>.zip'

        srv:
            demo:
                port: 8001
                root: './'
                index: './demos/index.html'


    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-concat'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-zip'
    grunt.loadNpmTasks 'node-srv'

    grunt.registerTask 'build', 'Build project', (test)->
        grunt.log.write 'Run build...'

        pkg = grunt.config.get('pkg')
        jqConfig = grunt.config.get('jqConfig')
        bowerConfig = grunt.config.get('bowerConfig')

        jqConfig.version = pkg.version
        bowerConfig.version = pkg.version

        grunt.file.write './glassyWorms.jquery.json', JSON.stringify jqConfig, null, 2
        grunt.file.write './bower.json', JSON.stringify bowerConfig, null, 2

        grunt.task.run ['clear', 'coffee', 'concat:plugin', 'uglify', 'zip']


    grunt.registerTask 'clear', 'Clean builds folder', ()->
        files = grunt.file.expand './lib/**/*'

        files.forEach (file)->
            try
                grunt.file.delete file
                grunt.log.ok 'Removed file: ' + file
            catch e
                grunt.log.error 'File' + file + ' not removed'

        grunt.log.ok 'Files cleared at ' + grunt.template.today()
