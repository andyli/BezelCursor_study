package bezelcursor.model;

using Lambda;

import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.CursorManager;

typedef CursorSetting = {
	_class:Class<Cursor>,
	data:Dynamic
}

class InputMethod implements IStruct {
	public var name:String;
	public var forScreen:CursorSetting;
	public var forBezel:CursorSetting;
	public var forThumbSpace:CursorSetting;
	
	public function new(name:String, ?forScreen:CursorSetting, ?forBezel:CursorSetting, ?forThumbSpace:CursorSetting):Void {
		this.name = name;
		this.forScreen = forScreen;
		this.forBezel = forBezel;
		this.forThumbSpace = forThumbSpace;
	}
	
	static public var None:InputMethod = new InputMethod(
		"None",
		null,
		null,
		null
	);
	
	static public var BezelCursor_acceleratedDynaSpot:InputMethod = new InputMethod(
		"BezelCursor - accelerated DynaSpot",
		null,
		{ _class: bezelcursor.cursor.MouseCursor, data: {} },
		null
	);
	
	static public var BezelCursor_directMappingDynaSpot:InputMethod = new InputMethod(
		"BezelCursor - direct mapping DynaSpot",
		null,
		{ _class: bezelcursor.cursor.StickCursor, data: {} },
		null
	);
	
	static public var BezelCursor_acceleratedBubbleCursor:InputMethod = new InputMethod(
		"Bezelcursor - accelerated BubbleCursor",
		null,
		{ _class: bezelcursor.cursor.BubbleMouseCursor, data: {} },
		null
	);
	
	static public var MagStick:InputMethod = new InputMethod(
		"MagStick",
		{ _class: bezelcursor.cursor.MagStickCursor, data: {} },
		null,
		null
	);
	
	static public var ThumbSpace:InputMethod = new InputMethod(
		"ThumbSpace",
		null,
		null,
		{ _class: bezelcursor.cursor.BubbleMouseCursor, data: { drawBubble: false } }
	);
}