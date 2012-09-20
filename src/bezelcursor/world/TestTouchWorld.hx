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
	public var targetQueue:Array<{target:Int, camera:{x:Float, y:Float}}>;
	public var targets:Array<Target>;
	
	public var startBtn:OverlayButton;
	public var missedLabel:Label;
	
	override public function new(taskBlockData:TaskBlockData):Void {
		super();
		
		targets = [];
		for (td in taskBlockData.targets) {
			var t = new Target().fromObj(td).init();
			targets.push(t);
		}
		targetQueue = taskBlockData.targetQueue.copy();
		
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
	}
	
	public function next():Void {
		var cm = HXP.engine.asMain().cursorManager;
		cm.cursorsEnabled = false;
		
		if (cm.inputMethod.requireOverlayButton){
			startBtn.visible = false;
		}
		
		var nextSpec = targetQueue.shift();
		
		if (nextSpec == null) { //end
			onFinish();
			return;
		}
		
		camera.tween(0.5, nextSpec.camera).onComplete(function() {
			currentTarget = targets[nextSpec.target];
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
	
	function onFinish():Void {
		HXP.world = new PowerMenuWorld();
	}
}
