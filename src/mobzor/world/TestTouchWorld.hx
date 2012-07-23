package mobzor.world;

import com.haxepunk.HXP;
import com.haxepunk.World;
import nme.events.TouchEvent;
import nme.system.Capabilities;
import nme.ui.Multitouch;
import nme.display.Sprite;

import mobzor.cursor.StickCursor;

class TestTouchWorld extends World {
	var ruler:Sprite;
	var cursor:StickCursor;

	override public function begin():Void {
		super.begin();
		trace("supportsTouchEvents:" + Multitouch.supportsTouchEvents);
		
		var dpi = Capabilities.screenDPI;
		ruler = new Sprite();
		ruler.graphics.beginFill(0xFFFFFF);
		ruler.graphics.lineStyle(1, 0x000000, 1);
		var x = 0.0;
		while (x < HXP.stage.stageWidth) {
			ruler.graphics.moveTo(x, 0);
			ruler.graphics.lineTo(x, 100);
			x += dpi;
		}
		ruler.graphics.endFill();
		
		HXP.stage.addChild(ruler);
		
		cursor = new StickCursor();
		cursor.start();
		
		HXP.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
		HXP.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		HXP.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
	}
	
	override public function end():Void {
		HXP.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
		HXP.stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		HXP.stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		
		cursor.end();
		
		HXP.stage.removeChild(ruler);
		
		super.end();
	}
	
	function onTouchBegin(evt:TouchEvent):Void {
		trace("TouchBegin: " + evt.sizeX);
	}
	
	function onTouchMove(evt:TouchEvent):Void {
		trace("TouchMove: " + evt.sizeX);
	}
	
	function onTouchEnd(evt:TouchEvent):Void {
		trace("TouchEnd: " + evt.sizeX);
	}
}
