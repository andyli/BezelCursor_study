package mobzor.entity;

import nme.geom.Point;
import nme.system.Capabilities;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
using org.casalib.util.NumberUtil;
using Std;

import mobzor.cursor.Cursor;

class Target extends Entity {
	
	var cursor:Cursor;
	var image:Image;
	
	public function new(c:Cursor):Void {
		super();
		
		rndSize();
		rndPos();
		cursor = c;
		
		cursor.onClickSignaler.bind(onClick);
	}
	
	function rndSize():Void {
		var toInch = Capabilities.screenDPI;
		resize(
			NumberUtil.randomIntegerWithinRange((0.5 * toInch).int(), (1 * toInch).int()),
			NumberUtil.randomIntegerWithinRange((0.5 * toInch).int(), (1 * toInch).int())
		);
	}
	
	function resize(w:Int, h:Int):Void {
		graphic = image = Image.createRect(width = w, height = h, (Math.random() * 0xFFFFFF).int());
	}
	
	function rndPos():Void {
		x = NumberUtil.randomIntegerWithinRange(0, HXP.stage.stageWidth - width);
		y = NumberUtil.randomIntegerWithinRange(0, HXP.stage.stageHeight - height);
	}
	
	function onClick(pt:Point):Void {
		if (collidePoint(x, y, pt.x, pt.y)) {
			rndSize();
			rndPos();
		}
	}
}
