package bezelcursor.world;

import com.haxepunk.HXP;

using bezelcursor.Main;
import bezelcursor.entity.Button;
import bezelcursor.entity.PowerMenu;
import bezelcursor.model.InputMethods;
import bezelcursor.model.TaskBlockData;
using bezelcursor.world.GameWorld;
using bezelcursor.world.TestTouchWorld;

class PowerMenuWorld extends GameWorld {
	var powerMenu:PowerMenu;
	public function new():Void {
		super();
		
		add(powerMenu = new PowerMenu());

		powerMenu.add(createBtnForMethod(InputMethods.BezelCursor_acceleratedBubbleCursor));
		powerMenu.add(createBtnForMethod(InputMethods.BezelCursor_acceleratedDynaSpot));
		powerMenu.add(createBtnForMethod(InputMethods.BezelCursor_directMappingDynaSpot));
		powerMenu.add(createBtnForMethod(InputMethods.MagStick));
		powerMenu.add(createBtnForMethod(InputMethods.ThumbSpace));
	}
	
	static function createBtnForMethod(method:InputMethod):Button {
		var btn = new Button(method.name);
		btn.resize(btn.text.width + 20, btn.text.height + 20);
		btn.onClickSignaler.bindVoid(function() {
			HXP.engine.asMain().cursorManager.createCursor = method.createCursor;
			HXP.world = new TestTouchWorld(HXP.engine.asMain().taskblocks[0]);
		});
		return btn;
	}
}