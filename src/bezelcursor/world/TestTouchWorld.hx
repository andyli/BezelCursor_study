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
import bezelcursor.entity.StartButton;
import bezelcursor.model.DeviceData;
import bezelcursor.model.TouchData;
import bezelcursor.model.TaskBlockData;
using bezelcursor.Main;

class TestTouchWorld extends GameWorld {
	public var currentTarget:Target;	
	public var targetQueue:Array<{target:Int, camera:Point}>;
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
		
		for (target in targets) {
			add(target);
		}
		
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
		cm.thumbSpaceEnabled = false;
		
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
		
		add(startBtn);
		
		if (HXP.engine.asMain().cursorManager.thumbSpaceEnabled) {
			HXP.stage.addChild(HXP.engine.asMain().cursorManager.thumbSpaceView);
		}
		
		next();
	}
}
