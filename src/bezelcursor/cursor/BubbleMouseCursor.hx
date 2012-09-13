package bezelcursor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.DrawBubble;
import bezelcursor.cursor.behavior.DrawStick;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.behavior.MouseMove;

class BubbleMouseCursor extends MouseCursor {
	public function new():Void {
		super();
		
		var r = Math.POSITIVE_INFINITY;
		current_radius = r;
		target_radius = r;
		default_radius = r;
		
		behaviors = [new DrawBubble(this), new MouseMove(this), new ClickWhenTouchEnd(this)];
	}
}
