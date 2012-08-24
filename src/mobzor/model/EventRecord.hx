package mobzor.model;

import sys.db.Types;

class EventRecord {
	public function new(type:EventRecordType):Void {
		this.timestamp = Sys.cpuTime();
		this.type = type;
	}
	
	public var timestamp(default,null):Float;
	public var type(default,null):EventRecordType;
}

enum EventRecordType {
	EStart;
	ETouchDown(touchId:Int, x:Float, y:Float, size:Float);
	ETouchMove(touchId:Int, x:Float, y:Float, size:Float);
	ETouchUp(touchId:Int, x:Float, y:Float, size:Float);
	ETapped(touchId:Int, x:Float, y:Float, size:Float, ?targetId:Int);
	ECursorAdded(cursorId:Int, x:Float, y:Float);
	ECursorHover(cursorId:Int, x:Float, y:Float);
	ECursorClicked(cursorId:Int, x:Float, y:Float, ?targetId:Int);
	ECursorRemoved(cursorId:Int, x:Float, y:Float);
	ETargetAdded(targetId:Int, type:String, x:Float, y:Float, w:Float, h:Float);
	ETargetRemoved(targetId:Int);
	EEnd;
}