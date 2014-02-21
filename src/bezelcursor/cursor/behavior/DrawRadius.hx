package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceData;

class DrawRadius extends Behavior<Cursor> {
	public var lineWeight:Float = 2;
	public var alpha:Float = 1;
	public var centerSpotRadius:Float = 0.25;
	
	public function new(c:Cursor):Void {
		super(c);

		lineWeight = 2 * 2;
		alpha = 1;
		centerSpotRadius = 0.25;
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
}