package bezelcursor.cursor.behavior;

using Lambda;
import flash.geom.Point;

import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.PointActivatedCursor;
import bezelcursor.model.DeviceData;

class DrawStick extends Behavior<PointActivatedCursor> {
	public var lineWidth:Array<Float>;
	public var alpha:Array<Float>;
	
	public function new(c:PointActivatedCursor):Void {
		super(c);
		
		lineWidth = [3.5, 3.0, 2.2, 2.0, 1.5].map(function(_) return _ * 2);
		alpha = [1.0, 1.0, 1.0, 1.0, 1.0];
	}
	
	override public function onFrame(timestamp:Float):Void {
		super.onFrame(timestamp);
		
		if (cursor.position != null) {
			var color = [];
			for (i in 0...lineWidth.length) {
				color.push(cursor.color);
			}
			drawGradientLine(cursor.view.graphics, cursor.activatedPoint, cursor.position, lineWidth, color, alpha);
		}
	}
	
	static public function drawGradientLine(g:flash.display.Graphics, start:Point, end:Point, lineWidth:Array<Float>, color:Array<Int>, alpha:Array<Float>):Void {
		g.moveTo(start.x, start.y);
		var v = end.subtract(start);
		var steps = Math.min(Math.min(lineWidth.length, alpha.length), color.length);
		for (i in 0...Std.int(steps)) {
			g.lineStyle(lineWidth[i], color[i], alpha[i]);
			var mid = Point.interpolate(end, start, (i+1)/steps);
			g.lineTo(mid.x, mid.y);
		}
	}
}