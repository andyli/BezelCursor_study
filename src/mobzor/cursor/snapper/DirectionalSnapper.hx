package mobzor.cursor.snapper;

import nme.geom.Point;
import nme.system.Capabilities;
import com.haxepunk.HXP;
import org.casalib.util.GeomUtil;
using org.casalib.util.NumberUtil;

import mobzor.cursor.PointActivatedCursor;
import mobzor.entity.Target;

class DirectionalSnapper extends Snapper<PointActivatedCursor> {
	override public function getSnapTarget():Null<Target> {
		var entities = [];
		HXP.world.getType(Target.TYPE, entities);
		var targets:Array<Target> = cast entities;
		
		var minDistance = Math.POSITIVE_INFINITY;
		var closestTarget = null;
		for (target in targets) {
			if (target.collidePoint(target.x, target.y, cursor.currentPoint.x, cursor.currentPoint.y)) {
				closestTarget = target;
				break;
			} else {
				var distance = target.distanceToPoint(cursor.currentPoint.x, cursor.currentPoint.y, true);
				if (distance > Capabilities.screenDPI * cursor.currentSize)
					continue;
				
				var distance = de.polygonal.motor.geom.distance.DistancePoint.find4(cursor.currentPoint.x, cursor.currentPoint.y, target.centerX, target.centerY);
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
