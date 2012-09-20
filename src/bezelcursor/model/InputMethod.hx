package bezelcursor.model;

using Lambda;

#if !php
import bezelcursor.cursor.BubbleMouseCursor;
import bezelcursor.cursor.MagStickCursor;
import bezelcursor.cursor.MouseCursor;
import bezelcursor.cursor.StickCursor;
#end

typedef CursorSetting = {
	_class:String,
	data:Dynamic
}

class InputMethod implements IStruct {
	public var name:String;
	public var forScreen:CursorSetting;
	public var forBezel:CursorSetting;
	public var forThumbSpace:CursorSetting;
	public var requireOverlayButton:Bool;
	
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
	
	static public var DirectTouch:InputMethod = new InputMethod(
		"Direct touch",
		{ _class: "bezelcursor.cursor.StickCursor", data: {
			drawRadius: null,
			scaleFactor: 1,
			jointActivateDistance: Math.POSITIVE_INFINITY,
			dynaScale: null,
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
		"Bezelcursor - accelerated BubbleCursor",
		null,
		{ _class: "bezelcursor.cursor.BubbleMouseCursor", data: {} },
		null,
		false
	);
	
	static public var MagStick:InputMethod = new InputMethod(
		"MagStick",
		{ _class: "bezelcursor.cursor.MagStickCursor", data: {} },
		null,
		null,
		true
	);
	
	static public var ThumbSpace:InputMethod = new InputMethod(
		"ThumbSpace",
		null,
		null,
		{ _class: "bezelcursor.cursor.BubbleMouseCursor", data: { drawBubble: null } },
		true
	);
}