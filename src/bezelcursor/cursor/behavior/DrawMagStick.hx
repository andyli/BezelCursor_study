package bezelcursor.cursor.behavior;

import nme.geom.Point;

import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.MagStickCursor;
import bezelcursor.cursor.behavior.DrawStick;
import bezelcursor.model.DeviceInfo;

class DrawMagStick extends Behavior<MagStickCursor> {
	public var lineWidthThumb:Array<Float>;
	public var alphaThumb:Array<Float>;
	public var lineWidthTarget:Array<Float>;
	public var alphaTarget:Array<Float>;
	public var radiusCircleLineWidth:Float;
	public var radiusCircleAlpha:Float;
	
	public function new(c:MagStickCursor, ?config:Dynamic):Void {
		super(c, config);
		
		lineWidthThumb = config != null && Reflect.hasField(config, "lineWidthThumb") ? config.lineWidthThumb : [3.5, 3.0, 2.2, 2.0];
		alphaThumb = config != null && Reflect.hasField(config, "alphaThumb") ? config.alphaThumb : [1.0, 1.0, 1.0, 1.0];
		lineWidthTarget = config != null && Reflect.hasField(config, "lineWidthTarget") ? config.lineWidthTarget : [2.0, 1.5];
		alphaTarget = config != null && Reflect.hasField(config, "alphaTarget") ? config.alphaTarget : [1.0, 1.0];
		radiusCircleLineWidth = config != null && Reflect.hasField(config, "radiusCircleLineWidth") ? config.radiusCircleLineWidth : 2.0;
		radiusCircleAlpha = config != null && Reflect.hasField(config, "radiusCircleAlpha") ? config.radiusCircleAlpha : 1.0;
	}
	
	override public function onFrame(timeInterval:Float):Void {
		super.onFrame(timeInterval);
		
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
				var tpt = new Point(cursor.snapper.target.centerX, cursor.snapper.target.centerY);
				var v = tpt.subtract(cursor.activatedPoint);
				v.normalize(cursor.currentTouchPoint.subtract(cursor.activatedPoint).length);
				var end = cursor.activatedPoint.add(v);
				v.normalize(4);
				DrawStick.drawGradientLine(g, cursor.activatedPoint.add(v), end, lineWidthTarget, colorTarget, alphaTarget);
				if (radiusCircleLineWidth > 0){
					g.lineStyle(radiusCircleLineWidth, cursor.color, radiusCircleAlpha);
					g.drawCircle(end.x, end.y, DeviceInfo.current.screenDPI * cursor.radius);
				}
			} else {
				var v = cursor.position.subtract(cursor.activatedPoint);
				v.normalize(4);
				var end = cursor.position;
				DrawStick.drawGradientLine(g, cursor.activatedPoint.add(v), end, lineWidthTarget, colorTarget, alphaTarget);
				g.drawCircle(end.x, end.y, DeviceInfo.current.screenDPI * cursor.radius);
				if (radiusCircleLineWidth > 0){
					g.lineStyle(radiusCircleLineWidth, cursor.color, radiusCircleAlpha);
					g.drawCircle(end.x, end.y, DeviceInfo.current.screenDPI * cursor.radius);
				}
			}
		}
	}
	
	override public function getConfig():Dynamic {
		var config:Dynamic = super.getConfig();
		
		config.lineWidthThumb = lineWidthThumb.copy();
		config.alphaThumb = alphaThumb.copy();
		config.lineWidthTarget = lineWidthTarget.copy();
		config.alphaTarget = alphaTarget.copy();
		config.radiusCircleLineWidth = radiusCircleLineWidth;
		config.radiusCircleAlpha = radiusCircleAlpha;
		
		return config;
	}
	
	override public function setConfig(config:Dynamic):Void {
		super.setConfig(config);

		lineWidthThumb = config.lineWidthThumb;
		alphaThumb = config.alphaThumb;
		lineWidthTarget = config.lineWidthTarget;
		alphaTarget = config.alphaTarget;
		radiusCircleLineWidth = config.radiusCircleLineWidth;
		radiusCircleAlpha = config.radiusCircleAlpha;
	}
	
	override public function clone(?c:MagStickCursor):DrawMagStick {
		return new DrawMagStick(c == null ? cursor : c, getConfig());
	}
}