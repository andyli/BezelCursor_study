package bezelcursor.world;

import hsl.haxe.*;
import com.haxepunk.*;
import com.haxepunk.graphics.*;
using com.eclecticdesignstudio.motion.Actuate;
import nme.display.Sprite;
import nme.events.TouchEvent;
import nme.geom.*;
import nme.text.*;
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
	public var missedLabel:Label;
	
	override public function new(taskBlockData:TaskBlockData):Void {
		super();
		
		targets = [];
		for (td in taskBlockData.targets) {
			var t = new Target().fromObj(td).init();
			targets.push(t);
		}
		targetQueue = taskBlockData.targetQueue.copy();
		
		startBtn = new StartButton("Start");
		
		missedLabel = new Label("MISSED", {
			color: 0xFF0000,
			size: Math.round(DeviceData.current.screenDPI * 0.36),
			resizable: true,
			align: TextFormatAlign.CENTER
		});
		missedLabel.text.scrollX = missedLabel.text.scrollY = 0;
		missedLabel.x = (HXP.stage.stageWidth - missedLabel.width) * 0.5;
		missedLabel.y = (HXP.stage.stageHeight - missedLabel.height) * 0.5;
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
		
		camera.tween(0.5, nextSpec.camera).onComplete(function() {
			currentTarget = targets[nextSpec.target];
			currentTarget.color = 0xFF0000;
			currentTarget.color_hover = 0x66FF66;
			startBtn.visible = true;
		});
	}
	
	override public function begin():Void {
		super.begin();
		
		var cm = HXP.engine.asMain().cursorManager;
		
		if (cm.inputMethod.forThumbSpace != null) {
			HXP.stage.addChild(cm.thumbSpaceView);
		}
		
		for (target in targets) {
			add(target);
		}
		
		add(startBtn);
		
		cm.onClickSignaler.bind(onCursorClick);
		if (cm.inputMethod != InputMethod.DirectTouch && cm.inputMethod != InputMethod.ThumbSpace) {
			cm.isValidStart = function(t:TouchData) {
				var worldTouchPos = screenToWorld(new Point(t.x, t.y));
				return !currentTarget.collidePoint(currentTarget.x, currentTarget.y, worldTouchPos.x, worldTouchPos.y);
			}
		}
		
		next();
	}
	
	override public function end():Void {
		var cm = HXP.engine.asMain().cursorManager;
		cm.onClickSignaler.unbind(onCursorClick);
		cm.isValidStart = function(t) return true;
		super.end();
	}
	
	function onCursorClick(target:Target):Void {
		startBtn.visible = false;
		
		var cm = HXP.engine.asMain().cursorManager;
		cm.cursorsEnabled = false;
		
		if (target == currentTarget){
			next();
		} else {
			add(missedLabel);
			missedLabel.text.alpha = 0;
			missedLabel.text.tween(0.5, { alpha:1.0 }).onComplete(function(){ 
				remove(missedLabel); 
				next();
			});
		}
	}
}
