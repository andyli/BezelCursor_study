package bezelcursor.controller;

using Lambda;
using StringTools;
import haxe.Json;
import ufront.web.mvc.Controller;
import ufront.web.mvc.JsonResult;
import ufront.web.mvc.ViewResult;

import bezelcursor.model.*;
import bezelcursor.model.db.*;

class TaskBlockDataController extends Controller {
	static function __init__():Void {
		TaskBlockDataStore.manager;
	}
	
    public function get() {
		var qs = controllerContext.request.query;
		var buildData:BuildData = haxe.Unserializer.run(qs.get("buildData"));
		var deviceData:DeviceData = haxe.Unserializer.run(qs.get("deviceData"));
		
		//var screenResolutionXInch = deviceData.screenResolutionX / deviceData.screenDPI;
		//var screenResolutionYInch = deviceData.screenResolutionY / deviceData.screenDPI;
		
		//return deviceData.screenResolutionX + "," + deviceData.screenResolutionY + "," + deviceData.screenDPI;
		
		var tbds:List<TaskBlockDataStore> = TaskBlockDataStore.manager.search(
			$screenResolutionX == deviceData.screenResolutionX && 
			$screenResolutionY == deviceData.screenResolutionY && 
			$screenDPI == deviceData.screenDPI,
			{ orderBy: -generateTime }
		);
		
		if (tbds.length > 0){
			return haxe.Serializer.run(tbds.first().taskBlockDatas);
		} else {
			return "null";
		}
    }
	
	public function set() {
		//trace("Content-type: " + controllerContext.request.clientHeaders.get("Content-type"));
		//return controllerContext.request.postString.substr(0, 200);
		//sys.io.File.saveContent("log"+Date.now().toString() + ".txt", controllerContext.request.postString);
		
		var post = controllerContext.request.post;
		var buildData:BuildData = haxe.Unserializer.run(post.get("buildData"));
		var deviceData:DeviceData = haxe.Unserializer.run(post.get("deviceData"));
		var taskBlockDatas:Array<TaskBlockData> = haxe.Unserializer.run(post.get("taskblocks"));
		
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
		
		return "ok";
	}
}