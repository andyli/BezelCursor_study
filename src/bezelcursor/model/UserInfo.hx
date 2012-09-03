package bezelcursor.model;

class UserInfo extends Struct {
	/**
	* uuid of length 36
	*/
	public var id(default,null):String;
	public var userName:String;
	public var userEmail:Null<String>;
	
	public function new():Void {
		id = org.casalib.util.StringUtil.uuid();
	}
	

	public static var sharedObject(get_sharedObject, null):nme.net.SharedObject;
	static function get_sharedObject():nme.net.SharedObject {
		if (sharedObject != null) 
			return sharedObject;
		else
			return sharedObject = nme.net.SharedObject.getLocal("UserInfo");
	}
	
	
	public static var current(get_current, null):UserInfo;
	static function get_current():UserInfo {
		if (current != null) return current;
		
		try {
			#if !flash
			current = sharedObject.data.current;
			#else
			current = new UserInfo();
			current.fromObj(sharedObject.data.current);
			#end
		}catch(e:Dynamic){}
		
		if (current == null) {
			current = new UserInfo();
			
			current.userName = "User";
			
			sharedObject.data.current = current;
			sharedObject.flush();
		}
		return current;
	}
}