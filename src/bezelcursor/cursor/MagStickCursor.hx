package bezelcursor.cursor;

using Lambda;
import nme.events.Event;
import nme.events.TouchEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.snapper.DistanceToOriginSnapper;
import bezelcursor.model.DeviceInfo;

class MagStickCursor extends StickCursor {
	public function new(touchPointID:Int):Void {
		super(touchPointID);
		
		jointActivateDistance = Math.POSITIVE_INFINITY;
		scaleFactor = -1;
		current_radius = target_radius = default_radius = 0.1;
		
		behaviors = [new ClickWhenTouchEnd(this)];
		snapper = new DistanceToOriginSnapper(this);
	}
	
	override function onFrame(evt:Event = null):Void {		
		super.onFrame(evt);
		
		view.graphics.clear();
		if (position != null) {
			view.graphics.lineStyle(2, 0xFF0000, 1);
			view.graphics.moveTo(currentTouchPoint.x, currentTouchPoint.y);
			view.graphics.lineTo(activatedPoint.x, activatedPoint.y);
			if (snapper.lastSnapTarget != null) {
				var tpt = new Point(snapper.lastSnapTarget.centerX, snapper.lastSnapTarget.centerY);
				var v = tpt.subtract(activatedPoint);
				v.normalize(currentTouchPoint.subtract(activatedPoint).length);
				tpt = activatedPoint.add(v);
				view.graphics.lineTo(tpt.x, tpt.y);
				view.graphics.drawCircle(tpt.x, tpt.y, DeviceInfo.current.screenDPI * radius);
			} else {
				view.graphics.lineTo(position.x, position.y);
				view.graphics.drawCircle(position.x, position.y, DeviceInfo.current.screenDPI * radius);
			}
		}
	}
}
