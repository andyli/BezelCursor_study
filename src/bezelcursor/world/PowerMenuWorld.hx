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
import bezelcursor.model.InputMethods;
import bezelcursor.model.TaskBlockData;
import bezelcursor.model.DeviceData;
using bezelcursor.world.GameWorld;
using bezelcursor.world.TestTouchWorld;
using bezelcursor.util.UnitUtil;

class PowerMenuWorld extends GameWorld {
	var selectedMethod:InputMethod;
	var selectedTargetSize:{width:Float, height:Float};
	public function new():Void {
		super();
		
		var dpi = DeviceData.current.screenDPI;
		remove(startBtn);
		
		var _x = 0;
		
		var powerMenu = new PowerMenu();
		powerMenu.x = _x;
		add(powerMenu);
	
		function createBtnForMethod(method:InputMethod):Button {
			var btn = new Button(method.name);
			btn.resize(btn.text.width + 20, btn.text.height + 20);
			btn.onClickSignaler.bindVoid(function() {
				selectedMethod = method;
				HXP.engine.asMain().cursorManager.createCursor = selectedMethod.createCursor;
				camera.tween(0.5, { x: powerMenu.x + powerMenu.width });
			});
			return btn;
		}

		powerMenu.add(createBtnForMethod(InputMethods.BezelCursor_acceleratedBubbleCursor));
		powerMenu.add(createBtnForMethod(InputMethods.BezelCursor_acceleratedDynaSpot));
		powerMenu.add(createBtnForMethod(InputMethods.BezelCursor_directMappingDynaSpot));
		powerMenu.add(createBtnForMethod(InputMethods.MagStick));
		//powerMenu.add(createBtnForMethod(InputMethods.ThumbSpace));
		
		_x += HXP.stage.stageWidth;
		
		
		
		
		var powerMenu = new PowerMenu();
		powerMenu.x = _x;
		add(powerMenu);
		
		var btn = new Button("Back");
		btn.resize(btn.text.width + 5, btn.text.height + 5);
		btn.onClickSignaler.bindVoid(function(){
			camera.tween(0.5, { x: powerMenu.x - powerMenu.width });
		});
		powerMenu.add(btn);
		
		for (targetSize in TaskBlockData.targetSizes) {
			var btn = new Button(targetSize.name);
			btn.resize(btn.text.width + 20, btn.text.height + 20);
			btn.onClickSignaler.bindVoid(function(){
				selectedTargetSize = targetSize;
				camera.tween(0.5, { x: powerMenu.x + powerMenu.width })
					.onComplete(function(){
						add(startBtn);
					});
			});
			powerMenu.add(btn);
		}
		
		_x += HXP.stage.stageWidth;
		
		
		
		for (i in 0...5) {
			var powerMenu = new PowerMenu();
			powerMenu.x = _x;
			add(powerMenu);
		
			var btn = new Button("Back");
			btn.resize(btn.text.width + 5, btn.text.height + 5);
			btn.onClickSignaler.bindVoid(function(){
				remove(startBtn);
				camera.tween(0.5, { x: powerMenu.x - powerMenu.width })
					.onComplete(function(){
						if(i > 0)
							add(startBtn);
					});
			});
			powerMenu.add(btn);
		
			var rect = new Rectangle(0, 0, HXP.stage.stageWidth * 0.8, dpi * 2.5);
			rect.x = (HXP.stage.stageWidth - rect.width) * 0.5 + _x;
			rect.y = btn.text.height + 20;
		
			var btn = new RandomMovingTarget( rect, {
				color: 0xFF0000,
				color_hover: 0x00FF00
			});
			btn.onAddedSignaler.bindVoid(function(){
				btn.resize(Math.round(selectedTargetSize.width), Math.round(selectedTargetSize.height));	
			});
			btn.onClickSignaler.bindVoid(function(){
				if (i == 4) {
					HXP.world = new TestTouchWorld(HXP.engine.asMain().taskblocks.filter(function(tb){
						return tb.targetSize.width == selectedTargetSize.width && tb.targetSize.height == selectedTargetSize.height;
					}).first());
					return;
				}
				remove(startBtn);
				
				camera.tween(0.5, { x: powerMenu.x + powerMenu.width })
					.onComplete(function(){
						add(startBtn);
					});
			});
			add(btn);
		
			_x += HXP.stage.stageWidth;
		}
	}
}