package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceInfo;

class DrawBubble extends Behavior<PointActivatedCursor> {
	public var lineWeight:Float = 2;
	public var alpha:Float = 1;
	public var centerSpotRadius:Float = 0.25;
	
	override public function onFrame():Void {
		super.onFrame();
		
		if (cursor.snapper.target != null) {
			var dist = 	cursor.snapper.target.distanceToPoint(cursor.position.x, cursor.position.y, true)
				 		+ Math.max(cursor.snapper.target.width, cursor.snapper.target.height);
			
			if (cursor.snapper.interestedTargets.length > 1) {
				dist = Math.min(
					cursor.snapper.interestedTargets[1].distanceToPoint(cursor.position.x, cursor.position.y, true),
					dist
				);
			}
			
			cursor.view.graphics.lineStyle(lineWeight, cursor.color, alpha);
			cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, centerSpotRadius);
			cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, dist);
		}
	}
}