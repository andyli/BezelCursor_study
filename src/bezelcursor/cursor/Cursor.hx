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

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.snapper.Snapper;
import bezelcursor.cursor.snapper.SimpleSnapper;
import bezelcursor.entity.Target;
import bezelcursor.model.TouchData;
using bezelcursor.model.Struct;

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
	* Color of the view.
	*/
	public var color:Int;
	
	/**
	* The visual graphics of the cursor.
	* It is automatically added to the stage on `start` and removed on `end`.
	*/
	public var view(default, null):Sprite;
	
	/**
	* Basically Lib.stage.
	*/
	public var stage(default, null):Stage;
	
	public function new(?config:Dynamic):Void {
		id = config != null && Reflect.hasField(config, "id") ? config.id : nextId++;
		color = config != null && Reflect.hasField(config, "color") ? config.color : 0xFF0000;
		current_position = config != null && Reflect.hasField(config, "current_position") ? config.current_position.toPoint() : null;
		target_position = config != null && Reflect.hasField(config, "target_position") ? config.target_position.toPoint() : null;
		current_radius = config != null && Reflect.hasField(config, "current_radius") ? config.current_radius :  0.001;
		target_radius = config != null && Reflect.hasField(config, "target_radius") ? config.target_radius :  0.001;
		default_radius = config != null && Reflect.hasField(config, "default_radius") ? config.default_radius : 0.001;
		
		//behaviors = config != null && Reflect.hasField(config, "behaviors") ? config.behaviors : [];
		//snapper = config != null && Reflect.hasField(config, "snapper") ? config.snapper : new SimpleSnapper(this);
		behaviors = [];
		snapper = new SimpleSnapper(this);
		
		stage = Lib.stage;
		view = new Sprite();
		view.mouseEnabled = false;
		
		onActivateSignaler = new DirectSignaler<Point>(this);
		onMoveSignaler = new DirectSignaler<Point>(this);
		onClickSignaler = new DirectSignaler<Point>(this);
		onEndSignaler = new DirectSignaler<Void>(this);
	}
	
	public function dispatch(signaler:Signaler<Point>):Void {
		var snapTarget = snapper.target;
		if (snapTarget != null) {
			signaler.dispatch(new Point(snapTarget.centerX, snapTarget.centerY));
		} else {
			signaler.dispatch(current_position);
		}
	}
	
	function onFrame(evt:Event = null):Void {
		snapper.run();
			
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
		
		view.graphics.clear();
		for (behavior in behaviors) {
			behavior.onFrame();
		}
	}
	
	public function onTouchBegin(touch:TouchData):Void {
		current_radius = target_radius = default_radius;
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

    function hxSerialize(s:haxe.Serializer) {
		s.serialize(getConfig());
    }
	
    function hxUnserialize(s:haxe.Unserializer) {
		setConfig(s.unserialize());
    }
	
	public function getConfig():Dynamic {
		var config:Dynamic = {};
		
		config._class = Type.getClass(this).string();
		config.id = id;
		config.current_position = current_position.toObj();
		config.target_position = target_position.toObj();
		config.current_radius = current_radius;
		config.target_radius = target_radius;
		config.behaviors = behaviors.copy();
		config.snapper = snapper;
		config.color = color;
		
		return config;
	}
	
	public function setConfig(config:Dynamic):Void {
		#if debug
		if (config._class != Type.getClass(this).string())
			throw "Should not set " + Type.getClass(this).string() + "from a config of " + config._class;
		#end
		id = config.id;
		current_position = config.current_position.toPoint();
		target_position = config.target_position.toPoint();
		current_radius = config.current_radius;
		target_radius = config.target_radius;
		default_radius = config.default_radius;
		behaviors = config.behaviors;
		snapper = config.snapper;
		color = config.color;
	}
	
	public function clone():Cursor {
		return new Cursor(getConfig());
	}
	
	static public function createFromConfig<C:Cursor>(config:Dynamic):C {
		return Type.createInstance(Type.resolveClass(config._class), [config]);
	}
}
