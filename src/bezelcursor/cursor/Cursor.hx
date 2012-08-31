package bezelcursor.cursor;

using Std;
import nme.Lib;
import nme.display.Stage;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.TouchEvent;
import nme.geom.Point;
import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.snapper.Snapper;
import bezelcursor.cursor.snapper.SimpleSnapper;
import bezelcursor.entity.Target;

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
	public var currentPoint:Point;
	
	/**
	* Where this cursor is heading to.
	*/
	public var targetPoint:Point;
	
	
	//in inch
	public var currentSize:Float;
	public var targetSize:Float;
	public var startSize:Float;
	
	/**
	* The Behavior instances that define how the cursor behaves.
	*/
	public var behaviors(default, null):Array<Behavior<Dynamic>>;
	
	public var snapper(default, null):Snapper<Dynamic>;
	
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
		behaviors = [];
		snapper = new SimpleSnapper(this);
		targetSize = currentSize = startSize = 0.001;
		
		onActivateSignaler = new DirectSignaler<Point>(this);
		onMoveSignaler = new DirectSignaler<Point>(this);
		onClickSignaler = new DirectSignaler<Point>(this);
		onEndSignaler = new DirectSignaler<Void>(this);
	}
	
	public function dispatch(signaler:Signaler<Point>):Void {
		var snapTarget = snapper.getSnapTarget();
		if (snapTarget != null) {
			signaler.dispatch(new Point(snapTarget.centerX, snapTarget.centerY));
		} else {
			signaler.dispatch(currentPoint);
		}
	}
	
	function onFrame(evt:Event = null):Void {		
		if (targetPoint != null) {
			if (currentPoint == null) {
				currentPoint = targetPoint;
				onActivateSignaler.dispatch(currentPoint);
			} else if (!currentPoint.equals(targetPoint)) {
				var pt = targetPoint.subtract(currentPoint);
				pt.normalize(pt.length * stage.frameRate.map(0, 30, 1, 0.78));
				currentPoint = currentPoint.add(pt);
			}
			
			dispatch(onMoveSignaler);
		}
		
		currentSize += (targetSize - currentSize) * stage.frameRate.map(0, 30, 1, 0.3);
		
		for (behavior in behaviors) {
			behavior.onFrame();
		}
	}
	
	public function onTouchBegin(evt:TouchEvent):Void {
		targetSize = currentSize = startSize;
		
		for (behavior in behaviors) {
			behavior.onTouchBegin(evt);
		}
	}
	
	public function onTouchMove(evt:TouchEvent):Void {
		for (behavior in behaviors) {
			behavior.onTouchMove(evt);
		}
	}
	
	public function onTouchEnd(evt:TouchEvent):Void {
		for (behavior in behaviors) {
			behavior.onTouchEnd(evt);
		}
	}
	
	public function start():Void {
		stage.addChild(view);
		stage.addEventListener(Event.ENTER_FRAME, onFrame);
		
		for (behavior in behaviors) {
			behavior.start();
		}
	}
	
	public function end():Void {
		for (behavior in behaviors) {
			behavior.end();
		}
		stage.removeEventListener(Event.ENTER_FRAME, onFrame);
		stage.removeChild(view);
		currentPoint = targetPoint = null;
		onEndSignaler.dispatch();
	}
	
	public function clone():Cursor {
		var cursor = new Cursor();
		cursor.id = id;
		cursor.currentPoint = currentPoint;
		cursor.targetPoint = targetPoint;
		cursor.behaviors = behaviors.copy();
		return cursor;
	}
	
    function hxSerialize( s : haxe.Serializer ) {
		s.serialize(id);
        s.serialize(currentPoint);
        s.serialize(targetPoint);
		s.serialize(behaviors);
    }
    function hxUnserialize( s : haxe.Unserializer ) {
		id = s.unserialize();
        currentPoint = s.unserialize();
        targetPoint = s.unserialize();
		behaviors = s.unserialize();
    }
}
