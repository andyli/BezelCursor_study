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
	
	public function new(c:PointActivatedCursor):Void {
		super(c);
		
		collapseVelocity = DeviceInfo.current.screenDPI * 0.015;
		expendVelocity = DeviceInfo.current.screenDPI * 0.035;
		collapseLag = 0.6;
		expendedSize = 0.15;
		collapsedSize = 0.0;
	}
	
	override function start():Void {
		super.start();
		expended = false;
		expendedTime = 0;
		cursor.radius = 0;
	}
	
	override function onFrame():Void {
		super.onFrame();
		
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
}