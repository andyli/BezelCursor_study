package bezelcursor.model;

import bezelcursor.util.BuildDataHelper;

class BuildData implements IStruct {
	static public var current(get_current, null):BuildData;
	static function get_current():BuildData {
		return current != null ? current : {
			current = new BuildData();
			current.isDebug = #if debug true #else false #end;
			current.isAndroid = #if android true #else false #end;
			current.isIos = #if ios true #else false #end;
			current.isCpp = #if cpp true #else false #end;
			current.isFlash = #if flash true #else false #end;
			current.isPhp = #if php true #else false #end;
			current.isMac = #if mac true #else false #end;
			current.isWindows = #if windows true #else false #end;
			current.isLinux = #if linux true #else false #end;
			current.buildTime = BuildDataHelper.getTime();
			current;
		}
	}
	
	public function new():Void{ }
	
	public var isDebug(default, null):Bool;
	public var isAndroid(default, null):Bool;
	public var isIos(default, null):Bool;
	public var isCpp(default, null):Bool;
	public var isFlash(default, null):Bool;
	public var isPhp(default, null):Bool;
	public var isMac(default, null):Bool;
	public var isWindows(default, null):Bool;
	public var isLinux(default, null):Bool;
	public var buildTime(default, null):Float;
	//public var gitLog(default, null):String = BuildDataHelper.getGitLog();
}