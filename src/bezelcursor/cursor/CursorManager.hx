package bezelcursor.cursor;

using Std;
using Lambda;
import flash.Lib;
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.system.Capabilities;
import flash.ui.*;
import hsl.haxe.*;
using org.casalib.util.NumberUtil;
using org.casalib.util.RatioUtil;
import com.haxepunk.HXP;
using motion.Actuate;

import bezelcursor.cursor.behavior.*;
import bezelcursor.model.*;
import bezelcursor.entity.*;
import bezelcursor.world.*;
using bezelcursor.world.GameWorld;
using bezelcursor.util.RectangleUtil;

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

class CursorManager implements IStruct {
	public var inputMethod(default, set_inputMethod):InputMethod;
	function set_inputMethod(v:InputMethod):InputMethod {
		if (v.forThumbSpace == null) thumbSpaceEnabled = false;
		
		return inputMethod = v;
	}
	
	dynamic public function isValidStart(touch:TouchData):Bool {
		return true;
	}
	
	public var cursorsEnabled(default, set_cursorsEnabled):Bool;
	public var thumbSpaceEnabled(default, set_thumbSpaceEnabled):Bool;

	/**
	* Width in inches to be considered as bezel.
	*/
	public var bezelWidth(default, null):Float;
	var bezelOut:Rectangle;
	var bezelIn:Rectangle;
	
	public var thumbSpace(default, null):Rectangle;
	@skip public var thumbSpaceView(default, null):Sprite;
	@skip public var thumbSpaceViewBitmap(default, null):Bitmap;
	@skip public var thumbSpaceConfigState(default, null):ConfigState;
	
	@skip public var onStartSignaler(default, null):Signaler<Void>;
	@skip public var onMoveSignaler(default, null):Signaler<Target>;
	@skip public var onClickSignaler(default, null):Signaler<Target>;
	@skip public var onEndSignaler(default, null):Signaler<Void>;
	
	@skip public var onTouchStartSignaler(default, null):Signaler<TouchData>;
	@skip public var onTouchMoveSignaler(default, null):Signaler<TouchData>;
	@skip public var onTouchEndSignaler(default, null):Signaler<TouchData>;
	
	/**
	* Basically Lib.stage.
	*/
	@skip public var stage(default, null):Stage;
	
	function set_cursorsEnabled(v:Bool):Bool {
		if (!v) {
			thumbSpaceEnabled = false;
			if (cursors != null) {
				for (cursor in cursors.array()) {
					cursor.end();
				}
			}
		}
		return cursorsEnabled = v;
	}
	
	function set_thumbSpaceEnabled(v:Bool):Bool {
		
		if (thumbSpaceView != null) {
			if (v) {
				thumbSpaceViewDraw();
				thumbSpaceView.tween(0.25, { alpha: 1.0 }).autoVisible(true);
				Lib.stage.addEventListener(Event.ENTER_FRAME, thumbSpaceViewOnFrame);
			} else {
				thumbSpaceView.tween(0.25, { alpha: 0.0 }).autoVisible(true);
				Lib.stage.removeEventListener(Event.ENTER_FRAME, thumbSpaceViewOnFrame);
			}
		}
		
		return thumbSpaceEnabled = v;
	}
	
	function thumbSpaceViewDraw():Void {
		var thumbSpace = thumbSpace.normalize();

		thumbSpaceViewBitmap.x = thumbSpace.x;
		thumbSpaceViewBitmap.y = thumbSpace.y;
		thumbSpaceViewBitmap.width = thumbSpace.width;
		thumbSpaceViewBitmap.height = thumbSpace.height;
		
		thumbSpaceView.graphics.clear();
		thumbSpaceView.graphics.lineStyle(1, 0x000000, 1, true, LineScaleMode.NONE);
		thumbSpaceView.graphics.drawRect(thumbSpace.x, thumbSpace.y, thumbSpace.width, thumbSpace.height);
		thumbSpaceView.graphics.lineStyle(1, 0xFFFFFF, 1, true, LineScaleMode.NONE);
		thumbSpaceView.graphics.drawRect(thumbSpace.x - 1, thumbSpace.y - 1, thumbSpace.width + 2, thumbSpace.height + 2);
	}

	function thumbSpaceViewOnFrame(evt):Void {
		thumbSpaceView.visible = false;
		thumbSpaceViewBitmap.bitmapData.lock();
		thumbSpaceViewBitmap.bitmapData.fillRect(thumbSpaceViewBitmap.bitmapData.rect, 0x333333);
		thumbSpaceViewBitmap.bitmapData.draw(Lib.current);
		thumbSpaceViewBitmap.bitmapData.unlock();
		thumbSpaceView.visible = true;
	}
	
	/**
	* Cursor id as key
	*/
	var cursors:Map<Int,Cursor>;
	
	/**
	* touchPointId as key
	*/
	var pointActivatedCursors:Map<Int,PointActivatedCursor>;
	
	@skip var touchFilters:Map<Int,{x:OneEuroFilter, y:OneEuroFilter, next:TouchData}>;
	
	public function new():Void {
		thumbSpace = new Rectangle(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
		thumbSpaceConfigState = NotConfigured;
		
		bezelWidth = 0.15;
		
		cursors = new Map();
		pointActivatedCursors = new Map();
		touchFilters = new Map();
		
		init();
		
		inputMethod = InputMethod.DirectTouch;
	}
	
	public function init():CursorManager {
		stage = Lib.stage;
		
		onStartSignaler = new DirectSignaler<Void>(this);
		onMoveSignaler = new DirectSignaler<Target>(this);
		onClickSignaler = new DirectSignaler<Target>(this);
		onEndSignaler = new DirectSignaler<Void>(this);
		
		onTouchStartSignaler = new DirectSignaler<TouchData>(this);
		onTouchMoveSignaler = new DirectSignaler<TouchData>(this);
		onTouchEndSignaler = new DirectSignaler<TouchData>(this);
		
		var bd = new BitmapData(Lib.stage.stageWidth, Lib.stage.stageHeight, false);
		thumbSpaceViewBitmap = new Bitmap(bd, PixelSnapping.NEVER, true);//new Sprite();
		thumbSpaceViewBitmap.alpha = 0.9;
		//thumbSpaceViewBitmap.filters = [new flash.filters.DropShadowFilter(0, 0, 0, 0.8, 0.05 * DeviceData.current.screenDPI, 0.05 * DeviceData.current.screenDPI)];
		thumbSpaceView = new Sprite();
		thumbSpaceView.addChild(thumbSpaceViewBitmap);
		
		return this;
	}
	
	public function onResize(evt:Event = null):Void {
		bezelOut = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		bezelIn = bezelOut.clone();
		
		var bezelWidthPx = DeviceData.current.screenDPI * bezelWidth;
		bezelIn.inflate(-bezelWidthPx, -bezelWidthPx); 
	}
	
	public function start():Void {
		cursorsEnabled = true;
		
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
	}
	
	public function startThumbSpaceConfig():Void {
		thumbSpaceConfigState = Configuring;
		thumbSpace.x = Math.NEGATIVE_INFINITY;
		thumbSpace.y = Math.NEGATIVE_INFINITY;
		thumbSpace.width = 0;
		thumbSpace.height = 0;
		thumbSpaceViewDraw();
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
		
		for (filters in touchFilters) {
			var touch = filters.next.clone();
			touch.x = filters.x.filter(touch.x, timestamp);
			touch.y = filters.y.filter(touch.y, timestamp);
		
			if (pointActivatedCursors.exists(touch.touchPointID)) {
				var cursor = pointActivatedCursors.get(touch.touchPointID);
				cursor.onTouchMove(touch);
			}
		}
		
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
		var time = haxe.Timer.stamp();
		onTouchStartSignaler.dispatch(touch);
		
		var filters = {
			x: new OneEuroFilter(Lib.stage.frameRate, 1, 0.2),
			y: new OneEuroFilter(Lib.stage.frameRate, 1, 0.2),
			next: touch
		};
		touchFilters.set(touch.touchPointID, filters);
		
		touch.x = filters.x.filter(touch.x, time);
		touch.y = filters.y.filter(touch.y, time);
		
		
		switch (thumbSpaceConfigState) {
			case Configuring:
				thumbSpace.x = touch.x;
				thumbSpace.y = touch.y;
				return;
			default:
		}
		
		if (!cursorsEnabled) return;
		
		if (!isValidStart(touch)) return;
		
		var createFor = if (inputMethod.forBezel != null && insideBezel(touch)) {
			ForBezel;
		} else if (thumbSpaceEnabled && inputMethod.forThumbSpace != null && insideThumbSpace(touch)) {
			ForThumbSpace;
		} else if (inputMethod.forScreen != null) {
			ForScreen;
		} else {
			null;
		}
		
		if (createFor == null) return;
		
		var cursor:Cursor = (switch (createFor) {
			case ForBezel:
				Type.createInstance(Type.resolveClass(inputMethod.forBezel._class), []).fromObj(inputMethod.forBezel.data);
			case ForThumbSpace:
				Type.createInstance(Type.resolveClass(inputMethod.forThumbSpace._class), []).fromObj(inputMethod.forThumbSpace.data);
			case ForScreen:
				Type.createInstance(Type.resolveClass(inputMethod.forScreen._class), []).fromObj(inputMethod.forScreen.data);
		}).fromObj({touchPointID: touch.touchPointID});
		
		//tests:
		//cursor = Cursor.createFromData(cursor.getData());
		//cursor = cursor.clone();
		//trace(haxe.Json.stringify(cursor));
		
		cursors.set(cursor.id, cursor);
		if (cursor.is(PointActivatedCursor)) {
			var pCursor = cast(cursor,PointActivatedCursor);
			pointActivatedCursors.set(pCursor.touchPointID, pCursor);
		}
		
		cursor.onStartSignaler.addBubblingTarget(onStartSignaler);
		cursor.onMoveSignaler.addBubblingTarget(onMoveSignaler);
		cursor.onClickSignaler.addBubblingTarget(onClickSignaler);
		cursor.onEndSignaler.addBubblingTarget(onEndSignaler);
		
		cursor.onEndSignaler.bindAdvanced(function(signal:Signal<Void>):Void {
			var cursor:Cursor = cast signal.origin;
				
			cursor.onStartSignaler.removeBubblingTarget(onStartSignaler);
			cursor.onMoveSignaler.removeBubblingTarget(onMoveSignaler);
			cursor.onClickSignaler.removeBubblingTarget(onClickSignaler);
			cursor.onEndSignaler.removeBubblingTarget(onEndSignaler);
			
			cursors.remove(cursor.id);
			if (cursor.is(PointActivatedCursor))
				pointActivatedCursors.remove(untyped cursor.touchPointID);
		}).destroyOnUse();
			
		cursor.start();
		cursor.onTouchBegin(touch);
		switch (createFor){
			case ForBezel:
				if(cursor.is(PointActivatedCursor))
					cursor.behaviors.push(new DrawStick(untyped cursor));
			case ForScreen:
				
			case ForThumbSpace:
				cursor.setImmediatePosition(new Point(
					touch.x.map(thumbSpace.left, thumbSpace.right, 0, stage.stageWidth),
					touch.y.map(thumbSpace.top, thumbSpace.bottom, 0, stage.stageHeight)
				));
				thumbSpaceEnabled = false;
				cursor.onEndSignaler.bindVoid(function(){
					if (!cursorsEnabled) return;
					
					if (HXP.world.is(TestTouchWorld)) {
						cast(HXP.world, TestTouchWorld).startBtn.visible = true;
					}
				}).destroyOnUse();
		}
	}
	
	function onMove(touch:TouchData):Void {
		var time = haxe.Timer.stamp();
		onTouchMoveSignaler.dispatch(touch);
		
		var filters = touchFilters.get(touch.touchPointID);
		if (filters != null) {
			filters.next = touch;
		}
		
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
					
					var normalized = thumbSpace.normalize();
					if (!HXP.bounds.containsRect(normalized)) {
						var constrainted = normalized.scaleToFit(normalized.intersection(HXP.bounds));
						
						thumbSpace.width = constrainted.width;
						thumbSpace.height = constrainted.height;
					
						if (flipX) thumbSpace.width *= -1;
						if (flipY) thumbSpace.height *= -1;
					}
					
					thumbSpaceViewDraw();
					return;
				}
			default:
		}
	}
	
	function onEnd(touch:TouchData):Void {
		onTouchEndSignaler.dispatch(touch);
		
		switch (thumbSpaceConfigState) {
			case Configuring:
				if (Math.abs(thumbSpace.width) < DeviceData.current.screenDPI * 0.4) {
					startThumbSpaceConfig();
				} else {
					endThumbSpaceConfig();
				}
				return;
			default:
		}
		
		if (pointActivatedCursors.exists(touch.touchPointID)) {
			var cursor = pointActivatedCursors.get(touch.touchPointID);
			cursor.onTouchEnd(touch);
		}
		
		touchFilters.remove(touch.touchPointID);
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