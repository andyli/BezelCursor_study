package mobzor.cursor.behavior;

import nme.system.Capabilities;
using org.casalib.util.NumberUtil;

/**
* Scale the cursor area like a DynaSpot cursor.
*/
class DynaScale extends Behavior<PointActivatedCursor> {
	var expended:Bool;
	var expendedTime:Float;
	
	override function start():Void {
		super.start();
		expended = false;
		expendedTime = 0;
		cursor.targetSize = cursor.currentSize = 0;
	}
	
	override function onFrame():Void {
		super.onFrame();
		
		var l = cursor.touchVelocity.length;
				
		var curTime = haxe.Timer.stamp();
				
		if (l > Capabilities.screenDPI * 0.02) {
			expendedTime = curTime;
		} else if (expended && (curTime - expendedTime > 0.4)) {
			cursor.targetSize = 0.01;
			expended = false;
		}
				
		if (l > Capabilities.screenDPI * 0.035) {
			cursor.targetSize = 0.15;
			expended = true;
		}
		
		cursor.currentSize += (cursor.targetSize - cursor.currentSize) * cursor.stage.frameRate.map(0, 30, 1, 0.3);
	}
}