package bezelcursor.world;

using StringTools;
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
import org.casalib.util.*;

using bezelcursor.Main;
import bezelcursor.cursor.*;
import bezelcursor.cursor.behavior.*;
import bezelcursor.entity.*;
import bezelcursor.model.*;
using bezelcursor.util.UnitUtil;

class PracticeTouchWorld extends TestTouchWorld {
	public var endPracticeBtn:OverlayButton;
	override public function new(taskBlockData:TaskBlockData):Void {
		super(taskBlockData);
		
		var dpi = DeviceData.current.screenDPI;
		var buttonWidth = 45.mm2inches() * dpi;
		var buttonHeight = 9.mm2inches() * dpi;
		
		endPracticeBtn = new OverlayButton("Begin");
		endPracticeBtn.resize(buttonWidth, buttonHeight);
		endPracticeBtn.onClickSignaler.bindVoid(nextWorld).destroyOnUse();
	}
	
	override public function begin():Void {
		super.begin();

		add(endPracticeBtn);
		endPracticeBtn.x = (HXP.stage.stageWidth - endPracticeBtn.width) * 0.5;
		endPracticeBtn.y = (HXP.stage.stageHeight - endPracticeBtn.height) * 0.5;
		endPracticeBtn.visible = false;
	}
	
	override public function update():Void {
		super.update();
		
		if (Input.pressed("menu")) {
			var cm = HXP.engine.asMain().cursorManager;
			
			endPracticeBtn.visible = !endPracticeBtn.visible;
			
			if (endPracticeBtn.visible) {
				//add(title);
				cm.cursorsEnabled = false;
				remove(startBtn);
			} else {
				//remove(title);
				if (cm.inputMethod.name.startsWith("BezelCursor")) {
					cm.cursorsEnabled = true;
					startBtn.visible = true;
				} else {
					cm.cursorsEnabled = !startBtn.visible;
				}
				add(startBtn);
			}
		}
	}
	
	override public function next():Void {
		currentQueueIndex = NumberUtil.randomIntegerWithinRange(0, taskBlockData.targetQueue.length-1);
		super.next();
		title.label = "Practice";
	}
}
