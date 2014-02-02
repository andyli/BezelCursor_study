package bezelcursor.model;

class TouchData implements IStruct {
	public var touchPointID(default, null):Int;
	public var x:Float;
	public var y:Float;
	public var sizeX:Float;
	public var sizeY:Float;
	
	public function new(touchPointID:Int, x:Float, y:Float, sizeX:Float, sizeY:Float):Void {
		this.touchPointID = touchPointID;
		this.x = x;
		this.y = y;
		this.sizeX = sizeX;
		this.sizeY = sizeY;
	}
	
	public function clone():TouchData {
		return new TouchData(touchPointID, x, y, sizeX, sizeY);
	}
	
	#if !php
	static public function fromTouchEvent(evt:flash.events.TouchEvent):TouchData {
		#if js
		return new TouchData(evt.touchPointID, evt.stageX, evt.stageY, 1, 1);
		#else
		return new TouchData(evt.touchPointID, evt.stageX, evt.stageY, evt.sizeX, evt.sizeY);
		#end
	}
	
	static public function fromMouseEvent(evt:flash.events.MouseEvent):TouchData {
		return new TouchData(0, evt.stageX, evt.stageY, 1, 1);
	}
	#end
}