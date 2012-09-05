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
import bezelcursor.cursor.snapper.DistanceToOriginSnapper;
import bezelcursor.model.DeviceInfo;

class MagStickCursor extends StickCursor {
	public function new(touchPointID:Int):Void {
		super(touchPointID);
		
		jointActivateDistance = Math.POSITIVE_INFINITY;
		scaleFactor = -1;
		current_radius = target_radius = default_radius = 0.1;
		
		behaviors = [new DrawMagStick(this), new ClickWhenTouchEnd(this)];
		snapper = new DistanceToOriginSnapper(this);
	}
}
