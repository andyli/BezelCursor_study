package bezelcursor.entity;

using Std;
import hsl.haxe.Signal;
import nme.geom.Point;
import nme.geom.Rectangle;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import org.casalib.util.GeomUtil;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.DeviceData;

class RandomMovingTarget extends Target {
	
	public var posRect:Rectangle;
	
	public function new(posRect:Rectangle, ?data:Dynamic):Void {
		super(data);
		
		this.posRect = posRect;
		rndSize();
		rndPos();
	}
	
	public function rndSize():Void {
		return;
		var toInch = DeviceData.current.screenDPI;
		resize(
			NumberUtil.randomIntegerWithinRange((0.2 * toInch).int(), (1 * toInch).int()),
			NumberUtil.randomIntegerWithinRange((0.2 * toInch).int(), (1 * toInch).int())
		);
	}
	
	public function rndPos():Void {
		var rect = GeomUtil.randomlyPlaceRectangle(posRect, new Rectangle(0, 0, width, height), false);
		x = rect.x;
		y = rect.y;
	}
	
	override function onClick(signal:Signal<Point>):Void {
		super.onClick(signal);
		
		var pt = signal.data;
		
		if (collidePoint(x, y, pt.x, pt.y)) {
			rndSize();
			rndPos();
		}
	}
}
