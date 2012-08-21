package mobzor.cursor;

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
	
	public function new(touchPointID:Int):Void {
		super();
		
		this.touchPointID = touchPointID;
	}
	
	public function onTouchBegin(evt:TouchEvent):Void {
		if (evt.touchPointID != touchPointID) return;
		
		var pt = new Point(evt.localX, evt.localY);
		this.activatedPoint = pt;
	}
	
	public function onTouchMove(evt:TouchEvent):Void {
		if (evt.touchPointID != touchPointID) return;
	}
	
	public function onTouchEnd(evt:TouchEvent):Void {
		if (evt.touchPointID != touchPointID) return;
		
		this.activatedPoint = null;
	}
}