// Plugin glassy-worms. Beautiful worms on background
// Author: Nick Iv. Sorced 17 May 2014
// Site: http://dev.nim579.ru/glassy-worms
// Version: 1.0.0 (Thu Jun 15 2017 15:51:52)
(function() {
  var $, Sketch, Utils, app, root;

  if (!root && typeof self === 'object' && self.self === self) {
    root = self;
  }

  if (!root && typeof global === 'object' && global.global === global) {
    root = global;
  }

  $ = null;

  Sketch = null;

  app = null;

  if (typeof define === 'function' && define.amd) {
    define(['jquery', 'sketch-js', 'exports'], function(d1, d2, d3) {
      $ = d1;
      Sketch = d2;
      return app = d3;
    });
  } else if (typeof exports !== 'undefined') {
    $ = require('jquery');
    Sketch = require('sketch-js');
    app = exports;
  } else {
    $ = root.$, Sketch = root.Sketch;
    app = root;
  }

  Utils = {};

  Utils.unique = function() {
    if (this._i == null) {
      this._i = 0;
    }
    this._i++;
    return this._i;
  };

  Sketch.install(Utils);

  app.GlassyWormsParticle = (function() {
    function GlassyWormsParticle(x1, y1, mass, colors) {
      this.x = x1 != null ? x1 : 0.0;
      this.y = y1 != null ? y1 : 0.0;
      this.mass = mass != null ? mass : 1.0;
      if (colors == null) {
        colors = ['#000000'];
      }
      this.tail = [];
      this.radius = this.mass * 0.15;
      this.charge = Utils.random([-1, 1]);
      this.color = Utils.random(colors);
      this.fx = this.fy = 0.0;
      this.vx = this.vy = 0.0;
    }

    return GlassyWormsParticle;

  })();

  app.GlassyWorms = (function() {
    GlassyWorms.prototype.defaults = function() {
      return {
        numParticles: 'auto',
        tailLength: 12,
        maxForce: 8,
        friction: 0.75,
        gravity: 9.81,
        interval: 3,
        colors: ['#FFFFFF'],
        element: document.createElement('canvas'),
        useStyles: true,
        retina: true
      };
    };

    function GlassyWorms(el, options) {
      if (options == null) {
        options = {};
      }
      options = $.extend(this.defaults(), options);
      if (options.id) {
        options.element.id = options.id;
      }
      if (options.className) {
        options.element.classList.toggle(options.className, true);
      }
      if (options.useStyles) {
        $(options.element).css({
          position: "absolute",
          top: "0",
          left: "0",
          width: "100%",
          height: "100%"
        });
      }
      this.id = Utils.unique();
      this.el = el;
      this.options = options;
      this.init();
      $(window).bind("resize.glassyWorms" + this.id, (function(_this) {
        return function(e) {
          return _this.onResize(e);
        };
      })(this));
    }

    GlassyWorms.prototype.init = function() {
      var instance;
      instance = this;
      if (this._sketch) {
        this._sketch.destroy();
        delete this._sketch;
      }
      return this._sketch = Sketch.create({
        container: this.el,
        element: this.options.element,
        particles: [],
        interval: this.options.interval,
        params: this.options,
        setup: function() {
          return instance._setup.apply(this, arguments);
        },
        draw: function() {
          return instance._draw.apply(this, arguments);
        }
      });
    };

    GlassyWorms.prototype.start = function() {
      var ref;
      return (ref = this._sketch) != null ? ref.start.apply(this._sketch, arguments) : void 0;
    };

    GlassyWorms.prototype.stop = function() {
      var ref;
      return (ref = this._sketch) != null ? ref.stop.apply(this._sketch, arguments) : void 0;
    };

    GlassyWorms.prototype.toggle = function() {
      var ref;
      return (ref = this._sketch) != null ? ref.toggle.apply(this._sketch, arguments) : void 0;
    };

    GlassyWorms.prototype.clear = function() {
      var ref;
      return (ref = this._sketch) != null ? ref.clear.apply(this._sketch, arguments) : void 0;
    };

    GlassyWorms.prototype.setup = function() {
      var ref;
      return (ref = this._sketch) != null ? ref.setup.apply(this._sketch, arguments) : void 0;
    };

    GlassyWorms.prototype.draw = function() {
      var ref;
      return (ref = this._sketch) != null ? ref.draw.apply(this._sketch, arguments) : void 0;
    };

    GlassyWorms.prototype.destroy = function() {
      var ref;
      $(window).unbind(".glassyWorms" + this.id);
      if ((ref = this._sketch) != null) {
        ref.destroy.apply(this._sketch, arguments);
      }
      return delete this._sketch;
    };

    GlassyWorms.prototype.onResize = function() {
      this.stop();
      if (this._resizeTO) {
        clearTimeout(this._resizeTO);
      }
      return this._resizeTO = setTimeout((function(_this) {
        return function() {
          _this.clear();
          _this.setup();
          return _this.start();
        };
      })(this), 100);
    };

    GlassyWorms.prototype._setup = function() {
      var i, k, m, num, ref, results, x, y;
      this.particles = [];
      if (this.params.numParticles === 'auto') {
        num = Math.round(Utils.sqrt((this.width * this.height) / this.params.gravity));
      } else {
        num = this.params.numParticles;
      }
      results = [];
      for (i = k = 0, ref = num; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        x = Utils.random(this.width);
        y = Utils.random(this.height);
        m = Utils.random(8.0, 14.0);
        results.push(this.particles.push(new app.GlassyWormsParticle(x, y, m, this.params.colors)));
      }
      return results;
    };

    GlassyWorms.prototype._draw = function() {
      var a, b, dSq, dst, dx, dy, f, fx, fy, i, j, k, l, len, len1, len2, len3, n, p, rad, ref, ref1, ref2, results;
      this.lineCap = this.lineJoin = 'round';
      ref = this.particles;
      results = [];
      for (i = k = 0, len1 = ref.length; k < len1; i = ++k) {
        a = ref[i];
        if (Utils.random() < 0.5) {
          a.charge = -a.charge;
        }
        ref1 = this.particles.slice(i + 1);
        for (j = l = 0, len2 = ref1.length; l < len2; j = ++l) {
          b = ref1[j];
          dx = b.x - a.x;
          dy = b.y - a.y;
          dst = Utils.sqrt(dSq = (dx * dx + dy * dy) + 0.1);
          rad = a.radius + b.radius;
          if (dst >= rad) {
            len = 1.0 / dst;
            fx = dx * len;
            fy = dy * len;
            f = Utils.min(this.params.maxForce, (this.params.gravity * a.mass * b.mass) / dSq);
            a.fx += f * fx * b.charge;
            a.fy += f * fy * b.charge;
            b.fx += -f * fx * a.charge;
            b.fy += -f * fy * a.charge;
          }
        }
        a.vx += a.fx;
        a.vy += a.fy;
        a.vx *= this.params.friction;
        a.vy *= this.params.friction;
        a.tail.unshift({
          x: a.x,
          y: a.y
        });
        if (a.tail.length > this.params.tailLength) {
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
        ref2 = a.tail;
        for (n = 0, len3 = ref2.length; n < len3; n++) {
          p = ref2[n];
          this.lineTo(p.x, p.y);
        }
        results.push(this.stroke());
      }
      return results;
    };

    return GlassyWorms;

  })();

  $.fn.glassyWorms = function(options) {
    if (typeof options === 'string') {
      this.each(function(index, el) {
        var ref;
        if ((ref = el.glassyWorms) != null) {
          if (typeof ref[options] === "function") {
            ref[options]();
          }
        }
        if (options === 'destroy') {
          return delete el.glassyWorms;
        }
      });
      return this;
    }
    this.each(function(index, el) {
      if (el.glassyWorms) {
        el.glassyWorms.destroy();
        delete el.glassyWorms;
      }
      return el.glassyWorms = new app.GlassyWorms(el, options);
    });
    return this;
  };

}).call(this);
