package bezelcursor.model;

import sys.db.Types;

class DeviceInfo extends sys.db.Object {
	public var id:SUId;
	public var systemName:STinyText;
	public var screenResolutionX:SFloat;
	public var screenResolutionY:SFloat;
	public var screenDPI:SFloat;
	public var pixelAspectRatio:SFloat;
	
	public static var manager = new sys.db.Manager(DeviceInfo);
}