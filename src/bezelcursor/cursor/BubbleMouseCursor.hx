package bezelcursor.cursor;

using Lambda;
import nme.events.Event;
import nme.events.TouchEvent;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.DrawBubble;
import bezelcursor.cursor.behavior.DrawStick;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.behavior.MouseMove;

class BubbleMouseCursor extends MouseCursor {
	public var drawBubble(default, set_drawBubble):Bool;
	function set_drawBubble(v:Bool):Bool {
		if (drawBubble == v) return v;
		
		var db = behaviors.filter(function(b) return Std.is(b, DrawBubble)).first();
		
		if (v && db == null) {
			behaviors.push(new DrawBubble(this));
		} else if (!v && db != null) {
			behaviors.remove(db);
		}
		
		return drawBubble = v;
	}
	
	public function new():Void {
		super();
		
		var r = Math.POSITIVE_INFINITY;
		current_radius = r;
		target_radius = r;
		default_radius = r;
		
		behaviors = [new MouseMove(this), new ClickWhenTouchEnd(this)];
		
		drawBubble = true;
	}
}
