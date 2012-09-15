package bezelcursor.controller;

import haxe.Json;
import ufront.web.mvc.Controller;
import ufront.web.mvc.JsonResult;
import ufront.web.mvc.ViewResult;

import bezelcursor.model.BuildData;
import bezelcursor.model.DeviceData;
import bezelcursor.model.TaskBlockData;
import bezelcursor.model.TaskBlockDataGenerator;

class TaskBlockDataController extends Controller {
    public function get() {
		var qs = this.controllerContext.request.query;
		var bd = new BuildData().fromObj(Json.parse(qs.get("buildData")));
		//return qs;
        return new JsonResult(bd.toObj());
    }
}