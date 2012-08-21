package mobzor.cursor;

import nme.Lib;
import nme.display.Stage;
import nme.events.Event;
import nme.events.TouchEvent;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.system.Capabilities;
import nme.ui.Multitouch;
import nme.ui.MultitouchInputMode;
import hsl.haxe.Signal;
import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;

class BezelActivatedCursorManager {
	public var onActivateSignaler(default, null):Signaler<Point>;
	public var onMoveSignaler(default, null):Signaler<Point>;
	public var onClickSignaler(default, null):Signaler<Point>;
	public var onEndSignaler(default, null):Signaler<Void>;
	
	dynamic public function createCursor(evt:TouchEvent):PointActivatedCursor {
		return new mobzor.cursor.MouseCursor(evt.touchPointID);
	}
	
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
	
	var pointActivatedCursors:IntHash<PointActivatedCursor>;
	
	public function new():Void {
		this.stage = Lib.stage;
		
		onActivateSignaler = new DirectSignaler<Point>(this);
		onMoveSignaler = new DirectSignaler<Point>(this);
		onClickSignaler = new DirectSignaler<Point>(this);
		onEndSignaler = new DirectSignaler<Void>(this);
		
		pointActivatedCursors = new IntHash<PointActivatedCursor>();
	}
	
	public function onResize(evt:Event = null):Void {
		bezelOut = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		bezelIn = bezelOut.clone();
		
		var bezelWidthPx = Capabilities.screenDPI * bezelWidth;
		bezelIn.inflate(-bezelWidthPx, -bezelWidthPx); 
	}
	
	public function start():Void {
		onResize();
		
		if (Multitouch.supportsTouchEvents) {
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		} else {
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		stage.addEventListener(Event.RESIZE, onResize);
	}
	
	public function end():Void {
		stage.removeEventListener(Event.RESIZE, onResize);
		
		if (Multitouch.supportsTouchEvents) {
			stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		} else {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
	}
	
	function onTouchBegin(evt:TouchEvent):Void {
		var pt = new Point(evt.localX, evt.localY);
		if (bezelOut.containsPoint(pt) && !bezelIn.containsPoint(pt)) {
			var cursor = createCursor(evt);
			pointActivatedCursors.set(evt.touchPointID, cursor);
			//trace(evt.touchPointID);
			cursor.start();
			cursor.onTouchBegin(evt);
		
			cursor.onActivateSignaler.addBubblingTarget(onActivateSignaler);
			cursor.onMoveSignaler.addBubblingTarget(onMoveSignaler);
			cursor.onClickSignaler.addBubblingTarget(onClickSignaler);
			cursor.onEndSignaler.addBubblingTarget(onEndSignaler);
		
			cursor.onEndSignaler.bindAdvanced(function(signal:Signal<Void>):Void {
				var cursor:PointActivatedCursor = cast signal.origin;
				cursor.onActivateSignaler.removeBubblingTarget(onActivateSignaler);
				cursor.onMoveSignaler.removeBubblingTarget(onMoveSignaler);
				cursor.onClickSignaler.removeBubblingTarget(onClickSignaler);
				cursor.onEndSignaler.removeBubblingTarget(onEndSignaler);
				pointActivatedCursors.remove(cursor.touchPointID);
			}).destroyOnUse();
		}
	}
	
	function onTouchMove(evt:TouchEvent):Void {
		if (pointActivatedCursors.exists(evt.touchPointID)) {
			var cursor = pointActivatedCursors.get(evt.touchPointID);
			cursor.onTouchMove(evt);
		}
	}
	
	function onTouchEnd(evt:TouchEvent):Void {
		if (pointActivatedCursors.exists(evt.touchPointID)) {
			var cursor = pointActivatedCursors.get(evt.touchPointID);
			cursor.onTouchEnd(evt);
		}
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