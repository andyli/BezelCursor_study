package bezelcursor.entity;

import nme.events.MouseEvent;
import nme.geom.Point;
import com.haxepunk.HXP;
import hsl.haxe.Signal;
using com.eclecticdesignstudio.motion.Actuate;

using bezelcursor.Main;
import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceData;
using bezelcursor.util.UnitUtil;
using bezelcursor.world.GameWorld;

class OverlayButton extends Button {
	inline static public var TYPE = "OverlayButton";
	inline static public var WIDTH:Float = 18.mm2inches();
	inline static public var HEIGHT:Float = 9.mm2inches();
	
	public function new(labelText:String):Void {
		super(labelText);
		type = TYPE; //so it is not snapped by cursor
		text.size *= 2;
		
		var dpi = DeviceData.current.screenDPI;
		
		resize(Math.round(dpi * WIDTH), Math.round(dpi * HEIGHT));
		
		for (g in graphicList_default.children) {
			g.scrollX = g.scrollY = 0;
		}
		for (g in graphicList_hover.children) {
			g.scrollX = g.scrollY = 0;
		}
		
		alpha = 0.8;
		layer = 5;
		
		x = (HXP.stage.stageWidth - width) * 0.5;
		y = HXP.stage.stageHeight - dpi * (HEIGHT + 2.mm2inches());
	}
	
	override public function added():Void {
		super.added();
		HXP.stage.addEventListener(MouseEvent.MOUSE_DOWN, onPressed);
	}
	
	override public function removed():Void {
		super.removed();
		HXP.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onPressed);
	}
	
	function onPressed(evt:MouseEvent):Void {
		if (visible && collidePoint(x, y, evt.stageX, evt.stageY)) {			
			click();
		}
	}
}