package mobzor.cursor;

import nme.display.Stage;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.TouchEvent;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.system.Capabilities;
import nme.ui.Multitouch;
import nme.ui.MultitouchInputMode;
import nme.Lib;
using org.casalib.util.NumberUtil;


class BezelActivatedCursor extends Cursor {
	/**
	* The touch that is controlling this cursor.
	*/
	public var touchPointID(default, null):Int;
	
	/**
	* Where this cursor is triggered (on bezel).
	*/
	public var activatedPoint(default, null):Point;
	
	/**
	* Where this cursor is heading to.
	*/
	public var targetPoint(default, null):Point;
	
	/**
	* The visual graphics of the cursor.
	* It is automatically added to the stage on `start` and removed on `end`.
	*/
	public var view(default, null):Sprite;
	
	/**
	* Basically Lib.stage.
	*/
	public var stage(default, null):Stage;
	
	public function new(touchPointID:Int):Void {
		super();
		
		this.touchPointID = touchPointID;
		this.stage = Lib.stage;
		this.view = new Sprite();
		//this.activatedPoint = activatedPoint;
	}
	
	override public function start():Void {
		super.start();
		stage.addChild(view);
		stage.addEventListener(Event.ENTER_FRAME, onFrame);
	}
	
	override public function end():Void {
		stage.removeEventListener(Event.ENTER_FRAME, onFrame);
		stage.removeChild(view);
		super.end();
	}
	
	
	function onFrame(evt:Event = null):Void {
		if (targetPoint != null) {
			if (currentPoint == null) {
				currentPoint = targetPoint;
				onActivateSignaler.dispatch(currentPoint);
				onMoveSignaler.dispatch(currentPoint);
			} else if (!currentPoint.equals(targetPoint)) {
				var pt = targetPoint.subtract(currentPoint);
				pt.normalize(pt.length * stage.frameRate.map(0, 30, 1, 0.78));
				currentPoint = currentPoint.add(pt);
				onMoveSignaler.dispatch(currentPoint);
			}
		}
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