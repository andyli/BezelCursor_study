package bezelcursor.model;

class UserData implements IStruct {
	/**
	* uuid of length 36
	*/
	public var id(default,null):String;
	public var name:String;
	
	public function new():Void {
		id = org.casalib.util.StringUtil.uuid();
	}
	

	public static var sharedObject(get_sharedObject, null):nme.net.SharedObject;
	static function get_sharedObject():nme.net.SharedObject {
		if (sharedObject != null) 
			return sharedObject;
		else
			return sharedObject = nme.net.SharedObject.getLocal("UserData");
	}
	
	
	public static var current(get_current, null):UserData;
	static function get_current():UserData {
		if (current != null) return current;
		
		current = new UserData();
		
		if (sharedObject.data.current == null) {
			current.name = "User";
			
			sharedObject.data.current = current.toObj();
			sharedObject.flush();
		} else {
			current.fromObj(sharedObject.data.current);
		}
		
		return current;
	}
}