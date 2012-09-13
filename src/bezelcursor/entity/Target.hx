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
using bezelcursor.model.Struct;
using bezelcursor.world.GameWorld;

class Target extends Entity {
	inline static public var TYPE = "Target";
	static var nextId = 0;
	
	public var onAddedSignaler(default, null):Signaler<Void>;
	public var onRemovedSignaler(default, null):Signaler<Void>;
	public var onClickSignaler(default, null):Signaler<Void>;
	public var onRollOverSignaler(default, null):Signaler<Void>;
	public var onRollOutSignaler(default, null):Signaler<Void>;
	
	var cursorManager:CursorManager;
	var graphicList:Graphiclist;
	var graphicList_hover:Graphiclist;
	
	
	public var id(default, null):Int;
	public var color(default, set_color):Int;
	public var color_hover(default, set_color_hover):Int;
	public var image:Image;
	public var image_hover:Image;
	public var isHoverBy(default, null):IntHash<Cursor>;
	
	public function new(?data:Dynamic):Void {
		super();
		
		type = Target.TYPE;
		
		onAddedSignaler = new DirectSignaler<Void>(this);
		onRemovedSignaler = new DirectSignaler<Void>(this);
		onClickSignaler = new DirectSignaler<Void>(this);
		onRollOverSignaler = new DirectSignaler<Void>(this);
		onRollOutSignaler = new DirectSignaler<Void>(this);
		
		cursorManager = HXP.engine.asMain().cursorManager;
		graphic = graphicList = new Graphiclist();
		graphicList_hover = new Graphiclist();
		
		isHoverBy = data != null && Reflect.hasField(data, "isHoverBy") ? data.isHoverBy.toIntHashCursor() : new IntHash<Cursor>();
		
		id = data != null && Reflect.hasField(data, "id") ? data.id : nextId++;
		width = data != null && Reflect.hasField(data, "width") ? data.width : 100;
		height = data != null && Reflect.hasField(data, "height") ? data.height : 100;
		color = data != null && Reflect.hasField(data, "color") ? data.color : 0xFFFFFF;
		color_hover = data != null && Reflect.hasField(data, "color_hover") ? data.color_hover : 0xFF6666;
		moveTo(
			data != null && Reflect.hasField(data, "x") ? data.x : 0,
			data != null && Reflect.hasField(data, "y") ? data.y : 0
		);
	}
	
	override public function added():Void {
		super.added();
		
		onAddedSignaler.dispatch();
	}
	
	override public function removed():Void {
		super.removed();
		
		onRemovedSignaler.dispatch();
	}
	
	function set_color(c:Int):Int {
		color = c;
		resize();
		return c;
	}
	
	function set_color_hover(c:Int):Int {
		color_hover = c;
		resize();
		return c;
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
		data.x = x;
		data.y = y;
		data.width = width;
		data.height = height;
		data.color = color;
		data.color_hover = color_hover;
		data.isHoverBy = isHoverBy.toObj();
		
		return data;
	}
	
	public function setData(data:Dynamic):Void {
		#if debug
		if (data._class != Type.getClassName(Type.getClass(this)))
			throw "Should not set " + Type.getClassName(Type.getClass(this)) + "from a data of " + data._class;
		#end
		
		id = data.id;
		x = data.x;
		y = data.y;
		width = data.width;
		height = data.height;
		color = data.color;
		color_hover = data.color_hover;
		isHoverBy = data.isHoverBy.toIntHashCursor();
	}
	
	public function clone():Target {
		return new Target(getData());
	}
	
	static public function createFromData<T:Target>(data:Dynamic):T {
		return Type.createInstance(Type.resolveClass(data._class), [data]);
	}
}
