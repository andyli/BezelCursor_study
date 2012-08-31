package bezelcursor.cursor.behavior;

import nme.system.Capabilities;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.PointActivatedCursor;

class MouseMove extends Behavior<PointActivatedCursor> {
	public var minVelocityFactor:Float;
	public var maxVelocityFactor:Float;
	public var minVelocityFactorTouchVelocity:Float;
	public var maxVelocityFactorTouchVelocity:Float;
	
	public function new(c:PointActivatedCursor):Void {
		super(c);
		
		minVelocityFactor = 1;
		maxVelocityFactor = 3;
		minVelocityFactorTouchVelocity = Capabilities.screenDPI * 0.01;
		maxVelocityFactorTouchVelocity = Capabilities.screenDPI * 0.05;
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
	}
}