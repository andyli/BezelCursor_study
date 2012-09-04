package bezelcursor.entity;

import nme.display.Sprite;
import nme.system.Capabilities;
import com.haxepunk.Entity;
import com.haxepunk.HXP;

/**
	Just an on-screen ruler.
	Each mark is an inch apart.
*/
class Ruler extends Entity {
	public var sprite:Sprite;
	
	public function new():Void {
		super();
		
		sprite = new Sprite();
	}
	
	override public function added():Void {
		super.added();
		
		var dpi = DeviceInfo.current.screenDPI;
		sprite.graphics.beginFill(0xFFFFFF);
		sprite.graphics.lineStyle(1, 0x000000, 1);
		var x = 0.0;
		while (x < HXP.stage.stageWidth) {
			sprite.graphics.moveTo(x, 0);
			sprite.graphics.lineTo(x, 100);
			x += dpi;
		}
		sprite.graphics.endFill();
		
		HXP.stage.addChild(sprite);
	}
	
	override public function removed():Void {
		HXP.stage.removeChild(sprite);
	}
}
