package mobzor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.system.Capabilities;
import nme.ui.Multitouch;
import nme.ui.MultitouchInputMode;


class PointActivatedCursor extends Cursor {
	/**
	* The touch that is controlling this cursor.
	*/
	public var touchPointID(default, null):Int;
	
	/**
	* Where this cursor is triggered (on bezel).
	*/
	public var activatedPoint(default, null):Point;

	var pFrameTouchPoint:Point;
	var currentTouchPoint:Point;
	var touchVelocity:Point;
	
	public function new(touchPointID:Int):Void {
		super();
		
		this.touchPointID = touchPointID;
		touchVelocity = new Point();
	}
	
	override public function onFrame(evt:Event = null):Void {
		super.onFrame();
		
		if (currentTouchPoint != null) {
			if (pFrameTouchPoint != null) {
				touchVelocity = currentTouchPoint.subtract(pFrameTouchPoint);
			}
			pFrameTouchPoint = currentTouchPoint;
		}
	}
	
	override public function onTouchBegin(evt:TouchEvent):Void {
		if (evt.touchPointID != touchPointID) return;
		
		super.onTouchBegin(evt);
		
		var pt = new Point(evt.localX, evt.localY);
		pFrameTouchPoint = currentTouchPoint = activatedPoint = pt;
	}
	
	override public function onTouchMove(evt:TouchEvent):Void {
		if (evt.touchPointID != touchPointID) return;
		
		super.onTouchMove(evt);
		
		if (activatedPoint != null) {
			currentTouchPoint = new Point(evt.localX, evt.localY);
		}
	}
	
	override public function onTouchEnd(evt:TouchEvent):Void {
		if (evt.touchPointID != touchPointID) return;
		
		pFrameTouchPoint = currentTouchPoint = activatedPoint = null;
		
		super.onTouchEnd(evt);
	}
	
	override public function clone():PointActivatedCursor {
		var cursor = new PointActivatedCursor(touchPointID);
		cursor.id = id;
		cursor.currentPoint = currentPoint;
		cursor.targetPoint = targetPoint;
		cursor.activatedPoint = activatedPoint;
		cursor.pFrameTouchPoint = pFrameTouchPoint;
		cursor.currentTouchPoint = currentTouchPoint;
		cursor.touchVelocity = touchVelocity;
		return cursor;
	}
	
    override function hxSerialize( s : haxe.Serializer ) {
		super.hxSerialize(s);
        s.serialize(touchPointID);
        s.serialize(activatedPoint);
        s.serialize(pFrameTouchPoint);
        s.serialize(currentTouchPoint);
        s.serialize(touchVelocity);
    }
    override function hxUnserialize( s : haxe.Unserializer ) {
		super.hxUnserialize(s);
        touchPointID = s.unserialize();
        activatedPoint = s.unserialize();
        pFrameTouchPoint = s.unserialize();
        currentTouchPoint = s.unserialize();
        touchVelocity = s.unserialize();
    }
}