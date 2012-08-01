package mobzor.world;

import hsl.haxe.Signal;
import com.haxepunk.HXP;
import com.haxepunk.World;
import nme.display.Sprite;
import nme.geom.Point;
import nme.system.Capabilities;

import mobzor.cursor.Cursor;
import mobzor.cursor.StickCursor;
import mobzor.entity.Target;
import mobzor.entity.RandomMovingTarget;
import mobzor.event.CursorEvent;
using mobzor.event.CursorEventType;

class TestTouchWorld extends World {
	public var cursor:Cursor;
	public var currentTarget(default, set_currentTarget):Target;
	public var targets:Array<Target>;

	override public function begin():Void {
		super.begin();
		
		cursor = new StickCursor();
		cursor.start();
		
		targets = [];
		
		var dpi = Capabilities.screenDPI;
		var _w = Std.int(0.4 * dpi);
		var _h = Std.int(0.3 * dpi);
		var margin = Std.int(dpi*0.1);
		
		var _x = 0.5 * (HXP.stage.stageWidth - Math.floor(HXP.stage.stageWidth / _w) * _w);
		while (_x + _w < HXP.stage.stageWidth) {
			var _y = 0.5 * (HXP.stage.stageHeight - Math.floor(HXP.stage.stageHeight / _h) * _h);
			while (_y + _h < HXP.stage.stageHeight) {
			
				var target = new Target(cursor, _w - margin, _h - margin);
				target.moveTo(_x + margin*0.5, _y + margin*0.5);
				target.onClickSignaler.bindAdvanced(onTargetClick);
				add(target);
				targets.push(target);
				
				_y += _h;
			}
			_x += _w;
		}
		
		currentTarget = targets[Std.int(Math.random() * targets.length)];
	}
	
	override public function end():Void {
		
		cursor.end();
		
		super.end();
	}
	
	function onTargetClick(signal:Signal<Point>):Void {
		var target:Target = untyped signal.origin;
		if (target == currentTarget) {
			currentTarget = targets[Std.int(Math.random() * targets.length)];
		}
	}
	
	function set_currentTarget(t:Target):Target {
		if (currentTarget != null){
			currentTarget.color = 0xFFFFFF;
			currentTarget.color_hover = 0xFF6666;
		}
		currentTarget = t;
		currentTarget.color = 0xFF0000;
		currentTarget.color_hover = 0x66FF66;
		return t;
	}
}
