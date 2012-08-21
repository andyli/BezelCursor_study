package mobzor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.system.Capabilities;
using org.casalib.util.NumberUtil;

class StickCursor extends PointActivatedCursor {
	override function start():Void {
		super.start();
		
		this.targetPoint = this.currentPoint = this.activatedPoint;
	}
	
	override function onFrame(evt:Event = null):Void {
		if (currentPoint != null) {
			view.graphics.clear();
			view.graphics.lineStyle(2, 0xFF0000, 1);
			view.graphics.moveTo(activatedPoint.x, activatedPoint.y);
			view.graphics.lineTo(currentPoint.x, currentPoint.y);
			view.graphics.drawCircle(currentPoint.x, currentPoint.y, Capabilities.screenDPI * 0.08);
		}
		
		super.onFrame(evt);
	}
	
	override function onTouchBegin(evt:TouchEvent):Void {
		super.onTouchBegin(evt);
		
		this.targetPoint = this.currentPoint = this.activatedPoint;
	}
	
	override function onTouchMove(evt:TouchEvent):Void {
		super.onTouchMove(evt);
		
		if (activatedPoint != null) {
			targetPoint = getStickEnd(activatedPoint, new Point(evt.localX, evt.localY));
		}
	}
	
	override function onTouchEnd(evt:TouchEvent):Void {
		if (evt.touchPointID != touchPointID) return;
		
		var pt = new Point(evt.localX, evt.localY);
		if (currentPoint != null) {
			onClickSignaler.dispatch(currentPoint);
		} else {
			onClickSignaler.dispatch(pt);
		}
		
		view.graphics.clear();
		
		this.targetPoint = this.currentPoint = null;
		
		super.onTouchEnd(evt);
		
		end();
	}
	
	static public function getStickEnd(down:Point, up:Point):Point {
		var v = up.subtract(down);
		v.normalize(v.length * 3);
		return down.add(v);
	}
}
