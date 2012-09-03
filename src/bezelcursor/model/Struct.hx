package bezelcursor.model;

class Struct {
    function hxSerialize(s:haxe.Serializer) {
		s.serialize(toObj());
    }
	
    function hxUnserialize(s:haxe.Unserializer) {
		fromObj(s.unserialize());
    }
	
	function fromObj(obj:Dynamic) {
		for (field in Reflect.fields(obj)) {
			try {
				Reflect.setProperty(this, field, Reflect.field(obj, field));
			} catch (e:Dynamic){ #if debug trace(e); #end }
		}
	}
	
	function toObj():Dynamic {
    	var obj = {};
		for (field in Type.getInstanceFields(Type.getClass(this))) {
			var value = Reflect.getProperty(this, field);
			if (Reflect.isFunction(value)) continue;
			Reflect.setField(obj, field, value);
		}
		return obj;
	}
}