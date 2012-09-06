package bezelcursor.cursor.snapper;

import bezelcursor.cursor.Cursor;
import bezelcursor.entity.Target;

class Snapper<C:Cursor> {
	public var cursor(default, null):C;
	
	/**
	* The Target for a cursor. null if none is suitable.
	*/
	public var target(get_target, null):Null<Target>;
	function get_target():Null<Target> {
		return interestedTargets.length > 0 ? interestedTargets[0] : null;
	}
	
	/**
	* The interested targets(usually based on distance to the cursor).
	* Sorted as the most suitable ones come first.
	*/
	public var interestedTargets(default, null):Array<Target>;
	
	public function new(c:C, ?data:Dynamic):Void {
		cursor = c;
		target = null;
		interestedTargets = [];
	}
	
	public function run():Void {
		interestedTargets = [];
	}

    function hxSerialize(s:haxe.Serializer) {
		s.serialize(getData());
    }
	
    function hxUnserialize(s:haxe.Unserializer) {
		setData(s.unserialize());
    }
	
	public function getData():Dynamic {
		var data:Dynamic = {};
		
		data._class = Type.getClassName(Type.getClass(this));
				
		return data;
	}
	
	public function setData(data:Dynamic):Void {
		#if debug
		if (data._class != Type.getClassName(Type.getClass(this)))
			throw "Should not set " + Type.getClassName(Type.getClass(this)) + "from a data of " + data._class;
		#end
	}
	
	public function clone(?c:C):Snapper<C> {
		return new Snapper<C>(c == null ? cursor : c, getData());
	}
	
	static public function createFromData<C:Cursor, S:Snapper<Dynamic>>(c:C, data:Dynamic):S {
		return Type.createInstance(Type.resolveClass(data._class), [c, data]);
	}
}