// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var win = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel();
win.add(label);
win.open();

// TODO: write your module tests here
var tiziparchive = require('TiZipArchive');
Ti.API.info("module is => " + tiziparchive);

var zipfile = Ti.Filesystem.getFile('sample.zip');

// var filelist = tiziparchive.files(zipfile);
// Ti.API.debug(filelist);

var data = tiziparchive.read(zipfile, "minizip/crypt.h");
Ti.API.debug(data);


tiziparchive.extract({
    file: zipfile,
    target: Ti.Filesystem.applicationDataDirectory,
    success: function(e) {
        Ti.API.debug(e.target);
        alert("success");
    },
    error :function(e) {
        alert("error");
    }
});

