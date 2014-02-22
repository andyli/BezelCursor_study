package bezelcursor.world;

using Std;
import com.haxepunk.*;
import flash.display.*;
import flash.geom.*;
import flash.system.Capabilities;
import hsl.haxe.*;
import sys.io.*;

using bezelcursor.Main;
import bezelcursor.cursor.*;
import bezelcursor.entity.*;
import bezelcursor.model.*;

class GameWorld extends World {
	public var worldQueue:Array<GameWorld>;

	public var bound:Rectangle;
	public var screenBound:Rectangle;

	@skip public var currentTargets(default, null):Array<Target> = [];
	
	public function new():Void {
		super();
		
		worldQueue = [];

		screenBound = HXP.bounds.clone();

		bound = HXP.bounds.clone();
		bound.inflate(0, 10 * HXP.bounds.height);
	}

	override public function add<E:Entity>(e:E):E {
		if (e.type == Target.TYPE)
			this.currentTargets.push(cast e);
		return super.add(e);
	}

	override public function remove<E:Entity>(e:E):E {
		if (e.type == Target.TYPE)
			this.currentTargets.remove(cast e);
		return super.remove(e);
	}
	
	function nextWorld():Void {
		var next = worldQueue.shift();
		next.worldQueue = next.worldQueue.concat(worldQueue);
		HXP.world = next;
	}
	
	function isTargetInBound(target:Target):Bool {
		return bound.intersects(new Rectangle(target.x - camera.x, target.y - camera.y, target.width, target.height));
	}
	
	function isTargetInScreenBound(target:Target):Bool {
		return screenBound.intersects(new Rectangle(target.x - camera.x, target.y - camera.y, target.width, target.height));
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
