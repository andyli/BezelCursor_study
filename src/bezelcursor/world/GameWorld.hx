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
	public var isCameraMoving(default, null):Bool;
	var pCameraX:Float;
	var pCameraY:Float;
	
	public var eventRecords(default, null):Array<EventRecord>;
	
	public var visibleTargets:Array<Target>;
	public var invisibleTargets:Array<Target>;
	
	public function new():Void {
		super();
		isCameraMoving = true;
		
		visibleTargets = [];
		invisibleTargets = [];
		
		pCameraX = camera.x;
		pCameraY = camera.y;
	}
	
	function isTargetInBound(target:Target):Bool {
		return HXP.bounds.intersects(new Rectangle(target.x - camera.x, target.y - camera.y, target.width, target.height));
	}
	
	override public function add(e:Entity):Entity {
		if (e.is(Target)) {
			var target:Target = cast e;
			if (isTargetInBound(target)) {
				visibleTargets.push(target);
				return super.add(e);
			} else {
				invisibleTargets.push(target);
				return e;
			}
		}
		return super.add(e);
	}
	
	public function clipTargets():Void {
		var pInvisibleTargets = invisibleTargets.copy();
		var pVisibleTargets = visibleTargets.copy();
		
		for (target in pInvisibleTargets) {
			if (isTargetInBound(target)) {
				invisibleTargets.remove(target);
				super.add(target);
				visibleTargets.push(target);
			}
		}
				
		for (target in pVisibleTargets) {
			if (!isTargetInBound(target)) {
				visibleTargets.remove(target);
				remove(target);
				invisibleTargets.push(target);
			}
		}
	}
	
	override public function update():Void {
		super.update();
		
		var diff = Math.abs(camera.x - pCameraX) + Math.abs(camera.y - pCameraY);
		if (diff > 0.01) {			
			isCameraMoving = true;
			clipTargets();
		} else if (isCameraMoving){
			isCameraMoving = false;	
			clipTargets();
		}
		pCameraX = camera.x;
		pCameraY = camera.y;
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
