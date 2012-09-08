package bezelcursor.model;

import nme.Lib;
import nme.geom.Rectangle;
using org.casalib.util.GeomUtil;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.CursorManager;
import bezelcursor.model.TouchData;

typedef InputMethod = {
	name:String,
	createCursor: TouchData->CreateCursorFor->Cursor
}

class InputMethods {
	static public var BezelCursor_acceleratedDynaSpot = {
		name: "",
		
	}
}

class TaskBlockData extends Struct {
	/**
	* uuid of length 36
	*/
	public var id(default,null):String;
	
	public var targets:Array<TargetData>;
	
	public function new():Void {
		id = org.casalib.util.StringUtil.uuid();
	}
	

	public static var sharedObject(get_sharedObject, null):nme.net.SharedObject;
	static function get_sharedObject():nme.net.SharedObject {
		if (sharedObject != null) 
			return sharedObject;
		else
			return sharedObject = nme.net.SharedObject.getLocal("TaskBlockData");
	}
	
	/**
	* Inputs:
	*  1. BezelCursor - accelerated DynaSpot
	*  2. BezelCursor - direct mapping DynaSpot
	*  3. Bezelcursor - accelerated BubbleCursor
	*  4. MagStick
	*  5. ThumbSpace
	*  6? BezelCursor - Radar
	* 
	* Target size:
	*  1. small - 0.2 * 0.15 inches
	*  2. 12.8mm * 9.6mm (Target size study for one-handed thumb use on small touchscreen devices)
	*  
	* Target separation:
	*  1. separation > 10 mm
	* 
	* Regions:
	*  1. 3 * 4
	*  
	* Number of targets per region:
	*  1. 3
	*  
	* Number of times for each target to be selected:
	*  1. 1
	*/
	static function generateTaskBlocks():Array<TaskBlockData> {
		//Division of regions
		var width = 3;
		var height = 4;
		
		var input;
		
		var regions = [];
		for (x in 0...width) {
			for (y in 0...height) {
				var region = new Rectangle(
					x.map(0, width, 0, Lib.stage.stageWidth),
					y.map(0, height, 0, Lib.stage.stageHeight),
					Lib.stage.stageWidth / width,
					Lib.stage.stageHeight / height
				);
				
				regions.push(region);
			}
		}
		
		var pts = [];
		for (region in regions) {
			var pt = GeomUtil.randomlyPlacePoint(region, false);
			pts.push(pt);
		}
	}
}