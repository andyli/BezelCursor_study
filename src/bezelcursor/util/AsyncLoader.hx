package bezelcursor.util;

using Lambda;
using StringTools;
#if cpp
import cpp.vm.*;
#elseif neko
import neko.vm.*;
#end
import flash.events.*;
import flash.net.*;
import hsl.haxe.*;

enum HttpMethod {
	Get;
	Post;
}

class AsyncLoader {
	static public var instances:Array<AsyncLoader> = [];
	
	public var url(default, null):String;
	public var method(default, null):HttpMethod;
	public var data:Dynamic<String>;
	public var isLoading(default, null):Bool;
	
	public var onCompleteSignaler(default, null):Signaler<String>;
	public var onErrorSignaler(default, null):Signaler<String>;
	
	public function new(url:String, method:HttpMethod):Void {
		this.url = url;
		this.method = method;

		urlLoader = new URLLoader();
		
		onCompleteSignaler = new DirectSignaler<String>(this);
		onErrorSignaler = new DirectSignaler<String>(this);
		
		instances.push(this);
	}
	
	public function destroy():Void {
		instances.remove(this);
	}
	
	var urlLoader:URLLoader;
	function loadWithUrlLoader():Void {
		isLoading = true;
		
		var urlRequest = new URLRequest(url);
		#if air
		urlRequest.useCache = false;
		#end
		urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
		
		switch(method) {
			case Get:
				urlRequest.method = URLRequestMethod.GET;
				if (data != null) {
					#if !flash
					urlRequest.url += "?" + Reflect.fields(data).map(function(f) {
						var v:String = Reflect.field(data, f);
						return f + "=" + v.urlEncode();
					}).join("&");
					#else
					var variables:URLVariables = new URLVariables();
					for (f in Reflect.fields(data)) {
						Reflect.setField(variables, f, Reflect.field(data, f));
					}
					urlRequest.data = variables;
					#end
				}
				
			case Post:
				urlRequest.method = URLRequestMethod.POST;
				if (data != null) {
					var variables:URLVariables = new URLVariables();
					for (f in Reflect.fields(data)) {
						Reflect.setField(variables, f, Reflect.field(data, f));
					}
					urlRequest.data = variables;
				}
		}

		//urlLoader.addEventListener(Event.OPEN, function(evt) trace("open"));
		//urlLoader.addEventListener(ProgressEvent.PROGRESS, function(evt) updateMsg("Receiving data..."));
		urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(evt:SecurityErrorEvent) {
			onErrorSignaler.dispatch(evt.type);
			isLoading = false;
			destroy();
		});
		urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(evt:HTTPStatusEvent) {
			if (evt.status != 200) {
				onErrorSignaler.dispatch(Std.string(evt.status));
				isLoading = false;
				destroy();
			}
		});
		urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(evt:IOErrorEvent){
			onErrorSignaler.dispatch(evt.type);
			isLoading = false;
			destroy();
		});
		urlLoader.addEventListener(Event.COMPLETE, function(evt:Event){
			onCompleteSignaler.dispatch(urlLoader.data);
			isLoading = false;
			destroy();
		});
		
		urlLoader.load(urlRequest);
	}
	
	#if (cpp || neko)
	var loadThread:Thread;
	function loadWithHttp():Void {
		isLoading = true;
		loadThread = Thread.create(function():Void {
			var http = new haxe.Http(url);
			http.cnxTimeout = 60;
			if (data != null) {
				Reflect.fields(data).iter(function(f) http.setParameter(f, Reflect.field(data, f)));
			}
			http.onError = function(_error:String){
				onErrorSignaler.dispatch(_error);
				isLoading = false;
				destroy();
			};
			http.onData = function(_respond:String) {
				onCompleteSignaler.dispatch(_respond);
				isLoading = false;
				destroy();
			};
			http.onStatus = function(_status:Int) {
				if (_status != 200) {
					onErrorSignaler.dispatch(Std.string(_status));
					isLoading = false;
					destroy();
				}
			}
			http.request(switch(method){ case Get: false; case Post: true; });
		});
	}
	#end
	
	public function load():Void {		
		switch(method) {
			case Get:
				loadWithUrlLoader();
			case Post:
				#if (cpp || neko)
				loadWithHttp();
				#else
				loadWithUrlLoader();
				#end
		}
	}
	
}