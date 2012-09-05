package bezelcursor.model;

class TouchData extends Struct {
	public var touchPointID(default, null):Int;
	public var x(default, null):Float;
	public var y(default, null):Float;
	public var sizeX(default, null):Float;
	public var sizeY(default, null):Float;
	
	public function new(touchPointID:Int, x:Float, y:Float, sizeX:Float, sizeY:Float):Void {
		this.touchPointID = touchPointID;
		this.x = x;
		this.y = y;
		this.sizeX = sizeX;
		this.sizeY = sizeY;
	}
	
	static public function fromTouchEvent(evt:nme.events.TouchEvent):TouchData {
		return new TouchData(evt.touchPointID, evt.stageX, evt.stageY, evt.sizeX, evt.sizeY);
	}
	
	static public function fromMouseEvent(evt:nme.events.MouseEvent):TouchData {
		return new TouchData(0, evt.stageX, evt.stageY, 1, 1);
	}
}