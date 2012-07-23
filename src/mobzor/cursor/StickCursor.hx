package mobzor.cursor;

import nme.Lib;
import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.TouchEvent;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.system.Capabilities;
import nme.ui.Multitouch;

class StickCursor {
	public var bezelOut:Rectangle;
	public var bezelIn:Rectangle;
	public var view:DisplayObjectContainer;
	
	public var stick:Sprite;

	public function new():Void {
		view = Lib.current.stage;
		stick = new Sprite();
	}
	
	public function onResize(evt:Event = null):Void {
		bezelOut = new Rectangle(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		bezelIn = bezelOut.clone();
		
		var dpi = Capabilities.screenDPI;
		var bezelWidth = dpi * 0.1;
		bezelIn.inflate(-bezelWidth, -bezelWidth); 
	}
	
	public function start():Void {
		onResize();
		
		view.addChild(stick);
		
		if (Multitouch.supportsTouchEvents) {
			view.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			view.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			view.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		}
		view.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		view.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		view.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		
		view.addEventListener(Event.RESIZE, onResize);
	}
	
	public function end():Void {
		view.removeEventListener(Event.RESIZE, onResize);
		
		if (Multitouch.supportsTouchEvents) {
			view.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			view.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			view.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		}
		view.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		view.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		view.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		
		view.removeChild(stick);
	}
	
	var startPos:Point;
	var onBezel:Bool = false;
	
	function onTouchBegin(evt:TouchEvent):Void {
		
	}
	
	function onTouchMove(evt:TouchEvent):Void {
		
	}
	
	function onTouchEnd(evt:TouchEvent):Void {
		
	}
	
	function onMouseDown(evt:MouseEvent):Void {
		var pt = new Point(evt.stageX, evt.stageY);
		onBezel = bezelOut.containsPoint(pt) && !bezelIn.containsPoint(pt);
		
		if (onBezel) {
			startPos = pt;
		}
	}
	
	function onMouseMove(evt:MouseEvent):Void {
		if (onBezel) {
			var pt = new Point(evt.stageX, evt.stageY);
			
			stick.graphics.clear();
			stick.graphics.beginFill(0xFF0000);
			stick.graphics.lineStyle(2, 0xFF0000, 1);
			stick.graphics.moveTo(startPos.x, startPos.y);
			stick.graphics.lineTo(pt.x, pt.y);
		}
	}
	
	function onMouseUp(evt:MouseEvent):Void {
		onBezel = false;
		
		stick.graphics.clear();
	}
}
