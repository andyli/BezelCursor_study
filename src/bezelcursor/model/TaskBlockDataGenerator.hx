package bezelcursor.model;

#if cpp
import cpp.vm.*;
#elseif neko
import neko.vm.*;
#end
using Lambda;
import nme.geom.*;
import nape.callbacks.*;
import nape.constraint.*;
import nape.geom.*;
import nape.phys.*;
import nape.shape.*;
import nape.space.*;
using org.casalib.util.ArrayUtil;
using org.casalib.util.GeomUtil;
using org.casalib.util.NumberUtil;

import bezelcursor.model.*;
using bezelcursor.util.RectangleUtil;
using bezelcursor.util.UnitUtil;

class TaskBlockDataGenerator implements IStruct {
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
	* Target sizes to be tested.
	* Name is merely a humam readable name.
	*/
	public var targetSizes(default, null):Array<{width:Float, height:Float, name:String}>;
	
	/**
	* Minimum distances between targets.
	*/
	public var targetSeperations(default, null):Array<Float>;
	
	/**
	* Regions within the screen. At least one target will be placed completely inside each region.
	*/
	public var regionss(default, null):Array<Array<Rectangle>>;
	
	/**
	* Input methods to be tested.
	*/
	public var inputMethods:Array<InputMethod>;
	
	/**
	* How many times should one region be tested.
	*/
	public var timesPerRegion:Int;
	
	/**
	* Rectangle that the size is set to match the device screen.
	*/
	public var stageRect(default, null):Rectangle;
	
	
	public function new(deviceData:DeviceData):Void {
		this.deviceData = deviceData;
		
		stageRect = new Rectangle(0, 0, deviceData.screenResolutionX, deviceData.screenResolutionY);
		
		inputMethods = [
			InputMethod.DirectTouch,
			InputMethod.BezelCursor_acceleratedBubbleCursor,
			InputMethod.BezelCursor_directMappingBubbleCursor,
			InputMethod.BezelCursor_acceleratedDynaSpot,
			InputMethod.BezelCursor_directMappingDynaSpot,
			InputMethod.MagStick,
			InputMethod.ThumbSpace,
		];
		
		targetSizes = [
			{
				width:9.6.mm2inches() * deviceData.screenDPI, 
				height:9.6.mm2inches() * deviceData.screenDPI,
				name: "9.6mm * 9.6mm"
			},
			{
				width:3.mm2inches() * deviceData.screenDPI, 
				height:3.mm2inches() * deviceData.screenDPI,
				name: "3mm * 3mm"
			}
		];
		
		targetSeperations = [
			1.mm2inches() * deviceData.screenDPI
		];
		
		regionss = [
			genRegions(3, 4)
		];
		
		timesPerRegion = 3;
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
	
	public function generateTaskBlocks(onComplete:Array<TaskBlockData>->Dynamic):Void {
		#if (cpp || neko)
		Thread.create(function():Void {
		#end
			var taskBlockDatas = [];
		
			var numTargetsPerRegion = 1;
			cpp.vm.Profiler.start("generateTaskBlocks");
			var i = 0;
			for (regions in regionss)
			for (targetSeperation in targetSeperations)
			for (targetSize in targetSizes) 
			{
				taskBlockDatas[i] = generateTaskBlock(
					targetSize,
					targetSeperation,
					regions,
					3
				);
				trace(i);
				++i;
			}

			onComplete(taskBlockDatas);
			cpp.vm.Profiler.stop();
		#if (cpp || neko)
		});
		#end
	}
	
	function generateTaskBlock(targetSize:{width:Float, height:Float}, targetSeperation:Float, regions:Array<Rectangle>, timesPerRegion:Int):TaskBlockData {
		var data = new TaskBlockData();
		
		var targetSizeWithSeperationRect = new Rectangle(0, 0, targetSize.width + targetSeperation, targetSize.height + targetSeperation);
		var numTargets = Math.round(Math.max((stageRect.width / (targetSize.width + targetSeperation)) * (stageRect.height / (targetSize.height + targetSeperation)) * 0.4, regions.length));
		
		var regionsMultiplied = [];
		for (tpr in 0...timesPerRegion) {
			regionsMultiplied = regionsMultiplied.concat(regions.randomize());
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
				
		for (r in 0...regionsMultiplied.length) {
			var region = regionsMultiplied[r];
			do {
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
				
				while (space.liveBodies.length > 0) {
					space.step(1/30);
				}
				
				//trace(space.bodies.length + " all slept");
			
			} while (space.bodies.exists(function(body) {
				for (arbiter in body.arbiters) {
					for (contact in arbiter.collisionArbiter.contacts) {
						if (contact.penetration > 1) return true;
					}
				}
				return false;
			}));
			
			data.targetQueue.push(bodys.map(function(body) {
				return {
					x: body.position.x - targetSize.width * 0.5,
					y: body.position.y - targetSize.height * 0.5,
					width: targetSize.width,
					height: targetSize.height
				};
			}).array());
			
			trace(r);
		}
		
		return data;
	}
}