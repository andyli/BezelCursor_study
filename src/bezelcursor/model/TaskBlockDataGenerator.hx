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

class TaskBlockDataGenerator implements IStruct {
	#if !php
	static public var current(get_current, null):TaskBlockDataGenerator;
	static function get_current() {
		return current != null ? current : current = new TaskBlockDataGenerator(DeviceData.current);
	}
	#end
	
	public var deviceData(default, null):DeviceData;
	public function new(deviceData:DeviceData):Void {
		this.deviceData = deviceData;
		
		inputMethods = [
			InputMethod.DirectTouch,
			InputMethod.BezelCursor_acceleratedBubbleCursor,
			InputMethod.BezelCursor_acceleratedDynaSpot,
			InputMethod.BezelCursor_directMappingDynaSpot,
			InputMethod.MagStick,
			InputMethod.ThumbSpace,
		];
		
		timesPerRegion = 3;
	}
	
	function genRegions(width:Int, height:Int):Array<Rectangle> {		
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
	
	public function generateTaskBlocks():Array<TaskBlockData> {
		var taskBlockDatas = [];
		
		var numTargetsPerRegion = 1;
		
		for (regions in regionss)
		for (targetSeperation in targetSeperations)
		for (targetSize in targetSizes) 
		{
			taskBlockDatas.push(generateTaskBlock(
				targetSize,
				targetSeperation,
				regions,
				3
			));			
		}
		
		return taskBlockDatas; 
	}
	
	public var targetSizes(get_targetSizes, null):Array<{width:Float, height:Float, name:String}>;
	function get_targetSizes(){
		return targetSizes != null ? targetSizes : targetSizes = [
			{
				width:3.mm2inches() * deviceData.screenDPI, 
				height:3.mm2inches() * deviceData.screenDPI,
				name: "3mm * 3mm"
			}, 
			{
				width:9.6.mm2inches() * deviceData.screenDPI, 
				height:9.6.mm2inches() * deviceData.screenDPI,
				name: "9.6mm * 9.6mm"
			}
		];
	}
	
	public var targetSeperations(get_targetSeperations, null):Array<Float>;
	function get_targetSeperations() {
		return targetSeperations != null ? targetSeperations : targetSeperations = [
			2.mm2inches() * deviceData.screenDPI
		];
	}
	
	public var regionss(get_regionss, null):Array<Array<Rectangle>>;
	function get_regionss() {
		return regionss != null ? regionss : regionss = [
			genRegions(3, 4)
		];
	}
	
	public var inputMethods:Array<InputMethod>;
	
	public var timesPerRegion:Int;
	
	public var stageRect(get_stageRect, null):Rectangle;
	function get_stageRect() {
		return stageRect != null ? stageRect : stageRect = new Rectangle(0, 0, deviceData.screenResolutionX, deviceData.screenResolutionY);
	}
	
	public function generateTaskBlock(targetSize:{width:Float, height:Float}, targetSeperation:Float, regions:Array<Rectangle>, timesPerRegion:Int):TaskBlockData {
		var data = new TaskBlockData();

		var targetSizeRect = new Rectangle(0, 0, targetSize.width, targetSize.height);
		var numTargets = Math.round(Math.max((stageRect.width / (targetSize.width + targetSeperation)) * (stageRect.height / (targetSize.height + targetSeperation)) * 0.4, regions.length));
		
		var regionsMultiplied = [];
		for (tpr in 0...timesPerRegion) {
			regionsMultiplied = regionsMultiplied.concat(regions.randomize());
		}
		
		for (r in 0...regionsMultiplied.length) {
			var region = regionsMultiplied[r];
			
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
						return generateTaskBlock(targetSize, targetSeperation, regions, timesPerRegion);
					}
				} while (!(
					//target separation constraint
					rects.foreach(function(rect2)
						return rect.distanceRects(rect2) > targetSeperation
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
		}
		
		return data;
	}
}