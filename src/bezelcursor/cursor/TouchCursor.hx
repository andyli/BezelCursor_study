package bezelcursor.cursor;

import flash.geom.*;
import bezelcursor.cursor.behavior.*;
import bezelcursor.cursor.snapper.*;
import bezelcursor.model.*;


class TouchCursor extends PointActivatedCursor {
	public var maxDistance:Float;
	public var isDragging(default, null):Bool = false;
	
	public function new():Void {
		super();
		maxDistance = DeviceData.current.screenDPI * 0.1;
	}
	
	override function start():Void {
		super.start();
	}
	
	override function onTouchBegin(touch:TouchData):Void {
		super.onTouchBegin(touch);

		setImmediatePosition(activatedPoint);
	}
	
	override function onTouchMove(touch:TouchData):Void {
		super.onTouchMove(touch);

		var pt = new Point(touch.x, touch.y);
		position = pt;

		if (!isDragging && activatedPoint != null && Point.distance(pt, activatedPoint) > maxDistance){
			isDragging = true;
		}

		if (isDragging) {
			onDragSignaler.dispatch();
		}
	}
	
	override function onTouchEnd(touch:TouchData):Void {
		if (isDragging) {

		} else {
			click();
		}
		super.onTouchEnd(touch);
		end();
	}
}
