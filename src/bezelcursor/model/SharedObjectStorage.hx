package bezelcursor.model;

import nme.net.SharedObject;

typedef SharedObjectStorageData = {
	currentDevice:DeviceInfo,
	currentUser:UserInfo
}

class SharedObjectStorage {
	public static var instance(get_instance, null):SharedObject;
	static function get_instance():SharedObject {
		if (instance != null) 
			return instance;
		else
			return instance = SharedObject.getLocal("BezelCursorData");
	}
	
	public static var data(get_data, null):SharedObjectStorageData;
	static function get_data():SharedObjectStorageData {
		return get_instance().data;
	}
}