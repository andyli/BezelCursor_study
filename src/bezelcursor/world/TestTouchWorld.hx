package bezelcursor.world;

using Lambda;
import hsl.haxe.Signal;
import com.haxepunk.HXP;
using com.eclecticdesignstudio.motion.Actuate;
import nme.display.Sprite;
import nme.events.TouchEvent;
import nme.geom.Point;
import nme.geom.Matrix3D;
using org.casalib.util.ArrayUtil;

import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.CursorManager;
import bezelcursor.cursor.behavior.DrawBubble;
import bezelcursor.cursor.behavior.DynaScale;
import bezelcursor.cursor.behavior.MouseMove;
import bezelcursor.entity.Panel;
import bezelcursor.entity.Button;
import bezelcursor.entity.Target;
import bezelcursor.entity.RandomMovingTarget;
import bezelcursor.model.DeviceData;
import bezelcursor.model.TouchData;
import bezelcursor.model.TaskBlockData;
using bezelcursor.Main;

class TestTouchWorld extends GameWorld {
	public var currentTarget:Target;	
	public var targetQueue:Array<{target:Int, camera:Point}>;
	public var targets:Array<Target>;
	
	override public function new(taskBlockData:TaskBlockData):Void {
		super();
		
		targets = [];
		for (td in taskBlockData.targets) {
			targets.push(new Target(td.toObj()));
		}
		targetQueue = taskBlockData.targetQueue.copy();
		
		for (target in targets) {
			add(target);
		}
		
		for (spec in targetQueue) {
			var target = targets[spec.target];
			target.color = 0xFF0000;
			target.color_hover = 0x66FF66;
		}
	}
	
	public function next():Void {
		remove(startBtn);
		HXP.engine.asMain().cursorManager.cursorsEnabled = false;
		
		var nextSpec = targetQueue.shift();
		
		if (nextSpec == null) { //end
			HXP.world = new bezelcursor.world.PowerMenuWorld();
			return;
		}
		
		currentTarget = targets[nextSpec.target];
		currentTarget.onClickSignaler.bindVoid(next).destroyOnUse();
		
		camera.tween(0.5, nextSpec.camera).onComplete(function(){ add(startBtn); });
	}
	
	override public function begin():Void {
		super.begin();
		
		/*
		var panel = new Panel();
		panel.layer = 1;
		add(panel);
		
		var btn = new Button();
		btn.useGlobalPosition = false;
		panel.add(btn);
		
		var btn = new Button();
		btn.useGlobalPosition = false;
		panel.add(btn);
		*/
		
		next();
		
		/*
		var target = new Target({
			x: margin, 
			y: HXP.stage.stageHeight - _h - margin * 0.5,
			width: _w - margin, 
			height: _h - margin
		});
		target.color = 0x0000FF;
		target.color_hover = 0x3333FF;
		add(target);
		
		target.onClickSignaler.bindVoid(function() {
			HXP.engine.asMain().cursorManager.createCursor = CursorManager.defaultCreateCursor;
		});
		
		var target = new Target({
			x:_w + margin, 
			y:HXP.stage.stageHeight - _h - margin * 0.5, 
			width: _w - margin, 
			height: _h - margin
		});
		target.color = 0x0000FF;
		target.color_hover = 0x3333FF;
		add(target);
		
		target.onClickSignaler.bindVoid(function() {
			HXP.engine.asMain().cursorManager.createCursor = function(touch:TouchData, _for:CreateCursorFor):Cursor {
				switch(_for) {
					case ForBezel: 
						return new bezelcursor.cursor.StickCursor({touchPointID: touch.touchPointID});
					case ForScreen:
						return new bezelcursor.cursor.MagStickCursor({touchPointID: touch.touchPointID});
					case ForThumbSpace:
						return new bezelcursor.cursor.MouseCursor({touchPointID: touch.touchPointID});
				}
			}
		});
		
		var target = new Target({
			x: _w * 2 + margin,
			y: HXP.stage.stageHeight - _h - margin * 0.5,
			width: _w - margin, 
			height: _h - margin
		});
		target.color = 0x0000FF;
		target.color_hover = 0x3333FF;
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
		
		var target = new Target({
			x: _w * 3 + margin, 
			y: HXP.stage.stageHeight - _h - margin * 0.5, 
			width: _w - margin, 
			height: _h - margin
		});
		target.color = 0x00FFFF;
		target.color_hover = 0x33FFFF;
		add(target);
		
		target.onClickSignaler.bindVoid(function() {
			var cm = HXP.engine.asMain().cursorManager;
			if(cm.thumbSpace.x == Math.NEGATIVE_INFINITY) {
				cm.startThumbSpaceConfig();
			} else {
				cm.thumbSpaceEnabled = true;
			}
		});
		
		*/
	}
}
