package mobzor.world;

import hsl.haxe.Signal;
import com.haxepunk.HXP;
import nme.display.Sprite;
import nme.events.TouchEvent;
import nme.geom.Point;
import nme.system.Capabilities;

import mobzor.cursor.Cursor;
import mobzor.entity.Target;
import mobzor.entity.RandomMovingTarget;
using mobzor.Main;

class TestTouchWorld extends GameWorld {
	override public function new():Void {
		super();
	}
	
	override public function begin():Void {
		super.begin();
		
		var dpi = Capabilities.screenDPI;
		var _w = Std.int(0.4 * dpi);
		var _h = Std.int(0.3 * dpi);
		var margin = Std.int(dpi*0.1);
		
		var _x = 0.5 * (HXP.stage.stageWidth - Math.floor(HXP.stage.stageWidth / _w) * _w);
		while (_x + _w < HXP.stage.stageWidth) {
			var _y = 0.5 * (HXP.stage.stageHeight - Math.floor(HXP.stage.stageHeight / _h) * _h);
			while (_y + _h < HXP.stage.stageHeight) {
			
				var target = new Target(_w - margin, _h - margin);
				target.moveTo(_x + margin*0.5, _y + margin*0.5);
				add(target);
				
				_y += _h;
			}
			_x += _w;
		}
		
		
		targets[0].onClickSignaler.bindVoid(function() {
			HXP.engine.asMain().bezelActivatedCursorManager.createCursor = function(evt:TouchEvent) {
				return new mobzor.cursor.StickCursor(evt.touchPointID);
			}
		});
		
		targets[1].onClickSignaler.bindVoid(function() {
			HXP.engine.asMain().bezelActivatedCursorManager.createCursor = function(evt:TouchEvent) {
				return new mobzor.cursor.MouseCursor(evt.touchPointID);
			}
		});
		
		targets[2].onClickSignaler.bindVoid(function() {
			HXP.engine.asMain().bezelActivatedCursorManager.createCursor = function(evt:TouchEvent) {
				return new mobzor.cursor.DynaStickCursor(evt.touchPointID);
			}
		});
		
		currentTarget = targets[Std.int(Math.random() * targets.length)];
	}
	
	override function onTargetClick(signal:Signal<Point>):Void {
		super.onTargetClick(signal);
		
		var target:Target = untyped signal.origin;
		while (target == currentTarget) {
			currentTarget = targets[Std.int(Math.random() * targets.length)];
		}
	}
}
