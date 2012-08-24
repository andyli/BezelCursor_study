package mobzor.cursor.behavior;

import nme.system.Capabilities;
using org.casalib.util.NumberUtil;

class DynaScale extends Behavior<PointActivatedCursor> {	
	var expended:Bool = false;
	var expendedTime:Float = 0;
	
	
	override function start():Void {
		super.start();
		cursor.targetSize = cursor.currentSize = 0;
	}
	
	override function onFrame():Void {
		super.onFrame();
		
		var l = cursor.touchVelocity.length;
				
		var curTime = Sys.cpuTime();
				
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