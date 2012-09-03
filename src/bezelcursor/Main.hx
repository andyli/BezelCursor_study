package bezelcursor;

import com.haxepunk.Engine;
import com.haxepunk.HXP;
import nme.display.Sprite;
import nme.events.KeyboardEvent;
import nme.ui.Keyboard;
import nme.Lib;

import bezelcursor.cursor.CursorManager;
import bezelcursor.model.BuildInfo;
import bezelcursor.model.DeviceInfo;
import bezelcursor.model.Env;
import bezelcursor.model.UserInfo;
import bezelcursor.world.TestTouchWorld;

class Main extends Engine {
	public var cursorManager:CursorManager;
	public var isFirstRun:Bool;
	
	public function new():Void {
		super(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight, 30, true);
	}

	override public function init():Void {		
		HXP.screen.color = 0x333333;
		HXP.screen.scale = 1;
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		#if !js
		HXP.console.enable();
		#end
		//HXP.console.visible = false;
		
		initStorage();

		cursorManager = new CursorManager();
		cursorManager.start();

		HXP.world = new TestTouchWorld();
	}
	
	function initStorage():Void {
		try {
			isFirstRun = DeviceInfo.sharedObject.data.current == null;
		}catch(e:Dynamic){
			isFirstRun = true;
		}
		
		trace(new DeviceInfo());
		trace(isFirstRun ? "isFirstRun" : "not isFirstRun");
		trace(DeviceInfo.current.id);
		trace(UserInfo.current.id);
		/*
		for (f in Type.getInstanceFields(DeviceInfo)) {
			trace(f + " " + Reflect.getProperty(DeviceInfo.current, f));
		}
		*/
	}
	
	function onKeyUp(evt:KeyboardEvent):Void {
		switch(evt.keyCode) {
			#if android
				case Keyboard.ESCAPE:
					Sys.exit(0);
			#else
				case Keyboard.ESCAPE:
					HXP.console.visible = !HXP.console.visible;
			#end
		}
	}
	
	static public function main():Void {
		Lib.current.addChild(new Main());
	}
	
	static public function asMain(e:Engine):Main {
		return cast e;
	}
}