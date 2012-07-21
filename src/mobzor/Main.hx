package mobzor;

import com.haxepunk.Engine;
import com.haxepunk.HXP;
import nme.display.Sprite;
import nme.events.KeyboardEvent;
import nme.ui.Keyboard;
import nme.Lib;

class Main extends Engine {
	
	public function new():Void {
		super(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight, 30, false);
	}

	override public function init():Void {		
		HXP.screen.color = 0x333333;
		HXP.screen.scale = 1;
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		//HXP.world = 
		
	}
	
	function onKeyUp(evt:KeyboardEvent):Void {
		switch(evt.keyCode) {
			case Keyboard.ESCAPE:
				HXP.console.enable();
		}
	}
	
	public static function main():Void {
		Lib.current.addChild(new Main());
	}
}