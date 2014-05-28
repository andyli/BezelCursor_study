package bezelcursor.cursor;

import flash.*;
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import haxe.*;
import hsl.haxe.*;
import bezelcursor.model.*;
using bezelcursor.util.UnitUtil;
using Std;

class TapTap {
	inline static public var scale:Float = 3;
	var stage:Stage = Lib.stage;
	var cm:CursorManager;
	@skip public var view(default, null):Sprite;
	@skip public var viewBitmap(default, null):Bitmap;
	public var matrix(default, null):Matrix;
	@skip public var cursor(default, set):PointActivatedCursor;
	function set_cursor(v:PointActivatedCursor):PointActivatedCursor {
		if (cursor != null) {
			cursor.onClickSignaler.unbindVoid(onCursorClick);
		}
		cursor = v;
		if (cursor != null) {
			syncCursor(view.globalToLocal(cursor.activatedPoint));
			cursor.onClickSignaler.bindVoid(onCursorClick);
		}
		return v;
	}

	function onCursorClick():Void {
		cursor = null;
		enabled = false;
	}

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
		var marginx = 5.mm2inches() * dpi;
		var marginy = 5.mm2inches() * dpi;
		var bd = new BitmapData((stage.stageWidth - marginx*2).int(), (stage.stageHeight - marginy*2).int(), false);
		viewBitmap = new Bitmap(bd, PixelSnapping.NEVER, true);
		// viewBitmap.alpha = 0.9;
		view = new Sprite();
		view.x = (stage.stageWidth - bd.width) * 0.5;
		view.y = (stage.stageHeight - bd.height) * 0.5;
		view.addChild(viewBitmap);
		view.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMoveOnView);
	}

	function onTouchEnd(td:TouchData):Void {
		if (!showView) {
			matrix.identity();
			matrix.translate(-td.x, -td.y);
			matrix.scale(scale, scale);
			matrix.translate(viewBitmap.width*0.5, viewBitmap.height*0.5);
			viewDraw();
			showView = true;
		}
	}

	function onTouchMoveOnView(evt:TouchEvent):Void {
		if (cursor != null) {
			syncCursor(new Point(evt.localX, evt.localY));
		}
	}

	function syncCursor(localPt:Point):Void {
		var m = matrix.clone();
		m.invert();
		cursor.setImmediatePosition(m.transformPoint(localPt));
	}
	
	function viewDraw():Void {
		view.graphics.clear();
		view.graphics.lineStyle(1, 0x000000, 1, true, LineScaleMode.NONE);
		view.graphics.drawRect(0, 0, view.width, view.height);
		view.graphics.lineStyle(1, 0xFFFFFF, 1, true, LineScaleMode.NONE);
		view.graphics.drawRect(-1, -1, view.width + 2, view.height + 2);
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