package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.TouchData;

class Behavior<C:Cursor> {
	public var cursor(default, null):C;
	
	public function new(c:C):Void {
		cursor = c;
	}
	
	public function start():Void {
		
	}
	
	public function end():Void {
		
	}
	
	public function onFrame():Void {		
		
	}
	
	public function onTouchBegin(touch:TouchData):Void {
		
	}
	
	public function onTouchMove(touch:TouchData):Void {
		
	}
	
	public function onTouchEnd(touch:TouchData):Void {
		
	}
}