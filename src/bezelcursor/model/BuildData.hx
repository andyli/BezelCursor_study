package bezelcursor.model;

import bezelcursor.util.BuildDataHelper;

class BuildData implements IStruct {
	static public var current(get_current, null):BuildData;
	static function get_current():BuildData {
		return current != null ? current : current = new BuildData();
	}
	
	public function new():Void{}
	public var isDebug(default, null) = #if debug true #else false #end;
	public var isAndroid(default, null) = #if android true #else false #end;
	public var isIos(default, null) = #if ios true #else false #end;
	public var isCpp(default, null) = #if cpp true #else false #end;
	public var isFlash(default, null) = #if flash true #else false #end;
	public var isPhp(default, null) = #if php true #else false #end;
	public var isMac(default, null) = #if mac true #else false #end;
	public var isWindows(default, null) = #if windows true #else false #end;
	public var isLinux(default, null) = #if linux true #else false #end;
	public var buildTime(default, null):Float = BuildDataHelper.getTime();
	//public var gitLog(default, null):String = BuildDataHelper.getGitLog();
}