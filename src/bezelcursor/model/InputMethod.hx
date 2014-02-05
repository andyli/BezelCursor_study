package bezelcursor.model;

using Std;
using Lambda;

#if !php
import bezelcursor.cursor.BubbleMouseCursor;
import bezelcursor.cursor.BubbleStickCursor;
import bezelcursor.cursor.MagStickCursor;
import bezelcursor.cursor.MouseCursor;
import bezelcursor.cursor.StickCursor;
import bezelcursor.world.*;
import flash.Lib;
import flash.geom.*;
import com.haxepunk.*;
#end
import bezelcursor.model.*;

typedef CursorSetting = {
	_class:String,
	data:Dynamic
}

class InputMethod implements IStruct {
	public var name(default, null):String;
	public var forScreen(default, null):CursorSetting;
	public var forBezel(default, null):CursorSetting;
	public var forThumbSpace(default, null):CursorSetting;
	public var requireOverlayButton(default, null):Bool;

	/**
	* Width in inches to be considered as bezel.
	*/
	public var bezelWidth(default, null):Float = 0.15;
	var bezelOut(get, null):Rectangle;
	function get_bezelOut() {
		return bezelOut != null ? bezelOut : bezelOut = new Rectangle(0, 0, Lib.stage.stageWidth, Lib.stage.stageHeight);
	}
	var bezelIn(get, null):Rectangle;
	function get_bezelIn() {
		return bezelIn != null ? bezelIn : {
			var bezelWidthPx = DeviceData.current.screenDPI * bezelWidth;
			bezelIn = bezelOut.clone();
			bezelIn.inflate(-bezelWidthPx, -bezelWidthPx);
			bezelIn;
		};
	}

	dynamic public function insideBezel(touch:TouchData):Bool {
		var pt = new Point(touch.x, touch.y);
		return bezelOut.containsPoint(pt) && !bezelIn.containsPoint(pt);
	}
	
	public function new(name:String, ?forScreen:CursorSetting, ?forBezel:CursorSetting, ?forThumbSpace:CursorSetting, requireOverlayButton:Bool = false, insideBezel:TouchData->Bool = null):Void {
		this.name = name;
		this.forScreen = forScreen;
		this.forBezel = forBezel;
		this.forThumbSpace = forThumbSpace;
		this.requireOverlayButton = requireOverlayButton;
		if (insideBezel != null)
			this.insideBezel = insideBezel;
	}
	
	static public var None(default, never):InputMethod = new InputMethod(
		"None",
		null,
		null,
		null,
		false
	);
	
	static public var PracticalBezelCursor(default, never):InputMethod = new InputMethod(
		"BezelCursor",
		{ _class: "bezelcursor.cursor.StickCursor", data: {
			drawRadius: null,
			scaleFactor: 1,
			jointActivateDistance: Math.POSITIVE_INFINITY,
			dynaScale: null,
			drawStick: null,
			default_radius: 0
		} },
		{ _class: "bezelcursor.cursor.StickCursor", data: {} },
		null,
		false
	);
	
	static public var PracticalButtonCursor(default, never):InputMethod = new InputMethod(
		"ButtonCursor",
		{ _class: "bezelcursor.cursor.StickCursor", data: {
			drawRadius: null,
			scaleFactor: 1,
			jointActivateDistance: Math.POSITIVE_INFINITY,
			dynaScale: null,
			drawStick: null,
			default_radius: 0
		} },
		{ _class: "bezelcursor.cursor.StickCursor", data: {} },
		null,
		true,
		function(touch:TouchData):Bool {
			var testTouchWorld = HXP.world.instance(TestTouchWorld);
			var startBtn = testTouchWorld == null ? null : testTouchWorld.startBtn;
			if (startBtn != null && startBtn.visible && startBtn.collidePoint(startBtn.x, startBtn.y, touch.x, touch.y)) {
				return true;
			}
			return false;
		}
	);
	
	static public var DirectTouch(default, never):InputMethod = new InputMethod(
		"Direct touch",
		{ _class: "bezelcursor.cursor.StickCursor", data: {
			drawRadius: null,
			scaleFactor: 1,
			jointActivateDistance: Math.POSITIVE_INFINITY,
			dynaScale: null,
			drawStick: null,
			default_radius: 0
		} },
		null,
		null,
		false
	);
	
	static public var BezelCursor_acceleratedDynaSpot(default, never):InputMethod = new InputMethod(
		"BezelCursor - accelerated DynaSpot",
		null,
		{ _class: "bezelcursor.cursor.MouseCursor", data: {} },
		null,
		false
	);
	
	static public var BezelCursor_directMappingDynaSpot(default, never):InputMethod = new InputMethod(
		"BezelCursor - direct mapping DynaSpot",
		null,
		{ _class: "bezelcursor.cursor.StickCursor", data: {} },
		null,
		false
	);
	
	static public var BezelCursor_acceleratedBubbleCursor(default, never):InputMethod = new InputMethod(
		"BezelCursor - accelerated Bubble",
		null,
		{ _class: "bezelcursor.cursor.BubbleMouseCursor", data: {} },
		null,
		false
	);
	
	static public var BezelCursor_directMappingBubbleCursor(default, never):InputMethod = new InputMethod(
		"BezelCursor - direct mapping Bubble",
		null,
		{ _class: "bezelcursor.cursor.BubbleStickCursor", data: {} },
		null,
		false
	);
	
	static public var MagStick(default, never):InputMethod = new InputMethod(
		"MagStick",
		{ _class: "bezelcursor.cursor.MagStickCursor", data: {} },
		null,
		null,
		false
	);
	
	static public var ThumbSpace(default, never):InputMethod = new InputMethod(
		"ThumbSpace",
		{ _class: "bezelcursor.cursor.StickCursor", data: {
			drawRadius: null,
			scaleFactor: 1,
			jointActivateDistance: Math.POSITIVE_INFINITY,
			dynaScale: null,
			drawStick: null,
			default_radius: 0
		} },
		null,
		{ _class: "bezelcursor.cursor.BubbleMouseCursor", data: { 
			drawBubble: null,
			drawStick: null
		}},
		true
	);
}