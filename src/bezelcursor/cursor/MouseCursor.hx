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
	@deep public var drawRadius(default, set_drawRadius):DrawRadius;
	function set_drawRadius(v:DrawRadius):DrawRadius {
		behaviors.remove(drawRadius);
		if (v != null) behaviors.push(v);
		return drawRadius = v;
	}
	
	@deep public var mouseMove(default, set_mouseMove):MouseMove;
	function set_mouseMove(v:MouseMove):MouseMove {
		behaviors.remove(mouseMove);
		if (v != null) behaviors.push(v);
		return mouseMove = v;
	}
	
	@deep public var dynaScale(default, set_dynaScale):DynaScale;
	function set_dynaScale(v:DynaScale):DynaScale {
		behaviors.remove(dynaScale);
		if (v != null) behaviors.push(v);
		return dynaScale = v;
	}
	
	@deep public var clickWhenTouchEnd(default, set_clickWhenTouchEnd):ClickWhenTouchEnd;
	function set_clickWhenTouchEnd(v:ClickWhenTouchEnd):ClickWhenTouchEnd {
		behaviors.remove(clickWhenTouchEnd);
		if (v != null) behaviors.push(v);
		return clickWhenTouchEnd = v;
	}
	
	public function new():Void {
		super();
		
		drawRadius = new DrawRadius(this);
		mouseMove = new MouseMove(this);
		dynaScale = new DynaScale(this);
		clickWhenTouchEnd = new ClickWhenTouchEnd(this);
	}
	
	override function onTouchBegin(touch:TouchData):Void {
		super.onTouchBegin(touch);
		
		target_position = current_position = activatedPoint;
	}
}
