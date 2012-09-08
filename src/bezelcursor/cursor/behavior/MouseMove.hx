package bezelcursor.cursor.behavior;

import nme.Lib;
import nme.geom.Rectangle;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.PointActivatedCursor;
import bezelcursor.model.DeviceData;
using bezelcursor.model.Struct;

class MouseMove extends Behavior<PointActivatedCursor> {
	public var minVelocityFactor:Float;
	public var maxVelocityFactor:Float;
	public var minVelocityFactorTouchVelocity:Float;
	public var maxVelocityFactorTouchVelocity:Float;
	
	public var constraint:Rectangle;
	
	var ptimestamp:Float;
	
	public function new(c:PointActivatedCursor, ?data:Dynamic):Void {
		super(c, data);
		
		minVelocityFactor = data != null && Reflect.hasField(data, "minVelocityFactor") ? data.minVelocityFactor : 1;
		maxVelocityFactor = data != null && Reflect.hasField(data, "maxVelocityFactor") ? data.maxVelocityFactor : 3;
		minVelocityFactorTouchVelocity = data != null && Reflect.hasField(data, "minVelocityFactorTouchVelocity") ? data.minVelocityFactorTouchVelocity : DeviceData.current.screenDPI * 0.01 * 30;
		maxVelocityFactorTouchVelocity = data != null && Reflect.hasField(data, "maxVelocityFactorTouchVelocity") ? data.maxVelocityFactorTouchVelocity : DeviceData.current.screenDPI * 0.05 * 30;
		
		constraint = data != null && Reflect.hasField(data, "constraint") ? data.constraint.toRectangle() : new Rectangle(0, 0, Lib.stage.stageWidth, Lib.stage.stageHeight);
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
	
	override public function getData():Dynamic {
		var data:Dynamic = super.getData();
		
		data.minVelocityFactor = minVelocityFactor;
		data.maxVelocityFactor = maxVelocityFactor;
		data.minVelocityFactorTouchVelocity = minVelocityFactorTouchVelocity;
		data.maxVelocityFactorTouchVelocity = maxVelocityFactorTouchVelocity;
		
		data.constraint = constraint.toObj();
		
		return data;
	}
	
	override public function setData(data:Dynamic):Void {
		super.setData(data);
		
		minVelocityFactor = data.minVelocityFactor;
		maxVelocityFactor = data.maxVelocityFactor;
		minVelocityFactorTouchVelocity = data.minVelocityFactorTouchVelocity;
		maxVelocityFactorTouchVelocity = data.maxVelocityFactorTouchVelocity;
		
		constraint = data.constraint.toRectangle();
	}
	
	override public function clone(?c:PointActivatedCursor):MouseMove {
		return new MouseMove(c == null ? cursor : c, getData());
	}
}