package bezelcursor.model;

using Lambda;
import nme.Lib;
import nme.geom.Rectangle;
using org.casalib.util.GeomUtil;
using org.casalib.util.NumberUtil;
import com.haxepunk.HXP;

import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.CursorManager;
import bezelcursor.cursor.behavior.DrawBubble;
import bezelcursor.model.DeviceData;
import bezelcursor.model.TouchData;
using bezelcursor.util.UnitUtil;

typedef InputMethod = {
	name:String,
	createCursor: TouchData->CreateCursorFor->Cursor
}

class InputMethods {
	static public var BezelCursor_acceleratedDynaSpot = {
		name: "BezelCursor - accelerated DynaSpot",
		createCursor: function(touch:TouchData, _for:CreateCursorFor):Cursor {
			switch(_for) {
				case ForBezel: 
					return new bezelcursor.cursor.MouseCursor({touchPointID: touch.touchPointID});
				default:
					return null;
			}
		}
	}
	
	static public var BezelCursor_directMappingDynaSpot = {
		name: "BezelCursor - direct mapping DynaSpot",
		createCursor: function(touch:TouchData, _for:CreateCursorFor):Cursor {
			switch(_for) {
				case ForBezel: 
					return new bezelcursor.cursor.StickCursor({touchPointID: touch.touchPointID});
				default:
					return null;
			}
		}
	}
	
	static public var BezelCursor_acceleratedBubbleCursor = {
		name: "Bezelcursor - accelerated BubbleCursor",
		createCursor: function(touch:TouchData, _for:CreateCursorFor):Cursor {
			switch(_for) {
				case ForBezel: 
					return new bezelcursor.cursor.BubbleMouseCursor({touchPointID: touch.touchPointID});
				default:
					return null;
			}
		}
	}
	
	static public var MagStick = {
		name: "MagStick",
		createCursor: function(touch:TouchData, _for:CreateCursorFor):Cursor {
			switch(_for) {
				case ForScreen: 
					return new bezelcursor.cursor.MagStickCursor({touchPointID: touch.touchPointID});
				default:
					return null;
			}
		}
	}
	
	static public var ThumbSpace = {
		name: "ThumbSpace",
		createCursor: function(touch:TouchData, _for:CreateCursorFor):Cursor {
			switch(_for) {
				case ForThumbSpace: 
					var c = new bezelcursor.cursor.BubbleMouseCursor({touchPointID: touch.touchPointID});
					c.behaviors.remove(c.behaviors.filter(function(b) return Std.is(b, DrawBubble)).first());
					return c;
				default:
					return null;
			}
		}
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
	static public function generateTaskBlocks():Array<TaskBlockData> {
		//Division of regions
		var width = 3;
		var height = 4;
		
		var numTargetsPerRegion = 1;
		
		var targetWidth = DeviceData.current.screenDPI * 0.2;
		var targetHeight = DeviceData.current.screenDPI * 0.15;
		
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
		
		var stageRect = new Rectangle(0, 0, Lib.stage.stageWidth, Lib.stage.stageHeight);
		
		var rects:Array<Rectangle>;
		var rect:Rectangle;
		do {
			rects = [];
			for (region in regions) {
				for (i in 0...numTargetsPerRegion) {
					do {
						var pt = GeomUtil.randomlyPlacePoint(region, false);
						rect = new Rectangle(pt.x, pt.y);
						rect.inflate(targetWidth * 0.5, targetHeight * 0.5);
					} while (!stageRect.containsRect(rect)); //should inside the screen
					rects.push(rect);
				}
			}
		} while ( //target separation constraint should be satisfied
			rects.exists(function(rect) return 
				rects.exists(function(rect2)
					return rect != rect2 && HXP.distanceRects(
						rect.x, 
						rect.y,
						rect.width,
						rect.height,
						rect2.x,
						rect2.y,
						rect2.width,
						rect2.height
					) < DeviceData.current.screenDPI * (10).mm2inches()
				)
			)
		);
		
		var data = new TaskBlockData();
		data.targets = cast rects.map(function(rect) {
			return {
				x:rect.x,
				y:rect.y,
				width:rect.width,
				height:rect.height
			}
		}).array();
		
		return [data]; 
	}
}