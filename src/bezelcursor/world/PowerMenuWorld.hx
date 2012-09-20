package bezelcursor.world;

using Lambda;
import nme.geom.Rectangle;
import com.haxepunk.HXP;
using com.eclecticdesignstudio.motion.Actuate;
using org.casalib.util.ArrayUtil;

using bezelcursor.Main;
import bezelcursor.entity.Button;
import bezelcursor.entity.PowerMenu;
import bezelcursor.entity.RandomMovingTarget;
import bezelcursor.model.InputMethod;
import bezelcursor.model.TaskBlockData;
import bezelcursor.model.TaskBlockDataGenerator;
import bezelcursor.model.DeviceData;
using bezelcursor.world.GameWorld;
using bezelcursor.world.TestTouchWorld;
using bezelcursor.world.ConfigThumbSpaceWorld;
using bezelcursor.util.UnitUtil;

class PowerMenuWorld extends GameWorld {
	var selectedMethod:InputMethod;
	
	public function startTest():Void {
		var testWorld = new TestTouchWorld(HXP.engine.asMain().taskblocks.random());
		
		if (selectedMethod.name.indexOf("ThumbSpace") == -1) {
			HXP.world = testWorld;
		} else {
			HXP.engine.asMain().worldQueue.add(testWorld);
			HXP.world = new ConfigThumbSpaceWorld();
		}
	}
	
	public function startPractice():Void {
		var targetSize = TaskBlockDataGenerator.current.targetSizes.random();
		var testWorld = new PracticeTouchWorld(HXP.engine.asMain().taskblocks.random());
		
		if (selectedMethod.name.indexOf("ThumbSpace") == -1) {
			HXP.world = testWorld;
		} else {
			HXP.engine.asMain().worldQueue.add(testWorld);
			HXP.world = new ConfigThumbSpaceWorld();
		}
	}
	
	override public function begin():Void {
		super.begin();
		
		var dpi = DeviceData.current.screenDPI;
		
		HXP.engine.asMain().cursorManager.inputMethod = InputMethod.DirectTouch;
		HXP.engine.asMain().cursorManager.cursorsEnabled = true;
		
		var _x = 0;
		
		var powerMenu = new PowerMenu();
		powerMenu.x = _x;
		add(powerMenu);
		
		for (method in TaskBlockDataGenerator.current.inputMethods) {
			var btn = new Button(method.name);
			btn.resize(btn.text.width + 20, btn.text.height + 40);
			btn.onClickSignaler.bindVoid(function() {
				selectedMethod = method;
				camera.tween(0.5, { x: powerMenu.x + powerMenu.width });
			});
			powerMenu.add(btn);
		}
		
		_x += HXP.stage.stageWidth;
		
		
		
		
		var powerMenu = new PowerMenu();
		powerMenu.x = _x;
		add(powerMenu);
		
		var btn = new Button("Back");
		btn.resize(btn.text.width + 5, btn.text.height + 15);
		btn.onClickSignaler.bindVoid(function(){
			camera.tween(0.5, { x: powerMenu.x - powerMenu.width });
		});
		powerMenu.add(btn);
		
		var btn = new Button("Practice");
		btn.resize(btn.text.width + 20, btn.text.height + 40);
		btn.onClickSignaler.bindVoid(function(){
			startPractice();
		});
		powerMenu.add(btn);
		
		var btn = new Button("Start");
		btn.resize(btn.text.width + 20, btn.text.height + 40);
		btn.onClickSignaler.bindVoid(function(){
			startTest();
		});
		powerMenu.add(btn);
		
		_x += HXP.stage.stageWidth;
	}
	
	override public function end():Void {
		super.end();
		
		if (selectedMethod != null)
			HXP.engine.asMain().cursorManager.inputMethod = selectedMethod;
	}
}