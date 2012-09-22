package bezelcursor.world;

using StringTools;
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
	public var taskBlockData:TaskBlockData;
	public var currentQueueIndex:Int;
	
	public var startBtn:OverlayButton;
	public var hitLabel:Label;
	public var missedLabel:Label;
	
	override public function new(taskBlockData:TaskBlockData):Void {
		super();
		
		this.taskBlockData = taskBlockData;
		
		startBtn = new OverlayButton("Start");
		startBtn.onClickSignaler.bindVoid(function(){
			var cm = HXP.engine.asMain().cursorManager;
			if (cm.inputMethod.forBezel != null || cm.inputMethod.forScreen != null || cm.inputMethod.forThumbSpace != null) {
				cm.cursorsEnabled = true;
			}
			if (cm.inputMethod.forThumbSpace != null) {
				cm.thumbSpaceEnabled = true;
			}
			
			startBtn.visible = false;
		});
		
		missedLabel = new Label("MISSED", {
			color: 0xFF0000,
			size: Math.round(DeviceData.current.screenDPI * 0.36),
			resizable: true,
			align: TextFormatAlign.CENTER
		});
		missedLabel.text.scrollX = missedLabel.text.scrollY = 0;
		missedLabel.x = (HXP.stage.stageWidth - missedLabel.width) * 0.5;
		missedLabel.y = (HXP.stage.stageHeight - missedLabel.height) * 0.5;
		
		hitLabel = new Label("HIT", {
			color: 0x00FF00,
			size: Math.round(DeviceData.current.screenDPI * 0.36),
			resizable: true,
			align: TextFormatAlign.CENTER
		});
		hitLabel.text.scrollX = hitLabel.text.scrollY = 0;
		hitLabel.x = (HXP.stage.stageWidth - hitLabel.width) * 0.5;
		hitLabel.y = (HXP.stage.stageHeight - hitLabel.height) * 0.5;
	}
	
	public function next():Void {
		var cm = HXP.engine.asMain().cursorManager;
		cm.cursorsEnabled = false;
		
		if (cm.inputMethod.requireOverlayButton){
			startBtn.visible = false;
		}
		
		if (currentQueueIndex > taskBlockData.targetQueue.length - 1) {
			onFinish();
			return;
		}
		
		var currentTargets = taskBlockData.targetQueue[currentQueueIndex];
		
		for (i in 0...currentTargets.length) {
			var target = create(Target, false);
			target.fromObj(currentTargets[i]);
			target.moveBy(currentQueueIndex * HXP.stage.stageWidth, 0);
			add(target);
			if (i == 0) {
				currentTarget = target;
			}
		}
		
		camera.tween(0.5, {x: currentQueueIndex * HXP.stage.stageWidth}).onComplete(function() {
			currentTarget.color = 0xFF0000;
			currentTarget.color_hover = 0x66FF66;
			
			if (cm.inputMethod.requireOverlayButton){
				startBtn.visible = true;
				if (cm.inputMethod.name.startsWith("BezelCursor")) {
					cm.cursorsEnabled = true;
				}
			} else {
				cm.cursorsEnabled = true;
			}
			
			while(invisibleTargets.length > 0) {
				recycle(invisibleTargets.pop());
			}
		});
		
		++currentQueueIndex;
	}
	
	override public function begin():Void {
		//cpp.vm.Profiler.start();
		super.begin();
		
		var cm = HXP.engine.asMain().cursorManager;
		
		if (cm.inputMethod.forThumbSpace != null) {
			HXP.stage.addChild(cm.thumbSpaceView);
		}		
		
		if (cm.inputMethod.requireOverlayButton){
			add(startBtn);
			startBtn.text.tween(0.5, {alpha:0.5}).reflect(true).repeat(-1);
		}
		
		cm.onClickSignaler.bind(onCursorClick);
		
		if (cm.inputMethod.requireOverlayButton && cm.inputMethod.name.startsWith("BezelCursor")) {
			cm.isValidStart = function(t:TouchData) {
				return startBtn.collidePoint(startBtn.x, startBtn.y, t.x, t.y);
			}
		} else if (cm.inputMethod.name != InputMethod.DirectTouch.name && cm.inputMethod.name != InputMethod.ThumbSpace.name) {
			cm.isValidStart = function(t:TouchData) {
				var worldTouchPos = screenToWorld(new Point(t.x, t.y));
				return !currentTarget.collidePoint(currentTarget.x, currentTarget.y, worldTouchPos.x, worldTouchPos.y);
			}
		}
		
		next();
		
		//cpp.vm.Profiler.stop();
	}
	
	override public function end():Void {
		var cm = HXP.engine.asMain().cursorManager;
		cm.onClickSignaler.unbind(onCursorClick);
		cm.isValidStart = function(t) return true;
		startBtn.text.stop();
		super.end();
	}
	
	function onCursorClick(target:Target):Void {
		var cm = HXP.engine.asMain().cursorManager;
		cm.cursorsEnabled = false;
		
		if (cm.inputMethod.requireOverlayButton) {
			startBtn.visible = false;
		}
		
		
		if (target == currentTarget){
			add(hitLabel);
			hitLabel.text.alpha = 0;
			hitLabel.text.tween(0.5, { alpha:1.0 }).onComplete(function(){ 
				remove(hitLabel); 
				next();
			});
		} else {
			add(missedLabel);
			missedLabel.text.alpha = 0;
			missedLabel.text.tween(0.5, { alpha:1.0 }).onComplete(function(){ 
				remove(missedLabel); 
				next();
			});
		}
	}
	
	function onFinish():Void {
		HXP.world = HXP.engine.asMain().worldQueue.pop();
	}
}
