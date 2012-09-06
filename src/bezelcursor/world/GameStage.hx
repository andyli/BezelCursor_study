package bezelcursor.world;

class GameStage extends GameWorld {
	public var id(default, null):String;
	public function new(config:Dynamic):Void {
		
	}

    function hxSerialize(s:haxe.Serializer) {
		s.serialize(getConfig());
    }
	
    function hxUnserialize(s:haxe.Unserializer) {
		setConfig(s.unserialize());
    }
	
	public function getConfig():Dynamic {
		var config:Dynamic = {};
		
		config._class = Type.getClassName(Type.getClass(this));
				
		return config;
	}
	
	public function setConfig(config:Dynamic):Void {
		#if debug
		if (config._class != Type.getClassName(Type.getClass(this)))
			throw "Should not set " + Type.getClassName(Type.getClass(this)) + "from a config of " + config._class;
		#end
	}
	
	public function clone(?c:C):Behavior<C> {
		return new Behavior<C>(c == null ? cursor : c, getConfig());
	}
	
	static public function createFromConfig<C:Cursor, B:Behavior<Dynamic>>(c:C, config:Dynamic):B {
		return Type.createInstance(Type.resolveClass(config._class), [c, config]);
	}
	
	static public function createFromConfigs<C:Cursor, B:Behavior<Dynamic>>(c:C, configs:Array<Dynamic>):Array<B> {
		var bs = [];
		for (config in configs) {
			bs.push(createFromConfig(c, config));
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