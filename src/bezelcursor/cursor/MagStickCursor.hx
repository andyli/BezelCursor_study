package bezelcursor.cursor;

using Lambda;
import nme.events.Event;
import nme.events.TouchEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.behavior.DrawRadius;
import bezelcursor.cursor.behavior.DrawMagStick;
import bezelcursor.cursor.snapper.Snapper;
import bezelcursor.cursor.snapper.DistanceToOriginSnapper;
import bezelcursor.model.DeviceData;

class MagStickCursor extends StickCursor {
	
	@deep public var drawMagStick(default, set_drawMagStick):DrawMagStick;
	function set_drawMagStick(v:DrawMagStick):DrawMagStick {
		behaviors.remove(drawMagStick);
		if (v != null) behaviors.push(v);
		return drawMagStick = v;
	}
	
	public function new():Void {
		super();
		
		jointActivateDistance = Math.POSITIVE_INFINITY;
		scaleFactor = -1;
		current_radius = 0.1;
		target_radius = 0.1;
		default_radius = 0.1;

		dynaScale = null;
		drawRadius = null;
		drawMagStick = new DrawMagStick(this);
		
		snapper = new DistanceToOriginSnapper(this);
	}
}
