package bezelcursor.cursor;

using Std;
import nme.Lib;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.PixelSnapping;
import nme.display.Sprite;
import nme.display.Stage;
import nme.display.LineScaleMode;
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
using com.eclecticdesignstudio.motion.Actuate;

import bezelcursor.cursor.behavior.DrawStick;
import bezelcursor.model.DeviceData;
import bezelcursor.model.TouchData;
import bezelcursor.model.IStruct;
import bezelcursor.model.InputMethod;
import bezelcursor.entity.Target;
import bezelcursor.entity.StartButton;
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
	
	@skip public var onStartSignaler(default, null):Signaler<Point>;
	@skip public var onMoveSignaler(default, null):Signaler<Point>;
	@skip public var onClickSignaler(default, null):Signaler<Point>;
	@skip public var onEndSignaler(default, null):Signaler<Point>;
	
	/**
	* Basically Lib.stage.
	*/
	@skip public var stage(default, null):Stage;
	
	function set_cursorsEnabled(v:Bool):Bool {
		if (!v) {
			thumbSpaceEnabled = false;
		}
		return cursorsEnabled = v;
	}
	
	function set_thumbSpaceEnabled(v:Bool):Bool {
		
		if (v) {
			thumbSpaceViewDraw();
			thumbSpaceView.tween(0.25, { alpha: 1.0 }).autoVisible(true);
		} else {
			thumbSpaceView.tween(0.25, { alpha: 0.0 }).autoVisible(true);
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
	
	/**
	* Cursor id as key
	*/
	var cursors:IntHash<Cursor>;
	
	/**
	* touchPointId as key
	*/
	var pointActivatedCursors:IntHash<PointActivatedCursor>;
	
	public function new():Void {
		thumbSpace = new Rectangle(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
		thumbSpaceConfigState = NotConfigured;
		
		bezelWidth = 0.15;
		
		cursors = new IntHash<Cursor>();
		pointActivatedCursors = new IntHash<PointActivatedCursor>();
		
		init();
		
		inputMethod = InputMethod.DirectTouch;
	}
	
	public function init():CursorManager {
		stage = Lib.stage;
		
		onStartSignaler = new DirectSignaler<Point>(this);
		onMoveSignaler = new DirectSignaler<Point>(this);
		onClickSignaler = new DirectSignaler<Point>(this);
		onEndSignaler = new DirectSignaler<Point>(this);
		
		thumbSpaceViewBitmap = new Bitmap(HXP.buffer, PixelSnapping.NEVER, true);//new Sprite();
		thumbSpaceViewBitmap.alpha = 0.9;
		//thumbSpaceViewBitmap.filters = [new nme.filters.DropShadowFilter(0, 0, 0, 0.8, 0.05 * DeviceData.current.screenDPI, 0.05 * DeviceData.current.screenDPI)];
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
		
		if (!cursorsEnabled) return;
		
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
		
		var cursor = (switch (createFor) {
			case ForBezel:
				Type.createInstance(inputMethod.forBezel._class, []).fromObj(inputMethod.forBezel.data);
			case ForThumbSpace:
				Type.createInstance(inputMethod.forThumbSpace._class, []).fromObj(inputMethod.forThumbSpace.data);
			case ForScreen:
				Type.createInstance(inputMethod.forScreen._class, []).fromObj(inputMethod.forScreen.data);
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
				cursor.onEndSignaler.bindVoid(function(){
					if (!cursorsEnabled) return;
					var startBtn:StartButton = HXP.world.classFirst(StartButton);
					if (startBtn != null) {
						startBtn.visible = true;
					}
				}).destroyOnUse();
		}
		
		cursor.onStartSignaler.addBubblingTarget(onStartSignaler);
		cursor.onMoveSignaler.addBubblingTarget(onMoveSignaler);
		cursor.onClickSignaler.addBubblingTarget(onClickSignaler);
		cursor.onEndSignaler.addBubblingTarget(onEndSignaler);
		
		cursor.onEndSignaler.bindAdvanced(function(signal:Signal<Point>):Void {
			var cursor:Cursor = cast signal.origin;
				
			cursor.onStartSignaler.removeBubblingTarget(onStartSignaler);
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
		
		if (pointActivatedCursors.exists(touch.touchPointID)) {
			var cursor = pointActivatedCursors.get(touch.touchPointID);
			cursor.onTouchMove(touch);
		}
	}
	
	function onEnd(touch:TouchData):Void {
		switch (thumbSpaceConfigState) {
			case Configuring:
				if (thumbSpace.width < DeviceData.current.screenDPI * 0.4) {
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