package;

using tink.CoreApi;

interface Source {
	function getInfo():Promise<SourceInfo>;
}

typedef SourceInfo = {
	date:Date,
	sha:String,
}