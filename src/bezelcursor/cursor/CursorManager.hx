package bezelcursor.cursor;

using Std;
import nme.Lib;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.PixelSnapping;
import nme.display.Sprite;
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
using org.casalib.util.NumberUtil;
using org.casalib.util.RatioUtil;
import com.haxepunk.HXP;

import bezelcursor.cursor.behavior.DrawStick;
import bezelcursor.model.DeviceData;
import bezelcursor.model.TouchData;

enum CreateCursorFor {
	ForBezel;
	ForScreen;
	ForThumbSpace;
}

enum ConfigState {
	NotConfigured;
	Configuring;
	Configured;
}

class CursorManager {
	static public var defaultCreateCursor(default, null) = function(touch:TouchData, _for:CreateCursorFor):Cursor {
		switch(_for) {
			case ForBezel: 
				return new bezelcursor.cursor.MouseCursor({touchPointID: touch.touchPointID});
			case ForScreen:
				return new bezelcursor.cursor.MagStickCursor({touchPointID: touch.touchPointID});
			case ForThumbSpace:
				return new bezelcursor.cursor.MouseCursor({touchPointID: touch.touchPointID});
		}
	}
	
	public var tapEnabled(default, null):Bool;
	public var bezelCursorEnabled(default, null):Bool;
	public var screenCursorEnabled(default, null):Bool;
	public var thumbSpaceEnabled(default, set_thumbSpaceEnabled):Bool;

	/**
	* Width in inches to be considered as bezel.
	*/
	public var bezelWidth(default, null):Float = 0.15;
	var bezelOut:Rectangle;
	var bezelIn:Rectangle;
	
	public var thumbSpace(default, null):Rectangle;
	public var thumbSpaceView(default, null):Bitmap;
	public var thumbSpaceConfigState(default, null):ConfigState;
	
	public var createCursor:TouchData->CreateCursorFor->Cursor;
	
	public var onActivateSignaler(default, null):Signaler<Point>;
	public var onMoveSignaler(default, null):Signaler<Point>;
	public var onClickSignaler(default, null):Signaler<Point>;
	public var onEndSignaler(default, null):Signaler<Void>;
	
	/**
	* Basically Lib.stage.
	*/
	public var stage(default, null):Stage;
	
	function set_thumbSpaceEnabled(v:Bool):Bool {
		if (thumbSpaceEnabled == v) return v;
		
		if (v) {
			thumbSpaceViewDraw();
		}
		
		return thumbSpaceView.visible = thumbSpaceEnabled = v;
	}
	
	function thumbSpaceViewDraw():Void {
		var thumbSpace = thumbSpace.clone();
		
		if (thumbSpace.top > thumbSpace.bottom) {
			var top = thumbSpace.bottom;
			thumbSpace.bottom = thumbSpace.top;
			thumbSpace.top = top;
		}
		if (thumbSpace.left > thumbSpace.right) {
			var left = thumbSpace.right;
			thumbSpace.right = thumbSpace.left;
			thumbSpace.left = left;
		}
		
		thumbSpaceView.x = thumbSpace.x;
		thumbSpaceView.y = thumbSpace.y;
		thumbSpaceView.width = thumbSpace.width;
		thumbSpaceView.height = thumbSpace.height;
		/*
		thumbSpaceView.graphics.clear();
		thumbSpaceView.graphics.beginFill(0xFFFFFF, 0.1);
		thumbSpaceView.graphics.drawRect(thumbSpace.x, thumbSpace.y, thumbSpace.width, thumbSpace.height);
		*/
	}
	
	/**
	* Cursor id as key
	*/
	var cursors:IntHash<Cursor>;
	
	/**
	* touchPointId as key
	*/
	var pointActivatedCursors:IntHash<PointActivatedCursor>;
	
	public function new():Void {
		stage = Lib.stage;
		thumbSpace = new Rectangle(Math.NEGATIVE_INFINITY);
		thumbSpaceView = new Bitmap(HXP.buffer, PixelSnapping.ALWAYS, true);//new Sprite();
		thumbSpaceView.alpha = 0.9;
		//thumbSpaceView.filters = [new nme.filters.DropShadowFilter(0, 0, 0, 0.8, 0.05 * DeviceData.current.screenDPI, 0.05 * DeviceData.current.screenDPI)];
		thumbSpaceConfigState = NotConfigured;
		tapEnabled = true;
		bezelCursorEnabled = true;
		screenCursorEnabled = true;
		thumbSpaceEnabled = true;
		createCursor = defaultCreateCursor;
		
		onActivateSignaler = new DirectSignaler<Point>(this);
		onMoveSignaler = new DirectSignaler<Point>(this);
		onClickSignaler = new DirectSignaler<Point>(this);
		onEndSignaler = new DirectSignaler<Void>(this);
		
		cursors = new IntHash<Cursor>();
		pointActivatedCursors = new IntHash<PointActivatedCursor>();
		
	}
	
	public function onResize(evt:Event = null):Void {
		bezelOut = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		bezelIn = bezelOut.clone();
		
		var bezelWidthPx = DeviceData.current.screenDPI * bezelWidth;
		bezelIn.inflate(-bezelWidthPx, -bezelWidthPx); 
	}
	
	public function start():Void {
		onResize();
		stage.addChild(thumbSpaceView);
		
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
		
		stage.addEventListener(Event.ENTER_FRAME, onFrame);
		stage.addEventListener(Event.RESIZE, onResize);
	}
	
	public function end():Void {
		stage.removeEventListener(Event.ENTER_FRAME, onFrame);
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
		stage.removeChild(thumbSpaceView);
	}
	
	public function startThumbSpaceConfig():Void {
		thumbSpaceConfigState = Configuring;
		thumbSpace.x = Math.NEGATIVE_INFINITY;
	}
	
	public function endThumbSpaceConfig():Void {
		thumbSpaceConfigState = Configured;
		
		if (thumbSpace.top > thumbSpace.bottom) {
			var top = thumbSpace.bottom;
			thumbSpace.bottom = thumbSpace.top;
			thumbSpace.top = top;
		}
		if (thumbSpace.left > thumbSpace.right) {
			var left = thumbSpace.right;
			thumbSpace.right = thumbSpace.left;
			thumbSpace.left = left;
		}
		
		thumbSpaceViewDraw();
	}
	
	function onFrame(evt:Event):Void {		
		var timestamp = haxe.Timer.stamp();
		for (cursor in cursors) {
			cursor.onFrame(timestamp);
		}
	}
	
	function insideBezel(touch:TouchData):Bool {
		var pt = new Point(touch.x, touch.y);
		return bezelOut.containsPoint(pt) && !bezelIn.containsPoint(pt);
	}
	
	function insideThumbSpace(touch:TouchData):Bool {
		var pt = new Point(touch.x, touch.y);
		return thumbSpace.containsPoint(pt);
	}
	
	function onBegin(touch:TouchData):Void {
		switch (thumbSpaceConfigState) {
			case Configuring:
				thumbSpace.x = touch.x;
				thumbSpace.y = touch.y;
				return;
			default:
		}
		
		var createFor = (bezelCursorEnabled && insideBezel(touch)) ? ForBezel : (thumbSpaceEnabled && insideThumbSpace(touch)) ? ForThumbSpace : ForScreen;
		var cursor = createCursor(touch, createFor);
		
		if (cursor == null) return;
		
		//tests:
		//cursor = Cursor.createFromData(cursor.getData());
		//cursor = cursor.clone();
		//trace(haxe.Json.stringify(cursor));
		
		cursors.set(cursor.id, cursor);
		if (cursor.is(PointActivatedCursor)) {
			var pCursor = cast(cursor,PointActivatedCursor);
			pointActivatedCursors.set(pCursor.touchPointID, pCursor);
		}
			
		cursor.start();
		cursor.onTouchBegin(touch);
		switch (createFor){
			case ForBezel:
				if(cursor.is(PointActivatedCursor))
					cursor.behaviors.push(new DrawStick(untyped cursor));
			case ForScreen:
				
			case ForThumbSpace:
				cursor.position = new Point(
					touch.x.map(thumbSpace.left, thumbSpace.right, 0, stage.stageWidth),
					touch.y.map(thumbSpace.top, thumbSpace.bottom, 0, stage.stageHeight)
				);
				thumbSpaceEnabled = false;
		}
		
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
			
			cursors.remove(cursor.id);
			if (cursor.is(PointActivatedCursor))
				pointActivatedCursors.remove(untyped cursor.touchPointID);
		}).destroyOnUse();
	}
	
	function onMove(touch:TouchData):Void {
		switch (thumbSpaceConfigState) {
			case Configuring:
				if (thumbSpace.x != Math.NEGATIVE_INFINITY) {
					var bound = new Rectangle(thumbSpace.x, thumbSpace.y);
					bound.right = touch.x;
					bound.bottom = touch.y;
					
					var flipX = bound.left > bound.right;
					var flipY = bound.top > bound.bottom;
					
					if (flipX) bound.width *= -1;
					if (flipY) bound.height *= -1;
					
					thumbSpace = new Rectangle(
						thumbSpace.x, 
						thumbSpace.y, 
						stage.stageWidth, 
						stage.stageHeight
					).scaleToFill(bound, false);
					
					if (flipX) thumbSpace.width *= -1;
					if (flipY) thumbSpace.height *= -1;
					
					thumbSpaceViewDraw();
					return;
				}
			default:
		}
		
		if (pointActivatedCursors.exists(touch.touchPointID)) {
			var cursor = pointActivatedCursors.get(touch.touchPointID);
			cursor.onTouchMove(touch);
		}
	}
	
	function onEnd(touch:TouchData):Void {
		switch (thumbSpaceConfigState) {
			case Configuring:
				endThumbSpaceConfig();
				return;
			default:
		}
		
		if (pointActivatedCursors.exists(touch.touchPointID)) {
			var cursor = pointActivatedCursors.get(touch.touchPointID);
			cursor.onTouchEnd(touch);
		} else if (tapEnabled) {
			onClickSignaler.dispatch(new Point(touch.x, touch.y));
		}
	}
	
	function onTouchBegin(evt:TouchEvent):Void {
		onBegin(TouchData.fromTouchEvent(evt));
	}
	
	function onTouchMove(evt:TouchEvent):Void {
		onMove(TouchData.fromTouchEvent(evt));
	}
	
	function onTouchEnd(evt:TouchEvent):Void {
		onEnd(TouchData.fromTouchEvent(evt));
	}
	
	function onMouseDown(evt:MouseEvent):Void {
		onBegin(TouchData.fromMouseEvent(evt));
	}
	
	function onMouseMove(evt:MouseEvent):Void {
		onMove(TouchData.fromMouseEvent(evt));
	}
	
	function onMouseUp(evt:MouseEvent):Void {
		onEnd(TouchData.fromMouseEvent(evt));
	}
}