package bezelcursor.model;

class StageData extends Struct {
	/**
	* uuid of length 36
	*/
	public var id(default,null):String;
	
	public var width:Int;
	public var height:Int;
	
	public var targets:Array<TargetData>;
	
	public function new():Void {
		id = org.casalib.util.StringUtil.uuid();
		width = 3;
		height = 4;
	}
	

	public static var sharedObject(get_sharedObject, null):nme.net.SharedObject;
	static function get_sharedObject():nme.net.SharedObject {
		if (sharedObject != null) 
			return sharedObject;
		else
			return sharedObject = nme.net.SharedObject.getLocal("StageData");
	}
}