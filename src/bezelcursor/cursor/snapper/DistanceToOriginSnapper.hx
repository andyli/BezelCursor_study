package bezelcursor.cursor.snapper;

import nme.geom.Point;
import com.haxepunk.HXP;
import org.casalib.util.GeomUtil;

import bezelcursor.cursor.Cursor;
import bezelcursor.entity.Target;
import bezelcursor.model.DeviceInfo;

class DistanceToOriginSnapper extends Snapper<PointActivatedCursor> {
	override public function getSnapTarget():Null<Target> {
		var targets:Array<Target> = [];
		HXP.world.getType(Target.TYPE, targets);
		
		var minDistanceToOrigin = Point.distance(cursor.activatedPoint, cursor.currentTouchPoint) + DeviceInfo.current.screenDPI * cursor.currentSize;
		//var oriAngle = GeomUtil.normalizeDegree(GeomUtil.angle(cursor.activatedPoint, cursor.currentTouchPoint) + 180);
		//var minAngle = 40.0;
		var minDistance = Math.POSITIVE_INFINITY;
		var closestTarget = null;
		for (target in targets) {
			if (target.collidePoint(target.x, target.y, cursor.currentPoint.x, cursor.currentPoint.y)) {
				closestTarget = target;
				break;
			} else if (cursor.currentSize > 0) {
				var distance = target.distanceToPoint(cursor.currentPoint.x, cursor.currentPoint.y, true);
				if (distance > DeviceInfo.current.screenDPI * cursor.currentSize)
					continue;
				
				var distance = target.distanceToPoint(cursor.activatedPoint.x, cursor.activatedPoint.y, true);
				if (distance > minDistanceToOrigin)
					continue;
				
				//var minAngle = Math.abs(GeomUtil.distanceBetweenDegrees(oriAngle, GeomUtil.angle(cursor.activatedPoint, new Point(target.centerX, target.centerY))));
				var distance = Point.distance(cursor.currentPoint, new Point(target.centerX, target.centerY));
				if (distance < minDistance) {
					minDistance = distance;
					closestTarget = target;
				}
			}
		}
		
		return lastSnapTarget = closestTarget;
	}
}
