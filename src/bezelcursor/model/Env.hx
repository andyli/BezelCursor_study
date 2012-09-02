package bezelcursor.model;

#if !macro @:build(bezelcursor.model.EnvBuilder.build("env.json")) #end
class Env {
	
}

#if macro
import haxe.Json;
import haxe.macro.Expr;
import haxe.macro.Context;
import sys.io.File;
#end
class EnvBuilder {
	@:macro public static function build(jsonFile:String) : Array<Field> {        
		var pos = Context.currentPos();
		var fields = Context.getBuildFields();
		
		jsonFile = Context.resolvePath(jsonFile);
		var json = Json.parse(File.getContent(jsonFile));
		for (f in Reflect.fields(json)) {
			var fExpr = Context.makeExpr(Reflect.field(json, f), pos);
			fields.push({ name : f, doc : null, meta : [], access : [APublic, AStatic], kind : FVar(null, fExpr), pos : pos });
		}
		
		//register the json file with the class being built
		var cls = Context.getLocalClass().get();
		Context.registerModuleDependency(cls.pack.join(".") + "." + cls.name, jsonFile);
		
		return fields;
	}
}