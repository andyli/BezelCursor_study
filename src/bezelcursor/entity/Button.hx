package bezelcursor.entity;

import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;

import bezelcursor.model.DeviceData;

class Button extends Target {
	public var text:Text;
	public function new(labelText:String):Void {
		text = new Text(labelText, {resizable: true});
		text.color = 0x000000;
		text.size = Math.round(DeviceData.current.screenDPI * 0.08);
		super();
	}
	
	override public function resize(w:Int = -1, h:Int = -1):Void {
		image_default = Image.createRect(width = w == -1 ? width : w, height = h == -1 ? height : h, color);
		image_hover = Image.createRect(width = w == -1 ? width : w, height = h == -1 ? height : h, color_hover);
		
		text.x = (width - text.width) * 0.5;
		text.y = (height - text.height) * 0.5;
			
		graphicList_default.removeAll();
		graphicList_default.add(image_default);
		graphicList_default.add(text);
		
		graphicList_hover.removeAll();
		graphicList_hover.add(image_hover);
		graphicList_hover.add(text);
	}
}