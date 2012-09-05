package bezelcursor.cursor.behavior;

import nme.geom.Rectangle;
using org.casalib.util.NumberUtil;

import bezelcursor.cursor.PointActivatedCursor;
import bezelcursor.model.DeviceInfo;
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
		minVelocityFactorTouchVelocity = config != null && Reflect.hasField(config, "minVelocityFactorTouchVelocity") ? config.minVelocityFactorTouchVelocity : DeviceInfo.current.screenDPI * 0.01;
		maxVelocityFactorTouchVelocity = config != null && Reflect.hasField(config, "maxVelocityFactorTouchVelocity") ? config.maxVelocityFactorTouchVelocity : DeviceInfo.current.screenDPI * 0.05;
		
		constraint = config != null && Reflect.hasField(config, "constraint") ? config.constraint.toRectangle() : new Rectangle(0, 0, c.stage.stageWidth, c.stage.stageHeight);
	}
	
	override public function onFrame():Void {
		super.onFrame();
		
		if (cursor.position != null) {
			var v = cursor.touchVelocity.clone();
			var l = cursor.touchVelocity.length;
			v.normalize(
				l
				* l.map(minVelocityFactorTouchVelocity, maxVelocityFactorTouchVelocity, minVelocityFactor, maxVelocityFactor).constrain(minVelocityFactor, maxVelocityFactor)
				* cursor.stage.frameRate.map(30, 60, 1, 0.5)
			);
			cursor.position = cursor.position.add(v);
		} else {
			cursor.position = cursor.currentTouchPoint;
		}
		
		if (!constraint.containsPoint(cursor.position)) {
			cursor.position.x = cursor.position.x.constrain(constraint.left, constraint.right);
			cursor.position.y = cursor.position.y.constrain(constraint.top, constraint.bottom);
		}
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