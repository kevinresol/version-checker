package source;

import tink.http.Client.*;

using Lambda;
using tink.CoreApi;

class GitHub implements Source {
	var owner:String;
	var project:String;
	var target:Target;
	var credentials:Credentials;
	
	public function new(owner, project, target, credentials) {
		this.owner = owner;
		this.project = project;
		this.target = target;
		this.credentials = credentials;
	}
	
	public function getInfo() {
		
		var res = switch target {
			case Tag(tag):
				fetch('https://api.github.com/repos/$owner/$project/tags', {headers: [credentials]}).all()
					.next(res -> {
						var obj:Array<{name:String, commit:{sha:String}}> = haxe.Json.parse(res.body);
						switch obj.find(t -> t.name == tag) {
							case null: new Error('GitHub: Tag $tag not found for $owner/$project');
							case v: fetch('https://api.github.com/repos/$owner/$project/commits?sha=${v.commit.sha}', {headers: [credentials]}).all();
						}
					});
			case Branch(branch):
				fetch('https://api.github.com/repos/$owner/$project/commits?sha=$branch', {headers: [credentials]}).all();
		}
		
		return res.next(res -> {
			var obj:Array<{sha:String, commit:{author:{date:String}}}> = haxe.Json.parse(res.body);
			switch obj[0] {
				case null: new Error('Unreachable');
				case v: {
					date: js.Syntax.code('new Date({0})', v.commit.author.date),
					sha: v.sha,
				}
			}
		});
	}
}

enum Target {
	Tag(tag:String);
	Branch(branch:String);
}

