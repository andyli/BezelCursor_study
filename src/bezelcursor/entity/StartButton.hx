package bezelcursor.entity;

import nme.geom.Point;
import com.haxepunk.HXP;
import hsl.haxe.Signal;

using bezelcursor.Main;
import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceData;
using bezelcursor.util.UnitUtil;

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
		
		trace(y + " " + y + height);
	}
	
	override public function added():Void {
		super.added();
		var cm = HXP.engine.asMain().cursorManager;
		cm.cursorsEnabled = false;
	}
	
	override public function removed():Void {
		super.removed();
		var cm = HXP.engine.asMain().cursorManager;
		cm.cursorsEnabled = true;
	}
	
	override function onClick(signal:Signal<Point>):Void {
		var pt = signal.data;
		//trace(pt.x + " " + pt.y + " " + x + " " + y);
		if (collidePoint(x, y, pt.x, pt.y)) {
			if (world != null)
				world.remove(this);
			
			isJustClicked = true;
			onClickSignaler.dispatch(pt);
			
			try {
				var cursor:Cursor = cast signal.origin;
				if (cursor != null)
					isHoverBy.remove(cursor.id);
			} catch(e:Dynamic){}
		}
	}
}