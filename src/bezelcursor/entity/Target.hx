package bezelcursor.entity;

using Std;
using Lambda;
import hsl.haxe.*;
import flash.display.*;
import flash.geom.*;
import com.haxepunk.*;
import com.haxepunk.graphics.*;
using motion.Actuate;

using bezelcursor.Main;
import bezelcursor.cursor.*;
import bezelcursor.model.*;
using bezelcursor.util.UnitUtil;

using bezelcursor.world.GameWorld;

class Target extends Entity implements IStruct {
	inline static public var TYPE = "Target";
	static var nextId = 0;
	
	@skip public var onAddedSignaler(default, null):Signaler<Void>;
	@skip public var onRemovedSignaler(default, null):Signaler<Void>;
	@skip public var onClickSignaler(default, null):Signaler<Void>;
	@skip public var onRollOverSignaler(default, null):Signaler<Void>;
	@skip public var onRollOutSignaler(default, null):Signaler<Void>;
	
	@skip var cursorManager:CursorManager;
	@skip var graphicList_default:Graphiclist = new Graphiclist();
	@skip var graphicList_hover:Graphiclist = new Graphiclist();
	
	
	public var id(default, null):Int;
	
	public var alpha(default, set):Float;
	function set_alpha(v:Float):Float {
		if (image_default != null)
			image_default.alpha = v;
		if (image_hover != null)
			image_hover.alpha = v;
		return alpha = v;
	}
	
	@skip public var color(get_color, set_color):Int;
	var _color:Int;
	function get_color() { return _color; }
	function set_color(c:Int):Int {
		_color = c;
		resize();
		return c;
	}
		
	@skip public var color_hover(get_color_hover, set_color_hover):Int;
	var _color_hover:Int;
	function get_color_hover() { return _color_hover; }
	function set_color_hover(c:Int):Int {
		_color_hover = c;
		resize();
		return c;
	}
	
	@skip public var image_default:Image;
	@skip public var image_hover:Image;
	@skip public var isHoverBy(default, null):Map<Int,Cursor>;
	
	@remove public var type:String;
	@remove public var x:Float;
	@remove public var y:Float;
	@remove public var width:Int;
	@remove public var height:Int;
	
	public function new():Void {
		super();
		
		type = Target.TYPE;
		
		isHoverBy = new Map();
		
		id = nextId++;
		width = 100;
		height = 100;
		_color = 0xFFFFFF;
		_color_hover = 0xFF6666;
		alpha = 1;

		onAddedSignaler = new DirectSignaler<Void>(this);
		onRemovedSignaler = new DirectSignaler<Void>(this);
		onClickSignaler = new DirectSignaler<Void>(this);
		onRollOverSignaler = new DirectSignaler<Void>(this);
		onRollOutSignaler = new DirectSignaler<Void>(this);
		
		init();
	}
	
	public function init():Target {
		if (HXP.engine != null)
			cursorManager = HXP.engine.asMain().cursorManager;
		
		graphic = graphicList_default;
		
		return this;
	}
	
	override public function added():Void {
		super.added();
		
		resize();
		
		onAddedSignaler.dispatch();
	}
	
	override public function removed():Void {
		super.removed();
		
		onRemovedSignaler.dispatch();
	}
	
	public function resize(w:Int = -1, h:Int = -1):Void {
		image_default = new Image(getBitmapdataOfColor(width = w == -1 ? width : w, height = h == -1 ? height : h, color));
		image_hover = new Image(getBitmapdataOfColor(width = w == -1 ? width : w, height = h == -1 ? height : h, color_hover));
		
		image_default.alpha = image_hover.alpha = alpha;

		graphicList_default.removeAll();
		graphicList_default.add(image_default);
		
		graphicList_hover.removeAll();
		graphicList_hover.add(image_hover);
	}
	
	public function click(?cursor:Cursor):Void {
		onClickSignaler.dispatch();
		
		image_default.alpha = 0.5;
		image_default.tween(0.1, {alpha: alpha});
		
		image_hover.alpha = 0.5;
		image_hover.tween(0.1, {alpha: alpha});
	}
	
	public function rollOver(?cursor:Cursor):Void {
		isHoverBy.set(cursor == null ? -1 : cursor.id, cursor);
		
		graphic = graphicList_hover;
	}
	
	public function rollOut(?cursor:Cursor):Void {
		isHoverBy.remove(cursor == null ? -1 : cursor.id);
		
		if (isHoverBy.empty()) {
			graphic = graphicList_default;
		}
	}
	
	public function fromTargetData(td:TargetData):Target {
		var dpi = DeviceData.current.screenDPI;
		x = td.x.mm2inches() * dpi;
		y = td.y.mm2inches() * dpi;
		width = Math.round(td.width.mm2inches() * dpi);
		height = Math.round(td.height.mm2inches() * dpi);
		
		return this;
	}
	
	static function getBitmapdataOfColor(width:Int, height:Int, color:Int):BitmapData {
		var key = width + "," + height + "," + color;
		if (bitmapdataOfColor.exists(key)) {
			return bitmapdataOfColor.get(key);
		} else {
			var bm = HXP.createBitmap(width, height, true, 0xFF000000 | color);
			bitmapdataOfColor.set(key, bm);
			return bm;
		}
	}
	static var bitmapdataOfColor:Map<String,BitmapData> = new Map();
}
