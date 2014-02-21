package bezelcursor.world;

using Std;
using Lambda;
using StringTools;
import flash.geom.*;
import flash.text.*;
import com.haxepunk.HXP;
using motion.Actuate;
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
	var selectedLeftHand:Bool;
	var selectedVerticalScrollDirection:Bool;
	var selectedBiggerTargetFirst:Bool;
	var participate:String;
	var powerMenuStack:Array<PowerMenu>;

	var buttonWidth:Float;
	var buttonHeight:Float;
	
	function popPowerMenuStack():Void {
		remove(powerMenuStack.pop());
		camera.tween(0.5, { x: powerMenuStack[powerMenuStack.length-1].x });
	}
	
	function pushPowerMenuStack(powerMenu:PowerMenu):Void {
		powerMenu.x = HXP.stage.stageWidth * powerMenuStack.length;
		powerMenuStack.push(add(powerMenu));
		camera.tween(0.5, { x: powerMenu.x });
	}

	function selectTargetSize():Void {
		var powerMenu = new PowerMenu();
		
		var btn = new Button("Back");
		btn.resize(buttonWidth * 0.5, buttonHeight);
		btn.onClickSignaler.bindVoid(popPowerMenuStack).destroyOnUse();
		powerMenu.add(btn);
		
		var btn = new Button("9.6mm x 9.6mm First");
		btn.resize(buttonWidth, buttonHeight);
		btn.onClickSignaler.bindVoid(function(){
			selectedBiggerTargetFirst = true;
			selectHandiness();
		});
		powerMenu.add(btn);
		
		var btn = new Button("3mm x 3mm First");
		btn.resize(buttonWidth, buttonHeight);
		btn.onClickSignaler.bindVoid(function(){
			selectedBiggerTargetFirst = false;
			selectHandiness();
		});
		powerMenu.add(btn);
				
		pushPowerMenuStack(powerMenu);
	}

	function selectScrollDirection():Void {
		var powerMenu = new PowerMenu();
		
		var btn = new Button("Back");
		btn.resize(buttonWidth * 0.5, buttonHeight);
		btn.onClickSignaler.bindVoid(popPowerMenuStack).destroyOnUse();
		powerMenu.add(btn);
		
		var btn = new Button("Vertical Scrolling");
		btn.resize(buttonWidth, buttonHeight);
		btn.onClickSignaler.bindVoid(function(){
			selectedVerticalScrollDirection = true;
			selectTargetSize();
		});
		powerMenu.add(btn);
		
		var btn = new Button("Horizontal Scrolling");
		btn.resize(buttonWidth, buttonHeight);
		btn.onClickSignaler.bindVoid(function(){
			selectedVerticalScrollDirection = false;
			selectTargetSize();
		});
		powerMenu.add(btn);
				
		pushPowerMenuStack(powerMenu);
	}
	
	function enterEmail():Void {
		var powerMenu = new PowerMenu();
		
		var btn = new Button("Back");
		btn.resize(buttonWidth * 0.5, buttonHeight);
		btn.onClickSignaler.bindVoid(popPowerMenuStack).destroyOnUse();
		powerMenu.add(btn);
		
		var label = new Label("Enter your name.\n Nickname will be fine.", {
			size: Math.round(DeviceData.current.screenDPI * 0.08),
			color: 0xFFFFFF
		});
		label.text2.visible = false;
		powerMenu.add(label);
		
		
		var textInput = new TextInput("", Math.max(buttonWidth, HXP.stage.stageWidth - 10), buttonHeight);
		powerMenu.add(textInput);
		
		var btn = new Button("OK");
		btn.resize(buttonWidth, buttonHeight);
		btn.onClickSignaler.bindVoid(function(){
			participate = textInput.textInput.text;
			startPractice();
		});
		powerMenu.add(btn);
				
		pushPowerMenuStack(powerMenu);
	}
	
	function selectHandiness():Void {
		var powerMenu = new PowerMenu();
		
		var btn = new Button("Back");
		btn.resize(buttonWidth * 0.5, buttonHeight);
		btn.onClickSignaler.bindVoid(popPowerMenuStack).destroyOnUse();
		powerMenu.add(btn);
		
		var btn = new Button("Use left hand");
		btn.resize(buttonWidth, buttonHeight);
		btn.onClickSignaler.bindVoid(function(){
			selectedLeftHand = true;
			enterEmail();
		});
		powerMenu.add(btn);
		
		var btn = new Button("Use right hand");
		btn.resize(buttonWidth, buttonHeight);
		btn.onClickSignaler.bindVoid(function(){
			selectedLeftHand = false;
			enterEmail();
		});
		powerMenu.add(btn);
				
		pushPowerMenuStack(powerMenu);
	}
	
	function startPractice():Void {
		UserData.current.name = participate;
		
		if (selectedUseStartButton && !selectedMethod.requireOverlayButton) {
			selectedMethod = new InputMethod("").fromObj(selectedMethod.toObj()).fromObj({requireOverlayButton: true});
		}
		
		if (selectedMethod.name.startsWith("BezelCursor") && selectedMethod.requireOverlayButton) {
			selectedMethod = new InputMethod("").fromObj(selectedMethod.toObj()).fromObj({
				forScreen: selectedMethod.forBezel,
				forBezel: null
			});
		}
		
		var testWorld = new PracticeTouchWorld(TaskBlockData.current[0], !selectedLeftHand, selectedVerticalScrollDirection);
		
		if (selectedMethod.name.indexOf("ThumbSpace") == -1) {
			HXP.world = testWorld;
		} else {
			var configThumbSpaceWorld = new ConfigThumbSpaceWorld();
			configThumbSpaceWorld.worldQueue.push(testWorld);
			HXP.world = configThumbSpaceWorld;
		}
		
		for (taskblock in (selectedBiggerTargetFirst ?
			TaskBlockData.current :
			[TaskBlockData.current[1], TaskBlockData.current[0]]
		)) {
			testWorld.worldQueue.push(new TestTouchWorld(taskblock, !selectedLeftHand, selectedVerticalScrollDirection));
		}
		testWorld.worldQueue.push(new PowerMenuWorld());
	}
	
	override public function begin():Void {
		super.begin();
		
		var dpi = DeviceData.current.screenDPI;
		buttonWidth = 45.mm2inches() * dpi;
		buttonHeight = 9.mm2inches() * dpi;
		
		HXP.engine.asMain().cursorManager.inputMethod = InputMethod.DirectTouch;
		HXP.engine.asMain().cursorManager.cursorsEnabled = true;
		
		powerMenuStack = new Array<PowerMenu>();
		
		
		var powerMenu = new PowerMenu();
		
		for (method in TaskBlockDataGenerator.current.inputMethods) {
			var btn = new Button(method.name);
			btn.resize(buttonWidth, buttonHeight);
			btn.onClickSignaler.bindVoid(function() {
				selectedMethod = method;
				selectScrollDirection();
			});
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