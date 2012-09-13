package bezelcursor.cursor.snapper;

import bezelcursor.cursor.Cursor;
import bezelcursor.entity.Target;
import bezelcursor.model.IStruct;

class Snapper<C:Cursor> implements IStruct {
	public var cursor(default, null):C;
	
	/**
	* The Target for a cursor. null if none is suitable.
	*/
	public var target(get_target, null):Null<Target>;
	function get_target():Null<Target> {
		return interestedTargets.length > 0 ? interestedTargets[0] : null;
	}
	
	/**
	* The interested targets(usually based on distance to the cursor).
	* Sorted as the most suitable ones come first.
	*/
	public var interestedTargets(default, null):Array<Target>;
	
	public function new(c:C):Void {
		cursor = c;
		target = null;
		interestedTargets = [];
	}
	
	public function run():Void {
		interestedTargets = [];
	}
}