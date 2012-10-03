package bezelcursor.controller;

using StringTools;
import ufront.web.mvc.Controller;
import ufront.web.mvc.ViewResult;

import bezelcursor.Server;

class HomeController extends Controller {
    public function index() {
        return new ViewResult();
    }
	
    public function result() {
        return new ViewResult();
    }
}


/*
var respond = null;
var bd = bezelcursor.model.BuildData.current.toObj();
var http = new haxe.Http("http://hxbuilds.s3.amazonaws.com/");
http.cnxTimeout = 1;
http.setParameter("buildData", haxe.Json.stringify(bd));
http.onData = function(data:String) respond = data;
http.request(false);
*/