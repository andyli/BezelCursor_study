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
	public var touchId(default, null):Int;
	
	/**
	* Where this cursor is triggered (on bezel).
	*/
	public var activatedPoint(default, null):Point;
	
	/**
	* Where this cursor is heading to.
	*/
	public var targetPoint(default, null):Point;
	
	/**
	* Current pointing position.
	*/
	public var currentPoint(default, null):Point;
	
	/**
	* The visual graphics of the cursor.
	* It is automatically added to the stage on `start` and removed on `end`.
	*/
	public var view(default, null):Sprite;
	
	/**
	* Basically Lib.stage.
	*/
	public var stage(default, null):Stage;

	/**
	* Width in inches to be considered as bezel.
	*/
	public var bezelWidth(default, null):Float = 0.1;
	var bezelOut:Rectangle;
	var bezelIn:Rectangle;
	
	public function new(touchId:Int, ?activatedPoint:Point):Void {
		super();
		
		this.touchId = touchId;
		this.stage = Lib.stage;
		this.view = new Sprite();
		this.activatedPoint = activatedPoint;
	}
	
	public function onResize(evt:Event = null):Void {
		bezelOut = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		bezelIn = bezelOut.clone();
		
		var bezelWidthPx = Capabilities.screenDPI * bezelWidth;
		bezelIn.inflate(-bezelWidthPx, -bezelWidthPx); 
	}
	
	override public function start():Void {
		super.start();
		
		onResize();
		
		stage.addChild(view);
		
		if (Multitouch.supportsTouchEvents) {
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			
			//trace(Multitouch.inputMode);
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		} else {
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		stage.addEventListener(Event.RESIZE, onResize);
		stage.addEventListener(Event.ENTER_FRAME, onFrame);
	}
	
	override public function end():Void {
		stage.removeEventListener(Event.RESIZE, onResize);
		stage.removeEventListener(Event.ENTER_FRAME, onFrame);
		
		if (Multitouch.supportsTouchEvents) {
			stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		} else {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
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
	
	function onTouchBegin(evt:TouchEvent):Void {
		var pt = new Point(evt.localX, evt.localY);
		if (bezelOut.containsPoint(pt) && !bezelIn.containsPoint(pt)) {
			this.activatedPoint = pt;
		} else {
			this.activatedPoint = null;
		}
	}
	
	function onTouchMove(evt:TouchEvent):Void {
		
	}
	
	function onTouchEnd(evt:TouchEvent):Void {	
		this.activatedPoint = null;
	}
	
	function onMouseDown(evt:MouseEvent):Void {
		onTouchBegin(new TouchEvent(
			TouchEvent.TOUCH_BEGIN, 
			evt.bubbles, 
			evt.cancelable,
			evt.localX, 
			evt.localY, 
			1, 
			1, 
			evt.relatedObject, 
			evt.ctrlKey, 
			evt.altKey, 
			evt.shiftKey, 
			evt.buttonDown, 
			evt.delta, 
			evt.commandKey, 
			evt.clickCount
		));
	}
	
	function onMouseMove(evt:MouseEvent):Void {
		onTouchMove(new TouchEvent(
			TouchEvent.TOUCH_BEGIN, 
			evt.bubbles, 
			evt.cancelable,
			evt.localX, 
			evt.localY, 
			1, 
			1, 
			evt.relatedObject, 
			evt.ctrlKey, 
			evt.altKey, 
			evt.shiftKey, 
			evt.buttonDown, 
			evt.delta, 
			evt.commandKey, 
			evt.clickCount
		));
	}
	
	function onMouseUp(evt:MouseEvent):Void {
		onTouchEnd(new TouchEvent(
			TouchEvent.TOUCH_BEGIN, 
			evt.bubbles, 
			evt.cancelable,
			evt.localX, 
			evt.localY, 
			1, 
			1, 
			evt.relatedObject, 
			evt.ctrlKey, 
			evt.altKey, 
			evt.shiftKey, 
			evt.buttonDown, 
			evt.delta, 
			evt.commandKey, 
			evt.clickCount
		));
	}
}