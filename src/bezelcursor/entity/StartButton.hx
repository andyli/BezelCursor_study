package bezelcursor.entity;

import nme.events.MouseEvent;
import nme.geom.Point;
import com.haxepunk.HXP;
import hsl.haxe.Signal;

using bezelcursor.Main;
import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceData;
using bezelcursor.util.UnitUtil;
using bezelcursor.world.GameWorld;

class StartButton extends Button {
	static public var HEIGHT:Float = 10.mm2inches();
	
	public function new(labelText:String):Void {
		super(labelText);
		type = "StartButton";
		
		resize(HXP.stage.stageWidth, Math.round(DeviceData.current.screenDPI * HEIGHT));
		
		for (g in graphicList.children) {
			g.scrollX = g.scrollY = 0;
		}
		for (g in graphicList_hover.children) {
			g.scrollX = g.scrollY = 0;
		}

		y = HXP.stage.stageHeight - DeviceData.current.screenDPI * HEIGHT;
	}
	
	override public function added():Void {
		super.added();
		
		var cm = HXP.engine.asMain().cursorManager;
		cm.cursorsEnabled = false;
		cm.tapEnabled = false;
		
		HXP.stage.addEventListener(MouseEvent.MOUSE_DOWN, onPressed);
	}
	
	override public function removed():Void {
		super.removed();
		
		var cm = HXP.engine.asMain().cursorManager;
		cm.cursorsEnabled = true;
		cm.tapEnabled = true;
		
		HXP.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onPressed);
	}
	
	function onPressed(evt:MouseEvent):Void {
		if (collidePoint(x, y, evt.stageX, evt.stageY)) {
			world.remove(this);
			click();
		}
	}
}