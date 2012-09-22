package bezelcursor.entity;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import com.haxepunk.graphics.Text;

import bezelcursor.model.*;
using bezelcursor.util.UnitUtil;

class Label extends Entity {
	public var label(get_label, set_label):String;
	function get_label():String {
		return text.text;
	}
	function set_label(v:String):String {
		text.text = text2.text = v;
		resize();
		return v;
	}
	
	public var alpha(default, set_alpha):Float;
	function set_alpha(v:Float):Float {
		return alpha = text.alpha = text2.alpha = v;
	}
	
	public var texts:Graphiclist;
	public var text:Text;
	public var text2:Text;
	
	public function new(label:String, ?options:TextOptions):Void {
		super();
		graphic = texts = new Graphiclist();
		
		text = new Text(label, options);
		Reflect.setField(options, "color", 0x000000);
		text2 = new Text(label, options);
		text2.x = text2.y = Math.max(1, DeviceData.current.screenDPI * 0.5.mm2inches());
		
		texts.add(text2);
		texts.add(text);
		
		alpha = 1;
		
		resize();
	}
	
	public function resize():Void {
		width = text.textWidth;
		height = text.textHeight;
	}
}