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
	* Position of where the cursor is pointing to.
	*/
	public var position(get_position, set_position):Point;
	var target_position:Point;
	var current_position:Point;
	function get_position():Point { return current_position; }
	function set_position(v:Point):Point { return target_position = v; }
	
	/**
	* The radius(in inch) of this cursor, which define the interest area used by snapper.
	*/
	public var radius(get_radius, set_radius):Float;
	var default_radius:Float;
	var target_radius:Float;
	var current_radius:Float;
	function get_radius():Float { return current_radius; }
	function set_radius(v:Float):Float { return target_radius = v; }
	
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
		view.mouseEnabled = false;
		behaviors = [];
		snapper = new SimpleSnapper(this);
		current_radius = target_radius = default_radius = 0.001;
		
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
			signaler.dispatch(current_position);
		}
	}
	
	function onFrame(evt:Event = null):Void {		
		if (target_position != null) {
			if (current_position == null) {
				current_position = target_position;
				onActivateSignaler.dispatch(current_position);
			} else if (!current_position.equals(target_position)) {
				var pt = target_position.subtract(current_position);
				pt.normalize(pt.length * stage.frameRate.map(0, 30, 1, 0.78));
				current_position = current_position.add(pt);
			}
			
			dispatch(onMoveSignaler);
		}
		
		current_radius += (target_radius - current_radius) * stage.frameRate.map(0, 30, 1, 0.3);
		
		for (behavior in behaviors) {
			behavior.onFrame();
		}
	}
	
	public function onTouchBegin(evt:TouchEvent):Void {
		current_radius = target_radius = default_radius;
		
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
		current_position = target_position = null;
		onEndSignaler.dispatch();
	}
	
	public function clone():Cursor {
		var cursor = new Cursor();
		cursor.id = id;
		cursor.current_position = current_position;
		cursor.target_position = target_position;
		cursor.current_radius = current_radius;
		cursor.target_radius = target_radius;
		cursor.behaviors = behaviors.copy();
		return cursor;
	}
}
