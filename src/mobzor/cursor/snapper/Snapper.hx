package mobzor.cursor.snapper;

import mobzor.cursor.Cursor;
import mobzor.entity.Target;

class Snapper<C:Cursor> {
	public var cursor(default, null):C;
	public var lastSnapTarget(default, null):Null<Target>;
	
	public function new(c:C):Void {
		cursor = c;
		lastSnapTarget = null;
	}
	
	public function getSnapTarget():Null<Target> {
		return lastSnapTarget = null;
	}
}