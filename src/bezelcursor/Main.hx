package bezelcursor;

using Lambda;
using StringTools;
import com.haxepunk.*;
import com.haxepunk.utils.*;
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
	
	public function new():Void {
		super(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight, 30, true);
	}

	override public function init():Void {		
		HXP.screen.color = 0x333333;
		HXP.screen.scale = 1;
		
		initStorage();
		
		cursorManager = new CursorManager();
		cursorManager.start();
		
		if (TaskBlockData.current == null){
			HXP.world = new ServerConnectionWorld();
		} else {
			HXP.world = new PowerMenuWorld();
		}
		
		Input.define("menu", [Keyboard.SPACE, 0x01000012]);
		Input.define("back", [Keyboard.ESCAPE]);
		//Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
	}
	
	function initStorage():Void {
		try {
			isFirstRun = DeviceData.sharedObject.data.current == null;
		}catch(e:Dynamic){
			isFirstRun = true;
		}
		
		/*
		trace(isFirstRun ? "isFirstRun" : "not isFirstRun");
		trace(DeviceData.current.id);
		trace(UserData.current.id);
		*/
	}
	
	var escCount = 0;
	var escStamp = 0.0;
	function onKey(evt:KeyboardEvent):Void {
		switch(evt.keyCode) {
			case Keyboard.ESCAPE:
				if (!Std.is(HXP.world, TestTouchWorld)) {
					Sys.exit(0);
				}
				
				if (++escCount >= 5) {
					if (haxe.Timer.stamp() - escStamp <= 1) {
						Sys.exit(0);
					}
					escCount = 0;
				}

				if (escCount == 1) {
					escStamp = haxe.Timer.stamp();
				}
			default:
				escCount = 0;
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