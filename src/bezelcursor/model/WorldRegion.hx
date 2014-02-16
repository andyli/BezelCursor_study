package bezelcursor.model;

import bezelcursor.model.WorldRegion.VPos.*;
import bezelcursor.model.WorldRegion.HPos.*;

@:enum abstract VPos(Int) from Int to Int {
	var Top = 0;
	var Middle = 1;
	var Bottom = 2;
}

@:enum abstract HPos(Int) from Int to Int {
	var Left = 0;
	var Center = 1;
	var Right = 2;
}

private typedef _WorldRegion = {
	public var x(default,never):HPos;
	public var y(default,never):VPos;
};

@:forward
@:enum abstract WorldRegion(_WorldRegion) to _WorldRegion {
	static public var TopLeft:WorldRegion = new WorldRegion(Left, Top);
	static public var TopCenter:WorldRegion = new WorldRegion(Center, Top);
	static public var TopRight:WorldRegion = new WorldRegion(Right, Top);
	static public var MiddleLeft:WorldRegion = new WorldRegion(Left, Middle);
	static public var MiddleCenter:WorldRegion = new WorldRegion(Center, Middle);
	static public var MiddleRight:WorldRegion = new WorldRegion(Right, Middle);
	static public var BottomLeft:WorldRegion = new WorldRegion(Left, Bottom);
	static public var BottomCenter:WorldRegion = new WorldRegion(Center, Bottom);
	static public var BottomRight:WorldRegion = new WorldRegion(Right, Bottom);

	private function new(x:HPos, y:VPos):Void {
		this = {
			x: x,
			y: y
		};
	}

	static function eq(r0:_WorldRegion, r1:_WorldRegion):Bool {
		return r0.x == r1.x && r0.y == r1.y;
	}

	public function getNeighbor(x:HPos, y:VPos):WorldRegion {
		return switch ({
			x: (this.x:Int) + (x:Int) - 1,
			y: (this.y:Int) + (y:Int) - 1
		}) {
			case eq.bind(WorldRegion.TopLeft) => true: TopLeft;
			case eq.bind(WorldRegion.TopCenter) => true: TopCenter;
			case eq.bind(WorldRegion.TopRight) => true: TopRight;
			case eq.bind(WorldRegion.MiddleLeft) => true: MiddleLeft;
			case eq.bind(WorldRegion.MiddleCenter) => true: MiddleCenter;
			case eq.bind(WorldRegion.MiddleRight) => true: MiddleRight;
			case eq.bind(WorldRegion.BottomLeft) => true: BottomLeft;
			case eq.bind(WorldRegion.BottomCenter) => true: BottomCenter;
			case eq.bind(WorldRegion.BottomRight) => true: BottomRight;
			case _: cast this;
		}
	}
}