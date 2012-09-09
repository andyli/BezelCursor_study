package bezelcursor;

using Lambda;
import com.haxepunk.Engine;
import com.haxepunk.HXP;
import nme.display.Sprite;
import nme.events.KeyboardEvent;
import nme.ui.Keyboard;
import nme.Lib;

import bezelcursor.cursor.CursorManager;
import bezelcursor.entity.Target;
import bezelcursor.model.BuildData;
import bezelcursor.model.DeviceData;
import bezelcursor.model.Env;
import bezelcursor.model.UserData;
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
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		
		#if !js
		HXP.console.enable();
		#end
		//HXP.console.visible = false;
		
		initStorage();

		cursorManager = new CursorManager();
		cursorManager.start();

		var taskblocks = bezelcursor.model.TaskBlockData.generateTaskBlocks();
		HXP.world = new TestTouchWorld(taskblocks[0]);
	}
	
	function initStorage():Void {
		try {
			isFirstRun = DeviceData.sharedObject.data.current == null;
		}catch(e:Dynamic){
			isFirstRun = true;
		}
		
		trace(isFirstRun ? "isFirstRun" : "not isFirstRun");
		trace(DeviceData.current.id);
		trace(UserData.current.id);
		
		/*
		for (f in Type.getInstanceFields(DeviceData)) {
			trace(f + " " + Reflect.getProperty(DeviceData.current, f));
		}
		*/
	}
	
	function onKey(evt:KeyboardEvent):Void {
		switch(evt.keyCode) {
			#if android
				case Keyboard.ESCAPE:
					Sys.exit(0);
				case 0x01000012: //MENU
					
			#else
				case Keyboard.ESCAPE:
					HXP.console.visible = !HXP.console.visible;
			#end
		}
		evt.stopImmediatePropagation();
	}
	
	static public function main():Void {
		Lib.current.addChild(new Main());
	}
	
	static public function asMain(e:Engine):Main {
		return cast e;
	}
}