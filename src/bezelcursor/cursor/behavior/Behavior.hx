package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.TouchData;

class Behavior<C:Cursor> {
	public var cursor(default, null):C;
	
	public function new(c:C, ?data:Dynamic):Void {
		cursor = c;
	}
	
	public function start():Void {
		
	}
	
	public function end():Void {
		
	}
	
	public function onFrame(timeInterval:Float):Void {		
		
	}
	
	public function onTouchBegin(touch:TouchData):Void {
		
	}
	
	public function onTouchMove(touch:TouchData):Void {
		
	}
	
	public function onTouchEnd(touch:TouchData):Void {
		
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
	
	public function clone(?c:C):Behavior<C> {
		return new Behavior<C>(c == null ? cursor : c, getData());
	}
	
	static public function createFromData<C:Cursor, B:Behavior<Dynamic>>(c:C, data:Dynamic):B {
		return Type.createInstance(Type.resolveClass(data._class), [c, data]);
	}
	
	static public function createFromDatas<C:Cursor, B:Behavior<Dynamic>>(c:C, datas:Array<Dynamic>):Array<B> {
		var bs = [];
		for (data in datas) {
			bs.push(createFromData(c, data));
		}
		return bs;
	}
}