package mobzor.model;

import nme.geom.Point;

import mobzor.cursor.Cursor;

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
	
	static public function fromCursor(cursor:Cursor):CursorData {
		var data = new CursorData();
		data.id = cursor.id;
		data.currentPoint = cursor.currentPoint;
		data.targetPoint = cursor.targetPoint;
		data.cursorClass = Type.getClassName(Type.getClass(cursor));
	}
}