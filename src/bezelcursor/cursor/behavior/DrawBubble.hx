package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceData;

class DrawBubble extends Behavior<PointActivatedCursor> {
	public var lineWeight:Float;
	public var alpha:Float;
	public var centerSpotRadius:Float;
	
	public function new(c:PointActivatedCursor, ?data:Dynamic):Void {
		super(c, data);
		
		lineWeight = data != null && Reflect.hasField(data, "lineWeight") ? data.lineWeight : 2;
		alpha = data != null && Reflect.hasField(data, "alpha") ? data.alpha : 1;
		centerSpotRadius = data != null && Reflect.hasField(data, "centerSpotRadius") ? data.centerSpotRadius : 0.25;
	}
	
	override public function onFrame(timestamp:Float):Void {
		super.onFrame(timestamp);
		
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
	
	override public function getData():Dynamic {
		var data:Dynamic = super.getData();
		
		data.lineWeight = lineWeight;
		data.alpha = alpha;
		data.centerSpotRadius = centerSpotRadius;
		
		return data;
	}
	
	override public function setData(data:Dynamic):Void {
		super.setData(data);
		
		lineWeight = data.lineWeight;
		alpha = data.alpha;
		centerSpotRadius = data.centerSpotRadius;
	}
	
	override public function clone(?c:PointActivatedCursor):DrawBubble {
		return new DrawBubble(c == null ? cursor : c, getData());
	}
}