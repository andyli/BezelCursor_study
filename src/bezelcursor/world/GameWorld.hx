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
	public var eventRecords(default, null):Array<EventRecord>;
}
