package bezelcursor.cursor.snapper;

import nme.geom.Point;
import com.haxepunk.HXP;

import bezelcursor.cursor.Cursor;
import bezelcursor.entity.Target;
import bezelcursor.model.DeviceInfo;

class SimpleSnapper extends Snapper<Cursor> {
	override public function getSnapTarget():Null<Target> {
		var minDistance = Math.POSITIVE_INFINITY;
		var closestTarget = null;
		for (target in getInterestedTargets()) {
			if (target.collidePoint(target.x, target.y, cursor.currentPoint.x, cursor.currentPoint.y)) {
				closestTarget = target;
				break;
			} else if (cursor.currentSize > 0) {
				var distance = Point.distance(cursor.currentPoint, new Point(target.centerX, target.centerY));
				if (distance < minDistance) {
					minDistance = distance;
					closestTarget = target;
				}
			}
		}
		
		return lastSnapTarget = closestTarget;
	}
	
	override public function getInterestedTargets():Array<Target> {
		var targets:Array<Target> = [];
		HXP.world.getType(Target.TYPE, targets);
		
		var lastInterestedTargets = [];
		
		for (target in targets) {
			var distance = target.distanceToPoint(cursor.currentPoint.x, cursor.currentPoint.y, true);
			if (distance > DeviceInfo.current.screenDPI * cursor.currentSize)
				continue;
			else
				lastInterestedTargets.push(target);
		}
		return lastInterestedTargets;
	}
}
