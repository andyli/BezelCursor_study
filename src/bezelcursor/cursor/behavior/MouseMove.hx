package bezelcursor.cursor.behavior;

import nme.Lib;
import nme.geom.Rectangle;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.PointActivatedCursor;
import bezelcursor.model.DeviceData;


class MouseMove extends Behavior<PointActivatedCursor> {
	public var minVelocityFactor:Float;
	public var maxVelocityFactor:Float;
	public var minVelocityFactorTouchVelocity:Float;
	public var maxVelocityFactorTouchVelocity:Float;
	
	public var constraint:Rectangle;
	
	var ptimestamp:Float;
	
	public function new(c:PointActivatedCursor):Void {
		super(c);
		
		minVelocityFactor = 1;
		maxVelocityFactor = 3;
		minVelocityFactorTouchVelocity = DeviceData.current.screenDPI * 0.01 * 30;
		maxVelocityFactorTouchVelocity = DeviceData.current.screenDPI * 0.05 * 30;
		
		constraint = new Rectangle(0, 0, Lib.stage.stageWidth, Lib.stage.stageHeight);
	}
	
	override public function start():Void {
		super.start();
		ptimestamp = haxe.Timer.stamp();
	}
	
	override public function onFrame(timestamp:Float):Void {
		super.onFrame(timestamp);
		
		var targetPos;
		if (cursor.position != null) {
			var v = cursor.touchVelocity.clone();
			var l = cursor.touchVelocity.length;
			v.normalize(
				(timestamp - ptimestamp) * l * l.map(minVelocityFactorTouchVelocity, maxVelocityFactorTouchVelocity, minVelocityFactor, maxVelocityFactor).constrain(minVelocityFactor, maxVelocityFactor)
			);
			targetPos = cursor.position.add(v);
		} else {
			targetPos = cursor.currentTouchPoint;
		}
		
		if (!constraint.containsPoint(targetPos)) {
			targetPos.x = targetPos.x.constrain(constraint.left, constraint.right);
			targetPos.y = targetPos.y.constrain(constraint.top, constraint.bottom);
		}
		
		cursor.position = targetPos;
		
		ptimestamp = timestamp;
	}
}