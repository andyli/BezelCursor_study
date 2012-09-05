package bezelcursor.cursor;

import nme.events.TouchEvent;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.behavior.DynaScale;
import bezelcursor.cursor.behavior.SimpleDraw;
import bezelcursor.cursor.behavior.MouseMove;

class MouseCursor extends PointActivatedCursor {
	public function new(touchPointID:Int):Void {
		super(touchPointID);
		
		behaviors.push(new DynaScale(this));
		behaviors.push(new SimpleDraw(this));
		behaviors.push(new MouseMove(this));
		behaviors.push(new ClickWhenTouchEnd(this));
	}
	
	override function onTouchBegin(evt:TouchEvent):Void {
		super.onTouchBegin(evt);
		
		target_position = current_position = activatedPoint;
	}
}
