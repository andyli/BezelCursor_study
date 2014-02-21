package bezelcursor.cursor.behavior;

import com.haxepunk.HXP;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceData;
using bezelcursor.world.GameWorld;

class DrawBubble extends Behavior<PointActivatedCursor> {
	public var lineWeight:Float;
	public var alpha:Float;
	public var centerSpotRadius:Float;
	
	public function new(c:PointActivatedCursor):Void {
		super(c);
		
		lineWeight = 2 * 2;
		alpha = 1;
		centerSpotRadius = 0.25;
	}
	
	override public function onFrame(timestamp:Float):Void {
		super.onFrame(timestamp);
		
		if (cursor.snapper.target != null) {
			var cursorInWorld = HXP.world.asGameWorld().screenToWorld(cursor.position);
			var dist = 	cursor.snapper.target.distanceToPoint(cursorInWorld.x, cursorInWorld.y, true)
				 		+ Math.max(cursor.snapper.target.width, cursor.snapper.target.height);
			
			if (cursor.snapper.interestedTargets.length > 1) {
				dist = Math.min(
					cursor.snapper.interestedTargets[1].distanceToPoint(cursorInWorld.x, cursorInWorld.y, true),
					dist
				);
			}
			
			cursor.view.graphics.lineStyle(lineWeight, cursor.color, alpha);
			cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, centerSpotRadius);
			cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, dist);
		}
	}
}