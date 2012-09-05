package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceInfo;

class SimpleDraw extends Behavior<Cursor> {
	override public function onFrame():Void {
		super.onFrame();
		
		if (cursor.position != null) {
			var sizePx = DeviceInfo.current.screenDPI * cursor.radius;
			cursor.view.graphics.clear();
			cursor.view.graphics.lineStyle(2, 0xFF0000, 1);
			cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, 0.25);
			cursor.view.graphics.drawCircle(cursor.position.x, cursor.position.y, sizePx);
		}
	}
}