package bezelcursor.model;

using Lambda;
import nme.Lib;
import nme.geom.Rectangle;
import nme.geom.Matrix3D;
using org.casalib.util.ArrayUtil;
using org.casalib.util.GeomUtil;
using org.casalib.util.NumberUtil;
import com.haxepunk.HXP;

import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.CursorManager;
import bezelcursor.cursor.behavior.DrawBubble;
import bezelcursor.entity.Target;
import bezelcursor.model.DeviceData;
import bezelcursor.model.TouchData;
using bezelcursor.util.RectangleUtil;
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
	public var targetQueue:Array<{target:Int, globalTransform:Matrix3D}>;
	
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
	*  1. small - 5mm * 3.75mm
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
		var taskBlockDatas = [];
		
		var dpi = DeviceData.current.screenDPI;
		
		//Division of regions
		var width = 3;
		var height = 4;
		
		var numTargetsPerRegion = 1;
		var targetSeperation = 5.mm2inches() * dpi;
		
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
		
		for (targetSize in [
			{width:5.mm2inches() * dpi, height:3.75.mm2inches() * dpi}, 
			//{width:12.8.mm2inches() * dpi, height:9.6.mm2inches() * dpi}
		]) {
			taskBlockDatas.push(generateTaskBlock(
				targetSize,
				targetSeperation,
				regions,
				stageRect
			));			
		}
		
		return taskBlockDatas; 
	}
	
	static function generateTaskBlock(targetSize:{width:Float, height:Float}, targetSeperation:Float, regions:Array<Rectangle>, stageRect:Rectangle):TaskBlockData {
		var numTargets = 2000;
		var numTargetsSqrt = Math.round(Math.sqrt(numTargets));
		var globalWorldRect = new Rectangle(0, 0, (targetSize.width + targetSeperation * 2) * numTargetsSqrt * 1.1, (targetSize.height + targetSeperation * 2) * numTargetsSqrt * 1.1);
			
		var rects:Array<Rectangle> = [];
		for (i in 0...numTargets) {
			var rect:Rectangle;
			do {
				rect = GeomUtil.randomlyPlaceRectangle(globalWorldRect, new Rectangle(0, 0, targetSize.width, targetSize.height), false);
			} while (!(
				//inside the globalWorldRect
				(globalWorldRect.containsRect(rect))// || {trace(179);false;})
					&&
				//target separation constraint
				(!rects.exists(function(rect2)
					return HXP.distanceRects(
						rect.x, 
						rect.y,
						rect.width,
						rect.height,
						rect2.x,
						rect2.y,
						rect2.width,
						rect2.height
					) < targetSeperation
				))// || {trace(193);false;})
			));
			trace(i);
			rects.push(rect);
		}
			
		var iter = 0;
		var iterMax = 500;
			
		var specs = new Array<{target:Int, globalTransform:Matrix3D}>();
		var focusRects = [];
		var tranforms = [];
		for (region in regions) {
			var transform:Matrix3D;
			var focusRect:Rectangle;
			var focusTargets:List<Rectangle>;
			do {
				focusRect = GeomUtil.randomlyPlaceRectangle(globalWorldRect, stageRect, false);
				transform = new Matrix3D();
				transform.appendTranslation(-focusRect.x, -focusRect.y, 0);
				focusTargets = rects.filter(function(rect) return rect.intersects(focusRect));
				if (iter++ > iterMax) {
					return generateTaskBlock(
						targetSize,
						targetSeperation,
						regions,
						stageRect
					);
				}
			} while(!(
				//at least one target is inside the region
				(focusTargets.exists(function(rect) return region.containsRect(rect.transform3D(transform))) || {trace(214);false;})
					&&
				//no target is not completely inside the screen bound
				//(!focusTargets.exists(function(rect) return !focusRect.containsRect(rect)) || {trace(217);false;})
				//	&&
				//no focusRects are intersecting
				(!focusRects.exists(function(focusRect2)
					return focusRect.intersects(focusRect2)
				) || {trace(222);false;})
					&&
				//no queued target is inside the region
				(!specs.exists(function(spec) return region.intersects(rects[spec.target])) || {trace(225);false;})
			));
				
			focusRects.push(focusRect);
			specs.push({
				target: rects.indexOf(focusTargets.filter(function(rect) return region.containsRect(rect.transform3D(transform))).array().random()), 
				globalTransform: transform
			});
		}
				
		trace(iter);
				
		var data = new TaskBlockData();
		data.targets = rects.map(function(rect) {
			return new TargetData(
				rect.x,
				rect.y,
				rect.width,
				rect.height
			);
		}).array();
		data.targetQueue = specs;
			
		return data;
	}
}