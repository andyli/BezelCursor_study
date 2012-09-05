package bezelcursor.world;

using Lambda;
import hsl.haxe.Signal;
import com.haxepunk.HXP;
import nme.display.Sprite;
import nme.events.TouchEvent;
import nme.geom.Point;

import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.CursorManager;
import bezelcursor.cursor.behavior.DynaScale;
import bezelcursor.cursor.behavior.MouseMove;
import bezelcursor.entity.Target;
import bezelcursor.entity.RandomMovingTarget;
import bezelcursor.model.DeviceInfo;
import bezelcursor.model.TouchData;
using bezelcursor.Main;

class TestTouchWorld extends GameWorld {
	var _w:Int;
	var _h:Int;
	var margin:Int;
	
	override public function new():Void {
		super();
		
		var dpi = DeviceInfo.current.screenDPI;
		_w = Std.int(0.4 * dpi);
		_h = Std.int(0.3 * dpi);
		margin = Std.int(dpi*0.1);
	}
	
	public function replaceTargets():Void {
		while (targets.length > 0) remove(targets.pop());

		
		var _x = 0.5 * (HXP.stage.stageWidth - Math.floor(HXP.stage.stageWidth / _w) * _w);
		while (_x + _w < HXP.stage.stageWidth) {
			var _y = 0.5 * (HXP.stage.stageHeight - Math.floor(HXP.stage.stageHeight / _h) * _h);
			while (_y + _h < HXP.stage.stageHeight - 100) {
				
				if (Math.random() < 0.25) {
					var target = new Target(_w - margin, _h - margin);
					target.moveTo(_x + margin*0.5, _y + margin*0.5);
					add(target);
				}
				
				_y += _h;
			}
			_x += _w;
		}
		
		currentTarget = targets[Std.int(Math.random() * targets.length)];
	}
	
	override public function begin():Void {
		super.begin();
		
		replaceTargets();
		
		var target = new Target(_w - margin, _h - margin);
		target.color = 0x0000FF;
		target.color_hover = 0x3333FF;
		target.moveTo(margin, HXP.stage.stageHeight - _h - margin * 0.5);
		add(target);
		targets.remove(target);
		
		target.onClickSignaler.bindVoid(function() {
			HXP.engine.asMain().cursorManager.createCursor = CursorManager.defaultCreateCursor;
		});
		
		
		
		var target = new Target(_w - margin, _h - margin);
		target.color = 0x0000FF;
		target.color_hover = 0x3333FF;
		target.moveTo(_w + margin, HXP.stage.stageHeight - _h - margin * 0.5);
		add(target);
		targets.remove(target);
		
		target.onClickSignaler.bindVoid(function() {
			HXP.engine.asMain().cursorManager.createCursor = function(touch:TouchData, _for:CreateCursorFor):Cursor {
				switch(_for) {
					case ForBezel: 
						return new bezelcursor.cursor.StickCursor(touch.touchPointID);
					case ForScreen:
						return new bezelcursor.cursor.MagStickCursor(touch.touchPointID);
				}
			}
		});
		
		var target = new Target(_w - margin, _h - margin);
		target.color = 0x0000FF;
		target.color_hover = 0x3333FF;
		target.moveTo(_w * 2 + margin, HXP.stage.stageHeight - _h - margin * 0.5);
		add(target);
		targets.remove(target);
		
		target.onClickSignaler.bindVoid(function() {
			HXP.engine.asMain().cursorManager.createCursor = function(touch:TouchData, _for:CreateCursorFor):Cursor {
				switch(_for) {
					case ForBezel: 
						return new bezelcursor.cursor.BubbleMouseCursor(touch.touchPointID);
					case ForScreen:
						return new bezelcursor.cursor.MagStickCursor(touch.touchPointID);
				}
			}
		});
	}
	
	override function onTargetClick(signal:Signal<Point>):Void {
		super.onTargetClick(signal);
		
		var target:Target = untyped signal.origin;
		if (target == currentTarget) {
			replaceTargets();
		}
	}
}
