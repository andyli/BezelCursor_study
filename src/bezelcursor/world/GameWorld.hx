package bezelcursor.world;

using Std;
import hsl.haxe.Signal;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.World;
import nme.display.Sprite;
import nme.geom.Point;
import nme.geom.Matrix;
import nme.geom.Matrix3D;
import nme.geom.Vector3D;
import nme.system.Capabilities;

using bezelcursor.Main;
import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.CursorManager;
import bezelcursor.entity.Target;
import bezelcursor.model.EventRecord;

class GameWorld extends World {
	public var eventRecords(default, null):Array<EventRecord>;
	public var globelCamera(get_globelCamera, set_globelCamera):Matrix3D;
	public var target_globelCamera:Matrix3D;
	public var current_globelCamera:Matrix3D;
	function get_globelCamera():Matrix3D {
		return current_globelCamera;
	}
	function set_globelCamera(v:Matrix3D):Matrix3D {
		return target_globelCamera = v;
	}
	
	public function new():Void {
		super();
		target_globelCamera = new Matrix3D();
		current_globelCamera = new Matrix3D();
		//target_globelCamera.appendTranslation(100, 0, 0);
	}
	
	override public function update():Void {
		super.update();
		
		current_globelCamera = Matrix3D.interpolate(current_globelCamera, target_globelCamera, 0.5);
		
		var targets:Array<Target> = [];
		getType(Target.TYPE, targets);
		
		for (target in targets) {
			var topLeft = target.globalPosition;
			var bottomRight = target.globalPosition.add(target.globalSize);
			topLeft = current_globelCamera.transformVector(topLeft);
			bottomRight = current_globelCamera.transformVector(bottomRight);
			target.x = Math.round(topLeft.x);
			target.y = Math.round(topLeft.y);
			target.width = Math.round(bottomRight.x - topLeft.x);
			target.height = Math.round(bottomRight.y - topLeft.y);
		}
	}
	
	inline static public function asGameWorld(world:World):GameWorld {
		return untyped world;
	}
	
	inline public function worldToScreen(pt:Point):Point {
		return pt.subtract(camera);
	}
	
	inline public function screenToWorld(pt:Point):Point {
		return pt.add(camera);
	}
}
