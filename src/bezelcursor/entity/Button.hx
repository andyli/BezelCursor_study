package bezelcursor.entity;

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
		
		image_default.alpha = image_hover.alpha = alpha;
		
		text.x = (width - text.textWidth) * 0.5;
		text.y = (height - text.textHeight) * 0.5;
			
		graphicList_default.removeAll();
		graphicList_default.add(image_default);
		graphicList_default.add(text);
		
		graphicList_hover.removeAll();
		graphicList_hover.add(image_hover);
		graphicList_hover.add(text);
	}
}