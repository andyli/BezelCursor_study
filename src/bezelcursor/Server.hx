package bezelcursor;

import Sys.*;
import php.*;
import haxe.*;
import haxe.web.*;
import sys.io.*;
import bezelcursor.model.*;
import bezelcursor.model.db.*;

class Server {
	static public var LOCAL_DIR(default, never):String = "BezelCursor";
	static public var ABSOLUT_PATH(default, never):String = Web.getHostName() == "localhost" ? "http://localhost/" + LOCAL_DIR + "/" : Env.website;
	
	public function new():Void {}

	public function doDefault():Void {
		Sys.print(File.getContent("view/bezelcursor/home/index.html"));
	}

	public function doTaskblockdata(action:String):Void {
		switch (action) {
			case "get":
				var params = Request.getParams();
				var deviceData:DeviceData = Unserializer.run(params.get("deviceData"));
				
				var screenResolutionXInch = deviceData.screenResolutionX / deviceData.screenDPI;
				var screenResolutionYInch = deviceData.screenResolutionY / deviceData.screenDPI;
				
				//return deviceData.screenResolutionX + "," + deviceData.screenResolutionY + "," + deviceData.screenDPI;
				
				var tbds:List<TaskBlockDataStore> = TaskBlockDataStore.manager.search(
					$screenResolutionXInch == screenResolutionXInch && 
					$screenResolutionYInch == screenResolutionYInch,
					{ orderBy: -generateTime }
				);
				
				if (tbds.length > 0){
					print(Serializer.run(tbds.first().taskBlockDatas));
				} else {
					print(null);
				}
			case "set":
				var params = Request.getParams();
				var deviceData:DeviceData = Unserializer.run(params.get("deviceData"));
				var taskBlockDatas:Array<TaskBlockData> = Unserializer.run(params.get("taskblocks"));
				print(params.get("deviceData"));
				return;
				var screenResolutionXInch = deviceData.screenResolutionX / deviceData.screenDPI;
				var screenResolutionYInch = deviceData.screenResolutionY / deviceData.screenDPI;
				
				var tbds = new TaskBlockDataStore();
				tbds.screenResolutionX = deviceData.screenResolutionX;
				tbds.screenResolutionY = deviceData.screenResolutionY;
				tbds.screenDPI = deviceData.screenDPI;
				tbds.screenResolutionXInch = deviceData.screenResolutionX / deviceData.screenDPI;
				tbds.screenResolutionYInch = deviceData.screenResolutionY / deviceData.screenDPI;
				tbds.generateTime = Date.now();
				tbds.taskBlockDatas = taskBlockDatas;
				tbds.insert();
				
				print("ok");
		}
	}

	static function main():Void {
		Dispatch.run(Web.getURI(), Web.getParams(), new Server());
	}
}
