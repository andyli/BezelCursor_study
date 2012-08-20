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
import nme.ui.MultitouchInputMode;
using org.casalib.util.NumberUtil;
import com.haxepunk.HXP;

class MouseCursor extends Cursor {
	public var bezelOut:Rectangle;
	public var bezelIn:Rectangle;
	public var view:DisplayObjectContainer;
	
	public var stick:Sprite;

	public function new():Void {
		super();
		
		view = Lib.current.stage;
		stick = new Sprite();
		velocity = new Point();
	}
	
	public function onResize(evt:Event = null):Void {
		bezelOut = new Rectangle(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		bezelIn = bezelOut.clone();
		
		var bezelWidth = Capabilities.screenDPI * 0.1;
		bezelIn.inflate(-bezelWidth, -bezelWidth); 
	}
	
	override public function start():Void {
		super.start();
		
		onResize();
		
		view.addChild(stick);
		
		if (Multitouch.supportsTouchEvents) {
			view.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			view.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			view.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			
			//trace(Multitouch.inputMode);
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		}
		view.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		view.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		view.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		
		view.addEventListener(Event.RESIZE, onResize);
		view.addEventListener(Event.ENTER_FRAME, onFrame);
	}
	
	override public function end():Void {
		view.removeEventListener(Event.RESIZE, onResize);
		view.removeEventListener(Event.ENTER_FRAME, onFrame);
		
		if (Multitouch.supportsTouchEvents) {
			view.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			view.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			view.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		}
		view.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		view.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		view.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		
		view.removeChild(stick);
		
		super.end();
	}
	
	var startDownPos:Point;
	var lastDownPos:Point;
	var targetPos:Point;
	var onBezel:Bool = false;
	var velocity:Point;
	
	function onFrame(evt:Event = null):Void {
		if (onBezel) {
			var velocity = lastDownPos.subtract(startDownPos);
			var l = velocity.length;
			velocity.normalize(
				l
				* l.map(Capabilities.screenDPI * 0.01, Capabilities.screenDPI * 0.05, 1, 3).constrain(1, 3)
				* HXP.frameRate.map(0, 30, 1, 0.75)
			);
			targetPos = targetPos.add(velocity);
			var pt = targetPos;
			stick.graphics.clear();
			stick.graphics.lineStyle(2, 0xFF0000, 1);
			stick.graphics.drawCircle(pt.x, pt.y, Capabilities.screenDPI * 0.001);
			stick.graphics.drawCircle(pt.x, pt.y, Capabilities.screenDPI * 0.08);
			
			onMoveSignaler.dispatch(targetPos);
			
			startDownPos = lastDownPos;
		}
	}
	
	function onTouchBegin(evt:TouchEvent):Void {
		
	}
	
	function onTouchMove(evt:TouchEvent):Void {
		//trace(evt.sizeX + " " + evt.sizeY);
	}
	
	function onTouchEnd(evt:TouchEvent):Void {
		
	}
	
	function onMouseDown(evt:MouseEvent):Void {
		var pt = new Point(evt.stageX, evt.stageY);
		onBezel = bezelOut.containsPoint(pt) && !bezelIn.containsPoint(pt);
		
		startDownPos = lastDownPos = targetPos = pt;
	}
	
	function onMouseMove(evt:MouseEvent):Void {
		if (onBezel) {
			lastDownPos = new Point(evt.stageX, evt.stageY);
		}
	}
	
	function onMouseUp(evt:MouseEvent):Void {
		if (onBezel) {
			onClickSignaler.dispatch(targetPos);
		} else {
			onClickSignaler.dispatch(new Point(evt.stageX, evt.stageY));
		}
	
		onBezel = false;
		
		stick.graphics.clear();
	}
}
