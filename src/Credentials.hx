import tink.http.Header;

abstract Credentials(String) from String {
	@:to inline function toHeader():HeaderField {
		return
			if(this == null)
				new HeaderField('X-DUMMY', '');
			else switch this.indexOf(':') {
				case -1: throw 'invalid credentials';
				case i: new HeaderField(AUTHORIZATION, HeaderValue.basicAuth(this.substr(0, i), this.substr(i + 1)));
			}
	}
}