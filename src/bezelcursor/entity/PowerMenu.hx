package bezelcursor.entity;

import com.haxepunk.HXP;

class PowerMenu extends Panel {	
	public function new():Void {
		super();
		
		layer = 10;
		
		width = HXP.stage.stageWidth;
		height = HXP.stage.stageHeight;
		layout = Verticle(Center);
	}
	
	override public function added():Void {
		x = world.camera.x;
		y = world.camera.y;
		resetLayout();
		
		super.added();
	}
}