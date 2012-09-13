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
using bezelcursor.model.Struct;
using bezelcursor.world.GameWorld;

class Cursor {
	static var nextId = 0;
	
	public var onStartSignaler(default, null):Signaler<Point>;
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
	* Color of the view.
	*/
	public var color:Int;
	
	/**
	* The visual graphics of the cursor.
	* It is automatically added to the stage on `start` and removed on `end`.
	*/
	public var view(default, null):Sprite;
	
	var positionXFilter:OneEuroFilter;
	var positionYFilter:OneEuroFilter;
	var radiusFilter:OneEuroFilter;
	
	public function new(?data:Dynamic):Void {
		id = data != null && Reflect.hasField(data, "id") ? data.id : nextId++;
		color = data != null && Reflect.hasField(data, "color") ? data.color : 0xFF0000;
		current_position = data != null && Reflect.hasField(data, "current_position") ? data.current_position.toPoint() : null;
		target_position = data != null && Reflect.hasField(data, "target_position") ? data.target_position.toPoint() : null;
		current_radius = data != null && Reflect.hasField(data, "current_radius") ? data.current_radius :  0.001;
		target_radius = data != null && Reflect.hasField(data, "target_radius") ? data.target_radius :  0.001;
		default_radius = data != null && Reflect.hasField(data, "default_radius") ? data.default_radius : 0.001;
		
		//behaviors = data != null && Reflect.hasField(data, "behaviors") ? data.behaviors : [];
		snapper = data != null && Reflect.hasField(data, "snapper") ? Snapper.createFromData(this, data.snapper) : new SimpleSnapper(this);
		behaviors = data != null && Reflect.hasField(data, "behaviors") ? Behavior.createFromDatas(this, data.behaviors) : [];
		
		onStartSignaler = new DirectSignaler<Point>(this);
		onMoveSignaler = new DirectSignaler<Point>(this);
		onClickSignaler = new DirectSignaler<Point>(this);
		onEndSignaler = new DirectSignaler<Void>(this);
		
		positionXFilter = new OneEuroFilter(Lib.stage.frameRate, 1, 0.2);
		positionYFilter = new OneEuroFilter(Lib.stage.frameRate, 1, 0.2);
		radiusFilter = new OneEuroFilter(Lib.stage.frameRate);
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
		onEndSignaler.dispatch();
	}

    function hxSerialize(s:haxe.Serializer) {
		s.serialize(getData());
    }
	
    function hxUnserialize(s:haxe.Unserializer) {
		setData(s.unserialize());
    }
	
	public function getData():Dynamic {
		var data:Dynamic = {};
		
		data._class = Type.getClassName(Type.getClass(this));
		data.id = id;
		data.current_position = current_position.toObj();
		data.target_position = target_position.toObj();
		data.current_radius = current_radius;
		data.target_radius = target_radius;
		data.behaviors = []; for (b in behaviors) data.behaviors.push(b.getData());
		data.snapper = snapper.getData();
		data.color = color;
		
		return data;
	}
	
	public function setData(data:Dynamic):Void {
		#if debug
		if (data._class != Type.getClassName(Type.getClass(this)))
			throw "Should not set " + Type.getClassName(Type.getClass(this)) + "from a data of " + data._class;
		#end
		id = data.id;
		current_position = data.current_position.toPoint();
		target_position = data.target_position.toPoint();
		current_radius = data.current_radius;
		target_radius = data.target_radius;
		default_radius = data.default_radius;
		behaviors = data.behaviors;
		snapper = Snapper.createFromData(this, data.snapper);
		color = data.color;
	}
	
	public function clone():Cursor {
		return new Cursor(getData());
	}
	
	static public function createFromData<C:Cursor>(data:Dynamic):C {
		return Type.createInstance(Type.resolveClass(data._class), [data]);
	}
}
