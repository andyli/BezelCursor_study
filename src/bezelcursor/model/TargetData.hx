package bezelcursor.model;

typedef TargetData = {
	@:optional public var _class:String;
	@:optional public var id:Int;
	@:optional public var x:Float;
	@:optional public var y:Float;
	@:optional public var width:Float;
	@:optional public var height:Float;
	@:optional public var color:Int;
	@:optional public var color_hover:Int;
	@:optional public var image:Null<String>;
	@:optional public var image_hover:Null<String>;
}