package bezelcursor.cursor.behavior;

import bezelcursor.cursor.Cursor;
import bezelcursor.model.TouchData;
import bezelcursor.model.IStruct;

class Behavior<C:Cursor> implements IStruct {
	@skip public var cursor(default, null):C;
	
	var _class:String;
	
	public function new(c:C):Void {
		cursor = c;
	}
	
	public function init() {		
		_class = Type.getClassName(Type.getClass(this));
		return this;
	}
	
	public function start():Void {
		
	}
	
	public function end():Void {
		
	}
	
	public function onFrame(timestamp:Float):Void {		
		
	}
	
	public function onTouchBegin(touch:TouchData):Void {
		
	}
	
	public function onTouchMove(touch:TouchData):Void {
		
	}
	
	public function onTouchEnd(touch:TouchData):Void {
		
	}
}