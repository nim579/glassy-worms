// Plugin glassy-worms. Beautiful worms on background
// Aunthor: Nick Iv. Sorced 17 May 2014
// Promo: http://dev.nim579.ru/glassy-worms
// Version: 0.0.2 (Sat May 17 2014 14:29:43)
(function() {
  $.glassyWorms = {
    version: '0.0.2',
    Particle: (function() {
      function _Class(x, y, mass, colors) {
        this.x = x != null ? x : 0.0;
        this.y = y != null ? y : 0.0;
        this.mass = mass != null ? mass : 1.0;
        if (colors == null) {
          colors = ['#000000'];
        }
        this.tail = [];
        this.radius = this.mass * 0.15;
        this.charge = random([-1, 1]);
        this.color = random(colors);
        this.fx = this.fy = 0.0;
        this.vx = this.vy = 0.0;
      }

      return _Class;

    })(),
    setup: function() {
      var i, m, x, y, _i, _ref, _results;
      _results = [];
      for (i = _i = 0, _ref = this.glassyWormsOptins.numParticles; _i <= _ref; i = _i += 1) {
        x = random(this.width);
        y = random(this.height);
        m = random(8.0, 14.0);
        _results.push(this.particles.push(new $.glassyWorms.Particle(x, y, m, this.glassyWormsOptins.colors)));
      }
      return _results;
    },
    draw: function() {
      var a, b, dSq, dst, dx, dy, f, fx, fy, i, j, len, p, rad, _i, _j, _k, _len, _ref, _ref1, _ref2, _ref3, _results;
      this.lineCap = this.lineJoin = 'round';
      _results = [];
      for (i = _i = 0, _ref = this.glassyWormsOptins.numParticles; _i <= _ref; i = _i += 1) {
        a = this.particles[i];
        if (random() < 0.5) {
          a.charge = -a.charge;
        }
        for (j = _j = _ref1 = i + 1, _ref2 = this.glassyWormsOptins.numParticles; _j <= _ref2; j = _j += 1) {
          b = this.particles[j];
          dx = b.x - a.x;
          dy = b.y - a.y;
          dst = sqrt(dSq = (dx * dx + dy * dy) + 0.1);
          rad = a.radius + b.radius;
          if (dst >= rad) {
            len = 1.0 / dst;
            fx = dx * len;
            fy = dy * len;
            f = min(this.glassyWormsOptins.maxForce, (this.glassyWormsOptins.gravity * a.mass * b.mass) / dSq);
            a.fx += f * fx * b.charge;
            a.fy += f * fy * b.charge;
            b.fx += -f * fx * a.charge;
            b.fy += -f * fy * a.charge;
          }
        }
        a.vx += a.fx;
        a.vy += a.fy;
        a.vx *= this.glassyWormsOptins.friction;
        a.vy *= this.glassyWormsOptins.friction;
        a.tail.unshift({
          x: a.x,
          y: a.y
        });
        if (a.tail.length > this.glassyWormsOptins.tailLength) {
          a.tail.pop();
        }
        a.x += a.vx;
        a.y += a.vy;
        a.fx = a.fy = 0.0;
        if (a.x > this.width + a.radius) {
          a.x = -a.radius;
          a.tail = [];
        } else if (a.x < -a.radius) {
          a.x = this.width + a.radius;
          a.tail = [];
        }
        if (a.y > this.height + a.radius) {
          a.y = -a.radius;
          a.tail = [];
        } else if (a.y < -a.radius) {
          a.y = this.height + a.radius;
          a.tail = [];
        }
        this.strokeStyle = a.color;
        this.lineWidth = a.radius * 0.1;
        this.beginPath();
        this.moveTo(a.x, a.y);
        _ref3 = a.tail;
        for (_k = 0, _len = _ref3.length; _k < _len; _k++) {
          p = _ref3[_k];
          this.lineTo(p.x, p.y);
        }
        _results.push(this.stroke());
      }
      return _results;
    }
  };

  $.fn.glassyWorms = function(options) {
    var element;
    if (typeof options === 'string') {
      this.each(function(index, el) {
        var _ref, _ref1;
        console.log(el.glassyWorms, (_ref = el.glassyWorms) != null ? _ref[options] : void 0);
        return (_ref1 = el.glassyWorms) != null ? typeof _ref1[options] === "function" ? _ref1[options]() : void 0 : void 0;
      });
      return this;
    }
    options = $.extend({
      numParticles: 250,
      tailLength: 12,
      maxForce: 8,
      friction: 0.75,
      gravity: 9.81,
      interval: 3,
      colors: ['#fff'],
      element: $('<canvas class="worms"></canvas>')[0],
      useStyles: false
    }, options);
    if (options.className || options.id) {
      element = $('<canvas></canvas>');
      if (options.className) {
        element.addClass(options.className);
      }
      if (options.id) {
        element.attr('id', options.id);
      }
      options.element = element[0];
    }
    if (options.useStyles) {
      element = $(options.element);
      element.css({
        position: "absolute",
        top: 0,
        bottom: 0,
        right: 0,
        left: 0
      });
      options.element = element[0];
    }
    this.each(function(index, el) {
      return el.glassyWorms = Sketch.create({
        container: el,
        element: options.element,
        particles: [],
        interval: options.interval,
        setup: $.glassyWorms.setup,
        draw: $.glassyWorms.draw,
        glassyWormsOptins: options
      });
    });
    return this;
  };

}).call(this);
