# Glassy worms

Beautiful worms on background

## Usage

Requires [jQuery](http://jquery.com/) (>1.6) and [Sketch.js](http://soulwire.github.io/sketch.js/)

Default usage
~~~~~ js
$('body').glassyWorms();
~~~~~

With options
~~~~~ js
$('body').glassyWorms({
	colors: ['#000', '#f00'],
	numParticles: 800
});
~~~~~

## Options
* `number` **numParticles** — Nums of worms on element. Default: `250`
* `number` **tailLength** — Worm's tail length. Default: `12`
* `number` **maxForce** — Moving force. Default: `8`
* `number` **friction** — Frictions. Default: `0.75`
* `number` **gravity** — Gravity. Default: `9.81`
* `number` **interval** — Moving speed. Default: `3`
* `array` **colors** — Array of worm's colors. Default: `["#fff"]`
* `HTML object` **element** — Element for animating. Default: `"<canvas class="worms"></canvas>"`
* `string` **className** — Classname of animating element. Replaces **element** option, complements **id** option
* `string` **id** — ID of animating element. Replaces **element** option, complements **className** option
* `boolean` **useStyles** — Flag for using default styles for animating element.

## Default styles
~~~~~ css
position: absolute;
top: 0;
bottom: 0;
right: 0;
left: 0;
~~~~~

## Methods

~~~~~ js
$('body').glassyWorms('destroy')
~~~~~

* **stop** — Stops animating
* **start** — Resume animating
* **destroy** — Remove worms
