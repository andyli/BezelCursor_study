package bezelcursor.model;

using Lambda;
import nme.geom.Rectangle;
import nme.geom.Point;
using org.casalib.util.ArrayUtil;
using org.casalib.util.GeomUtil;
using org.casalib.util.NumberUtil;

import bezelcursor.model.DeviceData;
import bezelcursor.model.TouchData;
using bezelcursor.util.RectangleUtil;
using bezelcursor.util.UnitUtil;

class TaskBlockData implements IStruct {
	/**
	* uuid of length 36
	*/
	public var id(default,null):String;
	
	public var targets:Array<Dynamic>;
	public var targetQueue:Array<{target:Int, camera:{x:Float, y:Float}}>;
	
	public function new():Void {
		id = org.casalib.util.StringUtil.uuid();
		targets = [];
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
	#end
}