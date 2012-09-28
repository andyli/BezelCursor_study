package bezelcursor.cursor;

using Std;
import nme.Lib;
import nme.display.Sprite;
import nme.events.Event;
import nme.geom.Point;
import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;
using org.casalib.util.NumberUtil;
import com.haxepunk.HXP;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.snapper.Snapper;
import bezelcursor.cursor.snapper.SimpleSnapper;
import bezelcursor.entity.Target;
import bezelcursor.model.TouchData;
import bezelcursor.model.IStruct;

using bezelcursor.world.GameWorld;

class Cursor implements IStruct {
	static var nextId = 0;
	
	@skip public var onStartSignaler(default, null):Signaler<Void>;
	@skip public var onMoveSignaler(default, null):Signaler<Target>;
	@skip public var onClickSignaler(default, null):Signaler<Target>;
	@skip public var onEndSignaler(default, null):Signaler<Void>;
	
	public var id(default, null):Int;
	
	/**
	* Position of where the cursor is pointing to.
	*/
	@skip public var position(get_position, set_position):Point;
	var target_position:Point;
	var current_position:Point;
	function get_position():Point { return current_position; }
	function set_position(v:Point):Point { return target_position = v; }
	
	@skip public var positionRecord:List<{
		position:Point,
		time:Float
	}>;
	
	/**
	* The radius(in inch) of this cursor, which define the interest area used by snapper.
	*/
	@skip public var radius(get_radius, set_radius):Float;
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
	* Color of the view.
	*/
	public var color:Int;
	
	/**
	* The visual graphics of the cursor.
	* It is automatically added to the stage on `start` and removed on `end`.
	*/
	@skip public var view(default, null):Sprite;
	
	var radiusFilter:OneEuroFilter;
	
	var ignoreTime:Float;
	
	public function new():Void {
		id = nextId++;
		color = 0xFF0000;
		current_position = null;
		target_position = null;
		current_radius =  0.001;
		target_radius =  0.001;
		default_radius = 0.001;
		ignoreTime = 0.05;
		
		behaviors = [];
		snapper = new SimpleSnapper(this);
		
		radiusFilter = new OneEuroFilter(Lib.stage.frameRate);
		
		init();
	}
	
	public function init():Cursor {
		onStartSignaler = new DirectSignaler<Void>(this);
		onMoveSignaler = new DirectSignaler<Target>(this);
		onClickSignaler = new DirectSignaler<Target>(this);
		onEndSignaler = new DirectSignaler<Void>(this);
		
		positionRecord = new List();
		
		return this;
	}
	
	public function click():Void {
		dispatch(onClickSignaler);
		if (snapper.target != null) {
			snapper.target.click(this);
		}
	}
	
	function dispatch(signaler:Signaler<Target>):Void {
		var snapTarget = snapper.target;
		if (snapTarget != null) {
			signaler.dispatch(snapTarget);
		} else {
			signaler.dispatch(null);
		}
	}
	
	public function onFrame(timestamp:Float):Void {
		if (target_position != null) {
			current_position = target_position.clone();
			positionRecord.add({
				position: current_position,
				time: timestamp
			});
			while (timestamp - positionRecord.first().time > ignoreTime) {
				positionRecord.pop();
			}
		
			current_radius = radiusFilter.filter(target_radius, timestamp);
		
			view.graphics.clear();
			for (behavior in behaviors) {
				behavior.onFrame(timestamp);
			}

			var lastTarget = snapper.target;
			snapper.run();
			if (snapper.target != lastTarget) {
				if (lastTarget != null) {
					lastTarget.rollOut(this);
				}
				if (snapper.target != null) {
					snapper.target.rollOver(this);
				}
			}
		
			dispatch(onMoveSignaler);
		}
	}
	
	public function onTouchBegin(touch:TouchData):Void {
		for (behavior in behaviors) {
			behavior.onTouchBegin(touch);
		}
	}
	
	public function onTouchMove(touch:TouchData):Void {
		for (behavior in behaviors) {
			behavior.onTouchMove(touch);
		}
	}
	
	public function onTouchEnd(touch:TouchData):Void {
		for (behavior in behaviors) {
			behavior.onTouchEnd(touch);
		}
	}
	
	public function start():Void {
		view = new Sprite();
		view.mouseEnabled = false;
		
		Lib.stage.addChild(view);

		current_radius = target_radius = default_radius;
		
		for (behavior in behaviors) {
			behavior.start();
		}
		
		onStartSignaler.dispatch();
	}
	
	public function end():Void {
		for (behavior in behaviors) {
			behavior.end();
		}
		if (snapper.target != null) {
			snapper.target.rollOut(this);
		}
		Lib.stage.removeChild(view);
		current_position = target_position = null;
		onEndSignaler.dispatch();
	}
	
	public function setImmediatePosition(pt:Point):Void {
		current_position = target_position = pt;
		var timestamp = haxe.Timer.stamp();
		positionRecord.clear();
		onFrame(timestamp);
	}
}