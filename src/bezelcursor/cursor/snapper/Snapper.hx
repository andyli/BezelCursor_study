package bezelcursor.cursor.snapper;

import bezelcursor.cursor.Cursor;
import bezelcursor.entity.Target;

class Snapper<C:Cursor> {
	public var cursor(default, null):C;
	public var lastSnapTarget(default, null):Null<Target>;
	public var lastInterestedTargets(default, null):Array<Target>;
	
	public function new(c:C):Void {
		cursor = c;
		lastSnapTarget = null;
	}
	
	/**
	* Get the Target for a cursor. Returns null if none is suitable.
	* Usually no need to override this one. Override getInterestedTargets instead.
	*/
	public function getSnapTarget():Null<Target> {		
		return lastSnapTarget = getInterestedTargets().length > 0 ? lastInterestedTargets[0] : null;
	}
	
	/**
	* Return the interested targets(usually based on distance to the cursor).
	* Sorted as the most suitable ones come first.
	*/
	public function getInterestedTargets():Array<Target> {
		return lastInterestedTargets = [];
	}
}