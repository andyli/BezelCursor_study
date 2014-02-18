package bezelcursor.model;

#if cpp
import cpp.vm.*;
#elseif neko
import neko.vm.*;
#end
using Std;
using Lambda;
import haxe.*;
import sys.io.*;
import flash.geom.*;
import nape.callbacks.*;
import nape.constraint.*;
import nape.geom.*;
import nape.phys.*;
import nape.shape.*;
import nape.space.*;
import hsl.haxe.*;
using org.casalib.util.ArrayUtil;
using org.casalib.util.GeomUtil;
using org.casalib.util.NumberUtil;

import bezelcursor.model.*;
import bezelcursor.util.*;
using bezelcursor.util.RectangleUtil;
using bezelcursor.util.UnitUtil;

class TaskBlockDataGenerator implements IStruct {
	static public var version(default, never):Int = 2;
	static function main():Void {
		var args = Sys.args();
		var deviceDataFile = args[0];
		
		var deviceData = if (deviceDataFile == null)
			DeviceData.current;
		else {
			new DeviceData().fromObj(haxe.Json.parse(File.getContent(deviceDataFile)));
		}
		trace(deviceData);
		var gen = new TaskBlockDataGenerator(deviceData);

		function onError(details:String):Void {
			trace("Error: " + details);
			Sys.exit(1);
		}

		function onTaskBlockGenerated(taskblocks:Array<TaskBlockData>){
			trace("Sync with server...");
			
			// haxe.Timer.delay(function(){
			// 	TaskBlockData.current = taskblocks;
			// 	ready();
			// }, 100);
			
			// return;

			var fileURL = "TaskBlockData.txt";
			File.saveContent(fileURL, Serializer.run(taskblocks));
			
			var load = new AsyncLoader(Env.website + "taskblockdata/set/", Post);
			load.data = {
				buildData: Serializer.run(BuildData.current),
				deviceData: Serializer.run(deviceData),
				taskblocks: Serializer.run(taskblocks)
			}
			load.onCompleteSignaler.bind(function(respond){
				if (respond != "ok") {
					onError(respond);
				} else {
					haxe.Timer.delay(function(){
						trace("Done");
						Sys.exit(0);
					}, 100);
				} 
			}).destroyOnUse();
			load.onErrorSignaler.bind(onError).destroyOnUse();
			load.load();
		}

		var done = false;
		var pbond = gen.onProgressSignaler.bind(function(p) {
			trace("Generating tasks...\n" + p.map(0, 1, 0, 100).int() + "%");
		});
		gen.onCompleteSignaler.bind(function(a) {
			onTaskBlockGenerated(a);
			pbond.destroy();
		}).destroyOnUse();
		gen.generateTaskBlocks();
		while(!done) {
			Sys.sleep(1);
		}
	}

	#if !php
	static public var current(get_current, null):TaskBlockDataGenerator;
	static function get_current() {
		return current != null ? current : current = new TaskBlockDataGenerator(DeviceData.current);
	}
	#end
	
	/**
	* It provide the device specific data to the generator, specifically screen resolution and dpi.
	*/
	public var deviceData(default, null):DeviceData;
	
	/**
	* Target sizes(mm) to be tested.
	* Name is merely a humam readable name.
	*/
	public var targetSizes(default, null):Array<{width:Float, height:Float, name:String}> = [
		{
			width:9.6, 
			height:9.6,
			name: "9.6mm * 9.6mm"
		},
		{
			width:3, 
			height:3,
			name: "3mm * 3mm"
		}
	];
	
	/**
	* Minimum distances(mm) between targets.
	*/
	public var targetSeperations(default, null):Array<Float> = [
		1
	];
	
	/**
	* Regions within the screen. At least one target will be placed completely inside each region.
	* Unit is mm.
	*/
	public var regionss(default, null):Array<Array<Rectangle>>;

	public var worldRegions(default, null) = [0, 1, 2];
	
	/**
	* Input methods to be tested.
	*/
	public var inputMethods:Array<InputMethod> = [
		InputMethod.DirectTouch,
		InputMethod.PracticalBezelCursor,
		InputMethod.PracticalButtonCursor,
		InputMethod.MagStick,
		InputMethod.ThumbSpace,
	];
	
	/**
	* How many times should one region be tested.
	*/
	public var timesPerRegion:Int = 1;
	
	/**
	* Rectangle that the size is set to match the device screen.
	* Unit is mm.
	*/
	public var stageRect(default, null):Rectangle;
	
	/**
	* Density of targets. Range: 0-1.
	*/
	public var targetDensity(default, null):Float = 0.5;
	
	/**
	* Number of red targets have been generated.
	*/
	public var generatedRedTargets(default, null):Int;
	
	/**
	* Compute the total number of red targets based on the current setting.
	*/
	public function getTotalRedTargets():Int {
		return regionss.length * targetSeperations.length * targetSizes.length * regionss[0].length * timesPerRegion * worldRegions.length;
	}

	@skip public var onProgressSignaler(default, null):Signaler<Float>;
	@skip public var onCompleteSignaler(default, null):Signaler<Array<TaskBlockData>>;
	
	public function new(deviceData:DeviceData):Void {
		this.deviceData = deviceData;
		
		var dpi = deviceData.screenDPI;
		
		stageRect = new Rectangle(0, 0, (deviceData.screenResolutionX / dpi).inches2mm(), (deviceData.screenResolutionY / dpi).inches2mm());
		
		regionss = [
			genRegions(3, 4)
		];
		
		onProgressSignaler = new DirectSignaler<Float>(this);
		onCompleteSignaler = new DirectSignaler<Array<TaskBlockData>>(this);
	}
	
	/**
	* Generates regions in the form of grid.
	*/
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
	
	public function generateTaskBlocks():Void {
		generatedRedTargets = 0;
		
		#if (cpp || neko)
		Thread.create(function():Void {
		#end
			var taskBlockDatas = [];
			
			for (regions in regionss)
			for (targetSeperation in targetSeperations)
			for (targetSize in targetSizes) 
			{	
				//trace('regions: $regions, targetSeperation: $targetSeperation, targetSize: $targetSize');
				taskBlockDatas.push(generateTaskBlock(
					targetSize,
					targetSeperation,
					regions,
					timesPerRegion
				));
			}
			
			onCompleteSignaler.dispatch(taskBlockDatas);
		#if (cpp || neko)
		});
		#end
	}
	
	function generateTaskBlock(targetSize:{width:Float, height:Float}, targetSeperation:Float, regions:Array<Rectangle>, timesPerRegion:Int):TaskBlockData {
		var data = new TaskBlockData();
		data.version = version;
		data.config = {
			targetSize: targetSize,
			targetSeperation: targetSeperation,
			regions: regions,
			timesPerRegion: timesPerRegion
		};
		
		var targetSizeWithSeperationRect = new Rectangle(0, 0, targetSize.width + targetSeperation, targetSize.height + targetSeperation);
		var numTargets = Math.round(Math.max((stageRect.width / (targetSize.width + targetSeperation)) * (stageRect.height / (targetSize.height + targetSeperation)) * targetDensity, regions.length));
		
		var regionsMultiplied = [];
		for (tpr in 0...timesPerRegion) {
			regionsMultiplied = regionsMultiplied.concat(regions);
		}
		
		var space = new Space(Broadphase.SWEEP_AND_PRUNE);
		space.worldLinearDrag = 0;
		
		var wallWidth = 50;
		
		//up
		var body = new Body(BodyType.STATIC);
		body.shapes.add(new Polygon(Polygon.rect(-wallWidth, -wallWidth, stageRect.width + wallWidth*2, wallWidth)));
		body.space = space;
		//left
		var body = new Body(BodyType.STATIC);
		body.shapes.add(new Polygon(Polygon.rect(-wallWidth, -wallWidth, wallWidth, stageRect.height + wallWidth*2)));
		body.space = space;
		//right
		var body = new Body(BodyType.STATIC);
		body.shapes.add(new Polygon(Polygon.rect(stageRect.width, -wallWidth, wallWidth, stageRect.height + wallWidth*2)));
		body.space = space;
		//bottom
		var body = new Body(BodyType.STATIC);
		body.shapes.add(new Polygon(Polygon.rect(-wallWidth, stageRect.height, stageRect.width + wallWidth*2, wallWidth)));
		body.space = space;
		
		
		var circleShape = new Circle(Math.max(targetSize.width + targetSeperation*0.5, targetSize.height + targetSeperation*0.5)*0.5);
		circleShape.material.dynamicFriction = 0;
		circleShape.material.staticFriction = 0;
		circleShape.material.rollingFriction = 0;
		var rectShape = new Polygon(Polygon.box(targetSize.width + targetSeperation, targetSize.height + targetSeperation));
		rectShape.material.dynamicFriction = 0;
		rectShape.material.staticFriction = 0;
		rectShape.material.rollingFriction = 0;
		
		var bodys = [];
		
		var redbody = new Body(BodyType.STATIC);
		redbody.shapes.add(circleShape);
		redbody.shapes.add(rectShape);
		redbody.allowRotation = false;
		redbody.align();
		bodys.push(redbody);
		
		for (i in 1...numTargets) {
			var circleShape = new Circle(Math.max(targetSize.width + targetSeperation*0.5, targetSize.height + targetSeperation*0.5)*0.5);
			circleShape.material.dynamicFriction = 0;
			circleShape.material.staticFriction = 0;
			circleShape.material.rollingFriction = 0;
			var rectShape = new Polygon(Polygon.box(targetSize.width + targetSeperation, targetSize.height + targetSeperation));
			rectShape.material.dynamicFriction = 0;
			rectShape.material.staticFriction = 0;
			rectShape.material.rollingFriction = 0;

			var body = new Body();
			body.shapes.add(circleShape);
			body.shapes.add(rectShape);
			body.allowRotation = false;
			body.align();
			body.space = space;
			bodys.push(body);
		}
		
		for (regionI in worldRegions)
		for (r in 0...regionsMultiplied.length) {
			var region = regionsMultiplied[r];
			var i;
			do {
				Sys.println("");
				var rect = GeomUtil.randomlyPlaceRectangle(
					region, 
					targetSizeWithSeperationRect, 
					false
				);
		
				//red target
				space.bodies.remove(redbody);
				redbody.space = null;				
				redbody.position.x = rect.x + targetSize.width * 0.5;
				redbody.position.y = rect.y + targetSize.height * 0.5;
				redbody.space = space;
		
			
				for (body in bodys) {
					if (body.isStatic()) continue;
				
					var rect = GeomUtil.randomlyPlaceRectangle(
						stageRect, 
						targetSizeWithSeperationRect, 
						false
					);
					body.position.x = rect.x + targetSize.width * 0.5;
					body.position.y = rect.y + targetSize.height * 0.5;
				}
				
				i = 500;
				while (space.liveBodies.length > 0 && i-->0) {
					space.step(1/30);
				}

				if (i <= 0)
					Sys.print(".");
			
			} while (i <= 0 || space.bodies.exists(function(body) {
				for (arbiter in body.arbiters) {
					for (contact in arbiter.collisionArbiter.contacts) {
						if (contact.penetration > 0.5) {
							Sys.print(",");
							return true;
						}
					}
				}
				return false;
			}));
			
			var level = new LevelData(regionI);
			level.targets = bodys.map(function(body) {
				return {
					x: body.position.x - targetSize.width * 0.5,
					y: body.position.y - targetSize.height * 0.5,
					width: targetSize.width,
					height: targetSize.height
				};
			});
			data.targetQueue.push(level);
			
			++generatedRedTargets;
			onProgressSignaler.dispatch(generatedRedTargets/getTotalRedTargets());
		}
		
		return data;
	}
}