package bezelcursor.cursor;

using Std;
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

enum CreateCursorFor {
	ForBezel;
	ForScreen;
}

class CursorManager {
	public var onActivateSignaler(default, null):Signaler<Point>;
	public var onMoveSignaler(default, null):Signaler<Point>;
	public var onClickSignaler(default, null):Signaler<Point>;
	public var onEndSignaler(default, null):Signaler<Void>;
	
	public var tapEnabled(default, null):Bool;
	public var bezelCursorEnabled(default, null):Bool;
	public var screenCursorEnabled(default, null):Bool;
	
	dynamic public function createCursor(evt:TouchEvent, _for:CreateCursorFor):Cursor {
		switch(_for) {
			case ForBezel: 
				return new bezelcursor.cursor.MouseCursor(evt.touchPointID);
			case ForScreen:
				var cursor = new bezelcursor.cursor.StickCursor(evt.touchPointID);
				cursor.scaleFactor *= -1;
				cursor.jointActivateDistance = Math.POSITIVE_INFINITY;
				return cursor;
		}
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
		stage = Lib.stage;
		tapEnabled = true;
		bezelCursorEnabled = true;
		screenCursorEnabled = true;
		
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
	
	function insideBezel(evt:TouchEvent):Bool {
		var pt = new Point(evt.localX, evt.localY);
		return bezelOut.containsPoint(pt) && !bezelIn.containsPoint(pt);
	}
	
	function addCursor(evt:TouchEvent, cursor:Cursor):Void {
		if (cursor.is(PointActivatedCursor)) {
			var pCursor = cast(cursor,PointActivatedCursor);
			pointActivatedCursors.set(pCursor.touchPointID, pCursor);
		}
			
		cursor.start();
		cursor.onTouchBegin(evt);
		
		cursor.onActivateSignaler.addBubblingTarget(onActivateSignaler);
		cursor.onMoveSignaler.addBubblingTarget(onMoveSignaler);
		cursor.onClickSignaler.addBubblingTarget(onClickSignaler);
		cursor.onEndSignaler.addBubblingTarget(onEndSignaler);
		
		cursor.onEndSignaler.bindAdvanced(function(signal:Signal<Void>):Void {
			var cursor:Cursor = cast signal.origin;
				
			cursor.onActivateSignaler.removeBubblingTarget(onActivateSignaler);
			cursor.onMoveSignaler.removeBubblingTarget(onMoveSignaler);
			cursor.onClickSignaler.removeBubblingTarget(onClickSignaler);
			cursor.onEndSignaler.removeBubblingTarget(onEndSignaler);
				
			if (cursor.is(PointActivatedCursor))
				pointActivatedCursors.remove(untyped cursor.touchPointID);
		}).destroyOnUse();
	}
	
	function onTouchBegin(evt:TouchEvent):Void {
		if (bezelCursorEnabled && insideBezel(evt)) {
			addCursor(evt, createCursor(evt, ForBezel));
		} else if (screenCursorEnabled) {
			addCursor(evt, createCursor(evt, ForScreen));
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
		} else if (tapEnabled) {
			onClickSignaler.dispatch(new Point(evt.localX, evt.localY));
		}
	}
	
	function onMouseDown(evt:MouseEvent):Void {
		#if cpp
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
		#elseif js
		onTouchBegin(new TouchEvent(
			TouchEvent.TOUCH_BEGIN, 
			evt.bubbles, 
			evt.cancelable,
			evt.localX, 
			evt.localY,
			evt.relatedObject, 
			evt.ctrlKey, 
			evt.altKey, 
			evt.shiftKey, 
			evt.buttonDown, 
			evt.delta, 
			evt.commandKey, 
			evt.clickCount
		));
		#else
		onTouchBegin(new TouchEvent(
			TouchEvent.TOUCH_BEGIN,
			evt.bubbles, 
			evt.cancelable,
			0,
			true,
			evt.localX, 
			evt.localY, 
			1, 
			1,
			Math.NaN,
			evt.relatedObject, 
			evt.ctrlKey, 
			evt.altKey, 
			evt.shiftKey
		));
		#end
	}
	
	function onMouseMove(evt:MouseEvent):Void {
		#if cpp
		onTouchMove(new TouchEvent(
			TouchEvent.TOUCH_MOVE, 
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
		#elseif js
		onTouchMove(new TouchEvent(
			TouchEvent.TOUCH_MOVE, 
			evt.bubbles, 
			evt.cancelable,
			evt.localX, 
			evt.localY,
			evt.relatedObject, 
			evt.ctrlKey, 
			evt.altKey, 
			evt.shiftKey, 
			evt.buttonDown, 
			evt.delta, 
			evt.commandKey, 
			evt.clickCount
		));
		#else
		onTouchMove(new TouchEvent(
			TouchEvent.TOUCH_MOVE,
			evt.bubbles, 
			evt.cancelable,
			0,
			true,
			evt.localX, 
			evt.localY, 
			1, 
			1,
			Math.NaN,
			evt.relatedObject, 
			evt.ctrlKey, 
			evt.altKey, 
			evt.shiftKey
		));
		#end
	}
	
	function onMouseUp(evt:MouseEvent):Void {
		#if cpp
		onTouchEnd(new TouchEvent(
			TouchEvent.TOUCH_END, 
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
		#elseif js
		onTouchEnd(new TouchEvent(
			TouchEvent.TOUCH_END, 
			evt.bubbles, 
			evt.cancelable,
			evt.localX, 
			evt.localY,
			evt.relatedObject, 
			evt.ctrlKey, 
			evt.altKey, 
			evt.shiftKey, 
			evt.buttonDown, 
			evt.delta, 
			evt.commandKey, 
			evt.clickCount
		));
		#else
		onTouchEnd(new TouchEvent(
			TouchEvent.TOUCH_END,
			evt.bubbles, 
			evt.cancelable,
			0,
			true,
			evt.localX, 
			evt.localY, 
			1, 
			1,
			Math.NaN,
			evt.relatedObject, 
			evt.ctrlKey, 
			evt.altKey, 
			evt.shiftKey
		));
		#end
	}
}