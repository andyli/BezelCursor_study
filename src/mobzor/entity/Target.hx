package mobzor.entity;

import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;
import nme.geom.Point;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
using Std;

using mobzor.Main;
import mobzor.cursor.BezelActivatedCursorManager;

class Target extends Entity {
	static var nextId = 0;
	
	public var onClickSignaler(default, null):Signaler<Point>;
	public var onCursorInSignaler(default, null):Signaler<Point>;
	public var onCursorOutSignaler(default, null):Signaler<Point>;
	
	var bezelActivatedCursorManager:BezelActivatedCursorManager;
	var image:Image;
	var image_hover:Image;
	
	public var id(default, null):Int;
	public var color(default, set_color):Int = 0xFFFFFF;
	public var color_hover(default, set_color_hover):Int = 0xFF6666;
	public var isHover(default, null):Bool = false;
	
	public function new(w:Int = 100, h:Int = 100):Void {
		super();
		
		id = nextId++;
		type = "Target";
		
		onClickSignaler = new DirectSignaler<Point>(this);
		onCursorInSignaler = new DirectSignaler<Point>(this);
		onCursorOutSignaler = new DirectSignaler<Point>(this);
		
		bezelActivatedCursorManager = HXP.engine.asMain().bezelActivatedCursorManager;
		resize(w, h);
	}
	
	override public function added():Void {
		super.added();
		
		bezelActivatedCursorManager.onClickSignaler.bind(onClick);
		bezelActivatedCursorManager.onMoveSignaler.bind(onCursorMove);
	}
	
	override public function removed():Void {
		bezelActivatedCursorManager.onClickSignaler.unbind(onClick);
		bezelActivatedCursorManager.onMoveSignaler.unbind(onCursorMove);
		
		super.removed();
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
		graphic = isHover ? image_hover : image;
	}
	
	function onClick(pt:Point):Void {
		if (collidePoint(x, y, pt.x, pt.y))
			onClickSignaler.dispatch(pt);
			
		onCursorOut();
	}
	
	function onCursorMove(pt:Point):Void {
		if (collidePoint(x, y, pt.x, pt.y)) {
			if (!isHover) {
				isHover = true;
				onCursorIn();
				onCursorInSignaler.dispatch(pt);
			}
		} else {
			if (isHover) {
				isHover = false;
				onCursorOut();
				onCursorOutSignaler.dispatch(pt);
			}
		}
	}
	
	function onCursorIn():Void {
		graphic = image_hover;
	}
	
	function onCursorOut():Void {
		graphic = image;
	}
}
