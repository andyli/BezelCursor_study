package bezelcursor.cursor.behavior;

using org.casalib.util.NumberUtil;

import bezelcursor.model.DeviceInfo;

/**
* Scale the cursor area like a DynaSpot cursor.
*/
class DynaScale extends Behavior<PointActivatedCursor> {
	var expended:Bool;
	var expendedTime:Float;
	
	public var expendedSize:Float;
	public var collapsedSize:Float;
	public var expendVelocity:Float;
	public var collapseVelocity:Float;
	public var collapseLag:Float;
	
	public function new(c:PointActivatedCursor, ?config):Void {
		super(c, config);
		
		collapseVelocity = config != null && Reflect.hasField(config, "collapseVelocity") ? config.collapseVelocity : DeviceInfo.current.screenDPI * 0.015 * 30;
		expendVelocity = config != null && Reflect.hasField(config, "expendVelocity") ? config.expendVelocity : DeviceInfo.current.screenDPI * 0.035 * 30;
		collapseLag = config != null && Reflect.hasField(config, "collapseLag") ? config.collapseLag : 0.6;
		expendedSize = config != null && Reflect.hasField(config, "expendedSize") ? config.expendedSize : 0.15;
		collapsedSize = config != null && Reflect.hasField(config, "collapsedSize") ? config.collapsedSize : 0.0;
		
		expended = config != null && Reflect.hasField(config, "expended") ? config.expended : false;
		expendedTime = config != null && Reflect.hasField(config, "expendedTime") ? config.expendedTime : 0;
	}
	
	override function start():Void {
		super.start();
		expended = false;
		expendedTime = 0;
		cursor.radius = 0;
	}
	
	override function onFrame(timeInterval:Float):Void {
		super.onFrame(timeInterval);
		
		var l = cursor.touchVelocity.length;
				
		var curTime = haxe.Timer.stamp();
				
		if (l > collapseVelocity) {
			expendedTime = curTime;
		} else if (expended && (curTime - expendedTime > collapseLag)) {
			cursor.radius = collapsedSize;
			expended = false;
		}
				
		if (l > expendVelocity) {
			cursor.radius = expendedSize;
			expended = true;
		}
	}
	
	override public function getConfig():Dynamic {
		var config:Dynamic = super.getConfig();
		
		config.collapseVelocity = collapseVelocity;
		config.expendVelocity = expendVelocity;
		config.collapseLag = collapseLag;
		config.expendedSize = expendedSize;
		config.collapsedSize = collapsedSize;
		
		config.expended = expended;
		config.expendedTime = expendedTime;
		
		return config;
	}
	
	override public function setConfig(config:Dynamic):Void {
		super.setConfig(config);
		
		collapseVelocity = config.collapseVelocity;
		expendVelocity = config.expendVelocity;
		collapseLag = config.collapseLag;
		expendedSize = config.expendedSize;
		collapsedSize = config.collapsedSize;
		
		expended = config.expended;
		expendedTime = config.expendedTime;
	}
	
	override public function clone(?c:PointActivatedCursor):DynaScale {
		return new DynaScale(c == null ? cursor : c, getConfig());
	}
}