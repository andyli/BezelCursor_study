package bezelcursor.cursor.behavior;

import nme.geom.Rectangle;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.PointActivatedCursor;
import bezelcursor.model.DeviceInfo;

class MouseMove extends Behavior<PointActivatedCursor> {
	public var minVelocityFactor:Float;
	public var maxVelocityFactor:Float;
	public var minVelocityFactorTouchVelocity:Float;
	public var maxVelocityFactorTouchVelocity:Float;
	
	public var constraint:Rectangle;
	
	public function new(c:PointActivatedCursor):Void {
		super(c);
		
		minVelocityFactor = 1;
		maxVelocityFactor = 3;
		minVelocityFactorTouchVelocity = DeviceInfo.current.screenDPI * 0.01;
		maxVelocityFactorTouchVelocity = DeviceInfo.current.screenDPI * 0.05;
		
		constraint = new Rectangle(0, 0, c.stage.stageWidth, c.stage.stageHeight);
	}
	
	override public function onFrame():Void {
		super.onFrame();
		
		if (cursor.targetPoint != null) {
			var v = cursor.touchVelocity.clone();
			var l = cursor.touchVelocity.length;
			v.normalize(
				l
				* l.map(minVelocityFactorTouchVelocity, maxVelocityFactorTouchVelocity, minVelocityFactor, maxVelocityFactor).constrain(minVelocityFactor, maxVelocityFactor)
				* cursor.stage.frameRate.map(30, 60, 1, 0.5)
			);
			cursor.targetPoint = cursor.targetPoint.add(v);
		} else {
			cursor.targetPoint = cursor.currentTouchPoint;
		}
		
		if (!constraint.containsPoint(cursor.targetPoint)) {
			cursor.targetPoint.x = cursor.targetPoint.x.constrain(constraint.left, constraint.right);
			cursor.targetPoint.y = cursor.targetPoint.y.constrain(constraint.top, constraint.bottom);
		}
	}
}