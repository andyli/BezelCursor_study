package bezelcursor.entity;

using Std;
using Lambda;
import hsl.haxe.Signal;
import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;
import nme.geom.Point;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.Graphiclist;
using com.eclecticdesignstudio.motion.Actuate;

using bezelcursor.Main;
import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.CursorManager;
using bezelcursor.model.IStruct;
using bezelcursor.world.GameWorld;

class Target extends Entity, implements IStruct {
	inline static public var TYPE = "Target";
	static var nextId = 0;
	
	@:skip public var onAddedSignaler(default, null):Signaler<Void>;
	@:skip public var onRemovedSignaler(default, null):Signaler<Void>;
	@:skip public var onClickSignaler(default, null):Signaler<Void>;
	@:skip public var onRollOverSignaler(default, null):Signaler<Void>;
	@:skip public var onRollOutSignaler(default, null):Signaler<Void>;
	
	@:skip var cursorManager:CursorManager;
	@:skip var graphicList:Graphiclist;
	@:skip var graphicList_hover:Graphiclist;
	
	
	public var id(default, null):Int;
	
	@:skip public var color(get_color, set_color):Int;
	var _color:Int;
	function get_color() { return _color; }
	function set_color(c:Int):Int {
		_color = c;
		resize();
		return c;
	}
		
	@:skip public var color_hover(get_color_hover, set_color_hover):Int;
	var _color_hover:Int;
	function get_color_hover() { return _color_hover; }
	function set_color_hover(c:Int):Int {
		_color_hover = c;
		resize();
		return c;
	}
	
	@:skip public var image:Image;
	@:skip public var image_hover:Image;
	public var isHoverBy(default, null):IntHash<Cursor>;
	
	@:remove public var type:String;
	@:remove public var x:Float;
	@:remove public var y:Float;
	@:remove public var width:Int;
	@:remove public var height:Int;
	
	public function new():Void {
		super();
		
		type = Target.TYPE;
		
		isHoverBy = new IntHash<Cursor>();
		
		id = nextId++;
		width = 100;
		height = 100;
		_color = 0xFFFFFF;
		_color_hover = 0xFF6666;
		
		init();
	}
	
	public function init():Target {
		onAddedSignaler = new DirectSignaler<Void>(this);
		onRemovedSignaler = new DirectSignaler<Void>(this);
		onClickSignaler = new DirectSignaler<Void>(this);
		onRollOverSignaler = new DirectSignaler<Void>(this);
		onRollOutSignaler = new DirectSignaler<Void>(this);
		cursorManager = HXP.engine.asMain().cursorManager;
		
		graphic = graphicList = new Graphiclist();
		graphicList_hover = new Graphiclist();
		
		resize();
		
		return this;
	}
	
	override public function added():Void {
		super.added();
		
		onAddedSignaler.dispatch();
	}
	
	override public function removed():Void {
		super.removed();
		
		onRemovedSignaler.dispatch();
	}
	
	public function resize(w:Int = -1, h:Int = -1):Void {
		image = Image.createRect(width = w == -1 ? width : w, height = h == -1 ? height : h, color);
		image_hover = Image.createRect(width = w == -1 ? width : w, height = h == -1 ? height : h, color_hover);
		
		graphicList.removeAll();
		graphicList.add(image);
		
		graphicList_hover.removeAll();
		graphicList_hover.add(image_hover);
	}
	
	public function click(?cursor:Cursor):Void {
		onClickSignaler.dispatch();
		
		image.alpha = 0.5;
		image.tween(0.1, {alpha: 1.0});
		
		image_hover.alpha = 0.5;
		image_hover.tween(0.1, {alpha: 1.0});
	}
	
	public function rollOver(?cursor:Cursor):Void {
		isHoverBy.set(cursor == null ? -1 : cursor.id, cursor);
		
		graphic = graphicList_hover;
	}
	
	public function rollOut(?cursor:Cursor):Void {
		isHoverBy.remove(cursor == null ? -1 : cursor.id);
		
		if (isHoverBy.empty()) {
			graphic = graphicList;
		}
	}
}
