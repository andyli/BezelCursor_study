package bezelcursor.world;

using Std;
import hsl.haxe.Signal;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.World;
import nme.display.Sprite;
import nme.geom.Point;
import nme.system.Capabilities;

using bezelcursor.Main;
import bezelcursor.cursor.Cursor;
import bezelcursor.cursor.CursorManager;
import bezelcursor.entity.Target;
import bezelcursor.model.EventRecord;

class GameWorld extends World {
	public var currentTarget(default, set_currentTarget):Target;
	public var targets(default, null):Array<Target>;
	
	public var eventRecords(default, null):Array<EventRecord>;
	
	override public function new():Void {
		super();
	}

	override public function begin():Void {
		super.begin();
		
		targets = [];
		eventRecords = [];
	}
	
	override public function end():Void {
		super.end();
	}
	
	override public function add(e:Entity):Entity {		
		super.add(e);

		if (e.is(Target)) {
			var target:Target = untyped e;
			target.onClickSignaler.bindAdvanced(onTargetClick);
			targets.push(target);
		}
		
		return e;
	}
	
	override public function remove(e:Entity):Entity {
		if (e.is(Target)) {
			var target:Target = untyped e;
			target.onClickSignaler.unbindAdvanced(onTargetClick);
			targets.remove(target);
		}
		
		return super.remove(e);
	}
	
	function onTargetClick(signal:Signal<Point>):Void {
		var target:Target = untyped signal.origin;
		if (target == currentTarget) {
			//eventRecords.push(new EventRecord());
		} else {
			
		}
	}
	
	function set_currentTarget(t:Target):Target {
		if (currentTarget != null){
			currentTarget.color = 0xFFFFFF;
			currentTarget.color_hover = 0xFF6666;
		}
		currentTarget = t;
		currentTarget.color = 0xFF0000;
		currentTarget.color_hover = 0x66FF66;
		return t;
	}
}
