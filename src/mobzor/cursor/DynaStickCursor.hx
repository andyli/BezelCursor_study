package mobzor.cursor;

import nme.events.Event;
import nme.events.TouchEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.system.Capabilities;
using org.casalib.util.NumberUtil;
import com.haxepunk.HXP;

import mobzor.entity.Target;

class DynaStickCursor extends PointActivatedCursor {
	var startDownPos:Point;
	var lastDownPos:Point;
	var targetSize:Float; //in inch
	var currentSize:Float; //in inch
	
	var expended:Bool = false;
	var expendedTime:Float = 0;
	
	override function start():Void {
		super.start();
		
		this.targetPoint = this.currentPoint = this.activatedPoint;
		targetSize = currentSize = 0;
	}
	
	override function onFrame(evt:Event = null):Void {
		if (lastDownPos != null) {
			if (startDownPos != null) {
				var velocity = lastDownPos.subtract(startDownPos);
				var l = velocity.length;
				
				var curTime = Sys.cpuTime();
				
				if (l > Capabilities.screenDPI * 0.02) {
					expendedTime = curTime;
				} else if (expended && (curTime - expendedTime > 0.4)) {
					targetSize = 0.01;
					expended = false;
				}
				
				if (l > Capabilities.screenDPI * 0.035) {
					targetSize = 0.15;
					expended = true;
				}
				
				/*
				if (l < Capabilities.screenDPI * 0.005) 
					targetSize -= 0.02 * stage.frameRate.map(30, 60, 1, 0.5);
				else 
					targetSize += 0.02 * stage.frameRate.map(30, 60, 1, 0.5);
				
				targetSize = targetSize.constrain(0.01, 0.2);
				*/
			}
			startDownPos = lastDownPos;
		}
		
		currentSize += (targetSize - currentSize) * stage.frameRate.map(0, 30, 1, 0.3);
		
		if (currentPoint != null) {
			var sizePx = Capabilities.screenDPI * currentSize;
			view.graphics.clear();
			view.graphics.lineStyle(2, 0xFF0000, 1);
			view.graphics.moveTo(activatedPoint.x, activatedPoint.y);
			view.graphics.lineTo(currentPoint.x, currentPoint.y);
			view.graphics.drawCircle(currentPoint.x, currentPoint.y, sizePx);
		}
		
		/*
		var targets:Array<Target> = [];
		HXP.world.getType("Target", cast targets);
		trace(targets.length);
		*/
		super.onFrame(evt);
	}
	
	override function onTouchBegin(evt:TouchEvent):Void {
		super.onTouchBegin(evt);
		
		startDownPos = lastDownPos = targetPoint = currentPoint = activatedPoint;
	}
	
	override function onTouchMove(evt:TouchEvent):Void {
		super.onTouchMove(evt);
		
		if (activatedPoint != null) {
			targetPoint = getStickEnd(activatedPoint, new Point(evt.localX, evt.localY));
			lastDownPos = new Point(evt.localX, evt.localY);
		}
	}
	
	override function onTouchEnd(evt:TouchEvent):Void {
		if (evt.touchPointID != touchPointID) return;
		
		var pt = new Point(evt.localX, evt.localY);
		if (currentPoint != null) {
			onClickSignaler.dispatch(currentPoint);
		} else {
			onClickSignaler.dispatch(pt);
		}
		
		view.graphics.clear();
		
		startDownPos = lastDownPos = targetPoint = currentPoint = null;
		
		super.onTouchEnd(evt);
		
		end();
	}
	
	static public function getStickEnd(down:Point, up:Point):Point {
		var v = up.subtract(down);
		v.normalize(v.length * 3);
		return down.add(v);
	}
}
