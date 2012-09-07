package bezelcursor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.DrawBubble;
import bezelcursor.cursor.behavior.DrawStick;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.behavior.MouseMove;

class BubbleMouseCursor extends MouseCursor {
	public function new(data:Dynamic):Void {
		super(data);
		
		var r = Math.POSITIVE_INFINITY;
		current_radius = data != null && Reflect.hasField(data, "current_radius") ? data.current_radius : r;
		target_radius = data != null && Reflect.hasField(data, "target_radius") ? data.target_radius : r;
		default_radius = data != null && Reflect.hasField(data, "default_radius") ? data.default_radius : r;
		
		behaviors = data != null && Reflect.hasField(data, "behaviors") ? Behavior.createFromDatas(this, data.behaviors) : [new DrawBubble(this), new MouseMove(this), new ClickWhenTouchEnd(this)];
	}
	
	override public function clone():BubbleMouseCursor {
		return new BubbleMouseCursor(getData());
	}
}
