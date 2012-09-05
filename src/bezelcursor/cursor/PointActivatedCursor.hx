package bezelcursor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.system.Capabilities;
import nme.ui.Multitouch;
import nme.ui.MultitouchInputMode;

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
		currentTouchPoint = activatedPoint = pt;
		touchVelocity.x = touchVelocity.y = 0;
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
		
		super.onTouchEnd(evt);
		
		pFrameTouchPoint = currentTouchPoint = activatedPoint = null;
		touchVelocity.x = touchVelocity.y = 0;
	}
	
	override public function clone():PointActivatedCursor {
		var cursor = new PointActivatedCursor(touchPointID);
		cursor.id = id;
		cursor.current_position = current_position;
		cursor.target_position = target_position;
		cursor.current_radius = current_radius;
		cursor.target_radius = target_radius;
		cursor.activatedPoint = activatedPoint;
		cursor.pFrameTouchPoint = pFrameTouchPoint;
		cursor.currentTouchPoint = currentTouchPoint;
		cursor.touchVelocity = touchVelocity;
		return cursor;
	}
}