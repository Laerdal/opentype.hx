// Generated by Haxe 4.0.5
(function ($global) { "use strict";
var TestOpenTypeJs = function() { };
TestOpenTypeJs.main = function() {
	console.log("TestOpenTypeJs.hx:4:","Hello");
	var ot = require("./opentype.js");
	ot.load("fonts/lato.ttf",function(e,f) {
		console.log("TestOpenTypeJs.hx:6:","Done");
		return;
	});
};
TestOpenTypeJs.main();
})({});