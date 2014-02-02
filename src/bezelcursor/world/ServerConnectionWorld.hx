package bezelcursor.world;

using Std;
using Lambda;
using StringTools;
import flash.events.*;
import flash.text.*;
import flash.net.*;
import com.haxepunk.*;
import com.haxepunk.graphics.*;
using motion.Actuate;
using org.casalib.util.NumberUtil;

using bezelcursor.Main;
import bezelcursor.entity.*;
import bezelcursor.model.*;
import bezelcursor.world.*;
import bezelcursor.util.*;

class ServerConnectionWorld extends GameWorld {
	var panel:Panel;
	var msgEntity:Entity;
	var msg:Text;
	var retryBtn:Button;
	
	function updateMsg(str:String):Void {
		msg.text = str;
		msgEntity.width = msg.textWidth;
		msgEntity.height = msg.textHeight;
		panel.resetLayout();
	}
	
	override public function begin():Void {
		super.begin();
		
		HXP.engine.asMain().cursorManager.inputMethod = InputMethod.DirectTouch;
		
		panel = new Panel();
		
		var text = new Text(
			"We need to connect\n to the server...\nMake sure you're \nconnected to the Internet.",
			{
				color: 0xFFFFFF,
				size: Math.round(DeviceData.current.screenDPI * 0.12),
				resizable: true,
				align: TextFormatAlign.CENTER
			}
		);
		var entity = new Entity();
		entity.graphic = text;
		entity.width = text.width;
		entity.height = text.height;
		panel.add(entity);
		
		msg = new Text(
			"",
			{
				color: 0xFFFFFF,
				size: Math.round(DeviceData.current.screenDPI * 0.12),
				resizable: true,
				align: TextFormatAlign.CENTER
			}
		);
		msg.tween(0.25, {alpha:0.5}).reflect(true).repeat(-1);
		
		msgEntity = new Entity();
		msgEntity.graphic = msg;
		panel.add(msgEntity);
		
		retryBtn = new Button("Retry");
		retryBtn.resize(retryBtn.text.width + 20, retryBtn.text.height + 20);
		retryBtn.visible = false;
		retryBtn.onClickSignaler.bindVoid(connect);
		panel.add(retryBtn);
		
		
		panel.x = 0;
		panel.y = DeviceData.current.screenDPI * 0.8;
		panel.width = HXP.stage.stageWidth;
		panel.layout = Verticle(Center);
		add(panel);
		
		connect();
	}
	
	override public function end():Void {
		retryBtn.onClickSignaler.unbindVoid(connect);
		msg.stop();
		super.end();
	}
	
	function onError(details:String):Void {
		trace(details);
		updateMsg("Error: " + details);
		msg.color = 0xFF0000;
		msg.stop();
	}
	
	function onTaskblockdataGet(respond:Null<String>):Void {
		//trace(respond);
		
		if (respond != null && respond != "null"){
			TaskBlockData.current = haxe.Unserializer.run(respond);
			ready();
		} else {
			updateMsg("Generating tasks...");
			
			// var gen = TaskBlockDataGenerator.current;
			// var pbond = gen.onProgressSignaler.bind(function(p) {
			// 	updateMsg("Generating tasks...\n" + p.map(0, 1, 0, 100).int() + "%");
			// });
			// gen.onCompleteSignaler.bind(function(a) {
			// 	onTaskBlockGenerated(a);
			// 	pbond.destroy();
			// }).destroyOnUse();
			// gen.generateTaskBlocks();
		}
	}
	
	function onTaskBlockGenerated(taskblocks:Array<TaskBlockData>){
		updateMsg("Sync with server...");
		
		haxe.Timer.delay(function(){
			TaskBlockData.current = taskblocks;
			ready();
		}, 100);
		
		return;
		
		var load = new AsyncLoader(Env.website + "taskblockdata/set/", Post);
		load.data = {
			buildData: haxe.Serializer.run(BuildData.current),
			deviceData: haxe.Serializer.run(DeviceData.current),
			taskblocks: haxe.Serializer.run(taskblocks)
		}
		load.onCompleteSignaler.bind(function(respond){
			if (respond != "ok") {
				onError(respond);
			} else {
				haxe.Timer.delay(function(){
					TaskBlockData.current = taskblocks;
					ready();
				}, 100);
			} 
		}).destroyOnUse();
		load.onErrorSignaler.bind(onError).destroyOnUse();
		load.load();
	}
	
	var urlLoader:URLLoader;
	var connectThead:Dynamic;
	function connect():Void {
		updateMsg("Connecting...");
		
		if (TaskBlockData.current != null) {
			ready();
		} else {
			updateMsg("Generating tasks...");
			
			var gen = TaskBlockDataGenerator.current;
			var pbond = gen.onProgressSignaler.bind(function(p) {
				updateMsg("Generating tasks...\n" + p.map(0, 1, 0, 100).int() + "%");
			});
			gen.onCompleteSignaler.bind(function(a) {
				onTaskBlockGenerated(a);
				pbond.destroy();
			}).destroyOnUse();
			gen.generateTaskBlocks();
		}
		
		return;
		
		var load = new AsyncLoader(Env.website + "taskblockdata/get/", Get);
		load.data = {
			buildData: haxe.Serializer.run(BuildData.current),
			deviceData: haxe.Serializer.run(DeviceData.current)
		}
		load.onCompleteSignaler.bind(onTaskblockdataGet).destroyOnUse();
		load.onErrorSignaler.bind(onError).destroyOnUse();
		load.load();
	}
	
	function ready():Void {
		updateMsg("OK!");
		msg.color = 0x00FF00;
		msg.tween(1, {alpha: 1}).onComplete(function(){
			HXP.world = new PowerMenuWorld();
		});
	}
}