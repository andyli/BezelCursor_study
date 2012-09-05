package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceInfo;

class DrawRadius extends Behavior<Cursor> {
	public var lineWeight:Float = 2;
	public var alpha:Float = 1;
	public var centerSpotRadius:Float = 0.25;
	
	override public function onFrame():Void {
		super.onFrame();
		
		if (cursor.position != null) {
			cursor.view.graphics.lineStyle(lineWeight, cursor.color, alpha);
			cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, DeviceInfo.current.screenDPI * cursor.radius);
			
			if (centerSpotRadius > 0)
				cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, centerSpotRadius);
		}
	}
}