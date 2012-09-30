package bezelcursor.entity;

using Math;
import com.haxepunk.*;
import com.haxepunk.graphics.*;
import nme.geom.*;
import nme.text.*;
import nme.Lib;

import bezelcursor.model.*;
using bezelcursor.world.GameWorld;
using bezelcursor.util.UnitUtil;

class TextInput extends Entity {
	public var textInput:TextField;
	
	public function new(label:String, width:Float, height:Float):Void {
		super();
		
		var fontObj = nme.Assets.getFont(HXP.defaultFont);
		var tf = new TextFormat(fontObj.fontName, Math.round(DeviceData.current.screenDPI * 0.2), 0xFFFFFF);
		
		textInput = new TextField();
		textInput.type = TextFieldType.INPUT;
		textInput.text = label;
		textInput.textColor = 0xFFFFFF;
		textInput.setTextFormat(tf);
		textInput.border = true;
		textInput.borderColor = 0x999999;
		this.width = (textInput.width = width).round();
		this.height = (textInput.height = height).round();
	}
	
	override public function added():Void {
		super.added();
		
		Lib.current.addChild(textInput);
	}
	
	override public function removed():Void {
		Lib.current.removeChild(textInput);
		
		super.removed();
	}
	
	override public function update():Void {
		super.update();
		var screenPt = world.asGameWorld().worldToScreen(new Point(x,y));
		textInput.x = screenPt.x;
		textInput.y = screenPt.y;
	}
}