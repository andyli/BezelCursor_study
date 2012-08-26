package mobzor;

import com.haxepunk.Engine;
import com.haxepunk.HXP;
import nme.display.Sprite;
import nme.events.KeyboardEvent;
import nme.ui.Keyboard;
import nme.Lib;

import mobzor.cursor.CursorManager;
import mobzor.world.TestTouchWorld;

class Main extends Engine {
	public var cursorManager:CursorManager;
	
	public function new():Void {
		super(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight, 30, true);
	}

	override public function init():Void {		
		HXP.screen.color = 0x333333;
		HXP.screen.scale = 1;
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		HXP.console.enable();
		#if (!debug)
		//HXP.console.visible = false;
		#end

		cursorManager = new CursorManager();
		cursorManager.start();

		HXP.world = new TestTouchWorld();
	}
	
	function onKeyUp(evt:KeyboardEvent):Void {
		switch(evt.keyCode) {
			case Keyboard.ESCAPE:
				HXP.console.visible = !HXP.console.visible;
		}
	}
	
	static public function main():Void {
		Lib.current.addChild(new Main());
	}
	
	static public function asMain(e:Engine):Main {
		return cast e;
	}
}