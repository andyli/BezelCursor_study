package mobzor.entity;

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

using mobzor.Main;
import mobzor.cursor.Cursor;
import mobzor.cursor.CursorManager;

class Target extends Entity {
	inline static public var TYPE = "Target";
	static var nextId = 0;
	
	public var onClickSignaler(default, null):Signaler<Point>;
	public var onCursorInSignaler(default, null):Signaler<Point>;
	public var onCursorOutSignaler(default, null):Signaler<Point>;
	
	var cursorManager:CursorManager;
	var graphicList:Graphiclist;
	var image:Image;
	var image_hover:Image;
	var text:Text;
	var needUpdate:Bool;
	
	public var id(default, null):Int;
	public var color(default, set_color):Int = 0xFFFFFF;
	public var color_hover(default, set_color_hover):Int = 0xFF6666;
	public var isHoverBy(default, null):IntHash<Cursor>;
	public var state(default, null):Int;
	
	public function new(w:Int = 100, h:Int = 100):Void {
		super();
		
		id = nextId++;
		type = Target.TYPE;
		isHoverBy = new IntHash<Cursor>();
		needUpdate = false;
		state = 0;
		
		onClickSignaler = new DirectSignaler<Point>(this);
		onCursorInSignaler = new DirectSignaler<Point>(this);
		onCursorOutSignaler = new DirectSignaler<Point>(this);
		
		cursorManager = HXP.engine.asMain().cursorManager;
		graphic = graphicList = new Graphiclist();
		resize(w, h);
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
		
		var pt = signal.data;
		
		if (collidePoint(x, y, pt.x, pt.y)) {
			//trace("clicked");
			onClickSignaler.dispatch(pt);
			
			var cursor:Cursor = cast signal.origin;
			if (cursor != null)
				isHoverBy.remove(cursor.id);
		}
	}
	
	function onCursorMove(signal:Signal<Point>):Void {
		var cursor:Cursor = cast signal.origin;
		var pt = signal.data;
		
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
}
