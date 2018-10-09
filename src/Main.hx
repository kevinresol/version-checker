package;

import tink.http.Client.*;
import lib.*;
import source.*;
import Source;
import js.Browser.*;

using DateTools;
using tink.CoreApi;

class Main {
	static function main() {
		
		function print(v:String) {
			var pre = document.createPreElement();
			pre.innerText = v;
			document.body.appendChild(pre);
		}
		
		function _check(lib:String) {
			check(lib, 'haxetink', lib, 'master')
				.handle(function(o) switch o {
					case Success({tag: tag, latest: latest}) if(tag.sha == latest.sha):
						// trace(tag, latest);	
						print('$lib is latest');
					case Success({tag: tag, latest: latest}):
						var dt = (latest.date.getTime() - tag.date.getTime()) / 1000;
						
						var format = 
							if(dt < 60) '$dt seconds';
							else if(dt < 3600) '${Std.int(dt / 60)} mintes'
							else if(dt < 24 * 3600) '${Std.int(dt / 3600)} hours'
							else '${Std.int(dt / 24 / 3600)} days';
						
						print('$lib is $format behind master\n(${latest.sha.substr(0, 8)} ${latest.date.format('%F %T')} >> ${tag.sha.substr(0, 8)} ${tag.date.format('%F %T')})');
					case Failure(e):
						trace(e);
				});
		}
		
		fetch('https://api.github.com/orgs/haxetink/repos?per_page=100').all()
			.handle(o -> {
				var repos:Array<{name:String}> = haxe.Json.parse(o.sure().body);
				trace('Got ${repos.length} repos');
				for(repo in repos) _check(repo.name);
			});
		
	}
	
	static function check(lib:String, owner:String, project:String, branch:String):Promise<Result> {
		var haxelib = new Haxelib(lib);
		return haxelib.getInfo()
			.next(lib -> {
				Promise.inParallel([
					new GitHub(owner, project, Tag(lib.version)).getInfo(),
					new GitHub(owner, project, Branch(branch)).getInfo(),
				]);
			})
			.next(res -> {
				tag: res[0],
				latest: res[1],
			});
	}
}

typedef Result = {
	latest:SourceInfo,
	tag:SourceInfo,
}