package bezelcursor.world;

using Lambda;
using StringTools;
import nme.geom.Rectangle;
import com.haxepunk.HXP;
using com.eclecticdesignstudio.motion.Actuate;
using org.casalib.util.ArrayUtil;

using bezelcursor.Main;
import bezelcursor.entity.*;
import bezelcursor.model.*;
import bezelcursor.world.*;
using bezelcursor.world.GameWorld;
using bezelcursor.util.UnitUtil;

class PowerMenuWorld extends GameWorld {
	var selectedMethod:InputMethod;
	var selectedUseStartButton:Bool;
	var powerMenuStack:Array<PowerMenu>;
	
	function popPowerMenuStack():Void {
		remove(powerMenuStack.pop());
		camera.tween(0.5, { x: powerMenuStack[powerMenuStack.length-1].x });
	}
	
	function pushPowerMenuStack(powerMenu:PowerMenu):Void {
		powerMenu.x = HXP.stage.stageWidth * powerMenuStack.length;
		powerMenuStack.push(add(powerMenu));
		camera.tween(0.5, { x: powerMenu.x });
	}
	
	public function startPractice():Void {
		if (selectedUseStartButton && !selectedMethod.requireOverlayButton) {
			selectedMethod = new InputMethod("").fromObj(selectedMethod.toObj()).fromObj({requireOverlayButton: true});
		}
		
		if (selectedMethod.name.startsWith("BezelCursor") && selectedMethod.requireOverlayButton) {
			selectedMethod = new InputMethod("").fromObj(selectedMethod.toObj()).fromObj({
				forScreen: selectedMethod.forBezel,
				forBezel: null
			});
		}
		
		var testWorld = new PracticeTouchWorld(HXP.engine.asMain().taskblocks[1]);
		
		if (selectedMethod.name.indexOf("ThumbSpace") == -1) {
			HXP.world = testWorld;
		} else {
			HXP.engine.asMain().worldQueue.add(testWorld);
			HXP.world = new ConfigThumbSpaceWorld();
		}
		
		for (taskblock in HXP.engine.asMain().taskblocks.randomize()) {
			HXP.engine.asMain().worldQueue.add(new TestTouchWorld(taskblock));
		}
		HXP.engine.asMain().worldQueue.add(new PowerMenuWorld());
	}
	
	override public function begin():Void {
		super.begin();
		
		var dpi = DeviceData.current.screenDPI;
		var buttonWidth = 45.mm2inches() * dpi;
		var buttonHeight = 9.mm2inches() * dpi;
		
		HXP.engine.asMain().cursorManager.inputMethod = InputMethod.DirectTouch;
		HXP.engine.asMain().cursorManager.cursorsEnabled = true;
		
		powerMenuStack = new Array<PowerMenu>();
		
		
		var powerMenu = new PowerMenu();
		
		for (method in TaskBlockDataGenerator.current.inputMethods) {
			var btn = new Button(method.name);
			btn.resize(buttonWidth, buttonHeight);
			if (method.requireOverlayButton) {
				btn.onClickSignaler.bindVoid(function() {
					selectedUseStartButton = true;
					selectedMethod = method;
					startPractice();
				});
			} else {
				btn.onClickSignaler.bindVoid(function() {
					selectedMethod = method;
				
					var powerMenu = new PowerMenu();
		
					var btn = new Button("Back");
					btn.resize(buttonWidth * 0.5, buttonHeight);
					btn.onClickSignaler.bindVoid(popPowerMenuStack).destroyOnUse();
					powerMenu.add(btn);
		
					var btn = new Button("Use start button");
					btn.resize(buttonWidth, buttonHeight);
					btn.onClickSignaler.bindVoid(function(){
						selectedUseStartButton = true;
						startPractice();
					});
					powerMenu.add(btn);
		
					var btn = new Button("No start button");
					btn.resize(buttonWidth, buttonHeight);
					btn.onClickSignaler.bindVoid(function(){
						selectedUseStartButton = false;
						startPractice();
					});
					powerMenu.add(btn);
				
					pushPowerMenuStack(powerMenu);
				});
			}
			powerMenu.add(btn);
		}

		pushPowerMenuStack(powerMenu);
	}
	
	override public function end():Void {
		super.end();
		
		if (selectedMethod != null)
			HXP.engine.asMain().cursorManager.inputMethod = selectedMethod;
	}
}