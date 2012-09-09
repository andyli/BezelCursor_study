package bezelcursor.model;

class TargetData extends Struct {
	public var _class:String;
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var color:Int;
	public var color_hover:Int;
	public var image:Null<String>;
	public var image_hover:Null<String>;
	
	public function new(x:Float, y:Float, width:Float, height:Float):Void {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		
		this._class = Std.string(bezelcursor.entity.Target);
		this.color = 0xFFFFFF;
		this.color_hover = 0xFF6666;
	}
}