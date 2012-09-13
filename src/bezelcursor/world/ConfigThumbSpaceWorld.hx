package bezelcursor.world;

import com.haxepunk.HXP;
import com.haxepunk.World;
import nme.Lib;

using bezelcursor.Main;

class ConfigThumbSpaceWorld extends GameWorld {	
	public function new():Void {
		super();
	}
	
	override public function begin():Void {
		super.begin();
		
		var cm = HXP.engine.asMain().cursorManager;
		cm.thumbSpaceEnabled = true;
		cm.startThumbSpaceConfig();
		Lib.stage.addChild(cm.thumbSpaceView);
	}
	
	override public function update():Void {
		var cm = HXP.engine.asMain().cursorManager;
		switch (cm.thumbSpaceConfigState) {
			case Configured:
				HXP.engine.asMain().cursorManager.thumbSpaceEnabled = false;
				HXP.world = HXP.engine.asMain().worldQueue.pop();
				return;
			default:
				
		}
	}
}