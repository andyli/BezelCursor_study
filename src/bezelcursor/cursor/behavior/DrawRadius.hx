package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceInfo;

class DrawRadius extends Behavior<Cursor> {
	public var lineWeight:Float = 2;
	public var alpha:Float = 1;
	public var centerSpotRadius:Float = 0.25;
	
	public function new(c:Cursor, ?config:Dynamic):Void {
		super(c, config);

		lineWeight = config != null && Reflect.hasField(config, "lineWeight") ? config.lineWeight : 2;
		alpha = config != null && Reflect.hasField(config, "alpha") ? config.alpha : 1;
		centerSpotRadius = config != null && Reflect.hasField(config, "centerSpotRadius") ? config.centerSpotRadius : 0.25;
	}
	
	override public function onFrame():Void {
		super.onFrame();
		
		if (cursor.position != null) {
			cursor.view.graphics.lineStyle(lineWeight, cursor.color, alpha);
			cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, DeviceInfo.current.screenDPI * cursor.radius);
			
			if (centerSpotRadius > 0)
				cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, centerSpotRadius);
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
	
	override public function clone(?c:Cursor):DrawRadius {
		return new DrawRadius(c == null ? cursor : c, getConfig());
	}
}