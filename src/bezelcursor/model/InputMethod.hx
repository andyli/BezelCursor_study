package bezelcursor.model;

using Lambda;

#if !php
import bezelcursor.cursor.BubbleMouseCursor;
import bezelcursor.cursor.BubbleStickCursor;
import bezelcursor.cursor.MagStickCursor;
import bezelcursor.cursor.MouseCursor;
import bezelcursor.cursor.StickCursor;
#end

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
	
	public function new(name:String, ?forScreen:CursorSetting, ?forBezel:CursorSetting, ?forThumbSpace:CursorSetting, requireOverlayButton:Bool = false):Void {
		this.name = name;
		this.forScreen = forScreen;
		this.forBezel = forBezel;
		this.forThumbSpace = forThumbSpace;
		this.requireOverlayButton = requireOverlayButton;
	}
	
	static public var None:InputMethod = new InputMethod(
		"None",
		null,
		null,
		null,
		false
	);
	
	static public var PracticalBezelCursor:InputMethod = new InputMethod(
		"Practical BezelCursor",
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
	
	static public var DirectTouch:InputMethod = new InputMethod(
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
	
	static public var BezelCursor_acceleratedDynaSpot:InputMethod = new InputMethod(
		"BezelCursor - accelerated DynaSpot",
		null,
		{ _class: "bezelcursor.cursor.MouseCursor", data: {} },
		null,
		false
	);
	
	static public var BezelCursor_directMappingDynaSpot:InputMethod = new InputMethod(
		"BezelCursor - direct mapping DynaSpot",
		null,
		{ _class: "bezelcursor.cursor.StickCursor", data: {} },
		null,
		false
	);
	
	static public var BezelCursor_acceleratedBubbleCursor:InputMethod = new InputMethod(
		"BezelCursor - accelerated Bubble",
		null,
		{ _class: "bezelcursor.cursor.BubbleMouseCursor", data: {} },
		null,
		false
	);
	
	static public var BezelCursor_directMappingBubbleCursor:InputMethod = new InputMethod(
		"BezelCursor - direct mapping Bubble",
		null,
		{ _class: "bezelcursor.cursor.BubbleStickCursor", data: {} },
		null,
		false
	);
	
	static public var MagStick:InputMethod = new InputMethod(
		"MagStick",
		{ _class: "bezelcursor.cursor.MagStickCursor", data: {} },
		null,
		null,
		false
	);
	
	static public var ThumbSpace:InputMethod = new InputMethod(
		"ThumbSpace",
		null,
		null,
		{ _class: "bezelcursor.cursor.BubbleMouseCursor", data: { 
			drawBubble: null,
			drawStick: null
		}},
		true
	);
}