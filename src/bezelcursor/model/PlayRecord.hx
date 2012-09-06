package bezelcursor.model;

class PlayRecord {
	/**
	* uuid of length 36
	*/
	public var id:Int;
	public var creationTime:Float;
	public var device:DeviceData;
	public var isPortrait:Bool;
	public var user:UserData;
	public var eventRecords:Array<EventRecord>;
}