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
		
		endPracticeBtn = new OverlayButton("Begin");
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
			var cm = HXP.engine.asMain().cursorManager;
			
			endPracticeBtn.visible = !endPracticeBtn.visible;
			
			if (endPracticeBtn.visible) {
				cm.cursorsEnabled = false;
			} else {
				cm.cursorsEnabled = true;
			}
		}
	}
	
	override function onFinish():Void {
		HXP.world = new PracticeTouchWorld(taskBlockData);
	}
}
