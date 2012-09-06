package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.TouchData;

class Behavior<C:Cursor> {
	public var cursor(default, null):C;
	
	public function new(c:C, ?config:Dynamic):Void {
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
		s.serialize(getConfig());
    }
	
    function hxUnserialize(s:haxe.Unserializer) {
		setConfig(s.unserialize());
    }
	
	public function getConfig():Dynamic {
		var config:Dynamic = {};
		
		config._class = Type.getClassName(Type.getClass(this));
				
		return config;
	}
	
	public function setConfig(config:Dynamic):Void {
		#if debug
		if (config._class != Type.getClassName(Type.getClass(this)))
			throw "Should not set " + Type.getClassName(Type.getClass(this)) + "from a config of " + config._class;
		#end
	}
	
	public function clone(?c:C):Behavior<C> {
		return new Behavior<C>(c == null ? cursor : c, getConfig());
	}
	
	static public function createFromConfig<C:Cursor, B:Behavior<Dynamic>>(c:C, config:Dynamic):B {
		return Type.createInstance(Type.resolveClass(config._class), [c, config]);
	}
	
	static public function createFromConfigs<C:Cursor, B:Behavior<Dynamic>>(c:C, configs:Array<Dynamic>):Array<B> {
		var bs = [];
		for (config in configs) {
			bs.push(createFromConfig(c, config));
		}
		return bs;
	}
}