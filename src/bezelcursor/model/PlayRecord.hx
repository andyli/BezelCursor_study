package bezelcursor.model;

class PlayRecord {
	/**
	* uuid of length 36
	*/
	public var id:Int;
	public var creationTime:Float;
	public var device:DeviceInfo;
	public var isPortrait:Bool;
	public var user:UserInfo;
	public var eventRecords:Array<EventRecord>;
}