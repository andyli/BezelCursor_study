package bezelcursor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.system.Capabilities;
import nme.ui.Multitouch;
import nme.ui.MultitouchInputMode;

import bezelcursor.model.TouchData;
using bezelcursor.model.Struct;

/**
* Cursor that is activated and controlled by a single touch.
*/
class PointActivatedCursor extends Cursor {
	/**
	* The touch that is controlling this cursor.
	*/
	public var touchPointID(default, null):Int;
	
	/**
	* Where this cursor is triggered (on bezel).
	*/
	public var activatedPoint(default, null):Point;

	/**
	* Touch point of the previous frame.
	*/
	public var pFrameTouchPoint(default, null):Point;
	
	/**
	* The last touch point recorded.
	*/
	public var currentTouchPoint(default, null):Point;
	
	/**
	* Velocity of the touch movement.
	*/
	public var touchVelocity(default, null):Point;
	
	var ptimestamp:Float;
	
	public function new(data:Dynamic):Void {
		super(data);
		
		touchPointID = data.touchPointID;
		touchVelocity = data != null && Reflect.hasField(data, "touchVelocity") ? data.touchVelocity.toPoint() : new Point();
		pFrameTouchPoint = data != null && Reflect.hasField(data, "pFrameTouchPoint") ? data.pFrameTouchPoint.toPoint() : null;
		currentTouchPoint = data != null && Reflect.hasField(data, "currentTouchPoint") ? data.currentTouchPoint.toPoint() : null;
		activatedPoint = data != null && Reflect.hasField(data, "activatedPoint") ? data.activatedPoint.toPoint() : null;
	}
	
	override public function start():Void {
		super.start();
		ptimestamp = haxe.Timer.stamp();
	}
	
	override public function onFrame(timestamp:Float):Void {
		super.onFrame(timestamp);
		
		if (currentTouchPoint != null) {
			if (pFrameTouchPoint != null) {
				touchVelocity = currentTouchPoint.subtract(pFrameTouchPoint);
				touchVelocity.normalize(touchVelocity.length/(timestamp - ptimestamp));
			}
			pFrameTouchPoint = currentTouchPoint;
		}
		
		ptimestamp = timestamp;
	}
	
	override public function onTouchBegin(touch:TouchData):Void {
		#if debug
		if (touch.touchPointID != touchPointID) throw "This cursor should receive only touchPointID of " + touchPointID + " but not " + touch.touchPointID + ".";
		#end
		
		super.onTouchBegin(touch);
		
		var pt = new Point(touch.x, touch.y);
		currentTouchPoint = activatedPoint = pt;
		touchVelocity.x = touchVelocity.y = 0;
	}
	
	override public function onTouchMove(touch:TouchData):Void {
		#if debug
		if (touch.touchPointID != touchPointID) throw "This cursor should receive only touchPointID of " + touchPointID + " but not " + touch.touchPointID + ".";
		#end
		
		super.onTouchMove(touch);
		
		if (activatedPoint != null) {
			currentTouchPoint = new Point(touch.x, touch.y);
		}
	}
	
	override public function onTouchEnd(touch:TouchData):Void {
		#if debug
		if (touch.touchPointID != touchPointID) throw "This cursor should receive only touchPointID of " + touchPointID + " but not " + touch.touchPointID + ".";
		#end
		
		super.onTouchEnd(touch);
		
		pFrameTouchPoint = currentTouchPoint = activatedPoint = null;
		touchVelocity.x = touchVelocity.y = 0;
	}
	
	override public function getData():Dynamic {
		var data:Dynamic = super.getData();
		
		data.touchPointID = touchPointID;
		data.activatedPoint = activatedPoint.toObj();
		data.pFrameTouchPoint = pFrameTouchPoint.toObj();
		data.currentTouchPoint = currentTouchPoint.toObj();
		data.touchVelocity = touchVelocity.toObj();
		
		return data;
	}
	
	override public function setData(data:Dynamic):Void {
		super.setData(data);
		
		touchPointID = data.touchPointID;
		activatedPoint = data.activatedPoint.toPoint();
		pFrameTouchPoint = data.pFrameTouchPoint.toPoint();
		currentTouchPoint = data.currentTouchPoint.toPoint();
		touchVelocity = data.touchVelocity.toPoint();
	}
	
	override public function clone():PointActivatedCursor {
		return new PointActivatedCursor(getData());
	}
}