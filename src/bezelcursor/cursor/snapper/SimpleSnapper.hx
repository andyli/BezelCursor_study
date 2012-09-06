package bezelcursor.cursor.snapper;

import nme.geom.Point;
import com.haxepunk.HXP;

import bezelcursor.cursor.Cursor;
import bezelcursor.entity.Target;
import bezelcursor.model.DeviceData;

class SimpleSnapper extends Snapper<Cursor> {	
	override public function run():Void {
		var targets:Array<Target> = [];
		HXP.world.getType(Target.TYPE, targets);
		
		interestedTargets = [];
		
		for (target in targets) {
			var distance = target.distanceToPoint(cursor.position.x, cursor.position.y, true);
			if (distance > DeviceData.current.screenDPI * cursor.radius)
				continue;
			else
				interestedTargets.push(target);
		}
		interestedTargets.sort(sortTargets);
	}
	
	function sortTargets(t0:Target, t1:Target):Int {
		var d0 = Point.distance(cursor.position, new Point(t0.centerX, t0.centerY));
		var d1 = Point.distance(cursor.position, new Point(t1.centerX, t1.centerY));
		
		return if (d0 < d1)
			-1;
		else if (d0 > d1)
			1;
		else
			0;
	}
	
	override public function clone(?c:Cursor):SimpleSnapper {
		return new SimpleSnapper(c == null ? cursor : c, getConfig());
	}
}
