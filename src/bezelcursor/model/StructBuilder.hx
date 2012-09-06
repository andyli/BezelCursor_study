package bezelcursor.model;

#if macro
using Lambda;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.rtti.Meta;
#end
class StructBuilder {
	@:macro static public function build():Array<Field> {
		var pos = Context.currentPos();
		var fields = Context.getBuildFields();
		var constructor = fields.filter(function(f) return f.name == "new").first();
		
		switch (constructor.kind) {
			case FFun(f):
				
			default:
				throw "Constructor should be a function.";
		}
		
		var instanceFields = fields.filter(function(f) return switch(f.kind){
			case FFun(_):
				false;
			default:
				!f.access.has(AStatic) && !f.meta.exists(function(m) return m.name == ":skip");
		});
		
		for (f in instanceFields) {
			switch(f.kind) {
				case FVar(t, e):
					if (e == null) continue;
					else throw f;
					fields.remove(f);
					fields.push({
						name: f.name,
						doc: f.doc,
						access: f.access,
						kind: FVar(t),
						pos: f.pos,
						meta: f.meta
					});
				case FProp(get, set, t, e):
					if (e == null) continue;
					else throw f;
					fields.remove(f);
					fields.push({
						name: f.name,
						doc: f.doc,
						access: f.access,
						kind: FProp(get, set, t),
						pos: f.pos,
						meta: f.meta
					});
				default:
			}
		}
		
		//trace("=============" + Context.getLocalClass().toString());
		//trace(instanceFields.map(function(p) return p.name));
		
		//function fromObj(obj:Dynamic) { ... }
		fields.push({
			access: [APublic, AOverride],
			name: "fromObj",
			kind:FFun({
				args: [{
					name: "obj",
					opt: false,
					type: TPath({pack:[], name:"Dynamic", params: []})
				}],
				ret: TPath({pack:[], name:"Void", params: []}),
				expr: { 
					expr: EBlock( [macro super.fromObj(obj)].concat(
						instanceFields.map(function(f){
							var fName = f.name;
							var thisField = {
								expr: EField(macro this, fName),
								pos: pos
							}
							var objField = {
								expr: EField(macro obj, fName),
								pos: pos
							}
							return macro try {
								$thisField = $objField;
							} catch (e:Dynamic){ trace(e); }
						}).array()
					)), 
					pos: pos
				},
				params: []
			}),
			pos: pos
		});
		
		//function toObj():Dynamic;
		fields.push({
			access: [APublic, AOverride],
			name: "toObj",
			kind:FFun({
				args: [],
				ret: TPath({pack:[], name:"Dynamic", params: []}),
				expr: { 
					expr: EBlock([macro var obj = super.toObj()].concat(
						instanceFields.map(function(f){
							var fName = f.name;
							var thisField = {
								expr: EField(macro this, fName),
								pos: pos
							}
							var objField = {
								expr: EField(macro obj, fName),
								pos: pos
							}
							return macro try {
								$objField = $thisField;
							} catch (e:Dynamic){ trace(e); }
						}).array()
					).concat([macro return obj])), 
					pos: pos
				},
				params: []
			}),
			pos: pos
		});
		
		return fields;
	}
}