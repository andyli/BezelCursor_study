package bezelcursor.model;

using Lambda;
import nme.geom.*;
using org.casalib.util.ArrayUtil;
using org.casalib.util.GeomUtil;
using org.casalib.util.NumberUtil;

import bezelcursor.model.*;
using bezelcursor.util.RectangleUtil;
using bezelcursor.util.UnitUtil;

class TaskBlockData implements IStruct {
	/**
	* uuid of length 36
	*/
	public var id(default,null):String;
	
	public var targetQueue:Array<Array<Dynamic>>;
	
	public function new():Void {
		id = org.casalib.util.StringUtil.uuid();
		targetQueue = [];
	}
	
	#if !php
	public static var sharedObject(get_sharedObject, null):nme.net.SharedObject;
	static function get_sharedObject():nme.net.SharedObject {
		if (sharedObject != null) 
			return sharedObject;
		else
			return sharedObject = nme.net.SharedObject.getLocal("TaskBlockData");
	}
	
	public static var current(get_current, set_current):Array<TaskBlockData>;
	static function get_current():Array<TaskBlockData> {
		if (current != null) return current;
		if (sharedObject.data.current == null) return null;
		
		return current = cast(sharedObject.data.current,Array<Dynamic>).map(function(o) return new TaskBlockData().fromObj(o)).array();
	}
	static function set_current(v:Array<TaskBlockData>):Array<TaskBlockData> {
		sharedObject.data.current = v.map(function(tbd) return tbd.toObj()).array();
		sharedObject.flush();
		return current = v;
	}
	#end
}