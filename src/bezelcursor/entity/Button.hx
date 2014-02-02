package bezelcursor.entity;

using Std;
using Math;
import com.haxepunk.graphics.*;

import bezelcursor.model.DeviceData;

class Button extends Target {
	public var text(default, null):Text;
	public function new(labelText:String, textColor:Int = 0x000000, textSize:Int = -1):Void {
		text = new Text(labelText, {resizable: true});
		text.color = 0x000000;
		text.size = textSize == -1 ? Math.round(DeviceData.current.screenDPI * 0.08) : textSize;
		super();
	}
	
	override public function resize(w:Float = -1, h:Float = -1):Void {
		image_default = Image.createRect(width = w == -1 ? width : w.round(), height = h == -1 ? height : h.round(), color);
		image_hover = Image.createRect(width = w == -1 ? width : w.round(), height = h == -1 ? height : h.round(), color_hover);
		
		text.x = (width - text.width) * 0.5;
		text.y = (height - text.height) * 0.5;

		var canvas_default = new Canvas( width = w == -1 ? width : w.round(), height = h == -1 ? height : h.round());
		canvas_default.drawGraphic(0,0,image_default);
		canvas_default.drawGraphic(((width - text.width) * 0.5).int(), ((height - text.height) * 0.5).int(), text);
		graphic_default = canvas_default;

		var canvas_hover = new Canvas( width = w == -1 ? width : w.round(), height = h == -1 ? height : h.round());
		canvas_hover.drawGraphic(0,0,image_hover);
		canvas_hover.drawGraphic(((width - text.width) * 0.5).int(), ((height - text.height) * 0.5).int(), text);
		graphic_hover = canvas_hover;
	}
}