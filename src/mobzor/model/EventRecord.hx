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
	ETouchDown(x:Float, y:Float, size:Float);
	ETouchMove(x:Float, y:Float, size:Float);
	ETouchUp(x:Float, y:Float, size:Float);
	ETapped(x:Float, y:Float, ?targetId:Int);
	ECursorAdded(x:Float, y:Float);
	ECursorHover(x:Float, y:Float);
	ECursorClicked(x:Float, y:Float, ?targetId:Int);
	ECursorRemoved(x:Float, y:Float);
	ETargetAdded(id:Int, type:String, x:Float, y:Float, w:Float, h:Float);
	ETargetRemoved(id:Int);
	EEnd;
}