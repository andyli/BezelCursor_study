package bezelcursor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.BubbleDraw;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.behavior.MouseMove;

class BubbleMouseCursor extends MouseCursor {
	public function new(touchPointID:Int):Void {
		super(touchPointID);
		
		targetSize = currentSize = startSize = stage.stageHeight + stage.stageWidth;
		behaviors = [new MouseMove(this), new BubbleDraw(this), new ClickWhenTouchEnd(this)];
	}
}
