package bezelcursor.entity;

import com.haxepunk.Entity;

enum PanelLayout {
	Verticle(vAlign:VerticleAlignment);
	Horizontal(hAlign:HorizontalAlignment);
}

enum VerticleAlignment {
	Left;
	Center;
	Right;
}

enum HorizontalAlignment {
	Top;
	Middle;
	Bottom;
}

class Panel extends Entity {
	static function verticleAlign(p:Panel, e:Entity, vAlign:VerticleAlignment):Void {
		e.x = switch(vAlign) {
			case Left:
				p.x + p.paddingLeft;
			case Center:
				p.x + (p.width - e.width) * 0.5;
			case Right:
				p.x + p.width - p.paddingRight - e.width;
		};
	}
	static function horizontalAlign(p:Panel, e:Entity, hAlign:HorizontalAlignment):Void {
		e.y = switch(hAlign) {
			case Top:
				p.y + p.paddingTop;
			case Middle:
				p.y + (p.height - e.height) * 0.5;
			case Bottom:
				p.y + p.height - p.paddingBottom - e.height;
		};
	}
	
	public var paddingTop:Float;
	public var paddingRight:Float;
	public var paddingBottom:Float;
	public var paddingLeft:Float;
	public var gapWidth:Float;
	
	var children:Array<Entity>;
	public var layout(get_layout, set_layout):PanelLayout;
	function get_layout():PanelLayout {
		return layout;
	}
	function set_layout(v:PanelLayout):PanelLayout {
		switch(v) {
			case Verticle(vAlign):
				if (children.length > 1) {
					var child = children[0];
					verticleAlign(this, child, vAlign);
					var _y = child.y = y + paddingTop;
					_y += child.height + gapWidth;
					for (i in 1...children.length) {
						child = children[i];
						verticleAlign(this, child, vAlign);
						child.y = _y;
						_y += child.height + gapWidth;
					}
				}
			case Horizontal(hAlign):
				if (children.length > 1) {
					var child = children[0];
					horizontalAlign(this, child, hAlign);
					var _x = child.x = x + paddingTop;
					_x += child.width + gapWidth;
					for (i in 1...children.length) {
						child = children[i];
						horizontalAlign(this, child, hAlign);
						child.x = _x;
						_x += child.width + gapWidth;
					}
				}
		}
		
		return layout = v;
	}
	
	public function new():Void {
		paddingTop = paddingRight = paddingBottom = paddingLeft = gapWidth = 0;
		children = [];
		super();
		layout = Verticle(Left);
	}
	
	override function update():Void {
		
	}
	
	public function add(e:Entity):Entity {
		children.push(e);
		e.layer = layer + 1;
		if (world != null) {
			world.add(e);
		}
		layout = layout;
		return e;
	}
	
	public function remove(e:Entity):Entity {
		children.remove(e);
		if (world != null) {
			world.remove(e);
		}
		layout = layout;
		return e;
	}
	
	override function setLayer(value:Int):Int {
		super.setLayer(value);
		for (child in children) {
			child.layer = value + 1;
		}
		return value;
	}
	
	public function iterator():Iterator<Entity> {
		return children.iterator();
	}
	
	override function added():Void {
		super.added();
		world.addList(children);
	}
	
	override function removed():Void {
		super.added();
		world.removeList(children);
	}
}