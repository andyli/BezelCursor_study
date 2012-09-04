package bezelcursor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.behavior.DynaScale;
import bezelcursor.cursor.behavior.SimpleDraw;
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
		
		snapper = new SimpleSnapper(this);
		
		behaviors.push(new DynaScale(this));
		behaviors.push(new SimpleDraw(this));
		behaviors.push(new ClickWhenTouchEnd(this));
	}
	
	override function start():Void {
		super.start();
		
		this.targetPoint = this.currentPoint = this.activatedPoint;
		joint = null;
	}
	
	override function onFrame(evt:Event = null):Void {		
		super.onFrame(evt);
		
		if (currentPoint != null) {
			view.graphics.lineStyle(2, 0xFF0000, 1);
			view.graphics.moveTo(activatedPoint.x, activatedPoint.y);
			if (joint != null) {
				view.graphics.drawCircle(joint.x, joint.y, 2);
				view.graphics.curveTo(joint.x, joint.y, currentPoint.x, currentPoint.y);
			} else {
				view.graphics.lineTo(currentPoint.x, currentPoint.y);
			}
		}
	}
	
	override function onTouchBegin(evt:TouchEvent):Void {
		super.onTouchBegin(evt);
		
		this.targetPoint = this.currentPoint = this.activatedPoint;
	}
	
	override function onTouchMove(evt:TouchEvent):Void {
		super.onTouchMove(evt);

		var pt = new Point(evt.localX, evt.localY);
		if (activatedPoint != null) {
			if (joint != null) {
				var v = pt.subtract(joint);
				v.normalize((v.length + jointActivateDistance) * scaleFactor - jointActivateDistance);
				targetPoint = joint.add(v);
			} else {
				if (Point.distance(pt, activatedPoint) > jointActivateDistance) {
					joint = pt;
				}
				
				var v = pt.subtract(activatedPoint);
				v.normalize(v.length * scaleFactor);
				targetPoint = activatedPoint.add(v);
			}
		}
	}
	
	override function onTouchEnd(evt:TouchEvent):Void {
		if (evt.touchPointID != touchPointID) return;
		joint = null;
		super.onTouchEnd(evt);
	}
}
