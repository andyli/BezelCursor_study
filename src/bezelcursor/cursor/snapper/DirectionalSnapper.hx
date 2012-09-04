package bezelcursor.cursor.snapper;

import nme.geom.Point;
import com.haxepunk.HXP;
import org.casalib.util.GeomUtil;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.PointActivatedCursor;
import bezelcursor.entity.Target;
import bezelcursor.model.DeviceInfo;

class DirectionalSnapper extends Snapper<PointActivatedCursor> {
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
				if (distance > DeviceInfo.current.screenDPI * cursor.currentSize)
					continue;
				
				var distance = Point.distance(cursor.currentPoint, new Point(target.centerX, target.centerY));
				var cursorAngle = GeomUtil.angle(cursor.activatedPoint, cursor.currentPoint);
				var targetAngle = GeomUtil.angle(cursor.activatedPoint, new Point(target.centerX, target.centerY));
				var panalty = Math.abs(GeomUtil.distanceBetweenDegrees(cursorAngle, targetAngle)).map(0, 90, 1, 10).constrain(1, 10);
				if (distance * panalty < minDistance) {
					minDistance = distance;
					closestTarget = target;
				}
			}
		}
		
		return lastSnapTarget = closestTarget;
	}
}
