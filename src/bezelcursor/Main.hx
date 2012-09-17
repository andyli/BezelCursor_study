package bezelcursor;

using Lambda;
using StringTools;
import com.haxepunk.*;
import nme.display.Sprite;
import nme.events.KeyboardEvent;
import nme.ui.Keyboard;
import nme.Lib;

import bezelcursor.cursor.*;
import bezelcursor.entity.*;
import bezelcursor.model.*;
import bezelcursor.model.db.*;
import bezelcursor.world.*;

class Main extends Engine {
	public var cursorManager:CursorManager;
	public var isFirstRun:Bool;
	public var powerMenu:PowerMenu;
	public var taskblocks:Array<TaskBlockData>;
	public var worldQueue:List<World>;
	
	public function new():Void {
		super(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight, 30, true);
	}

	override public function init():Void {		
		HXP.screen.color = 0x333333;
		HXP.screen.scale = 1;
		
		#if !js
		HXP.console.enable();
		#end
		#if !debug
		HXP.console.visible = false;
		#end
		
		initStorage();
		
		cursorManager = new CursorManager();
		cursorManager.start();

		worldQueue = new List<World>();

		HXP.world = new ServerConnectionWorld();

		//Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
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
					HXP.world = new PowerMenuWorld();
			#else
				case Keyboard.SPACE:
					HXP.console.visible = !HXP.console.visible;
				case Keyboard.ESCAPE:
					HXP.world = new PowerMenuWorld();
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