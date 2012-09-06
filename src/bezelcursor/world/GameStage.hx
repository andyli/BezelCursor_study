package bezelcursor.world;

class GameStage extends GameWorld {
	public var id(default, null):String;
	public function new(data:Dynamic):Void {
		
	}

    function hxSerialize(s:haxe.Serializer) {
		s.serialize(getData());
    }
	
    function hxUnserialize(s:haxe.Unserializer) {
		setData(s.unserialize());
    }
	
	public function getData():Dynamic {
		var data:Dynamic = {};
		
		data._class = Type.getClassName(Type.getClass(this));
				
		return data;
	}
	
	public function setData(data:Dynamic):Void {
		#if debug
		if (data._class != Type.getClassName(Type.getClass(this)))
			throw "Should not set " + Type.getClassName(Type.getClass(this)) + "from a data of " + data._class;
		#end
	}
	
	public function clone(?c:C):Behavior<C> {
		return new Behavior<C>(c == null ? cursor : c, getData());
	}
	
	static public function createFromData<C:Cursor, B:Behavior<Dynamic>>(c:C, data:Dynamic):B {
		return Type.createInstance(Type.resolveClass(data._class), [c, data]);
	}
	
	static public function createFromDatas<C:Cursor, B:Behavior<Dynamic>>(c:C, datas:Array<Dynamic>):Array<B> {
		var bs = [];
		for (data in datas) {
			bs.push(createFromData(c, data));
		}
		return bs;
	}
	
	public static var stages(get_stages, null):Array<GameStage>;
	function get_stages():Array<GameStage> {
		if (stages != null) return stages;
		
		stages = [];
		
		
		
		return stages;
	}
}