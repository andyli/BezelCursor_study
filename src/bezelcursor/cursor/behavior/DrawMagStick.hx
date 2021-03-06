package bezelcursor.cursor.behavior;

using Lambda;
import flash.geom.Point;
import com.haxepunk.HXP;

import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.MagStickCursor;
import bezelcursor.cursor.behavior.DrawStick;
import bezelcursor.model.DeviceData;
using bezelcursor.world.GameWorld;

class DrawMagStick extends Behavior<MagStickCursor> {
	public var lineWidthThumb:Array<Float>;
	public var alphaThumb:Array<Float>;
	public var lineWidthTarget:Array<Float>;
	public var alphaTarget:Array<Float>;
	public var radiusCircleLineWidth:Float;
	public var radiusCircleAlpha:Float;
	
	public function new(c:MagStickCursor):Void {
		super(c);
		
		lineWidthThumb = [3.5, 3.0, 2.2, 2.0].map(function(_) return _ * 2);
		alphaThumb = [1.0, 1.0, 1.0, 1.0];
		lineWidthTarget = [2.0, 1.5].map(function(_) return _ * 2);
		alphaTarget = [1.0, 1.0];
		radiusCircleLineWidth = 2 * 2;
		radiusCircleAlpha = 1.0;
	}
	
	override public function onFrame(timestamp:Float):Void {
		super.onFrame(timestamp);
		
		if (cursor.position != null) {
			var colorThumb = [];
			for (i in 0...lineWidthThumb.length) {
				colorThumb.push(cursor.color);
			}
				
			var colorTarget = [];
			for (i in 0...lineWidthTarget.length) {
				colorTarget.push(cursor.color);
			}
			
			var g = cursor.view.graphics;
			DrawStick.drawGradientLine(g, cursor.currentTouchPoint, cursor.activatedPoint, lineWidthThumb, colorThumb, alphaThumb);
			
			if (cursor.snapper.target != null) {
				var tpt = HXP.world.asGameWorld().worldToScreen(new Point(cursor.snapper.target.centerX, cursor.snapper.target.centerY));
				var v = tpt.subtract(cursor.activatedPoint);
				v.normalize(cursor.currentTouchPoint.subtract(cursor.activatedPoint).length);
				var end = cursor.activatedPoint.add(v);
				v.normalize(4);
				DrawStick.drawGradientLine(g, cursor.activatedPoint.add(v), end, lineWidthTarget, colorTarget, alphaTarget);
				if (radiusCircleLineWidth > 0){
					g.lineStyle(radiusCircleLineWidth, cursor.color, radiusCircleAlpha);
					g.drawCircle(end.x, end.y, DeviceData.current.screenDPI * cursor.radius);
				}
			} else {
				var v = cursor.position.subtract(cursor.activatedPoint);
				v.normalize(4);
				var end = cursor.position;
				DrawStick.drawGradientLine(g, cursor.activatedPoint.add(v), end, lineWidthTarget, colorTarget, alphaTarget);
				g.drawCircle(end.x, end.y, DeviceData.current.screenDPI * cursor.radius);
				if (radiusCircleLineWidth > 0){
					g.lineStyle(radiusCircleLineWidth, cursor.color, radiusCircleAlpha);
					g.drawCircle(end.x, end.y, DeviceData.current.screenDPI * cursor.radius);
				}
			}
		}
	}
}