package bezelcursor.world;

import com.haxepunk.HXP;
import com.haxepunk.World;
import com.haxepunk.graphics.Text;
import flash.Lib;
import flash.geom.Rectangle;
import flash.text.TextFormatAlign;
using org.casalib.util.RatioUtil;

using bezelcursor.Main;
import bezelcursor.cursor.CursorManager;
import bezelcursor.entity.Panel;
import bezelcursor.entity.Button;
import bezelcursor.model.DeviceData;

class ConfigThumbSpaceWorld extends GameWorld {
	var panel:Panel;
	
	public function new():Void {
		super();
		
		panel = new Panel();
		
		var btn = new Button("redefine", 0x000000, Math.round(DeviceData.current.screenDPI * 0.24));
		btn.resize(btn.text.width + 20, btn.text.height + 20);
		btn.onClickSignaler.bindVoid(function(){
			var clone = new ConfigThumbSpaceWorld();
			clone.worldQueue = worldQueue;
			HXP.world = clone;
		});
		panel.add(btn);
		
		var btn = new Button("OK", 0x000000, Math.round(DeviceData.current.screenDPI * 0.48));
		btn.resize(btn.text.width + 20, btn.text.height + 20);
		btn.onClickSignaler.bindVoid(onOk);
		panel.add(btn);
		
		panel.y = Lib.stage.stageHeight * 0.5;
		panel.width = Lib.stage.stageWidth;
		panel.layout = Verticle(Center);
	}
	
	public function onOk():Void {
		HXP.engine.asMain().cursorManager.thumbSpaceEnabled = false;
		nextWorld();
	}
	
	override public function begin():Void {
		super.begin();
		
		var cm = HXP.engine.asMain().cursorManager;
		cm.cursorsEnabled = true;
		cm.thumbSpaceEnabled = true;
		cm.startThumbSpaceConfig();
		Lib.stage.addChild(cm.thumbSpaceView);
		
		var text = new Text(
			"Drag you thumb to define \na rectangle that you can \ntap comfortably \nwith your thumb.",
			{
				color: 0xFFFFFF,
				size: Math.round(DeviceData.current.screenDPI * 0.12),
				resizable: true,
				align: TextFormatAlign.CENTER
			}
		);
		
		var textE = addGraphic(text);
		textE.x = (Lib.stage.stageWidth - text.width) * 0.5;
		textE.y = DeviceData.current.screenDPI * 0.8;
	}
	
	override public function update():Void {
		var cm = HXP.engine.asMain().cursorManager;
		switch (cm.thumbSpaceConfigState) {
			case Configured:
				add(panel);
			default:
				
		}
	}
}