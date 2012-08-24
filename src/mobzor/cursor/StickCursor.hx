package mobzor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.system.Capabilities;
using org.casalib.util.NumberUtil;

import mobzor.cursor.behavior.Behavior;
import mobzor.cursor.behavior.DynaScale;
import mobzor.cursor.behavior.SimpleDraw;

class StickCursor extends PointActivatedCursor {
	public function new(touchPointID:Int):Void {
		super(touchPointID);
		behaviors.push(new DynaScale(this));
		behaviors.push(new SimpleDraw(this));
	}
	
	override function start():Void {
		super.start();
		
		this.targetPoint = this.currentPoint = this.activatedPoint;
	}
	
	override function onFrame(evt:Event = null):Void {		
		super.onFrame(evt);
		
		if (currentPoint != null) {
			view.graphics.lineStyle(2, 0xFF0000, 1);
			view.graphics.moveTo(activatedPoint.x, activatedPoint.y);
			view.graphics.lineTo(currentPoint.x, currentPoint.y);
		}
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
