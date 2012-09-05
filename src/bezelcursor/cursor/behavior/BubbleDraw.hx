package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceInfo;

class BubbleDraw extends Behavior<PointActivatedCursor> {
	override public function onFrame():Void {
		super.onFrame();
		
		if (cursor.snapper.lastSnapTarget != null) {
			var dist = 	cursor.snapper.lastSnapTarget.distanceToPoint(cursor.position.x, cursor.position.y, true)
				 		+ Math.max(cursor.snapper.lastSnapTarget.width, cursor.snapper.lastSnapTarget.height);
			
			if (cursor.snapper.lastInterestedTargets.length > 1) {
				dist = Math.min(
					cursor.snapper.lastInterestedTargets[1].distanceToPoint(cursor.position.x, cursor.position.y, true),
					dist
				);
			}
			
			cursor.view.graphics.clear();
			cursor.view.graphics.lineStyle(2, 0xFF0000, 1);
			cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, 0.25);
			cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, dist);
		}
	}
}