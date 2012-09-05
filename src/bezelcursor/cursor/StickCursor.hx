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
import bezelcursor.model.DeviceInfo;

class StickCursor extends PointActivatedCursor {
	public var joint:Null<Point>;
	public var jointActivateDistance:Float;
	public var scaleFactor:Float;
	
	public function new(touchPointID:Int):Void {
		super(touchPointID);
		
		jointActivateDistance = DeviceInfo.current.screenDPI * 0.2;
		scaleFactor = 3;
		
		behaviors.push(new DynaScale(this));
		behaviors.push(new DrawStick(this));
		behaviors.push(new DrawRadius(this));
		behaviors.push(new ClickWhenTouchEnd(this));
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
	
	override function onTouchBegin(evt:TouchEvent):Void {
		super.onTouchBegin(evt);
		
		target_position = current_position = activatedPoint;
	}
	
	override function onTouchMove(evt:TouchEvent):Void {
		super.onTouchMove(evt);

		var pt = new Point(evt.localX, evt.localY);
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
	
	override function onTouchEnd(evt:TouchEvent):Void {
		joint = null;
		super.onTouchEnd(evt);
	}
	
	override public function clone():StickCursor {
		var cursor = new StickCursor(touchPointID); Cursor.nextId--;
		
		cursor.id = id;
		cursor.current_position = current_position;
		cursor.target_position = target_position;
		cursor.current_radius = current_radius;
		cursor.target_radius = target_radius;
		cursor.behaviors = behaviors.copy();
		cursor.snapper = snapper;
		cursor.color = color;
		
		cursor.pFrameTouchPoint = pFrameTouchPoint;
		cursor.activatedPoint = activatedPoint;
		cursor.currentTouchPoint = currentTouchPoint;
		cursor.touchVelocity = touchVelocity;

		cursor.joint = joint;
		cursor.jointActivateDistance = jointActivateDistance;
		cursor.scaleFactor = scaleFactor;
		
		return cursor;
	}
}
