package bezelcursor.cursor;

import nme.events.TouchEvent;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.behavior.DynaScale;
import bezelcursor.cursor.behavior.DrawRadius;
import bezelcursor.cursor.behavior.DrawStick;
import bezelcursor.cursor.behavior.MouseMove;
import bezelcursor.model.TouchData;

class MouseCursor extends PointActivatedCursor {
	public function new(touchPointID:Int = 0):Void {
		super(touchPointID);
		
		behaviors.push(new DrawStick(this));
		behaviors.push(new DrawRadius(this));
		behaviors.push(new MouseMove(this));
		behaviors.push(new DynaScale(this));
		behaviors.push(new ClickWhenTouchEnd(this));
	}
	
	override function onTouchBegin(touch:TouchData):Void {
		super.onTouchBegin(touch);
		
		target_position = current_position = activatedPoint;
	}
	
	override public function clone():MouseCursor {
		var cursor = new MouseCursor(touchPointID); Cursor.nextId--;
		cursor.setConfig(getConfig());		
		return cursor;
	}
}
