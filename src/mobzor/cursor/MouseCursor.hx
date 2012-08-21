package mobzor.cursor;

import nme.Lib;
import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.TouchEvent;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.system.Capabilities;
import nme.ui.Multitouch;
import nme.ui.MultitouchInputMode;
using org.casalib.util.NumberUtil;
import com.haxepunk.HXP;

class MouseCursor extends BezelActivatedCursor {	
	var startDownPos:Point;
	var lastDownPos:Point;
	var targetPos:Point;
	
	override function onFrame(evt:Event = null):Void {
		if (lastDownPos != null) {
			if (startDownPos != null) {
				var velocity = lastDownPos.subtract(startDownPos);
				var l = velocity.length;
				velocity.normalize(
					l
					* l.map(Capabilities.screenDPI * 0.01, Capabilities.screenDPI * 0.05, 1, 3).constrain(1, 3)
					* HXP.frameRate.map(0, 30, 1, 0.75)
				);
				targetPoint = targetPoint.add(velocity);
			} else {
				targetPoint = lastDownPos;
			}
			startDownPos = lastDownPos;
		}
		
		super.onFrame(evt);
		
		if (currentPoint != null) {
			view.graphics.clear();
			view.graphics.lineStyle(2, 0xFF0000, 1);
			view.graphics.drawCircle(currentPoint.x, currentPoint.y, Capabilities.screenDPI * 0.001);
			view.graphics.drawCircle(currentPoint.x, currentPoint.y, Capabilities.screenDPI * 0.08);
		}
	}
	
	override function onTouchBegin(evt:TouchEvent):Void {
		super.onTouchBegin(evt);
		
		startDownPos = lastDownPos = targetPoint = currentPoint = activatedPoint;
	}
	
	override function onTouchMove(evt:TouchEvent):Void {
		super.onTouchMove(evt);
		
		if (activatedPoint != null) {
			lastDownPos = new Point(evt.localX, evt.localY);
		}
	}
	
	override function onTouchEnd(evt:TouchEvent):Void {
		var pt = new Point(evt.localX, evt.localY);
		if (currentPoint != null) {
			onClickSignaler.dispatch(currentPoint);
		} else {
			onClickSignaler.dispatch(pt);
		}
		
		view.graphics.clear();
		
		startDownPos = lastDownPos = targetPoint = currentPoint = null;
		
		super.onTouchEnd(evt);
	}
}
