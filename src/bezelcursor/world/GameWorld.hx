package bezelcursor.world;

using Std;
import com.haxepunk.*;
import nme.display.*;
import nme.geom.*;
import nme.system.Capabilities;
import hsl.haxe.*;
import sys.io.*;

using bezelcursor.Main;
import bezelcursor.cursor.*;
import bezelcursor.entity.*;
import bezelcursor.model.*;

class GameWorld extends World {
	public var isCameraMoving(default, null):Bool;
	var pCameraX:Float;
	var pCameraY:Float;
	
	public var visibleTargets:Array<Target>;
	public var invisibleTargets:Array<Target>;
	
	public var worldQueue:Array<GameWorld>;
	
	public function new():Void {
		super();
		isCameraMoving = true;
		
		visibleTargets = [];
		invisibleTargets = [];
		worldQueue = [];
		
		pCameraX = camera.x;
		pCameraY = camera.y;
	}
	
	function nextWorld():Void {
		var next = worldQueue.shift();
		next.worldQueue = next.worldQueue.concat(worldQueue);
		HXP.world = next;
	}
	
	function isTargetInBound(target:Target):Bool {
		return HXP.bounds.intersects(new Rectangle(target.x - camera.x, target.y - camera.y, target.width, target.height));
	}
	
	override public function add<E:Entity>(e:E):E {
		if (e.type == Target.TYPE) {
			if (e.world == this) return e;
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
	
	override public function remove<E:Entity>(e:E):E {
		if (e.type == Target.TYPE) {
			var target:Target = cast e;
			visibleTargets.remove(target);
			invisibleTargets.remove(target);
		}
		return super.remove(e);
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
				super.remove(target);
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
	
	override public function end():Void {		
		removeAll();
		super.end();
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
