package bezelcursor.model;

#if macro
using Lambda;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.rtti.Meta;
#end

class StructBuilder {
	@:macro static public function buildClass():Array<Field> {
		var pos = Context.currentPos();
		var cls = Context.getLocalClass().get();
		var clsComplex = Context.toComplexType(Context.getType(cls.pack.concat([cls.name]).join(".")));
		var isDirectImpl = cls.interfaces.exists(function(i) return i.t.toString() == "bezelcursor.model.IStruct");
		var fields = Context.getBuildFields();
		
		var instanceFields = fields.filter(function(f) return switch(f.kind){
			case FFun(_):
				false;
			default:
				!f.access.has(AStatic) && !f.meta.exists(function(m) return m.name == ":skip");
		});
		/*
		var allInstanceFields = instanceFields.array();
		
		allInstanceFields.iter(function(f){
			f.kind = switch(f.kind) {
				case FVar(t, e):
					FVar(Context.toComplexType(Context.typeof({ expr: ECheckType(macro null, t ), pos: f.pos })));
				case FProp(get, set, t, e):
					FVar(Context.toComplexType(Context.typeof({ expr: ECheckType(macro null, t ), pos: f.pos })));
				default:
			}
			f.meta.push({ pos: f.pos, params: [], name : ":optional" });
		});
		
		
		var superCls = cls.superClass.t.get();
		var superType = Context.typeof(Context.parse("{var a:" + superCls.pack.concat([superCls.name]).join(".") + (cls.superClass.params.length > 0 ? cls.superClass.params.map(Std.string).join(",") : "") + "; a;}", pos));
		
		switch(superType) {
			case TInst
		}
		allInstanceFields.concat(superType.fields.get());
		*/
				
		/*/Data typedef
		var dataTypeDefinition = {
			pack: cls.pack,
			name: cls.name + "Data",
			pos: cls.pos,
			meta: [], //no need to copy metadata
			params: cls.params.map(function(p) return {name: p.name, constraints:[], params:[]}).array(),
			isExtern: false,
			kind: TDStructure,
			fields: allInstanceFields
		};
		
		Context.defineType(dataTypeDefinition);
		*/
		/*
		for (f in instanceFields) {
			switch(f.kind) {
				case FVar(t, e):
					if (e == null) continue;
					
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
		*/
		//trace("=============" + Context.getLocalClass().toString());
		//trace(instanceFields.map(function(p) return p.name));
		/*
		var dataComplexType = if (superCls.name != "Struct") {
			TExtend({ pack: superCls.pack, name: superCls.name + "Data", params:[] }, dataTypeDefinition.fields);
		} else {
			TPath(cast dataTypeDefinition);
		}*/
		
		//init
		if (!fields.exists(function(f) return f.name == "init")) {
			fields.push({
				access: isDirectImpl ? [APublic] : [APublic, AOverride],
				name: "init",
				kind:FFun({
					args: [],
					ret: clsComplex,
					expr: isDirectImpl ? macro return this : macro { super.init(); return this; },
					params: []
				}),
				pos: cls.pos
			});
		}
		
		//function hxSerialize(s:haxe.Serializer):Void;
		if (isDirectImpl && !fields.exists(function(f) return f.name == "hxSerialize")) {
			fields.push({
				access: [APublic],
				name: "hxSerialize",
				kind:FFun({
					args: [{
						name: "s",
						opt: false,
						type: TPath({pack:["haxe"], name:"Serializer", params: []})
					}],
					ret: TPath({pack:[], name:"Void", params: []}),
					expr: macro s.serialize(toObj()),
					params: []
				}),
				pos: cls.pos
			});
		}
		
		//function hxUnserialize(s:haxe.Unserializer)
		if (isDirectImpl && !fields.exists(function(f) return f.name == "hxUnserialize")) {
			fields.push({
				access: [APublic],
				name: "hxUnserialize",
				kind:FFun({
					args: [{
						name: "s",
						opt: false,
						type: TPath({pack:["haxe"], name:"Unserializer", params: []})
					}],
					ret: TPath({pack:[], name:"Void", params: []}),
					expr: macro {
						fromObj(s.unserialize());
						init();
				    },
					params: []
				}),
				pos: cls.pos
			});
		}
		
		//function toObj():Dynamic;
		if (!fields.exists(function(f) return f.name == "toObj")) {
			fields.push({
				access: isDirectImpl ? [APublic] : [APublic, AOverride],
				name: "toObj",
				kind:FFun({
					args: [],
					ret: TPath({pack:[], name:"Dynamic", params: []}),
					expr: { 
						expr: EBlock((isDirectImpl ? [macro var obj:Dynamic = {}] : [macro var obj:Dynamic = super.toObj()]).concat(
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
								return macro $objField = $thisField;
							}).array()
						).concat([macro return obj])), 
						pos: pos
					},
					params: []
				}),
				pos: cls.pos
			});
		}
		
		//function fromObj(obj:Dynamic) { ... }
		if (!fields.exists(function(f) return f.name == "fromObj")) {
			fields.push({
				access: isDirectImpl ? [APublic] : [APublic, AOverride],
				name: "fromObj",
				kind:FFun({
					args:  [{
						name: "obj",
						opt: false,
						type: TPath({pack:[], name:"Dynamic", params: []})
					}],
					ret: clsComplex,
					expr: isDirectImpl ? macro {
						if (obj == null) return this;
						
						for (f in Reflect.fields(obj)) {
							Reflect.setProperty(this, f, Reflect.field(obj, f));
						}
		
						return this;
					} : macro { super.fromObj(obj); return this; },
					params: []
				}),
				pos: cls.pos
			});
		}
		
		return fields.filter(function(f) return !(f.meta != null && f.meta.exists(function(m) return m.name == ":remove"))).array();
	}
}