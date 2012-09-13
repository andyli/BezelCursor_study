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
	public function new(data:Dynamic):Void {
		super(data);
		
		jointActivateDistance = data != null && Reflect.hasField(data, "jointActivateDistance") ? data.jointActivateDistance : Math.POSITIVE_INFINITY;
		scaleFactor = data != null && Reflect.hasField(data, "scaleFactor") ? data.scaleFactor : -1;
		current_radius = data != null && Reflect.hasField(data, "current_radius") ? data.current_radius : 0.1;
		target_radius = data != null && Reflect.hasField(data, "target_radius") ? data.target_radius : 0.1;
		default_radius = data != null && Reflect.hasField(data, "default_radius") ? data.default_radius : 0.1;
		
		behaviors = [new DrawMagStick(this), new ClickWhenTouchEnd(this)];
		snapper = data != null && Reflect.hasField(data, "snapper") ? Snapper.createFromData(this, data.snapper) : new DistanceToOriginSnapper(this);
	}
	
	override public function clone():MagStickCursor {
		return new MagStickCursor(getData());
	}
}
