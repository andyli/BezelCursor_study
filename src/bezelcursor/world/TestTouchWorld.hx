package bezelcursor.world;

import hsl.haxe.Signal;
import com.haxepunk.HXP;
using com.eclecticdesignstudio.motion.Actuate;
import nme.display.Sprite;
import nme.events.TouchEvent;
import nme.geom.*;
using org.casalib.util.ArrayUtil;

import bezelcursor.cursor.*;
import bezelcursor.cursor.behavior.*;
import bezelcursor.entity.*;
import bezelcursor.model.*;
using bezelcursor.Main;

class TestTouchWorld extends GameWorld {
	public var currentTarget:Target;	
	public var targetQueue:Array<{target:Int, camera:{x:Float, y:Float}}>;
	public var targets:Array<Target>;
	
	public var startBtn:StartButton;
	
	override public function new(taskBlockData:TaskBlockData):Void {
		super();
		
		targets = [];
		for (td in taskBlockData.targets) {
			var t = new Target().fromObj(td).init();
			targets.push(t);
		}
		targetQueue = taskBlockData.targetQueue.copy();
		
		for (spec in targetQueue) {
			var target = targets[spec.target];
			target.color = 0xFF0000;
			target.color_hover = 0x66FF66;
		}
		
		startBtn = new StartButton("Start");
	}
	
	public function next():Void {
		startBtn.visible = false;
		
		var cm = HXP.engine.asMain().cursorManager;
		cm.cursorsEnabled = false;
		
		var nextSpec = targetQueue.shift();
		
		if (nextSpec == null) { //end
			HXP.world = new bezelcursor.world.PowerMenuWorld();
			return;
		}
		
		currentTarget = targets[nextSpec.target];
		currentTarget.onClickSignaler.bindVoid(next).destroyOnUse();
		
		camera.tween(0.5, nextSpec.camera).onComplete(function() startBtn.visible = true);
	}
	
	override public function begin():Void {
		super.begin();
		
		if (HXP.engine.asMain().cursorManager.inputMethod.forThumbSpace != null) {
			HXP.stage.addChild(HXP.engine.asMain().cursorManager.thumbSpaceView);
		}
		
		for (target in targets) {
			add(target);
		}
		
		add(startBtn);
		
		next();
	}
	
	override public function end():Void {
		currentTarget.onClickSignaler.unbindVoid(next);
		super.end();
	}
}
