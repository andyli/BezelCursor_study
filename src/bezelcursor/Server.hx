package bezelcursor;

import haxe.xml.Fast;
import sys.FileSystem;
import sys.io.File;
import php.Lib;
import php.Web;
import thx.util.Imports;
import ufront.web.AppConfiguration;
import ufront.web.DirectoryUrlFilter;
import ufront.web.mvc.MvcApplication;
import ufront.web.routing.RouteCollection;

import bezelcursor.model.Env;

class Server {
	static public var LOCAL_DIR(default, never):String = "BezelCursor";
	static public var ABSOLUT_PATH(default, never):String = Web.getHostName() == "localhost" ? "http://localhost/" + LOCAL_DIR + "/" : Env.website;
	
	static function main():Void {
		Imports.pack("bezelcursor.controller", true);
		var config = new AppConfiguration("bezelcursor.controller", true);
		
		
		var routes = new RouteCollection();
		routes.addRoute("/", { controller : "home", action : "index" } );
		routes.addRoute("/taskblockdata/get/", { controller : "TaskBlockData", action : "get" } );
		routes.addRoute("/taskblockdata/set/", { controller : "TaskBlockData", action : "set" } );
		
		var application = new MvcApplication(config, routes);
		
		if (Web.getHostName() == "localhost")
			application.httpContext.addUrlFilter(new DirectoryUrlFilter(LOCAL_DIR));		
		
		application.execute();
	}
}
