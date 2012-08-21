package mobzor.cursor;

import nme.Lib;
import nme.display.Stage;
import nme.display.Sprite;
import nme.events.Event;
import nme.geom.Point;
import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;
using org.casalib.util.NumberUtil;

class Cursor {
	static var nextId = 0;
	
	public var onActivateSignaler(default, null):Signaler<Point>;
	public var onMoveSignaler(default, null):Signaler<Point>;
	public var onClickSignaler(default, null):Signaler<Point>;
	public var onEndSignaler(default, null):Signaler<Void>;
	
	public var id(default, null):Int;
	
	/**
	* Current pointing position.
	*/
	public var currentPoint(default, null):Point;
	
	/**
	* Where this cursor is heading to.
	*/
	public var targetPoint(default, null):Point;
	
	/**
	* The visual graphics of the cursor.
	* It is automatically added to the stage on `start` and removed on `end`.
	*/
	public var view(default, null):Sprite;
	
	/**
	* Basically Lib.stage.
	*/
	public var stage(default, null):Stage;
	
	public function new():Void {
		id = nextId++;
		stage = Lib.stage;
		view = new Sprite();
		
		onActivateSignaler = new DirectSignaler<Point>(this);
		onMoveSignaler = new DirectSignaler<Point>(this);
		onClickSignaler = new DirectSignaler<Point>(this);
		onEndSignaler = new DirectSignaler<Void>(this);
	}
	
	function onFrame(evt:Event = null):Void {
		if (targetPoint != null) {
			if (currentPoint == null) {
				currentPoint = targetPoint;
				onActivateSignaler.dispatch(currentPoint);
				onMoveSignaler.dispatch(currentPoint);
			} else if (!currentPoint.equals(targetPoint)) {
				var pt = targetPoint.subtract(currentPoint);
				pt.normalize(pt.length * stage.frameRate.map(0, 30, 1, 0.78));
				currentPoint = currentPoint.add(pt);
				onMoveSignaler.dispatch(currentPoint);
			}
		}
	}
	
	public function start():Void {
		stage.addChild(view);
		stage.addEventListener(Event.ENTER_FRAME, onFrame);
	}
	
	public function end():Void {
		stage.removeEventListener(Event.ENTER_FRAME, onFrame);
		stage.removeChild(view);
		currentPoint = targetPoint = null;
		onEndSignaler.dispatch();
	}
}
