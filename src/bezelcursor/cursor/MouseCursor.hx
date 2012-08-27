package bezelcursor.cursor;

import nme.Lib;
import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.TouchEvent;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.system.Capabilities;
import nme.ui.Multitouch;
import nme.ui.MultitouchInputMode;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.behavior.Behavior;
import bezelcursor.cursor.behavior.DynaScale;
import bezelcursor.cursor.behavior.SimpleDraw;

class MouseCursor extends PointActivatedCursor {
	public var minVelocityFactor:Float;
	public var maxVelocityFactor:Float;
	public var minVelocityFactorTouchVelocity:Float;
	public var maxVelocityFactorTouchVelocity:Float;
	
	public function new(touchPointID:Int):Void {
		super(touchPointID);
		
		minVelocityFactor = 1;
		maxVelocityFactor = 3;
		minVelocityFactorTouchVelocity = Capabilities.screenDPI * 0.01;
		maxVelocityFactorTouchVelocity = Capabilities.screenDPI * 0.05;
		
		behaviors.push(new DynaScale(this));
		behaviors.push(new SimpleDraw(this));
	}
	
	override function onFrame(evt:Event = null):Void {		
		super.onFrame(evt);
		
		if (activatedPoint != null) {
			var v = touchVelocity.clone();
			var l = touchVelocity.length;
			v.normalize(
				l
				* l.map(minVelocityFactorTouchVelocity, maxVelocityFactorTouchVelocity, minVelocityFactor, maxVelocityFactor).constrain(minVelocityFactor, maxVelocityFactor)
				* stage.frameRate.map(30, 60, 1, 0.5)
			);
			targetPoint = targetPoint.add(v);
		} else {
			targetPoint = currentTouchPoint;
		}
	}
	
	override function onTouchBegin(evt:TouchEvent):Void {
		super.onTouchBegin(evt);
		
		targetPoint = currentPoint = activatedPoint;
	}
	
	override function onTouchEnd(evt:TouchEvent):Void {
		if (evt.touchPointID != touchPointID) return;

		dispatch(onClickSignaler);
		
		view.graphics.clear();
		
		targetPoint = currentPoint = null;
		
		super.onTouchEnd(evt);
		
		end();
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
