package bezelcursor.entity;

import flash.events.MouseEvent;
import flash.geom.Point;
import com.haxepunk.HXP;
import hsl.haxe.Signal;
using motion.Actuate;

using bezelcursor.Main;
import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceData;
using bezelcursor.util.UnitUtil;
using bezelcursor.world.GameWorld;

class OverlayButton extends Button {
	inline static public var TYPE = "OverlayButton";
	inline static public var WIDTH:Float = 18.mm2inches();
	inline static public var HEIGHT:Float = 9.mm2inches();

	public var pressed(default, null) = false;
	public var dragged(default, null) = false;
	var startPressPt = new Point();
	var px:Float;
	var py:Float;
	
	public function new(labelText:String):Void {
		super(labelText);
		type = TYPE; //so it is not snapped by cursor
		text.size *= 2;
		
		var dpi = DeviceData.current.screenDPI;
		
		resize(Math.round(dpi * WIDTH), Math.round(dpi * HEIGHT));
		
		alpha = 0.8;
		layer = -10;
	}
	
	override public function resize(w:Float = -1, h:Float = -1):Void {
		super.resize(w, h);
		
		for (g in graphicList_default.children) {
			g.scrollX = g.scrollY = 0;
		}
		for (g in graphicList_hover.children) {
			g.scrollX = g.scrollY = 0;
		}
		
		var dpi = DeviceData.current.screenDPI;
		x = (HXP.stage.stageWidth - width) * 0.5;
		y = HXP.stage.stageHeight - dpi * (HEIGHT + 2.mm2inches());
	}
	
	override public function added():Void {
		super.added();
		HXP.stage.addEventListener(MouseEvent.MOUSE_DOWN, onPressed);
		HXP.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMoved);
		HXP.stage.addEventListener(MouseEvent.MOUSE_UP, onReleased);
	}
	
	override public function removed():Void {
		super.removed();
		HXP.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onPressed);
		HXP.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMoved);
		HXP.stage.removeEventListener(MouseEvent.MOUSE_UP, onReleased);
	}
	
	function onPressed(evt:MouseEvent):Void {
		if (visible && collidePoint(x, y, evt.stageX, evt.stageY)) {
			pressed = true;
			dragged = false;
			startPressPt.x = px = evt.stageX;
			startPressPt.y = py = evt.stageY;
		}
	}

	function onMoved(evt:MouseEvent):Void {
		if (pressed) {
			if (!dragged && Point.distance(startPressPt, new Point(evt.stageX, evt.stageY)) > DeviceData.current.screenDPI * 2.mm2inches()) {
				dragged = true;
			}

			if (dragged) {
				moveBy(evt.stageX - px, evt.stageY - py);
			}
			px = evt.stageX;
			py = evt.stageY;
		}
	}

	function onReleased(evt:MouseEvent):Void {
		if (visible && collidePoint(x, y, evt.stageX, evt.stageY) && pressed) {
			if (!dragged) {
				click();
			}
			pressed = false;
			dragged = false;
		}
	}
}