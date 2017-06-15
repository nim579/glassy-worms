root = self   if not root and typeof self   is 'object' and self.self     is self
root = global if not root and typeof global is 'object' and global.global is global

$ = null
Sketch = null
app = null

if typeof define is 'function' and define.amd
    define ['jquery', 'sketch-js', 'exports'], (d1, d2, d3)->
        $ = d1
        Sketch = d2
        app = d3

else if typeof exports isnt 'undefined'
    $ = require 'jquery'
    Sketch = require 'sketch-js'
    app = exports

else
    {$, Sketch} = root
    app = root

Utils = {}

Utils.unique = ->
    @_i ?= 0
    @_i++

    return @_i

Sketch.install Utils


class app.GlassyWormsParticle
    constructor: (@x=0.0, @y=0.0, @mass=1.0, colors=['#000000'])->
        @tail = []

        @radius = @mass * 0.15
        @charge = Utils.random [ -1, 1 ]
        @color = Utils.random colors

        @fx = @fy = 0.0
        @vx = @vy = 0.0


class app.GlassyWorms
    defaults: ->
        numParticles: 'auto'
        tailLength: 12
        maxForce: 8
        friction: 0.75
        gravity: 9.81
        interval: 3
        colors: ['#FFFFFF']
        element: document.createElement('canvas')
        useStyles: true
        retina: true

    constructor: (el, options={})->
        options = $.extend @defaults(), options

        options.element.id = options.id if options.id
        options.element.classList.toggle options.className, true if options.className

        if options.useStyles
            $(options.element).css position: "absolute", top: "0", left: "0", width: "100%", height: "100%"

        @id = Utils.unique()
        @el = el
        @options = options

        @init()
        $(window).bind "resize.glassyWorms#{@id}", (e)=> @onResize e

    init: ->
        instance = @

        if @_sketch
            @_sketch.destroy()
            delete @_sketch

        @_sketch = Sketch.create
            container: @el
            element: @options.element
            particles: []
            interval: @options.interval
            params: @options
            setup: -> instance._setup.apply @, arguments
            draw: -> instance._draw.apply @, arguments

    start:   -> @_sketch?.start.apply   @_sketch, arguments
    stop:    -> @_sketch?.stop.apply    @_sketch, arguments
    toggle:  -> @_sketch?.toggle.apply  @_sketch, arguments
    clear:   -> @_sketch?.clear.apply   @_sketch, arguments
    setup:   -> @_sketch?.setup.apply   @_sketch, arguments
    draw:    -> @_sketch?.draw.apply    @_sketch, arguments

    destroy: ->
        $(window).unbind ".glassyWorms#{@id}"
        @_sketch?.destroy.apply @_sketch, arguments
        delete @_sketch

    onResize: ->
        @stop()

        clearTimeout @_resizeTO if @_resizeTO
        @_resizeTO = setTimeout =>
            @clear()
            @setup()
            @start()
        , 100

    _setup: ->
        @particles = []

        if @params.numParticles is 'auto'
            num = Math.round Utils.sqrt (@width * @height) / @params.gravity

        else
            num = @params.numParticles

        for i in [0...num]
            x = Utils.random @width
            y = Utils.random @height
            m = Utils.random 8.0, 14.0

            @particles.push new app.GlassyWormsParticle x, y, m, @params.colors

    _draw: ->
        @lineCap = @lineJoin = 'round'

        for a, i in @particles
            # invert charge
            if Utils.random() < 0.5 then a.charge = -a.charge

            for b, j in @particles.slice i+1
                # delta vector
                dx = b.x - a.x
                dy = b.y - a.y

                # distance
                dst = Utils.sqrt dSq = ( dx * dx + dy * dy ) + 0.1
                rad = a.radius + b.radius

                if dst >= rad
                    # derivative of unit length for normalisation
                    len = 1.0 / dst

                    fx = dx * len
                    fy = dy * len

                    # gravitational force
                    f = Utils.min @params.maxForce, (@params.gravity * a.mass * b.mass) / dSq

                    a.fx += f * fx * b.charge
                    a.fy += f * fy * b.charge

                    b.fx += -f * fx * a.charge
                    b.fy += -f * fy * a.charge

            # integrate
            a.vx += a.fx
            a.vy += a.fy

            a.vx *= @params.friction
            a.vy *= @params.friction

            a.tail.unshift x: a.x, y: a.y
            a.tail.pop() if a.tail.length > @params.tailLength

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
            el.glassyWorms?[options]?()
            delete el.glassyWorms if options is 'destroy'

        return @

    @each (index, el)->
        if el.glassyWorms
            el.glassyWorms.destroy()
            delete el.glassyWorms

        el.glassyWorms = new app.GlassyWorms el, options

    return @
