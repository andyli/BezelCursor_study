package bezelcursor.cursor.behavior;

import nme.system.Capabilities;

import bezelcursor.cursor.Cursor;

class SimpleDraw extends Behavior<Cursor> {
	override public function onFrame():Void {
		super.onFrame();
		
		if (cursor.currentPoint != null) {
			var sizePx = Capabilities.screenDPI * cursor.currentSize;
			cursor.view.graphics.clear();
			cursor.view.graphics.lineStyle(2, 0xFF0000, 1);
			cursor.view.graphics.drawCircle(cursor.currentPoint.x, cursor.currentPoint.y, 0.25);
			cursor.view.graphics.drawCircle(cursor.currentPoint.x, cursor.currentPoint.y, sizePx);
		}
	}
}