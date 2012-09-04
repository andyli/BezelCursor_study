package bezelcursor.cursor;

using Lambda;
import nme.events.Event;
import nme.events.TouchEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.model.DeviceInfo;

class MagStickCursor extends StickCursor {
	public function new(touchPointID:Int):Void {
		super(touchPointID);
		
		jointActivateDistance = Math.POSITIVE_INFINITY;
		scaleFactor = -1;
		startSize = targetSize = currentSize = 0.1;
		
		behaviors = [new ClickWhenTouchEnd(this)];
	}
	
	override function onFrame(evt:Event = null):Void {		
		super.onFrame(evt);
		
		view.graphics.clear();
		if (currentPoint != null) {
			view.graphics.lineStyle(2, 0xFF0000, 1);
			view.graphics.moveTo(currentTouchPoint.x, currentTouchPoint.y);
			view.graphics.lineTo(activatedPoint.x, activatedPoint.y);
			if (snapper.lastSnapTarget != null) {
				view.graphics.lineTo(snapper.lastSnapTarget.centerX, snapper.lastSnapTarget.centerY);
				view.graphics.drawCircle(snapper.lastSnapTarget.centerX, snapper.lastSnapTarget.centerY, 2);
			} else {
				view.graphics.lineTo(currentPoint.x, currentPoint.y);
				view.graphics.drawCircle(currentPoint.x, currentPoint.y, 2);
			}
		}
	}
}
