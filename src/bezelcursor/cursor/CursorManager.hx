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

import bezelcursor.model.DeviceInfo;
import bezelcursor.model.TouchData;

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
	
	static public var defaultCreateCursor = function(touch:TouchData, _for:CreateCursorFor):Cursor {
		switch(_for) {
			case ForBezel: 
				return new bezelcursor.cursor.MouseCursor(touch.touchPointID);
			case ForScreen:
				return new bezelcursor.cursor.MagStickCursor(touch.touchPointID);
		}
	}
	
	public var createCursor:TouchData->CreateCursorFor->Cursor;
	
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
		createCursor = defaultCreateCursor;
		
		onActivateSignaler = new DirectSignaler<Point>(this);
		onMoveSignaler = new DirectSignaler<Point>(this);
		onClickSignaler = new DirectSignaler<Point>(this);
		onEndSignaler = new DirectSignaler<Void>(this);
		
		pointActivatedCursors = new IntHash<PointActivatedCursor>();
	}
	
	public function onResize(evt:Event = null):Void {
		bezelOut = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		bezelIn = bezelOut.clone();
		
		var bezelWidthPx = DeviceInfo.current.screenDPI * bezelWidth;
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
	
	function insideBezel(touch:TouchData):Bool {
		var pt = new Point(touch.x, touch.y);
		return bezelOut.containsPoint(pt) && !bezelIn.containsPoint(pt);
	}
	
	function addCursor(touch:TouchData, cursor:Cursor):Void {
		if (cursor.is(PointActivatedCursor)) {
			var pCursor = cast(cursor,PointActivatedCursor);
			pointActivatedCursors.set(pCursor.touchPointID, pCursor);
		}
			
		cursor.start();
		cursor.onTouchBegin(touch);
		
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
		
		trace(cursor.getConfig());
	}
	
	function onTouchBegin(evt:TouchEvent):Void {
		var touchData = TouchData.fromTouchEvent(evt);
		if (bezelCursorEnabled && insideBezel(touchData)) {
			addCursor(touchData, createCursor(touchData, ForBezel));
		} else if (screenCursorEnabled) {
			addCursor(touchData, createCursor(touchData, ForScreen));
		}
	}
	
	function onTouchMove(evt:TouchEvent):Void {
		var touchData = TouchData.fromTouchEvent(evt);
		if (pointActivatedCursors.exists(touchData.touchPointID)) {
			var cursor = pointActivatedCursors.get(touchData.touchPointID);
			cursor.onTouchMove(touchData);
		}
	}
	
	function onTouchEnd(evt:TouchEvent):Void {
		var touchData = TouchData.fromTouchEvent(evt);
		if (pointActivatedCursors.exists(touchData.touchPointID)) {
			var cursor = pointActivatedCursors.get(touchData.touchPointID);
			cursor.onTouchEnd(touchData);
		} else if (tapEnabled) {
			onClickSignaler.dispatch(new Point(touchData.x, touchData.y));
		}
	}
	
	function onMouseDown(evt:MouseEvent):Void {
		var touchData = TouchData.fromMouseEvent(evt);
		if (bezelCursorEnabled && insideBezel(touchData)) {
			addCursor(touchData, createCursor(touchData, ForBezel));
		} else if (screenCursorEnabled) {
			addCursor(touchData, createCursor(touchData, ForScreen));
		}
	}
	
	function onMouseMove(evt:MouseEvent):Void {
		var touchData = TouchData.fromMouseEvent(evt);
		if (pointActivatedCursors.exists(touchData.touchPointID)) {
			var cursor = pointActivatedCursors.get(touchData.touchPointID);
			cursor.onTouchMove(touchData);
		}
	}
	
	function onMouseUp(evt:MouseEvent):Void {
		var touchData = TouchData.fromMouseEvent(evt);
		if (pointActivatedCursors.exists(touchData.touchPointID)) {
			var cursor = pointActivatedCursors.get(touchData.touchPointID);
			cursor.onTouchEnd(touchData);
		} else if (tapEnabled) {
			onClickSignaler.dispatch(new Point(touchData.x, touchData.y));
		}
	}
}