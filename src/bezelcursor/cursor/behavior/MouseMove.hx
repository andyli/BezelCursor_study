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
	
	public function new(c:PointActivatedCursor, ?config:Dynamic):Void {
		super(c, config);
		
		minVelocityFactor = config != null && Reflect.hasField(config, "minVelocityFactor") ? config.minVelocityFactor : 1;
		maxVelocityFactor = config != null && Reflect.hasField(config, "maxVelocityFactor") ? config.maxVelocityFactor : 3;
		minVelocityFactorTouchVelocity = config != null && Reflect.hasField(config, "minVelocityFactorTouchVelocity") ? config.minVelocityFactorTouchVelocity : DeviceData.current.screenDPI * 0.01 * 30;
		maxVelocityFactorTouchVelocity = config != null && Reflect.hasField(config, "maxVelocityFactorTouchVelocity") ? config.maxVelocityFactorTouchVelocity : DeviceData.current.screenDPI * 0.05 * 30;
		
		constraint = config != null && Reflect.hasField(config, "constraint") ? config.constraint.toRectangle() : new Rectangle(0, 0, Lib.stage.stageWidth, Lib.stage.stageHeight);
	}
	
	override public function onFrame(timeInterval:Float):Void {
		super.onFrame(timeInterval);
		
		var targetPos;
		if (cursor.position != null) {
			var v = cursor.touchVelocity.clone();
			var l = cursor.touchVelocity.length;
			v.normalize(
				timeInterval * l * l.map(minVelocityFactorTouchVelocity, maxVelocityFactorTouchVelocity, minVelocityFactor, maxVelocityFactor).constrain(minVelocityFactor, maxVelocityFactor)
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
	}
	
	override public function getConfig():Dynamic {
		var config:Dynamic = super.getConfig();
		
		config.minVelocityFactor = minVelocityFactor;
		config.maxVelocityFactor = maxVelocityFactor;
		config.minVelocityFactorTouchVelocity = minVelocityFactorTouchVelocity;
		config.maxVelocityFactorTouchVelocity = maxVelocityFactorTouchVelocity;
		
		config.constraint = constraint.toObj();
		
		return config;
	}
	
	override public function setConfig(config:Dynamic):Void {
		super.setConfig(config);
		
		minVelocityFactor = config.minVelocityFactor;
		maxVelocityFactor = config.maxVelocityFactor;
		minVelocityFactorTouchVelocity = config.minVelocityFactorTouchVelocity;
		maxVelocityFactorTouchVelocity = config.maxVelocityFactorTouchVelocity;
		
		constraint = config.constraint.toRectangle();
	}
	
	override public function clone(?c:PointActivatedCursor):MouseMove {
		return new MouseMove(c == null ? cursor : c, getConfig());
	}
}