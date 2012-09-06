package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceInfo;

class DrawBubble extends Behavior<PointActivatedCursor> {
	public var lineWeight:Float;
	public var alpha:Float;
	public var centerSpotRadius:Float;
	
	public function new(c:PointActivatedCursor, ?config:Dynamic):Void {
		super(c, config);
		
		lineWeight = config != null && Reflect.hasField(config, "lineWeight") ? config.lineWeight : 2;
		alpha = config != null && Reflect.hasField(config, "alpha") ? config.alpha : 1;
		centerSpotRadius = config != null && Reflect.hasField(config, "centerSpotRadius") ? config.centerSpotRadius : 0.25;
	}
	
	override public function onFrame(timeInterval:Float):Void {
		super.onFrame(timeInterval);
		
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
	
	override public function getConfig():Dynamic {
		var config:Dynamic = super.getConfig();
		
		config.lineWeight = lineWeight;
		config.alpha = alpha;
		config.centerSpotRadius = centerSpotRadius;
		
		return config;
	}
	
	override public function setConfig(config:Dynamic):Void {
		super.setConfig(config);
		
		lineWeight = config.lineWeight;
		alpha = config.alpha;
		centerSpotRadius = config.centerSpotRadius;
	}
	
	override public function clone(?c:PointActivatedCursor):DrawBubble {
		return new DrawBubble(c == null ? cursor : c, getConfig());
	}
}