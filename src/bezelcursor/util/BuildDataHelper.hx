package bezelcursor.util;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class BuildDataHelper {
	macro static public function getTime():ExprOf<Float> {
		return Context.makeExpr(Date.now().getTime(), Context.currentPos());
	}
	
	macro static public function getGitLog():ExprOf<String> {
		trace(Sys.command("git", ["log", "--oneline", "-5"]));
		//Sys.stdin().readLine();
		//new sys.io.Process("git", ["log", "--oneline", "-5"]);
		//new sys.io.Process("ls", []);
		var p = new sys.io.Process("echo",["hello"]);
				var str = p.stdout.readAll();
		return Context.makeExpr(new sys.io.Process("git", ["log", "--oneline", "-5"]).stdout.readAll().toString(), Context.currentPos());
	}
}