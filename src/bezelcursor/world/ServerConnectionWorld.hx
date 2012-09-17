package bezelcursor.world;

using Lambda;
using StringTools;
import nme.events.*;
import nme.text.*;
import nme.net.*;
import com.haxepunk.*;
import com.haxepunk.graphics.*;
using com.eclecticdesignstudio.motion.Actuate;

using bezelcursor.Main;
import bezelcursor.entity.*;
import bezelcursor.model.*;
import bezelcursor.world.*;

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
		msg.tween(0.5, {alpha:0.5}).reflect(true).repeat(-1);
		
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
	
	function onError(code:String, details:String):Void {
		updateMsg("Error: (" + code + ")\n\n" + details);
		msg.color = 0xFF0000;
		msg.stop();
	}
	
	function onTaskblockdataGet(respond:Null<String>):Void {
		if (respond != null && respond != "null"){
			//trace(respond + " " +respond.length);
			HXP.engine.asMain().taskblocks = haxe.Unserializer.run(respond);
			ready();
		} else {
			updateMsg("Generating tasks...");
			var taskblocks = TaskBlockDataGenerator.current.generateTaskBlocks();

			updateMsg("Sync with server");
			
			cpp.vm.Thread.create(function():Void {
				var respond:Null<String> = null;
				var status:Null<Int> = null;
				var http = new haxe.Http(Env.website + "taskblockdata/set/");
				http.cnxTimeout = 30;
				http.setParameter("buildData", haxe.Serializer.run(BuildData.current));
				http.setParameter("deviceData", haxe.Serializer.run(DeviceData.current));
				http.setParameter("taskblocks", haxe.Serializer.run(taskblocks));
						
				http.onData = function(_respond:String) {
					respond = _respond;
				}
				http.onStatus = function(_status:Int) {
					status = _status;
				}

				updateMsg("Sync with server...");
						
				http.request(true);
						
				if (status == 200 && respond == "ok") {
					HXP.engine.asMain().taskblocks = taskblocks;
					ready();
				} else {
					onError(Std.string(status), "");
				}
			});
		}
	}
	
	var urlLoader:URLLoader;
	var connectThead:Dynamic;
	function connect():Void {
		updateMsg("Connecting...");
		
		var urlRequest = new URLRequest(Env.website + "taskblockdata/get/" +
			"?buildData=" + haxe.Serializer.run(BuildData.current).urlEncode() + 
			"&deviceData=" + haxe.Serializer.run(DeviceData.current).urlEncode());
		urlRequest.method = URLRequestMethod.GET;
		urlLoader = new URLLoader();
		urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
		//urlLoader.addEventListener(Event.OPEN, function(evt) trace("open"));
		urlLoader.addEventListener(ProgressEvent.PROGRESS, function(evt) updateMsg("Receiving data..."));
		urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(evt) onError("SECURITY_ERROR", ""));
		urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(evt:HTTPStatusEvent) {
			if (evt.status != 200) 
				onError(Std.string(evt.status), "");
		});
		urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(evt) onError("IO_ERROR", ""));
		urlLoader.addEventListener(Event.COMPLETE, function(evt:Event){
			onTaskblockdataGet(urlLoader.data);
		});
		urlLoader.load(urlRequest);
		
		/*
		connectThead = cpp.vm.Thread.create(function(){
			var respond:Null<String> = null;
			var status:Null<Int> = null;
			var http = new haxe.Http(Env.website + "taskblockdata/get/");
			http.cnxTimeout = 60;
			http.setParameter("buildData", haxe.Serializer.run(BuildData.current));
			http.setParameter("deviceData", haxe.Serializer.run(DeviceData.current));
			http.onData = function(_respond:String) {
				trace(_respond);
				respond += _respond;
			}
			http.onStatus = function(_status:Int) {
				trace(_status);
				status = _status;
			}
			//trace(http.url + "?buildData=" + haxe.Serializer.run(BuildData.current).urlEncode() + "&deviceData=" + haxe.Serializer.run(DeviceData.current).urlEncode());
			
			updateMsg("Connecting...");
			
			http.request(false);
			
			switch (status) {
				case 200:
					onTaskblockdataGet(respond);
				default:
					updateMsg("Error: (" + status + ")\n\n" + respond);
					msg.color = 0xFF0000;
					msg.stop();
					trace(respond);
			}
		});
		*/
	}
	
	function ready():Void {
		updateMsg("OK!");
		msg.color = 0x00FF00;
		msg.tween(1, {alpha: 1}).onComplete(function(){
			HXP.world = new PowerMenuWorld();
		});
	}
}