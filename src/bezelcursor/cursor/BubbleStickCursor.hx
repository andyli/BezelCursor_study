package bezelcursor.cursor;

import bezelcursor.cursor.behavior.*;

class BubbleStickCursor extends StickCursor {
	
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
