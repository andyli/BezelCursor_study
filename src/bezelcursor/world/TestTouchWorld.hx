package bezelcursor.world;

using StringTools;
using DateTools;
import haxe.*;
import sys.io.*;
import hsl.haxe.*;
import com.haxepunk.*;
import com.haxepunk.graphics.*;
using com.eclecticdesignstudio.motion.Actuate;
import nme.display.Sprite;
import nme.events.TouchEvent;
import nme.geom.*;
import nme.text.*;
using org.casalib.util.ArrayUtil;
import org.casalib.util.*;

import bezelcursor.cursor.*;
import bezelcursor.cursor.behavior.*;
import bezelcursor.entity.*;
import bezelcursor.model.*;
using bezelcursor.Main;
using bezelcursor.util.UnitUtil;

class TestTouchWorld extends GameWorld, implements IStruct {
	@skip var record:PlayRecord;
	public function log(event:String, data:Dynamic = null):Void {
		trace("event:" + event);
		record.addEvent(
			haxe.Timer.stamp(),
			event,
			data
		);
		trace("added");
	}
	
	@skip public var currentTarget(default, null):Target;
	public var taskBlockData(default, null):TaskBlockData;
	public var flipStage(default, null):Bool;
	public var currentQueueIndex(default, null):Int;
	
	@skip public var startBtn(default, null):OverlayButton;
	@skip public var hitLabel(default, null):Label;
	@skip public var missedLabel(default, null):Label;
	
	@skip public var title(default, null):Label;
	
	override public function new(taskBlockData:TaskBlockData, flipStage = false):Void {
		super();
		
		this.taskBlockData = taskBlockData;
		this.flipStage = flipStage;
		
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
		missedLabel.graphic.scrollX = missedLabel.graphic.scrollY = 0;
		
		hitLabel = new Label("HIT", {
			color: 0x00FF00,
			size: Math.round(DeviceData.current.screenDPI * 0.36),
			resizable: true,
			align: TextFormatAlign.CENTER
		});
		hitLabel.graphic.scrollX = hitLabel.graphic.scrollY = 0;
		
		title = new Label("", {
			color: 0x000000,
			size: Math.round(DeviceData.current.screenDPI * 0.36),
			resizable: true,
			align: TextFormatAlign.LEFT
		});
		title.graphic.scrollX = title.graphic.scrollY = 0;
		title.x = 10;
		title.y = 10;
		title.layer = 5;
		title.alpha = 0.5;
		//add(title);
	}
	
	public function next():Void {
		var cm = HXP.engine.asMain().cursorManager;
		cm.cursorsEnabled = false;
		
		if (cm.inputMethod.requireOverlayButton){
			startBtn.visible = false;
		}
		
		if (currentQueueIndex > taskBlockData.targetQueue.length - 1) {
			nextWorld();
			return;
		}
		
		var currentTargets = taskBlockData.targetQueue[currentQueueIndex];
		
		for (i in 0...currentTargets.length) {
			var target = create(Target, false);
			target.fromTargetData(currentTargets[i]);
			if (flipStage) {
				target.x = DeviceData.current.screenResolutionX - target.x - target.width;
			}
			target.moveBy(camera.x + HXP.stage.stageWidth, 0);
			add(target);
			if (i == 0) {
				currentTarget = target;
			}
		}
		
		camera.tween(0.5, {x: camera.x + HXP.stage.stageWidth}).onComplete(function() {
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
			
			haxe.Timer.delay(function(){
				clipTargets();
				while(invisibleTargets.length > 0) {
					recycle(invisibleTargets.pop());
				}
			}, 1);
			
			log("next", currentQueueIndex);
		});
		
		title.label = (currentQueueIndex+1) + " / " + taskBlockData.targetQueue.length;
		
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
			startBtn.tween(0.5, {alpha:0.5}).reflect(true).repeat(-1);
		}
		
		cm.onClickSignaler.bind(onCursorClick);
		
		cm.onTouchStartSignaler.bind(recTouchStart);
		cm.onTouchMoveSignaler.bind(recTouchMove);
		cm.onTouchEndSignaler.bind(recTouchEnd);
		
		cm.onStartSignaler.bindAdvanced(recCursorStart);
		cm.onMoveSignaler.bindAdvanced(recCursorMove);
		cm.onClickSignaler.bindAdvanced(recCursorClick);
		cm.onEndSignaler.bindAdvanced(recCursorEnd);
		
		
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
		
		record = new PlayRecord();
		record.creationTime = Date.now().getTime();
		record.id = StringUtil.uuid();
		record.user = UserData.current;
		record.device = DeviceData.current;
		record.build = BuildData.current;
		record.world = Type.getClassName(Type.getClass(this));
		record.taskBlockData = taskBlockData.toObj();
		record.flipStage = flipStage;
		record.inputMethod = HXP.engine.asMain().cursorManager.inputMethod.name;
		record.cursorManager = HXP.engine.asMain().cursorManager.toObj();
				
		log("begin");
		
		next();
		
		//cpp.vm.Profiler.stop();
	}
	
	override public function end():Void {
		var cm = HXP.engine.asMain().cursorManager;
		
		cm.onTouchStartSignaler.unbind(recTouchStart);
		cm.onTouchMoveSignaler.unbind(recTouchMove);
		cm.onTouchEndSignaler.unbind(recTouchEnd);
		
		cm.onStartSignaler.unbindAdvanced(recCursorStart);
		cm.onMoveSignaler.unbindAdvanced(recCursorMove);
		cm.onClickSignaler.unbindAdvanced(recCursorClick);
		cm.onEndSignaler.unbindAdvanced(recCursorEnd);
		
		log("end");
		
		var logFileURL = 
			#if android
			"/mnt/sdcard/BezelCursorLog_"
			#elseif sys
			"BezelCursorLog"
			#end
			+ DeviceData.current.id + "_" + Date.now().format("%Y%m%d_%H%M%S") + ".txt";
		
		logFileURL = logFileURL.replace(" ", "_");
		
		File.saveContent(logFileURL, record.toString());
		
		cm.onClickSignaler.unbind(onCursorClick);
		cm.isValidStart = function(t) return true;
		startBtn.stop();
		super.end();
	}
	
	function recTouchStart(touch:TouchData):Void {
		log("touch-start", touch.toObj());
	}
	
	function recTouchMove(touch:TouchData):Void {
		log("touch-move", touch.toObj());
	}
	
	function recTouchEnd(touch:TouchData):Void {
		log("touch-end", touch.toObj());
	}
	
	function recCursorStart(s:Signal<Void>):Void {
		log("cursor-start", {
			cursor: cast(s.origin,Cursor).toObj()
		});
	}
	
	function recCursorMove(s:Signal<Target>):Void {
		log("cursor-move", {
			cursor: cast(s.origin,Cursor).toObj(),
			target: s.data == null ? null : cast(s.data,Target).toObj(),
			isCurrent: s.data == currentTarget
		});
	}
	
	function recCursorClick(s:Signal<Target>):Void {
		log("cursor-click", {
			cursor: cast(s.origin,Cursor).toObj(),
			target: s.data == null ? null : cast(s.data,Target).toObj(),
			isCurrent: s.data == currentTarget
		});
	}
	
	function recCursorEnd(s:Signal<Void>):Void {
		log("cursor-end", {
			cursor: cast(s.origin,Cursor).toObj()
		});
	}
	
	function onCursorClick(target:Target):Void {
		var cm = HXP.engine.asMain().cursorManager;
		cm.cursorsEnabled = false;
		
		if (cm.inputMethod.requireOverlayButton) {
			startBtn.visible = false;
		}
		
		
		if (target == currentTarget){
			currentTarget.color = currentTarget.color_hover;
			add(hitLabel);
			hitLabel.label = title.label + "\nHIT";
			hitLabel.x = (HXP.stage.stageWidth - hitLabel.width) * 0.5;
			hitLabel.y = (HXP.stage.stageHeight - hitLabel.height) * 0.5;
			hitLabel.alpha = 0;
			hitLabel.tween(0.5, { alpha:1.0 }).onComplete(function(){ 
				remove(hitLabel); 
				next();
			});
		} else {
			add(missedLabel);
			missedLabel.label = title.label + "\nMISSED";
			missedLabel.x = (HXP.stage.stageWidth - missedLabel.width) * 0.5;
			missedLabel.y = (HXP.stage.stageHeight - missedLabel.height) * 0.5;
			missedLabel.alpha = 0;
			missedLabel.tween(0.5, { alpha:1.0 }).onComplete(function(){ 
				remove(missedLabel); 
				next();
			});
		}
	}
}
