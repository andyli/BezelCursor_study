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
	
	public function new(c:PointActivatedCursor):Void {
		super(c);
		
		collapseVelocity = DeviceData.current.screenDPI * 0.005 * 30;
		expendVelocity = DeviceData.current.screenDPI * 0.035 * 30;
		collapseLag = 0.6;
		expendedSize = 0.15;
		collapsedSize = 0.0;
		
		expended = false;
		expendedTime = 0;
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
}