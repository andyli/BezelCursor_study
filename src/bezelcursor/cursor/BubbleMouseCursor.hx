package bezelcursor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.DrawBubble;
import bezelcursor.cursor.behavior.DrawStick;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.behavior.MouseMove;

class BubbleMouseCursor extends MouseCursor {
	public function new(touchPointID:Int):Void {
		super(touchPointID);
		
		current_radius = target_radius = default_radius = stage.stageHeight + stage.stageWidth;
		behaviors = [new DrawStick(this), new DrawBubble(this), new MouseMove(this), new ClickWhenTouchEnd(this)];
	}
	
	override public function clone():BubbleMouseCursor {
		var cursor = new BubbleMouseCursor(touchPointID); Cursor.nextId--;
		
		cursor.id = id;
		cursor.current_position = current_position;
		cursor.target_position = target_position;
		cursor.current_radius = current_radius;
		cursor.target_radius = target_radius;
		cursor.behaviors = behaviors.copy();
		cursor.snapper = snapper;
		cursor.color = color;
		
		cursor.pFrameTouchPoint = pFrameTouchPoint;
		cursor.activatedPoint = activatedPoint;
		cursor.currentTouchPoint = currentTouchPoint;
		cursor.touchVelocity = touchVelocity;
		
		return cursor;
	}
}
