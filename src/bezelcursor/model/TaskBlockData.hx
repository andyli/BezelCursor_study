package bezelcursor.model;

using Lambda;
import nme.Lib;
import nme.geom.Rectangle;
import nme.geom.Point;
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

class TaskBlockData implements IStruct {
	/**
	* uuid of length 36
	*/
	public var id(default,null):String;
	
	public var targetSize:{width:Float, height:Float};
	public var targets:Array<Dynamic>;
	public var targetQueue:Array<{target:Int, camera:{x:Float, y:Float}}>;
	
	public function new():Void {
		id = org.casalib.util.StringUtil.uuid();
		targets = [];
		targetQueue = [];
	}
	

	public static var sharedObject(get_sharedObject, null):nme.net.SharedObject;
	static function get_sharedObject():nme.net.SharedObject {
		if (sharedObject != null) 
			return sharedObject;
		else
			return sharedObject = nme.net.SharedObject.getLocal("TaskBlockData");
	}
	
	static function genRegions(width:Int, height:Int):Array<Rectangle> {		
		var regions = [];
		for (x in 0...width) {
			for (y in 0...height) {
				var region = new Rectangle(
					x.map(0, width, 0, stageRect.width),
					y.map(0, height, 0, stageRect.height),
					stageRect.width / width,
					stageRect.height / height
				);
				regions.push(region);
			}
		}
		
		return regions;
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
		
		var numTargetsPerRegion = 1;
		
		for (regions in regionss)
		for (targetSeperation in targetSeperations)
		for (targetSize in targetSizes) 
		{
			taskBlockDatas.push(generateTaskBlock(
				targetSize,
				targetSeperation,
				regions
			));			
		}
		
		return taskBlockDatas; 
	}
	
	static public var targetSizes(get_targetSizes, null):Array<{width:Float, height:Float, name:String}>;
	static function get_targetSizes(){
		return targetSizes != null ? targetSizes : targetSizes = [
			{
				width:5.mm2inches() * DeviceData.current.screenDPI, 
				height:3.75.mm2inches() * DeviceData.current.screenDPI,
				name: "5mm * 3.75mm"
			}, 
			{
				width:9.6.mm2inches() * DeviceData.current.screenDPI, 
				height:9.6.mm2inches() * DeviceData.current.screenDPI,
				name: "9.6mm * 9.6mm"
			}
		];
	}
	
	static public var targetSeperations(get_targetSeperations, null):Array<Float>;
	static function get_targetSeperations() {
		return targetSeperations != null ? targetSeperations : targetSeperations = [
			2.mm2inches() * DeviceData.current.screenDPI
		];
	}
	
	static public var regionss(get_regionss, null):Array<Array<Rectangle>>;
	static function get_regionss() {
		return regionss != null ? regionss : regionss = [
			genRegions(3, 4)
		];
	}
	
	static public var stageRect(get_stageRect, null):Rectangle;
	static function get_stageRect() {
		return stageRect != null ? stageRect : stageRect = new Rectangle(0, 0, Lib.stage.stageWidth, Lib.stage.stageHeight - DeviceData.current.screenDPI * bezelcursor.entity.StartButton.HEIGHT);
	}
	
	static public function generateTaskBlock(targetSize:{width:Float, height:Float}, targetSeperation:Float, regions:Array<Rectangle>):TaskBlockData {
		var data = new TaskBlockData();

		var targetSizeRect = new Rectangle(0, 0, targetSize.width, targetSize.height);
		var numTargets = Math.round(Math.max((stageRect.width / (targetSize.width + targetSeperation)) * (stageRect.height / (targetSize.height + targetSeperation)) * 0.4, regions.length));
		
		var regions = regions.randomize();
		for (r in 0...regions.length) {
			var region = regions[r];
			
			var camera = new Point(r * stageRect.width, 0);
			
			var rects:Array<Rectangle> = [];
			
			var rect:Rectangle = GeomUtil.randomlyPlaceRectangle(region, targetSizeRect, false);
			rect.offsetPoint(camera);
			rects.push(rect);
			
			data.targetQueue.push({
				target: data.targets.length, 
				camera: {x:camera.x, y:camera.y}
			});
			
			
			for (i in 1...numTargets) {
		
				var itr = 0;
				var itrMax = 400;
				do {
					rect = GeomUtil.randomlyPlaceRectangle(stageRect, targetSizeRect, false);
					rect.offsetPoint(camera);
					
					if (itr++ > itrMax){
						return generateTaskBlock(targetSize, targetSeperation, regions);
					}
				} while (!(
					//target separation constraint
					rects.foreach(function(rect2)
						return HXP.distanceRects(
							rect.x, 
							rect.y,
							rect.width,
							rect.height,
							rect2.x,
							rect2.y,
							rect2.width,
							rect2.height
						) > targetSeperation
					)
				));
				//trace(i + "/" + numTargets);
				rects.push(rect);
			}
			
			data.targets = data.targets.concat(rects.map(function(rect) {
				return {
					x: rect.x,
					y: rect.y,
					width: rect.width,
					height: rect.height
				};
			}).array());
			
			data.targetSize = targetSize;
		}
		
		return data;
	}
}