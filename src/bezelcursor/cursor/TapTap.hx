package bezelcursor.cursor;

import flash.*;
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import hsl.haxe.*;
import bezelcursor.model.*;
using bezelcursor.util.UnitUtil;

class TapTap {
	var stage:Stage = Lib.stage;
	var cm:CursorManager;
	@skip public var view(default, null):Sprite;
	@skip public var viewBitmap(default, null):Bitmap;
	public var matrix(default, null):Matrix;

	@:isVar public var enabled(default, set):Bool;
	function set_enabled(v:Bool):Bool {
		if (v) {
			cm.onTouchEndSignaler.bind(onTouchEnd);
		} else {
			cm.onTouchEndSignaler.unbind(onTouchEnd);
			showView = false;
		}
		return enabled = v;
	}

	@:isVar public var showView(default, set):Bool;
	function set_showView(v:Bool):Bool {
		if (v) {
			stage.addEventListener(Event.ENTER_FRAME, viewOnFrame);
		} else {
			stage.removeEventListener(Event.ENTER_FRAME, viewOnFrame);
			view.visible = false;
		}
		return showView = v;
	}

	public function new(cm:CursorManager):Void {
		this.cm = cm;

		matrix = new Matrix();
		var dpi = DeviceData.current.screenDPI;
		//var marginx = 
		var bd = new BitmapData(stage.stageWidth, stage.stageHeight, false);
		viewBitmap = new Bitmap(bd, PixelSnapping.NEVER, true);
		viewBitmap.alpha = 0.9;
		view = new Sprite();
		view.addChild(viewBitmap);
	}

	public function onTouchEnd(td:TouchData):Void {
		if (!showView) {
			var scale = 3.0;
			matrix.identity();
			matrix.translate(-td.x, -td.y);
			matrix.scale(scale, scale);
			matrix.translate(viewBitmap.width*0.5, viewBitmap.height*0.5);

			showView = true;
		} else {
			//TODO click on target
			showView = false;
		}
	}
	
	function viewDraw():Void {
		view.graphics.clear();
		view.graphics.lineStyle(1, 0x000000, 1, true, LineScaleMode.NONE);
		view.graphics.drawRect(view.x, view.y, view.width, view.height);
		view.graphics.lineStyle(1, 0xFFFFFF, 1, true, LineScaleMode.NONE);
		view.graphics.drawRect(view.x - 1, view.y - 1, view.width + 2, view.height + 2);
	}

	function viewOnFrame(evt):Void {
		view.visible = false;
		viewBitmap.bitmapData.lock();
		viewBitmap.bitmapData.fillRect(viewBitmap.bitmapData.rect, 0x333333);
		viewBitmap.bitmapData.draw(Lib.current, matrix);
		viewBitmap.bitmapData.unlock();
		view.visible = true;
	}
}