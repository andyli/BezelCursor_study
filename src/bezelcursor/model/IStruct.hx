package bezelcursor.model;

@:keep
@:autoBuild(bezelcursor.model.StructBuilder.buildClass())
interface IStruct {
	private function hxSerialize(s:haxe.Serializer):Void;
	private function hxUnserialize(s:haxe.Unserializer):Void;
	public function init():IStruct;
	public function fromObj(obj:Dynamic):IStruct;
	public function toObj():Dynamic;
}