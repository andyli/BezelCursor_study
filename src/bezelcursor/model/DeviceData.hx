package bezelcursor.model;

import nme.system.Capabilities;
#if android
import nme.JNI;
#end

class DeviceData extends Struct {
	/**
	* uuid of length 36
	*/
	public var id(default,null):String;
	public var systemName(default,null):String;
	public var systemVersion(default,null):Null<String>;
	public var hardwareModel(default,null):Null<String>;
	public var screenResolutionX(default,null):Float;
	public var screenResolutionY(default,null):Float;
	public var screenDPI(default,null):Float;
	public var lastRemoteSyncTime(default,null):Null<Float>;
	public var lastLocalSyncTime(default,null):Float;
	
	public function new():Void {
		id = org.casalib.util.StringUtil.uuid();
	}
	

	public static var sharedObject(get_sharedObject, null):nme.net.SharedObject;
	static function get_sharedObject():nme.net.SharedObject {
		if (sharedObject != null) 
			return sharedObject;
		else
			return sharedObject = nme.net.SharedObject.getLocal("DeviceData");
	}
	
	
	public static var current(get_current, null):DeviceData;
	static function get_current():DeviceData {
		if (current != null) return current;
		

		current = new DeviceData();
		
		//overwrite anyway, use only the old id
		if (sharedObject.data.current != null) {
			current.id = sharedObject.data.current.id;
		}
		
		{
			current.systemName = if (BuildData.current.isAndroid) {
				"Android";
			} else if (BuildData.current.isIos) {
				"iOS";
			} else {
				#if sys
				Sys.systemName();
				#elseif flash
				"Flash";
				#else
				"";
				#end
			}
			
			#if (sys && !ios)
			current.systemVersion = getSystemVersion();
			#elseif flash
			current.systemVersion = Capabilities.os;
			#end
			
			#if android
			current.hardwareModel = getHardwareModel();
			#end
			
			current.screenResolutionX = Capabilities.screenResolutionX;
			current.screenResolutionY = Capabilities.screenResolutionY;
			
			#if !mac
			current.screenDPI = Capabilities.screenDPI;
			#else
			current.screenDPI = 129;	
			#end
			
			current.lastLocalSyncTime = Date.now().getTime();
			sharedObject.data.current = current.toObj();
			sharedObject.flush();
		}
		
		return current;
	}
	
	#if android
	
		static var _getSystemVersion:Dynamic;
		static public function getSystemVersion():String {
			if (_getSystemVersion == null) _getSystemVersion = JNI.createStaticMethod("net.onthewings.bezelcursor.MainActivity", "getSystemVersion", "()Ljava/lang/String;");
			return _getSystemVersion();
		}

		static var _getHardwareModel:Dynamic;
		static public function getHardwareModel():String {
			if (_getHardwareModel == null) _getHardwareModel = JNI.createStaticMethod("net.onthewings.bezelcursor.MainActivity", "getHardwareModel", "()Ljava/lang/String;");
			return _getHardwareModel();
		}
	
	#elseif sys
	
		static public function getSystemVersion():String {
			return switch (Sys.systemName()){
				case "Mac", "Linux":
					new sys.io.Process("uname", ["-mrsn"]).stdout.readAll().toString();
				case "Windows":
					new sys.io.Process("ver", []).stdout.readAll().toString();
				default:
					throw "unknown system: " + Sys.systemName();
			}
		}
	
	#end
}