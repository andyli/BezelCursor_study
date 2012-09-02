package bezelcursor.model;

class UserInfo {
	/**
	* uuid of length 36
	*/
	public var id(default,null):String;
	public var userName:String;
	public var userEmail:Null<String>;
	
	public function new():Void {
		id = org.casalib.util.StringUtil.uuid();
	}
	
	public static var current(get_current, null):UserInfo;
	static function get_current():UserInfo {
		if (current != null) return current;
		
		var storageData = SharedObjectStorage.data;
		if ((current = storageData.currentUser) == null) {
			current = new UserInfo();
			
			current.userName = "User";
			
			storageData.currentUser = current;
			SharedObjectStorage.instance.flush();
		}
		
		return current;
	}
}