package bezelcursor.model;

using Lambda;

import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.CursorManager;

typedef InputMethod = {
	name:String,
	createCursor: TouchData->CreateCursorFor->Cursor
}

class InputMethods {
	static public var BezelCursor_acceleratedDynaSpot = {
		name: "BezelCursor - accelerated DynaSpot",
		createCursor: function(touch:TouchData, _for:CreateCursorFor):Cursor {
			switch(_for) {
				case ForBezel: 
					return new bezelcursor.cursor.MouseCursor().fromObj({touchPointID: touch.touchPointID});
				default:
					return null;
			}
		}
	}
	
	static public var BezelCursor_directMappingDynaSpot = {
		name: "BezelCursor - direct mapping DynaSpot",
		createCursor: function(touch:TouchData, _for:CreateCursorFor):Cursor {
			switch(_for) {
				case ForBezel: 
					return new bezelcursor.cursor.StickCursor().fromObj({touchPointID: touch.touchPointID});
				default:
					return null;
			}
		}
	}
	
	static public var BezelCursor_acceleratedBubbleCursor = {
		name: "Bezelcursor - accelerated BubbleCursor",
		createCursor: function(touch:TouchData, _for:CreateCursorFor):Cursor {
			switch(_for) {
				case ForBezel: 
					return new bezelcursor.cursor.BubbleMouseCursor().fromObj({touchPointID: touch.touchPointID});
				default:
					return null;
			}
		}
	}
	
	static public var MagStick = {
		name: "MagStick",
		createCursor: function(touch:TouchData, _for:CreateCursorFor):Cursor {
			switch(_for) {
				case ForScreen: 
					return new bezelcursor.cursor.MagStickCursor().fromObj({touchPointID: touch.touchPointID});
				default:
					return null;
			}
		}
	}
	
	static public var ThumbSpace = {
		name: "ThumbSpace",
		createCursor: function(touch:TouchData, _for:CreateCursorFor):Cursor {
			switch(_for) {
				case ForThumbSpace: 
					var c = new bezelcursor.cursor.BubbleMouseCursor().fromObj({touchPointID: touch.touchPointID});
					c.behaviors.remove(c.behaviors.filter(function(b) return Std.is(b, bezelcursor.cursor.behavior.DrawBubble)).first());
					return c;
				default:
					return null;
			}
		}
	}
}