package bezelcursor.entity;

import com.haxepunk.HXP;
import com.haxepunk.Entity;

import bezelcursor.model.DeviceData;

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
		layout = v;
		resetLayout();
		return v;
	}
	
	public function new():Void {
		paddingTop = paddingRight = paddingBottom = paddingLeft = gapWidth = DeviceData.current.screenDPI * 0.1;
		children = [];
		super();
		layout = Verticle(Left);
		resetLayout();
	}
	
	public function resetLayout():Void {
		switch(layout) {
			case Verticle(vAlign):
				if (children.length > 0) {
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
				if (children.length > 0) {
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
		if (world != null) {
			world.addList(children);
		}
	}
	
	override function removed():Void {
		HXP.world.removeList(children);
		super.removed();
	}
}