package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceInfo;

class BubbleDraw extends Behavior<PointActivatedCursor> {
	override public function onFrame():Void {
		super.onFrame();
		
		if (cursor.snapper.lastSnapTarget != null) {
			var dist = cursor.snapper.lastSnapTarget.distanceToPoint(cursor.currentPoint.x, cursor.currentPoint.y, true);
			cursor.view.graphics.clear();
			cursor.view.graphics.lineStyle(2, 0xFF0000, 1);
			cursor.view.graphics.drawCircle(cursor.currentPoint.x, cursor.currentPoint.y, 0.25);
			cursor.view.graphics.drawCircle(cursor.currentPoint.x, cursor.currentPoint.y, dist);
		}
	}
}