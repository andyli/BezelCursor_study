package mobzor.model;

import sys.db.Types;
import haxe.Serializer;
import haxe.Unserializer;

class PlayRecord extends sys.db.Object {
	public var id:SUId;
	public var creationDate:STimeStamp;
	public var device:DeviceInfo;
	public var isPortrait:SBool;
	public var userName:STinyText;
	public var userEmail:SNull<STinyText>;

	var eventRecordsData:SSerialized;
	@:skip public var eventRecords(get_eventRecords, set_eventRecords):Array<EventRecord>;
	function get_eventRecords():Array<EventRecord> {
		return unserializer.run(eventRecordsData);
	}
	function set_eventRecords(v:Array<EventRecord>):Array<EventRecord> {
		eventRecordsData = serializer.run(v);
		return v;
	}
	
	public static var manager = new sys.db.Manager(PlayRecord);
	static var serializer = new Serializer();
	static var unserializer = new Unserializer();
}