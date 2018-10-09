package;

using tink.CoreApi;

interface Lib {
	function getInfo():Promise<LibInfo>;
}

typedef LibInfo = {
	// date:String,
	version:String,
}