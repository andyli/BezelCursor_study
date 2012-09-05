package bezelcursor.cursor.behavior;

import nme.system.Capabilities;
using org.casalib.util.NumberUtil;

import bezelcursor.model.TouchData;

class ClickWhenTouchEnd extends Behavior<PointActivatedCursor> {	
	override public function onTouchEnd(touch:TouchData):Void {
		cursor.dispatch(cursor.onClickSignaler);
		
		super.onTouchEnd(touch);
		
		cursor.end();
	}
	
	override public function clone(?c:PointActivatedCursor):ClickWhenTouchEnd {
		return new ClickWhenTouchEnd(c == null ? cursor : c, getConfig());
	}
}