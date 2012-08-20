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
import com.haxepunk.HXP;
using org.casalib.util.NumberUtil;

class StickCursor extends Cursor {
	public var bezelOut:Rectangle;
	public var bezelIn:Rectangle;
	public var view:DisplayObjectContainer;
	
	public var stick:Sprite;

	public function new():Void {
		super();
		
		view = Lib.current.stage;
		stick = new Sprite();
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
	
	var startPos:Point;
	var lastPos:Point;
	var targetPos:Point;
	var onBezel:Bool = false;
	
	function onFrame(evt:Event = null):Void {
		if (onBezel) {
			var pt = targetPos.subtract(lastPos);
			pt.normalize(pt.length * HXP.frameRate.map(0, 30, 1, 0.78));
			pt = lastPos.add(pt);
			stick.graphics.clear();
			stick.graphics.lineStyle(2, 0xFF0000, 1);
			stick.graphics.moveTo(startPos.x, startPos.y);
			stick.graphics.lineTo(pt.x, pt.y);
			stick.graphics.drawCircle(pt.x, pt.y, Capabilities.screenDPI * 0.08);
			
			onMoveSignaler.dispatch(lastPos = pt);
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
		
		startPos = lastPos = targetPos = pt;
	}
	
	function onMouseMove(evt:MouseEvent):Void {
		if (onBezel) {
			targetPos = getStickEnd(startPos, new Point(evt.stageX, evt.stageY));
		}
	}
	
	function onMouseUp(evt:MouseEvent):Void {
		var pt = new Point(evt.stageX, evt.stageY);
		if (onBezel) {
			onClickSignaler.dispatch(getStickEnd(startPos, pt));
		} else {
			onClickSignaler.dispatch(pt);
		}
	
		onBezel = false;
		
		stick.graphics.clear();
	}
	
	static public function getStickEnd(down:Point, up:Point):Point {
		var v = up.subtract(down);
		v.normalize(v.length * 3);
		return down.add(v);
	}
}
