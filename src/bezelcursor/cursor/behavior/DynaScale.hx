package bezelcursor.cursor.behavior;

using org.casalib.util.NumberUtil;

import bezelcursor.model.DeviceData;

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
	
	public function new(c:PointActivatedCursor, ?data):Void {
		super(c, data);
		
		collapseVelocity = data != null && Reflect.hasField(data, "collapseVelocity") ? data.collapseVelocity : DeviceData.current.screenDPI * 0.005 * 30;
		expendVelocity = data != null && Reflect.hasField(data, "expendVelocity") ? data.expendVelocity : DeviceData.current.screenDPI * 0.035 * 30;
		collapseLag = data != null && Reflect.hasField(data, "collapseLag") ? data.collapseLag : 0.6;
		expendedSize = data != null && Reflect.hasField(data, "expendedSize") ? data.expendedSize : 0.15;
		collapsedSize = data != null && Reflect.hasField(data, "collapsedSize") ? data.collapsedSize : 0.0;
		
		expended = data != null && Reflect.hasField(data, "expended") ? data.expended : false;
		expendedTime = data != null && Reflect.hasField(data, "expendedTime") ? data.expendedTime : 0;
	}
	
	override function start():Void {
		super.start();
		if (expended = true) {
			expendedTime = haxe.Timer.stamp();
			cursor.radius = expendedSize;
		} else {
			expendedTime = 0;
			cursor.radius = collapsedSize;
		}
	}
	
	override function onFrame(timestamp:Float):Void {
		super.onFrame(timestamp);
		
		var l = cursor.touchVelocity.length;
				
		if (l > collapseVelocity) {
			expendedTime = timestamp;
		} else if (expended && (timestamp - expendedTime > collapseLag)) {
			cursor.radius = collapsedSize;
			expended = false;
		}
				
		if (l > expendVelocity) {
			cursor.radius = expendedSize;
			expended = true;
		}
	}
	
	override public function getData():Dynamic {
		var data:Dynamic = super.getData();
		
		data.collapseVelocity = collapseVelocity;
		data.expendVelocity = expendVelocity;
		data.collapseLag = collapseLag;
		data.expendedSize = expendedSize;
		data.collapsedSize = collapsedSize;
		
		data.expended = expended;
		data.expendedTime = expendedTime;
		
		return data;
	}
	
	override public function setData(data:Dynamic):Void {
		super.setData(data);
		
		collapseVelocity = data.collapseVelocity;
		expendVelocity = data.expendVelocity;
		collapseLag = data.collapseLag;
		expendedSize = data.expendedSize;
		collapsedSize = data.collapsedSize;
		
		expended = data.expended;
		expendedTime = data.expendedTime;
	}
	
	override public function clone(?c:PointActivatedCursor):DynaScale {
		return new DynaScale(c == null ? cursor : c, getData());
	}
}