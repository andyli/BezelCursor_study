package bezelcursor.world;

import hsl.haxe.*;
import com.haxepunk.*;
import com.haxepunk.graphics.*;
import com.haxepunk.utils.*;
using com.eclecticdesignstudio.motion.Actuate;
import nme.display.Sprite;
import nme.events.TouchEvent;
import nme.geom.*;
import nme.text.*;
using org.casalib.util.ArrayUtil;

using bezelcursor.Main;
import bezelcursor.cursor.*;
import bezelcursor.cursor.behavior.*;
import bezelcursor.entity.*;
import bezelcursor.model.*;
using bezelcursor.util.UnitUtil;

class PracticeTouchWorld extends TestTouchWorld {
	public var endPracticeBtn:OverlayButton;
	public var taskBlockData:TaskBlockData;
	override public function new(taskBlockData:TaskBlockData):Void {
		super(taskBlockData);
		
		this.taskBlockData = taskBlockData;
		
		endPracticeBtn = new OverlayButton("End");
		endPracticeBtn.onClickSignaler.bindVoid(function(){
			HXP.world = new TestTouchWorld(taskBlockData);
		}).destroyOnUse();
	}
	
	override public function begin():Void {
		super.begin();

		add(endPracticeBtn).y = (HXP.stage.stageHeight - endPracticeBtn.height) * 0.5;
		endPracticeBtn.visible = false;
	}
	
	override public function update():Void {
		super.update();
		
		if (Input.pressed("menu")) {
			endPracticeBtn.visible = !endPracticeBtn.visible;
		}
	}
	
	override public function next():Void {
		var cm = HXP.engine.asMain().cursorManager;
		cm.cursorsEnabled = false;
		
		if (cm.inputMethod.requireOverlayButton){
			startBtn.visible = false;
		}
		
		var nextSpec = targetQueue.shift();
		
		if (nextSpec == null) { //end
			HXP.world = new PracticeTouchWorld(taskBlockData);
			return;
		}
		
		camera.tween(0.5, nextSpec.camera).onComplete(function() {
			currentTarget = targets[nextSpec.target];
			currentTarget.color = 0xFF0000;
			currentTarget.color_hover = 0x66FF66;
			
			if (cm.inputMethod.requireOverlayButton){
				startBtn.visible = true;
			} else {
				cm.cursorsEnabled = true;
			}
		});
	}
}
