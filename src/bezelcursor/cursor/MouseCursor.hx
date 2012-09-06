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
	public function new(data:Dynamic):Void {
		super(data);
		
		behaviors = data != null && Reflect.hasField(data, "behaviors") ? Behavior.createFromDatas(this, data.behaviors) : [new DrawStick(this), new DrawRadius(this), new MouseMove(this), new DynaScale(this), new ClickWhenTouchEnd(this)];
	}
	
	override function onTouchBegin(touch:TouchData):Void {
		super.onTouchBegin(touch);
		
		target_position = current_position = activatedPoint;
	}
	
	override public function clone():MouseCursor {
		return new MouseCursor(getData());
	}
}
