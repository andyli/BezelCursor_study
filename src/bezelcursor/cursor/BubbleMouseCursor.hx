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
	
	@deep public var drawBubble(default, set_drawBubble):DrawBubble;
	function set_drawBubble(v:DrawBubble):DrawBubble {
		behaviors.remove(drawBubble);
		if (v != null) behaviors.push(v);
		return drawBubble = v;
	}
	
	public function new():Void {
		super();
		
		var r = Math.POSITIVE_INFINITY;
		current_radius = r;
		target_radius = r;
		default_radius = r;
		
		drawRadius = null;
		dynaScale = null;
		drawBubble = new DrawBubble(this);
	}
}
