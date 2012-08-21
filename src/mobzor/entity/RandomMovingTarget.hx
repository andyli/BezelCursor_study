package mobzor.entity;

import hsl.haxe.Signal;
import nme.geom.Point;
import nme.system.Capabilities;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
using org.casalib.util.NumberUtil;
using Std;

import mobzor.cursor.Cursor;

class RandomMovingTarget extends Target {
	
	public function new():Void {
		super();
		
		color = (Math.random() * 0xFFFFFF).int();
		rndSize();
		rndPos();
	}
	
	function rndSize():Void {
		var toInch = Capabilities.screenDPI;
		resize(
			NumberUtil.randomIntegerWithinRange((0.5 * toInch).int(), (1 * toInch).int()),
			NumberUtil.randomIntegerWithinRange((0.5 * toInch).int(), (1 * toInch).int())
		);
	}
	
	function rndPos():Void {
		x = NumberUtil.randomIntegerWithinRange(0, HXP.stage.stageWidth - width);
		y = NumberUtil.randomIntegerWithinRange(0, HXP.stage.stageHeight - height);
	}
	
	override function onClick(signal:Signal<Point>):Void {
		super.onClick(signal);
		
		var cursor:Cursor = cast signal.origin;
		var pt = cursor.currentPoint;
		
		if (collidePoint(x, y, pt.x, pt.y)) {
			color = (Math.random() * 0xFFFFFF).int();
			rndSize();
			rndPos();
		}
	}
}
