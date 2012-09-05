package bezelcursor.cursor.behavior;

import nme.events.TouchEvent;
import nme.system.Capabilities;
using org.casalib.util.NumberUtil;

class ClickWhenTouchEnd extends Behavior<PointActivatedCursor> {	
	override public function onTouchEnd(evt:TouchEvent):Void {
		cursor.dispatch(cursor.onClickSignaler);
		
		super.onTouchEnd(evt);
		
		cursor.end();
	}
}