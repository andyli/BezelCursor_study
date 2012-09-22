package bezelcursor.cursor;

import nme.geom.*;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.behavior.*;
import bezelcursor.cursor.snapper.*;
import bezelcursor.model.*;


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
	
	@deep public var drawStick(default, set_drawStick):DrawStick;
	function set_drawStick(v:DrawStick):DrawStick {
		behaviors.remove(drawStick);
		if (v != null) behaviors.push(v);
		return drawStick = v;
	}
	
	public function new():Void {
		super();
		
		joint = null;
		jointActivateDistance = DeviceData.current.screenDPI * 0.2;
		scaleFactor = 3;

		drawStick = new DrawStick(this);
		dynaScale = new DynaScale(this);
		drawRadius = new DrawRadius(this);
		clickWhenTouchEnd = new ClickWhenTouchEnd(this);
	}
	
	override function start():Void {
		super.start();
		
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

		setImmediatePosition(activatedPoint);
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
