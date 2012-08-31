package bezelcursor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.ClickWhenTouchEnd;
import bezelcursor.cursor.behavior.DynaScale;
import bezelcursor.cursor.behavior.SimpleDraw;
import bezelcursor.cursor.behavior.MouseMove;

class BubbleCursor extends PointActivatedCursor {
	public function new(touchPointID:Int):Void {
		super(touchPointID);
		
		targetSize = currentSize = startSize = stage.stageHeight + stage.stageWidth;
		
		behaviors.push(new SimpleDraw(this));
		behaviors.push(new MouseMove(this));
		behaviors.push(new ClickWhenTouchEnd(this));
	}
	
	override function onFrame(evt:Event = null):Void {
		super.onFrame(evt);
		
		if (snapper.lastSnapTarget != null) {
			var dist = snapper.lastSnapTarget.distanceToPoint(currentPoint.x, currentPoint.y, true);
			view.graphics.drawCircle(currentPoint.x, currentPoint.y, dist);
		}
	}
	
	override function onTouchBegin(evt:TouchEvent):Void {
		super.onTouchBegin(evt);
		
		targetPoint = currentPoint = activatedPoint;
	}
}
