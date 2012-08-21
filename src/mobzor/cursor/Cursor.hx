package mobzor.cursor;

import nme.geom.Point;
import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;

class Cursor {
	static var nextId = 0;
	
	public var onActivateSignaler(default, null):Signaler<Point>;
	public var onMoveSignaler(default, null):Signaler<Point>;
	public var onClickSignaler(default, null):Signaler<Point>;
	public var onEndSignaler(default, null):Signaler<Void>;
	public var id(default, null):Int;
	
	public function new():Void {
		id = nextId++;
		
		onActivateSignaler = new DirectSignaler<Point>(this);
		onMoveSignaler = new DirectSignaler<Point>(this);
		onClickSignaler = new DirectSignaler<Point>(this);
		onEndSignaler = new DirectSignaler<Void>(this);
	}
	
	public function start():Void {
	
	}
	
	public function end():Void {
		onEndSignaler.dispatch();
	}
}
