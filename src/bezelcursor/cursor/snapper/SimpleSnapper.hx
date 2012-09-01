package bezelcursor.cursor.snapper;

import nme.system.Capabilities;
import com.haxepunk.HXP;

import bezelcursor.cursor.Cursor;
import bezelcursor.entity.Target;

class SimpleSnapper extends Snapper<Cursor> {
	override public function getSnapTarget():Null<Target> {
		var targets:Array<Target> = [];
		HXP.world.getType(Target.TYPE, targets);
		
		var minDistance = Math.POSITIVE_INFINITY;
		var closestTarget = null;
		for (target in targets) {
			if (target.collidePoint(target.x, target.y, cursor.currentPoint.x, cursor.currentPoint.y)) {
				closestTarget = target;
				break;
			} else if (cursor.currentSize > 0) {
				var distance = target.distanceToPoint(cursor.currentPoint.x, cursor.currentPoint.y, true);
				if (distance > Capabilities.screenDPI * cursor.currentSize)
					continue;
				
				var distance = de.polygonal.motor.geom.distance.DistancePoint.find4(cursor.currentPoint.x, cursor.currentPoint.y, target.centerX, target.centerY);
				//var distance = target.distanceToPoint(cursor.currentPoint.x, cursor.currentPoint.y, false);
				if (distance < minDistance) {
					minDistance = distance;
					closestTarget = target;
				}
			}
		}
		
		return lastSnapTarget = closestTarget;
	}
}
