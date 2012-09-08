package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceData;

class DrawRadius extends Behavior<Cursor> {
	public var lineWeight:Float = 2;
	public var alpha:Float = 1;
	public var centerSpotRadius:Float = 0.25;
	
	public function new(c:Cursor, ?data:Dynamic):Void {
		super(c, data);

		lineWeight = data != null && Reflect.hasField(data, "lineWeight") ? data.lineWeight : 2;
		alpha = data != null && Reflect.hasField(data, "alpha") ? data.alpha : 1;
		centerSpotRadius = data != null && Reflect.hasField(data, "centerSpotRadius") ? data.centerSpotRadius : 0.25;
	}
	
	override public function onFrame(timestamp:Float):Void {
		super.onFrame(timestamp);
		
		if (cursor.position != null) {
			cursor.view.graphics.lineStyle(lineWeight, cursor.color, alpha);
			cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, DeviceData.current.screenDPI * cursor.radius);
			
			if (centerSpotRadius > 0)
				cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, centerSpotRadius);
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
	
	override public function clone(?c:Cursor):DrawRadius {
		return new DrawRadius(c == null ? cursor : c, getData());
	}
}