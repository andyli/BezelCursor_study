package bezelcursor.cursor;

import nme.events.TouchEvent;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.behavior.DynaScale;
import bezelcursor.cursor.behavior.DrawRadius;
import bezelcursor.cursor.behavior.DrawStick;
import bezelcursor.cursor.behavior.MouseMove;

class MouseCursor extends PointActivatedCursor {
	public function new(touchPointID:Int):Void {
		super(touchPointID);
		
		behaviors.push(new DrawStick(this));
		behaviors.push(new DrawRadius(this));
		behaviors.push(new MouseMove(this));
		behaviors.push(new DynaScale(this));
		behaviors.push(new ClickWhenTouchEnd(this));
	}
	
	override function onTouchBegin(evt:TouchEvent):Void {
		super.onTouchBegin(evt);
		
		target_position = current_position = activatedPoint;
	}
	
	override public function clone():MouseCursor {
		var cursor = new MouseCursor(touchPointID); Cursor.nextId--;
		
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
