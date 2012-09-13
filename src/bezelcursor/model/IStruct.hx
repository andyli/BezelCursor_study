package bezelcursor.model;

@:keep
@:autoBuild(bezelcursor.model.StructBuilder.buildClass())
interface IStruct {
	//private function hxSerialize(s:haxe.Serializer):Void;
	//private function hxUnserialize(s:haxe.Unserializer):Void;
	public function init():IStruct;
	public function fromObj(obj:Dynamic):IStruct;
	public function toObj():Dynamic;
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