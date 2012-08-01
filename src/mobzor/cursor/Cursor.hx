package mobzor.cursor;

import nme.geom.Point;
import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;

class Cursor {
	public var onClickSignaler:Signaler<Point>;
	public var onMoveSignaler:Signaler<Point>;
	
	public function new():Void {
		onClickSignaler = new DirectSignaler<Point>(this);
		onMoveSignaler = new DirectSignaler<Point>(this);
	}
	
	public function start():Void {
	
	}
	
	public function end():Void {
	
	}
}
