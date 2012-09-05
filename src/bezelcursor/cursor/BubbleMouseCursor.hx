package bezelcursor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.DrawBubble;
import bezelcursor.cursor.behavior.DrawStick;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.behavior.MouseMove;

class BubbleMouseCursor extends MouseCursor {
	public function new(touchPointID:Int = 0):Void {
		super(touchPointID);
		
		current_radius = target_radius = default_radius = stage.stageHeight + stage.stageWidth;
		behaviors = [new DrawStick(this), new DrawBubble(this), new MouseMove(this), new ClickWhenTouchEnd(this)];
	}
	
	override public function clone():BubbleMouseCursor {
		var cursor = new BubbleMouseCursor(touchPointID); Cursor.nextId--;
		cursor.setConfig(getConfig());		
		return cursor;
	}
}
