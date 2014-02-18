package bezelcursor.model;

using Lambda;
import flash.geom.*;
using org.casalib.util.ArrayUtil;
using org.casalib.util.GeomUtil;
using org.casalib.util.NumberUtil;

using bezelcursor.util.RectangleUtil;
using bezelcursor.util.UnitUtil;

@:allow(bezelcursor.model.TaskBlockDataGenerator)
class TaskBlockData implements IStruct {
	/**
	* uuid of length 36
	*/
	public var id(default, null):String;

	public var version(default, null):Int = 1;
	
	public var targetQueue:Array<LevelData>;
	
	public var config:Dynamic;
	
	public function new():Void {
		id = org.casalib.util.StringUtil.uuid();
		targetQueue = [];
	}
	
	#if !php
	public static var sharedObject(get_sharedObject, null):flash.net.SharedObject;
	static function get_sharedObject():flash.net.SharedObject {
		if (sharedObject != null) 
			return sharedObject;
		else
			return sharedObject = flash.net.SharedObject.getLocal("TaskBlockData");
	}
	
	@:isVar public static var current(get_current, set_current):Array<TaskBlockData>;
	static function get_current():Array<TaskBlockData> {
		if (current != null) return current;
		if (sharedObject.data.current == null) return null;
		
		return current = haxe.Unserializer.run(sharedObject.data.current);
	}
	static function set_current(v:Array<TaskBlockData>):Array<TaskBlockData> {
		sharedObject.data.current = haxe.Serializer.run(v);
		sharedObject.flush();
		return current = v;
	}
	#end
}