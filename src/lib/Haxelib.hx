package lib;

import haxe.remoting.*;
import tink.http.Client.*;
import js.html.*;
import js.Browser.*;

import tink.CoreApi;

class Haxelib implements Lib {
	var lib:String;
	
	public function new(lib:String) {
		this.lib = lib;
	}
	
	public function getInfo() {
		
		// HACK: this hacks through CORS using the cors-anywhere service
		return fetch('https://cors-anywhere.herokuapp.com/https://lib.haxe.org/p/$lib').all()
			.next(res -> {
				var re = new EReg('<code>haxelib install $lib (.*)<\\/code>', '');
				if(re.match(res.body)) {version: re.matched(1)};
				else new Error('Haxelib: Unable to parse version of $lib');
			});
			
		// This won't work because of CORS
		// return Future.async(function(cb) {
		// 	var iframe = document.createIFrameElement();
		// 	iframe.src = 'https://lib.haxe.org/p/$lib';
		// 	iframe.onload = function() {
		// 		var re = new EReg('<code>haxelib install $lib (.*)<\\/code>', '');
		// 		if(re.match(iframe.contentWindow.document.body.innerHTML)) {
		// 			trace('matched');
		// 			trace(re.matched(1));
		// 			cb(Success({version: re.matched(1)}));
		// 		} else {
		// 			cb(Failure(new Error('Haxelib: Unable to parse version of $lib')));
		// 		}
		// 		document.body.removeChild(iframe);
		// 	}
		// 	document.body.appendChild(iframe);
		// });
		
		// This won't work because the API doesn't understand the OPTIONS verb
		// Which is necessary for cross domain requests
		// return Future.async(function(cb) {
		// 	var cnx = HttpAsyncConnection.urlConnect('http://lib.haxe.org/api/3.0/index.n');
		// 	cnx.setErrorHandler(function(e) cb(Failure(Error.withData('Error', e))));
		// 	cnx.api.getLatestVersion.call(['tink_core'], function(result:String) cb(Success({version: result})));
		// });
	}
}