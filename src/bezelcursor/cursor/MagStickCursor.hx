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
	public function new(config:Dynamic):Void {
		super(config);
		
		jointActivateDistance = config != null && Reflect.hasField(config, "jointActivateDistance") ? config.jointActivateDistance : Math.POSITIVE_INFINITY;
		scaleFactor = config != null && Reflect.hasField(config, "scaleFactor") ? config.scaleFactor : -1;
		current_radius = config != null && Reflect.hasField(config, "current_radius") ? config.current_radius : 0.1;
		target_radius = config != null && Reflect.hasField(config, "target_radius") ? config.target_radius : 0.1;
		default_radius = config != null && Reflect.hasField(config, "default_radius") ? config.default_radius : 0.1;
		
		behaviors = [new DrawMagStick(this), new ClickWhenTouchEnd(this)];
		snapper = new DistanceToOriginSnapper(this);
	}
	
	override public function clone():MagStickCursor {
		return new MagStickCursor(getConfig());
	}
}
