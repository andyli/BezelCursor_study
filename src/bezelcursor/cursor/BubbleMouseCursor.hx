package bezelcursor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.DrawBubble;
import bezelcursor.cursor.behavior.DrawStick;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.behavior.MouseMove;

class BubbleMouseCursor extends MouseCursor {
	public function new(config:Dynamic):Void {
		super(config);
		
		var r = Math.POSITIVE_INFINITY;
		current_radius = config != null && Reflect.hasField(config, "current_radius") ? config.current_radius : r;
		target_radius = config != null && Reflect.hasField(config, "target_radius") ? config.target_radius : r;
		default_radius = config != null && Reflect.hasField(config, "default_radius") ? config.default_radius : r;
		
		behaviors = config != null && Reflect.hasField(config, "behaviors") ? Behavior.createFromConfigs(this, config.behaviors) : [new DrawStick(this), new DrawBubble(this), new MouseMove(this), new ClickWhenTouchEnd(this)];
	}
	
	override public function clone():BubbleMouseCursor {
		return new BubbleMouseCursor(getConfig());
	}
}
