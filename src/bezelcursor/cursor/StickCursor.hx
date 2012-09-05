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
import bezelcursor.model.TouchData;
using bezelcursor.model.Struct;

class StickCursor extends PointActivatedCursor {
	public var joint:Null<Point>;
	public var jointActivateDistance:Float;
	public var scaleFactor:Float;
	
	public function new(config:Dynamic):Void {
		super(config);
		
		joint = config != null && Reflect.hasField(config, "joint") ? config.joint.toPoint() : null;
		jointActivateDistance = config != null && Reflect.hasField(config, "jointActivateDistance") ? config.jointActivateDistance : DeviceInfo.current.screenDPI * 0.2;
		scaleFactor = config != null && Reflect.hasField(config, "scaleFactor") ? config.scaleFactor : 3;
		behaviors = config != null && Reflect.hasField(config, "behaviors") ? Behavior.createFromConfigs(this, config.behaviors) : [new DynaScale(this), new DrawStick(this), new DrawRadius(this), new ClickWhenTouchEnd(this)];
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
	
	override public function getConfig():Dynamic {
		var config:Dynamic = super.getConfig();

		config.joint = joint.toObj();
		config.jointActivateDistance = jointActivateDistance;
		config.scaleFactor = scaleFactor;
		
		return config;
	}
	
	override public function setConfig(config:Dynamic):Void {
		super.setConfig(config);

		joint = config.joint.toPoint();
		jointActivateDistance = config.jointActivateDistance;
		scaleFactor = config.scaleFactor;
	}
	
	override public function clone():StickCursor {
		return new StickCursor(getConfig());
	}
}
