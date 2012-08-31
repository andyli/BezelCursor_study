package bezelcursor.cursor;

import nme.Lib;
import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.TouchEvent;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
using org.casalib.util.NumberUtil;

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
		
		targetPoint = currentPoint = activatedPoint;
	}
	
	override public function clone():MouseCursor {
		var cursor = new MouseCursor(touchPointID);
		cursor.id = id;
		cursor.currentPoint = currentPoint;
		cursor.targetPoint = targetPoint;
		cursor.pFrameTouchPoint = pFrameTouchPoint;
		cursor.currentTouchPoint = currentTouchPoint;
		return cursor;
	}
}
