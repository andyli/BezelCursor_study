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

using bezelcursor.Main;
import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.CursorManager;
using bezelcursor.model.Struct;
using bezelcursor.world.GameWorld;

class Target extends Entity {
	inline static public var TYPE = "Target";
	static var nextId = 0;
	
	public var onClickSignaler(default, null):Signaler<Point>;
	public var onCursorInSignaler(default, null):Signaler<Point>;
	public var onCursorOutSignaler(default, null):Signaler<Point>;
	
	var cursorManager:CursorManager;
	var graphicList:Graphiclist;
	
	
	public var id(default, null):Int;
	public var color(default, set_color):Int;
	public var color_hover(default, set_color_hover):Int;
	public var image:Image;
	public var image_hover:Image;
	public var state(default, null):Int;
	public var isHoverBy(default, null):IntHash<Cursor>;
	
	public function new(?data:Dynamic):Void {
		super();
		
		type = Target.TYPE;
		
		onClickSignaler = new DirectSignaler<Point>(this);
		onCursorInSignaler = new DirectSignaler<Point>(this);
		onCursorOutSignaler = new DirectSignaler<Point>(this);
		
		cursorManager = HXP.engine.asMain().cursorManager;
		graphic = graphicList = new Graphiclist();

		state = data != null && Reflect.hasField(data, "state") ? data.state : 0;
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
		
		cursorManager.onClickSignaler.bindAdvanced(onClick);
		cursorManager.onMoveSignaler.bindAdvanced(onCursorMove);
	}
	
	override public function removed():Void {
		cursorManager.onClickSignaler.unbindAdvanced(onClick);
		cursorManager.onMoveSignaler.unbindAdvanced(onCursorMove);
		
		super.removed();
	}
	
	override public function update():Void {
		super.update();
		
		if (state != 0 && isHoverBy.empty()) {
			graphic = image;
			state = 0;
			graphicList.removeAll();
			graphicList.add(image);
		} else if (state == 0 && !isHoverBy.empty()) {
			graphic = image_hover;
			state = 1;
			graphicList.removeAll();
			graphicList.add(image_hover);
		}
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
	
	function resize(w:Int = -1, h:Int = -1):Void {
		image = Image.createRect(width = w == -1 ? width : w, height = h == -1 ? height : h, color);
		image_hover = Image.createRect(width = w == -1 ? width : w, height = h == -1 ? height : h, color_hover);
		state = -1;
		update();
	}
	
	function onClick(signal:Signal<Point>):Void {
		var pt = HXP.world.asGameWorld().screenToWorld(signal.data);
		//trace(pt.x + " " + pt.y + " " + x + " " + y);
		if (collidePoint(x, y, pt.x, pt.y)) {
			//trace("clicked");
			onClickSignaler.dispatch(pt);
			
			try {
				var cursor:Cursor = cast signal.origin;
				if (cursor != null)
					isHoverBy.remove(cursor.id);
			} catch(e:Dynamic){}
		}
	}
	
	function onCursorMove(signal:Signal<Point>):Void {
		var cursor:Cursor = cast signal.origin;
		var pt = world.asGameWorld().screenToWorld(signal.data);
		
		if (collidePoint(x, y, pt.x, pt.y)) {
			if (!isHoverBy.exists(cursor.id)) {
				isHoverBy.set(cursor.id, cursor);
				onCursorInSignaler.dispatch(pt);
			}
		} else {
			if (isHoverBy.exists(cursor.id)) {
				isHoverBy.remove(cursor.id);
				onCursorOutSignaler.dispatch(pt);
			}
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
		data.state = state;
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
		state = data.state;
		isHoverBy = data.isHoverBy.toIntHashCursor();
	}
	
	public function clone():Target {
		return new Target(getData());
	}
	
	static public function createFromData<T:Target>(data:Dynamic):T {
		return Type.createInstance(Type.resolveClass(data._class), [data]);
	}
}
