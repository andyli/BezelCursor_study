package bezelcursor.entity;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import com.haxepunk.graphics.Text;

class Label extends Entity {
	public var label(get_label, set_label):String;
	function get_label():String {
		return text.text;
	}
	function set_label(v:String):String {
		text.text = v;
		resize();
		return v;
	}
	
	public var text:Text;
	
	public function new(label:String, ?options:TextOptions):Void {
		super();
		graphic = text = new Text(label, options);
		resize();
	}
	
	public function resize():Void {
		width = text.textWidth;
		height = text.textHeight;
	}
}