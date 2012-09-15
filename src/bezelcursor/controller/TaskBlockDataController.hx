package bezelcursor.controller;

import ufront.web.mvc.Controller;
import ufront.web.mvc.JsonResult;
import ufront.web.mvc.ViewResult;

import bezelcursor.model.DeviceData;
import bezelcursor.model.TaskBlockData;
import bezelcursor.model.TaskBlockDataGenerator;

class TaskBlockDataController extends Controller {
    public function get() {
        return new JsonResult({});
    }
}