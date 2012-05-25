var win = Ti.UI.createWindow({
	backgroundColor:'white'
});
var originImage = Ti.UI.createImageView({top:0, right:0, width:280, height:210});
win.add(originImage);

var effectedImage = Ti.UI.createImageView({top:210, right:0, width:280, height:210});
win.add(effectedImage);

var file = null,
	blob = null,
	factory = null,
	start = null,
	end = null;

var clear = function() {
	file = Ti.Filesystem.getFile('sample10.jpg');
	blob = file.read();
	
	var toycameraeffector = require('org.tektoh.toycameraeffector');
	Ti.API.info("module is => " + toycameraeffector);
	factory = toycameraeffector.createFactory({
		image: blob
	});
	originImage.setImage(blob);
	effectedImage.setImage(blob);
};

var reset = Ti.UI.createButton({
	bottom:0, left:0, width:40, height:30,
	title: 'C'
});
reset.addEventListener('click', clear);
win.add(reset);

var grayscale = Ti.UI.createButton({
	top:0, left:0, width:40, height:30,
	title: '1'
});
grayscale.addEventListener('click', function(e){
	start = (new Date()).getTime();
	factory.grayscale();
	end = (new Date()).getTime();
	Ti.API.info("Proccessing time: "+(end-start)+" msec");
	effectedImage.setImage(factory.image);
});
win.add(grayscale);

var histogramStretch = Ti.UI.createButton({
	top:30, left:0, width:40, height:30,
	title: '2'
});
histogramStretch.addEventListener('click', function(e){
	start = (new Date()).getTime();
	factory.histogramStretch();
	end = (new Date()).getTime();
	Ti.API.info("Proccessing time: "+(end-start)+" msec");
	effectedImage.setImage(factory.image);
});
win.add(histogramStretch);

var sigmoid = Ti.UI.createButton({
	top:60, left:0, width:40, height:30,
	title: '3'
});
sigmoid.addEventListener('click', function(e){
	start = (new Date()).getTime();
	factory.sigmoid(100);
	end = (new Date()).getTime();
	Ti.API.info("Proccessing time: "+(end-start)+" msec");
	effectedImage.setImage(factory.image);
});
win.add(sigmoid);

var modulateSaturation = Ti.UI.createButton({
	top:90, left:0, width:40, height:30,
	title: '4'
});
modulateSaturation.addEventListener('click', function(e){
	start = (new Date()).getTime();
	factory.modulateHSV({
		hue: 100,
		saturation: 150,
		brightness: 100
	});
	end = (new Date()).getTime();
	Ti.API.info("Proccessing time: "+(end-start)+" msec");
	effectedImage.setImage(factory.image);
});
win.add(modulateSaturation);

var darkenlimb = Ti.UI.createButton({
	top:120, left:0, width:40, height:30,
	title: '5'
});
darkenlimb.addEventListener('click', function(e){
	start = (new Date()).getTime();
	factory.darkenlimb(0.7, 2.0);
	end = (new Date()).getTime();
	Ti.API.info("Proccessing time: "+(end-start)+" msec");
	effectedImage.setImage(factory.image);
});
win.add(darkenlimb);

var emphasize = Ti.UI.createButton({
	top:150, left:0, width:40, height:30,
	title: '5'
});
emphasize.addEventListener('click', function(e){
	start = (new Date()).getTime();
	factory.emphasize(0.2, 0.3, 0.6);
	end = (new Date()).getTime();
	Ti.API.info("Proccessing time: "+(end-start)+" msec");
	effectedImage.setImage(factory.image);
});
win.add(emphasize);

win.open();
clear();
