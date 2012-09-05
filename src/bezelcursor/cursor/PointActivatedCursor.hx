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
	
	public function new(touchPointID:Int = 0):Void {
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
	
	override public function getConfig():Dynamic {
		var config:Dynamic = super.getConfig();
		
		config.touchPointID = touchPointID;
		config.activatedPoint = activatedPoint.toObj();
		config.pFrameTouchPoint = pFrameTouchPoint.toObj();
		config.currentTouchPoint = currentTouchPoint.toObj();
		config.touchVelocity = touchVelocity.toObj();
		
		return config;
	}
	
	override public function setConfig(config:Dynamic):Void {
		super.setConfig(config);
		
		touchPointID = config.touchPointID;
		activatedPoint = config.activatedPoint.toPoint();
		pFrameTouchPoint = config.pFrameTouchPoint.toPoint();
		currentTouchPoint = config.currentTouchPoint.toPoint();
		touchVelocity = config.touchVelocity.toPoint();
	}
	
	override public function clone():PointActivatedCursor {
		var cursor = new PointActivatedCursor(touchPointID); Cursor.nextId--;
		cursor.setConfig(getConfig());
		return cursor;
	}
}