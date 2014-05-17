$.glassyWorms =
    version: '<%= version %>'

    Particle: class
        constructor: ( @x = 0.0, @y = 0.0, @mass = 1.0, colors=['#000000'] ) ->
            @tail = []

            @radius = @mass * 0.15
            @charge = random [ -1, 1 ]
            @color = random colors

            @fx = @fy = 0.0
            @vx = @vy = 0.0

    setup: ->
        for i in [0..@glassyWormsOptins.numParticles] by 1

            x = random @width
            y = random @height
            m = random 8.0, 14.0

            @particles.push new $.glassyWorms.Particle x, y, m, @glassyWormsOptins.colors

    draw: ->
        @lineCap = @lineJoin = 'round'

        for i in [0..@glassyWormsOptins.numParticles] by 1
          
            a = @particles[i]

            # invert charge
            if random() < 0.5 then a.charge = -a.charge

            for j in [i+1..@glassyWormsOptins.numParticles] by 1

                b = @particles[j]

                # delta vector
                dx = b.x - a.x
                dy = b.y - a.y

                # distance
                dst = sqrt dSq = ( dx * dx + dy * dy ) + 0.1
                rad = a.radius + b.radius

                if dst >= rad
                    # derivative of unit length for normalisation
                    len = 1.0 / dst

                    fx = dx * len
                    fy = dy * len

                    # gravitational force
                    f = min @glassyWormsOptins.maxForce, ( @glassyWormsOptins.gravity * a.mass * b.mass ) / dSq

                    a.fx += f * fx * b.charge
                    a.fy += f * fy * b.charge

                    b.fx += -f * fx * a.charge
                    b.fy += -f * fy * a.charge
              
            # integrate
            a.vx += a.fx
            a.vy += a.fy

            a.vx *= @glassyWormsOptins.friction
            a.vy *= @glassyWormsOptins.friction

            a.tail.unshift x: a.x, y: a.y
            a.tail.pop() if a.tail.length > @glassyWormsOptins.tailLength

            a.x += a.vx
            a.y += a.vy

            # reset force
            a.fx = a.fy = 0.0

            # wrap

            if a.x > @width + a.radius
                a.x = -a.radius
                a.tail = []

            else if a.x < -a.radius
                a.x = @width + a.radius
                a.tail = []

            if a.y > @height + a.radius
                a.y = -a.radius
                a.tail = []

            else if a.y < -a.radius
                a.y = @height + a.radius
                a.tail = []
              
            # draw
            @strokeStyle = a.color
            @lineWidth = a.radius * 0.1

            @beginPath()
            @moveTo a.x, a.y
            @lineTo p.x, p.y for p in a.tail
            @stroke()

$.fn.glassyWorms = (options)->
    if typeof options is 'string'
        @each (index, el)->
            console.log(el.glassyWorms, el.glassyWorms?[options])
            el.glassyWorms?[options]?()

        return @

    options = $.extend
        numParticles: 250
        tailLength: 12
        maxForce: 8
        friction: 0.75
        gravity: 9.81
        interval: 3
        colors: ['#fff']
        element: $('<canvas class="worms"></canvas>')[0]
        useStyles: false
    , options

    if options.className or options.id
        element = $('<canvas></canvas>')
        element.addClass options.className if options.className
        element.attr 'id', options.id if options.id

        options.element = element[0]

    if options.useStyles
        element = $(options.element)
        element.css
            position: "absolute"
            top: 0
            bottom: 0
            right: 0
            left: 0

        options.element = element[0]

    @each (index, el)->
        el.glassyWorms = Sketch.create
            container: el
            element: options.element
            particles: []
            interval: options.interval
            setup: $.glassyWorms.setup
            draw: $.glassyWorms.draw
            glassyWormsOptins: options

    return @
