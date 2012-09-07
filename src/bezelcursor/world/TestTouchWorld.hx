package bezelcursor.world;

using Lambda;
import hsl.haxe.Signal;
import com.haxepunk.HXP;
import nme.display.Sprite;
import nme.events.TouchEvent;
import nme.geom.Point;
using org.casalib.util.ArrayUtil;

import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.CursorManager;
import bezelcursor.cursor.behavior.DrawBubble;
import bezelcursor.cursor.behavior.DynaScale;
import bezelcursor.cursor.behavior.MouseMove;
import bezelcursor.entity.Target;
import bezelcursor.entity.RandomMovingTarget;
import bezelcursor.model.DeviceData;
import bezelcursor.model.TouchData;
using bezelcursor.Main;

class TestTouchWorld extends GameWorld {
	public var currentTarget(default, set_currentTarget):Target;
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

	var targets:Array<Target>;
	var _w:Int;
	var _h:Int;
	var margin:Int;
	
	override public function new():Void {
		super();
		
		var dpi = DeviceData.current.screenDPI;
		_w = Std.int(0.4 * dpi);
		_h = Std.int(0.3 * dpi);
		margin = Std.int(dpi*0.1);
		targets = [];
	}
	
	public function replaceTargets():Void {
		while(targets.length > 0) remove(targets.pop());
		
		var _x = 0.5 * (HXP.stage.stageWidth - Math.floor(HXP.stage.stageWidth / _w) * _w);
		while (_x + _w < HXP.stage.stageWidth) {
			var _y = 0.5 * (HXP.stage.stageHeight - Math.floor(HXP.stage.stageHeight / _h) * _h);
			while (_y + _h < HXP.stage.stageHeight - 100) {
				
				if (Math.random() < 0.25) {
					var target = new Target({width: _w - margin, height: _h - margin});
					target.moveTo(_x + margin*0.5, _y + margin*0.5);
					targets.push(target);
					add(target);
				}
				
				_y += _h;
			}
			_x += _w;
		}
		
		currentTarget = targets.random();
		currentTarget.onClickSignaler.bindVoid(replaceTargets).destroyOnUse();
	}
	
	override public function begin():Void {
		super.begin();
		
		replaceTargets();
		
		
		var target = new Target({width: _w - margin, height: _h - margin});
		target.color = 0x0000FF;
		target.color_hover = 0x3333FF;
		target.moveTo(margin, HXP.stage.stageHeight - _h - margin * 0.5);
		add(target);
		
		target.onClickSignaler.bindVoid(function() {
			HXP.engine.asMain().cursorManager.createCursor = CursorManager.defaultCreateCursor;
		});
		
		var target = new Target({width: _w - margin, height: _h - margin});
		target.color = 0x0000FF;
		target.color_hover = 0x3333FF;
		target.moveTo(_w + margin, HXP.stage.stageHeight - _h - margin * 0.5);
		add(target);
		
		target.onClickSignaler.bindVoid(function() {
			HXP.engine.asMain().cursorManager.createCursor = function(touch:TouchData, _for:CreateCursorFor):Cursor {
				switch(_for) {
					case ForBezel: 
						return new bezelcursor.cursor.StickCursor({touchPointID: touch.touchPointID});
					case ForScreen:
						return new bezelcursor.cursor.MagStickCursor({touchPointID: touch.touchPointID});
					case ForThumbSpace:
						return new bezelcursor.cursor.StickCursor({touchPointID: touch.touchPointID});
				}
			}
		});
		
		var target = new Target({width: _w - margin, height: _h - margin});
		target.color = 0x0000FF;
		target.color_hover = 0x3333FF;
		target.moveTo(_w * 2 + margin, HXP.stage.stageHeight - _h - margin * 0.5);
		add(target);
		
		target.onClickSignaler.bindVoid(function() {
			HXP.engine.asMain().cursorManager.createCursor = function(touch:TouchData, _for:CreateCursorFor):Cursor {
				switch(_for) {
					case ForBezel: 
						return new bezelcursor.cursor.BubbleMouseCursor({touchPointID: touch.touchPointID});
					case ForScreen:
						return new bezelcursor.cursor.MagStickCursor({touchPointID: touch.touchPointID});
					case ForThumbSpace:
						var c = new bezelcursor.cursor.BubbleMouseCursor({touchPointID: touch.touchPointID});
						c.behaviors.remove(c.behaviors.filter(function(b) return Std.is(b, DrawBubble)).first());
						return c;
				}
			}
		});
		
		var target = new Target({width: _w - margin, height: _h - margin});
		target.color = 0x00FFFF;
		target.color_hover = 0x33FFFF;
		target.moveTo(_w * 3 + margin, HXP.stage.stageHeight - _h - margin * 0.5);
		add(target);
		
		target.onClickSignaler.bindVoid(function() {
			var cm = HXP.engine.asMain().cursorManager;
			if(cm.thumbSpace.x == Math.NEGATIVE_INFINITY) {
				cm.startThumbSpaceConfig();
			} else {
				cm.thumbSpaceEnabled = true;
			}
		});
	}
}
