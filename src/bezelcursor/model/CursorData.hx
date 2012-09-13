package bezelcursor.model;

import nme.geom.Point;

import bezelcursor.cursor.Cursor;

class CursorData {
	public var id(default, null):Int;
	
	/**
	* Current pointing position.
	*/
	public var currentPoint(default, null):Point;
	
	/**
	* Where this cursor is heading to.
	*/
	public var targetPoint(default, null):Point;
	
	public var cursorClass(default, null):String;
		
	public function new():Void {
		
	}
}