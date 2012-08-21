package mobzor.entity;

import hsl.haxe.Signal;
import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;
import nme.geom.Point;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
using Std;
using Lambda;

using mobzor.Main;
import mobzor.cursor.Cursor;
import mobzor.cursor.BezelActivatedCursorManager;

class Target extends Entity {
	static var nextId = 0;
	
	public var onClickSignaler(default, null):Signaler<Point>;
	public var onCursorInSignaler(default, null):Signaler<Point>;
	public var onCursorOutSignaler(default, null):Signaler<Point>;
	
	var bezelActivatedCursorManager:BezelActivatedCursorManager;
	var image:Image;
	var image_hover:Image;
	var needUpdate:Bool;
	
	public var id(default, null):Int;
	public var color(default, set_color):Int = 0xFFFFFF;
	public var color_hover(default, set_color_hover):Int = 0xFF6666;
	public var isHoverBy(default, null):IntHash<Cursor>;
	
	public function new(w:Int = 100, h:Int = 100):Void {
		super();
		
		id = nextId++;
		type = "Target";
		isHoverBy = new IntHash<Cursor>();
		needUpdate = false;
		
		onClickSignaler = new DirectSignaler<Point>(this);
		onCursorInSignaler = new DirectSignaler<Point>(this);
		onCursorOutSignaler = new DirectSignaler<Point>(this);
		
		bezelActivatedCursorManager = HXP.engine.asMain().bezelActivatedCursorManager;
		resize(w, h);
	}
	
	override public function added():Void {
		super.added();
		
		bezelActivatedCursorManager.onClickSignaler.bindAdvanced(onClick);
		bezelActivatedCursorManager.onMoveSignaler.bindAdvanced(onCursorMove);
	}
	
	override public function removed():Void {
		bezelActivatedCursorManager.onClickSignaler.unbindAdvanced(onClick);
		bezelActivatedCursorManager.onMoveSignaler.unbindAdvanced(onCursorMove);
		
		super.removed();
	}
	
	override public function update():Void {
		super.update();
		
		if (isHoverBy.empty()) {
			graphic = image;
		} else {
			graphic = image_hover;
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
		graphic = isHoverBy.empty() ? image : image_hover;
	}
	
	function onClick(signal:Signal<Point>):Void {
		var cursor:Cursor = cast signal.origin;
		var pt = cursor.currentPoint;
		//trace(cursor.currentPoint);
		if (collidePoint(x, y, pt.x, pt.y)) {
			//trace("clicked");
			onClickSignaler.dispatch(pt);
			isHoverBy.remove(cursor.id);
		}
	}
	
	function onCursorMove(signal:Signal<Point>):Void {
		var cursor:Cursor = cast signal.origin;
		var pt = cursor.currentPoint;
		
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
