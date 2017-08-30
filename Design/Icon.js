var Clumsy = require('clumsy');
var Canvas = require('canvas');
var helpers = require('clumsy/helpers');

var height = 1024;
var width = 1024;

var canvas = new Canvas(width, height);
var clumsy = new Clumsy(canvas);

var ctx = canvas.getContext('2d');

ctx.beginPath();
ctx.moveTo(0, height / 2);
ctx.fillStyle = '#0b3954';
ctx.fillRect(0, 0, width, height);

ctx.strokeStyle = '#a8d0db';
ctx.lineWidth = 20;

for(var i = 0; i < width; i ++) {
    var t = i / width;
    var t2 = 60 * (t - 0.5) * (t - 0.5);
    console.log(t, t2);
    let j = height * (0.5 + 0.33 * Math.sin(20 * Math.PI * t) * Math.exp(-t2));
    ctx.lineTo(1.1*i - 0.2*j + 0.2, j);
}
ctx.stroke();

helpers.saveAsPng(clumsy); // save as png of same name
