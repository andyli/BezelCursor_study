package mobzor.cursor.behavior;

import nme.events.Event;
import nme.events.TouchEvent;
import mobzor.cursor.Cursor;

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
	
	public function onTouchBegin(evt:TouchEvent):Void {
		
	}
	
	public function onTouchMove(evt:TouchEvent):Void {
		
	}
	
	public function onTouchEnd(evt:TouchEvent):Void {
		
	}
}