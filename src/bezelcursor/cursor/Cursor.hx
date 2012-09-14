package bezelcursor.cursor;

using Std;
import nme.Lib;
import nme.display.Stage;
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
	
	@skip public var onStartSignaler(default, null):Signaler<Point>;
	@skip public var onMoveSignaler(default, null):Signaler<Point>;
	@skip public var onClickSignaler(default, null):Signaler<Point>;
	@skip public var onEndSignaler(default, null):Signaler<Point>;
	
	public var id(default, null):Int;
	
	/**
	* Position of where the cursor is pointing to.
	*/
	@skip public var position(get_position, set_position):Point;
	var target_position:Point;
	var current_position:Point;
	function get_position():Point { return current_position; }
	function set_position(v:Point):Point { return target_position = v; }
	
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
	
	var positionXFilter:OneEuroFilter;
	var positionYFilter:OneEuroFilter;
	var radiusFilter:OneEuroFilter;
	
	public function new():Void {
		id = nextId++;
		color = 0xFF0000;
		current_position = null;
		target_position = null;
		current_radius =  0.001;
		target_radius =  0.001;
		default_radius = 0.001;
		
		behaviors = [];
		snapper = new SimpleSnapper(this);
		
		positionXFilter = new OneEuroFilter(Lib.stage.frameRate, 1, 0.2);
		positionYFilter = new OneEuroFilter(Lib.stage.frameRate, 1, 0.2);
		radiusFilter = new OneEuroFilter(Lib.stage.frameRate);
		
		init();
	}
	
	public function init():Cursor {
		onStartSignaler = new DirectSignaler<Point>(this);
		onMoveSignaler = new DirectSignaler<Point>(this);
		onClickSignaler = new DirectSignaler<Point>(this);
		onEndSignaler = new DirectSignaler<Point>(this);
		
		return this;
	}
	
	public function click():Void {
		dispatch(onClickSignaler);
		if (snapper.target != null) {
			snapper.target.click(this);
		}
	}
	
	function dispatch(signaler:Signaler<Point>):Void {
		var snapTarget = snapper.target;
		if (snapTarget != null) {
			signaler.dispatch(HXP.world.asGameWorld().worldToScreen(new Point(snapTarget.centerX, snapTarget.centerY)));
		} else {
			signaler.dispatch(current_position);
		}
	}
	
	public function onFrame(timestamp:Float):Void {
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
			
		if (target_position != null) {
			if (current_position == null) {
				onStartSignaler.dispatch(current_position);
			}
			current_position = new Point(
				positionXFilter.filter(target_position.x, timestamp),
				positionYFilter.filter(target_position.y, timestamp)
			);
			
			dispatch(onMoveSignaler);
		}
		
		current_radius = radiusFilter.filter(target_radius, timestamp);
		
		view.graphics.clear();
		for (behavior in behaviors) {
			behavior.onFrame(timestamp);
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
		onEndSignaler.dispatch(position);
	}
}