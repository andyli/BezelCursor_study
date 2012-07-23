package mobzor.world;

import com.haxepunk.HXP;
import com.haxepunk.World;
import nme.display.Sprite;

import mobzor.cursor.Cursor;
import mobzor.cursor.StickCursor;
import mobzor.entity.Target;
import mobzor.event.CursorEvent;
using mobzor.event.CursorEventType;

using org.casalib.util.NumberUtil;

class TestTouchWorld extends World {
	public var cursor:Cursor;
	public var target:Target;

	override public function begin():Void {
		super.begin();
		
		cursor = new StickCursor();
		cursor.start();
		
		target = new Target(cursor);
		add(target);
	}
	
	override public function end():Void {
		
		cursor.end();
		
		super.end();
	}
	
	function onCursorClick(evt:CursorEvent):Void {
		
	}
}
