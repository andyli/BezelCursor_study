package bezelcursor.model;

@:keep
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
    	var obj:Dynamic = {};
		for (field in Type.getInstanceFields(Type.getClass(this))) {
			var value = Reflect.getProperty(this, field);
			if (Reflect.isFunction(value)) continue;
			Reflect.setField(obj, field, value);
		}
		return obj;
	}
}

class PointToObj {
	static public function toObj(pt:nme.geom.Point) {
		return pt == null ? null : {
			x:pt.x,
			y:pt.y
		}
	}
	
	static public function toPoint(obj:Dynamic) {
		return obj == null ? null : new nme.geom.Point(obj.x, obj.y);
	}
}

class RectangleToObj {
	static public function toObj(rect:nme.geom.Rectangle) {
		return rect == null ? null : {
			x:rect.x,
			y:rect.y,
			width:rect.width,
			height:rect.height
		}
	}
	
	static public function toRectangle(obj:Dynamic) {
		return obj == null ? null : new nme.geom.Rectangle(obj.x, obj.y, obj.width, obj.height);
	}
}