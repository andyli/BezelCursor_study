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
	inline static public var TYPE = "StartButton";
	inline static public var HEIGHT:Float = 10.mm2inches();
	
	public function new(labelText:String):Void {
		super(labelText);
		type = TYPE; //so it is not snapped by cursor
		text.size *= 2;
		
		resize(HXP.stage.stageWidth, Math.round(DeviceData.current.screenDPI * HEIGHT));
		
		for (g in graphicList_default.children) {
			g.scrollX = g.scrollY = 0;
		}
		for (g in graphicList_hover.children) {
			g.scrollX = g.scrollY = 0;
		}
		
		alpha = 0.8;
		layer = 5;

		y = HXP.stage.stageHeight - DeviceData.current.screenDPI * HEIGHT;
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

			var cm = HXP.engine.asMain().cursorManager;
			if (cm.inputMethod.forBezel != null || cm.inputMethod.forScreen != null || cm.inputMethod.forThumbSpace != null) {
				cm.cursorsEnabled = true;
			}
			if (cm.inputMethod.forThumbSpace != null) {
				cm.thumbSpaceEnabled = true;
			}
			
			visible = false;
			
			click();
		}
	}
}