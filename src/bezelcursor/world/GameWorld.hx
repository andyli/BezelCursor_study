package bezelcursor.world;

using Std;
import hsl.haxe.Signal;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.World;
import nme.display.Sprite;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.geom.Matrix;
import nme.geom.Matrix3D;
import nme.geom.Vector3D;
import nme.system.Capabilities;
import hsl.haxe.Signal;
import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;

using bezelcursor.Main;
import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.CursorManager;
import bezelcursor.entity.Target;
import bezelcursor.model.EventRecord;

class GameWorld extends World {
	public var onEndTransformSignaler(default, null):Signaler<Void>;
	var isGlobalTransforming:Bool;
	
	public var eventRecords(default, null):Array<EventRecord>;
	public var globalTransform(get_globalTransform, set_globalTransform):Matrix3D;
	public var target_globalTransform:Matrix3D;
	public var current_globalTransform:Matrix3D;
	function get_globalTransform():Matrix3D {
		return current_globalTransform;
	}
	function set_globalTransform(v:Matrix3D):Matrix3D {
		return target_globalTransform = v;
	}
	
	public var visibleTargets:Array<Target>;
	public var invisibleTargets:Array<Target>;
	
	public function new():Void {
		super();
		target_globalTransform = new Matrix3D();
		current_globalTransform = new Matrix3D();
		isGlobalTransforming = true;
		//target_globalTransform.appendTranslation(100, 0, 0);
		
		visibleTargets = [];
		invisibleTargets = [];
		onEndTransformSignaler = new DirectSignaler<Void>(this);
	}
	
	function transformTarget(target:Target):Void {
		var topLeft = target.globalPosition;
		var bottomRight = target.globalPosition.add(target.globalSize);
		topLeft = current_globalTransform.transformVector(topLeft);
		bottomRight = current_globalTransform.transformVector(bottomRight);
		target.x = Math.round(topLeft.x);
		target.y = Math.round(topLeft.y);
		target.width = Math.round(bottomRight.x - topLeft.x);
		target.height = Math.round(bottomRight.y - topLeft.y);
	}
	
	function isTargetInBound(target:Target):Bool {
		return HXP.bounds.intersects(new Rectangle(target.x, target.y, target.width, target.height));
	}
	
	override public function begin():Void {
		super.begin();
		
		var targets:Array<Target> = [];
		getType(Target.TYPE, targets);
		for (target in targets) {
			transformTarget(target);
			if (isTargetInBound(target)) {
				//target.visible = true;
				add(target);
				visibleTargets.push(target);
			} else {
				//target.visible = false;
				remove(target);
				invisibleTargets.push(target);
			}

			//add(target);
		}
	}
	
	override public function update():Void {
		super.update();
		
		var diff = 0.0;
		for (i in 0...current_globalTransform.rawData.length) {
			diff += Math.abs(current_globalTransform.rawData[i] - target_globalTransform.rawData[i]);
		}
		if (diff > 0.01) {
			var targets:Array<Target> = [];
			getType(Target.TYPE, targets);
			
			isGlobalTransforming = true;
			current_globalTransform = Matrix3D.interpolate(current_globalTransform, target_globalTransform, 0.5);

			for (target in invisibleTargets.copy()) {
				transformTarget(target);
				if (isTargetInBound(target)) {
					invisibleTargets.remove(target);
					//target.visible = true;
					add(target);
					visibleTargets.push(target);
				}
			}
				
			for (target in visibleTargets.copy()) {
				transformTarget(target);
				if (!isTargetInBound(target)) {
					visibleTargets.remove(target);
					//target.visible = false;
					remove(target);
					invisibleTargets.push(target);
				}
			}
		} else {
			if (isGlobalTransforming) {
				isGlobalTransforming = false;	
				for (target in invisibleTargets) {
					transformTarget(target);
					if (isTargetInBound(target)) {
						invisibleTargets.remove(target);
						//target.visible = true;
						add(target);
						visibleTargets.push(target);
					}
				}
				
				for (target in visibleTargets) {
					transformTarget(target);
					if (!isTargetInBound(target)) {
						visibleTargets.remove(target);
						//target.visible = false;
						remove(target);
						invisibleTargets.push(target);
					}
				}			
				onEndTransformSignaler.dispatch();
			}
		}
	}
	
	static public function asGameWorld(world:World):GameWorld {
		return cast world;
	}
	
	inline public function worldToScreen(pt:Point):Point {
		return pt.subtract(camera);
	}
	
	inline public function screenToWorld(pt:Point):Point {
		return pt.add(camera);
	}
}
