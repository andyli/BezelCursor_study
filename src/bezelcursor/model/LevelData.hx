package bezelcursor.model;

class LevelData implements IStruct {
	/**
	* uuid of length 36
	*/
	public var id(default, null):String;

	public var targets:Array<TargetData>;
	public var region:Int;

	public function new(region:Int):Void {
		id = org.casalib.util.StringUtil.uuid();
		this.region = region;
	}

	inline public function iterator()
		return targets.iterator();
}