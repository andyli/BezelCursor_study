package bezelcursor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.behavior.DynaScale;
import bezelcursor.cursor.behavior.DrawStick;
import bezelcursor.cursor.behavior.DrawRadius;
import bezelcursor.cursor.snapper.SimpleSnapper;
import bezelcursor.model.DeviceData;
import bezelcursor.model.TouchData;


class StickCursor extends PointActivatedCursor {
	public var joint:Null<Point>;
	public var jointActivateDistance:Float;
	public var scaleFactor:Float;
	
	@deep public var clickWhenTouchEnd(default, set_clickWhenTouchEnd):ClickWhenTouchEnd;
	function set_clickWhenTouchEnd(v:ClickWhenTouchEnd):ClickWhenTouchEnd {
		behaviors.remove(clickWhenTouchEnd);
		if (v != null) behaviors.push(v);
		return clickWhenTouchEnd = v;
	}
	
	@deep public var dynaScale(default, set_dynaScale):DynaScale;
	function set_dynaScale(v:DynaScale):DynaScale {
		behaviors.remove(dynaScale);
		if (v != null) behaviors.push(v);
		return dynaScale = v;
	}
	@deep public var drawRadius(default, set_drawRadius):DrawRadius;
	function set_drawRadius(v:DrawRadius):DrawRadius {
		behaviors.remove(drawRadius);
		if (v != null) behaviors.push(v);
		return drawRadius = v;
	}
	
	public function new():Void {
		super();
		
		joint = null;
		jointActivateDistance = DeviceData.current.screenDPI * 0.2;
		scaleFactor = 3;
		
		dynaScale = new DynaScale(this);
		drawRadius = new DrawRadius(this);
		clickWhenTouchEnd = new ClickWhenTouchEnd(this);
	}
	
	override function start():Void {
		super.start();
		
		target_position = current_position = activatedPoint;
		joint = null;
	}
		
	/*
	override function onFrame(evt:Event = null):Void {		
		super.onFrame(evt);
		
		if (position != null) {
			view.graphics.lineStyle(2, 0xFF0000, 1);
			view.graphics.moveTo(activatedPoint.x, activatedPoint.y);
			if (joint != null) {
				view.graphics.drawCircle(joint.x, joint.y, 2);
				view.graphics.curveTo(joint.x, joint.y, position.x, position.y);
			} else {
				view.graphics.lineTo(position.x, position.y);
			}
		}
	}
	*/
	
	override function onTouchBegin(touch:TouchData):Void {
		super.onTouchBegin(touch);
		
		target_position = current_position = activatedPoint;
	}
	
	override function onTouchMove(touch:TouchData):Void {
		super.onTouchMove(touch);

		var pt = new Point(touch.x, touch.y);
		if (activatedPoint != null) {
			if (joint != null) {
				var v = pt.subtract(joint);
				v.normalize((v.length + jointActivateDistance) * scaleFactor - jointActivateDistance);
				position = joint.add(v);
			} else {
				if (Point.distance(pt, activatedPoint) > jointActivateDistance) {
					joint = pt;
				}
				
				var v = pt.subtract(activatedPoint);
				v.normalize(v.length * scaleFactor);
				position = activatedPoint.add(v);
			}
		}
	}
	
	override function onTouchEnd(touch:TouchData):Void {
		joint = null;
		super.onTouchEnd(touch);
	}
}
