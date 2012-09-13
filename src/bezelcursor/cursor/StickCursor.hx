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
using bezelcursor.model.Struct;

class StickCursor extends PointActivatedCursor {
	public var joint:Null<Point>;
	public var jointActivateDistance:Float;
	public var scaleFactor:Float;
	
	public function new(data:Dynamic):Void {
		super(data);
		
		joint = data != null && Reflect.hasField(data, "joint") ? data.joint.toPoint() : null;
		jointActivateDistance = data != null && Reflect.hasField(data, "jointActivateDistance") ? data.jointActivateDistance : DeviceData.current.screenDPI * 0.2;
		scaleFactor = data != null && Reflect.hasField(data, "scaleFactor") ? data.scaleFactor : 3;
		//behaviors = data != null && Reflect.hasField(data, "behaviors") ? Behavior.createFromDatas(this, data.behaviors) : [new DynaScale(this), new DrawRadius(this), new ClickWhenTouchEnd(this)];
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
	
	override public function getData():Dynamic {
		var data:Dynamic = super.getData();

		data.joint = joint.toObj();
		data.jointActivateDistance = jointActivateDistance;
		data.scaleFactor = scaleFactor;
		
		return data;
	}
	
	override public function setData(data:Dynamic):Void {
		super.setData(data);

		joint = data.joint.toPoint();
		jointActivateDistance = data.jointActivateDistance;
		scaleFactor = data.scaleFactor;
	}
	
	override public function clone():StickCursor {
		return new StickCursor(getData());
	}
}
