package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceInfo;

class DrawBubble extends Behavior<PointActivatedCursor> {
	public var lineWeight:Float = 2;
	public var alpha:Float = 1;
	public var centerSpotRadius:Float = 0.25;
	
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
			
			cursor.view.graphics.lineStyle(lineWeight, cursor.color, alpha);
			cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, centerSpotRadius);
			cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, dist);
		}
	}
}