package bezelcursor.model;

class TargetData extends Struct {
	public var _class:String;
	public var id:Int;
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var color:Int;
	public var color_hover:Int;
	public var image:Null<String>;
	public var image_hover:Null<String>;
	
	public function new():Void {
		
	}
}