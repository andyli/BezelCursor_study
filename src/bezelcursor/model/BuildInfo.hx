package bezelcursor.model;

class BuildInfo {
	static public var current(get_current, null):BuildInfo;
	static function get_current():BuildInfo {
		return current != null ? current : current = new BuildInfo();
	}
	
	function new():Void{}
	public var isDebug = #if debug true #else false #end;
	public var isAndroid = #if android true #else false #end;
	public var isIos = #if ios true #else false #end;
	public var isCpp = #if cpp true #else false #end;
	public var isFlash = #if flash true #else false #end;
	public var isMac = #if mac true #else false #end;
	public var isWindows = #if windows true #else false #end;
	public var isLinux = #if linux true #else false #end;
}