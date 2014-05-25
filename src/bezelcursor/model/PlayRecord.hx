package bezelcursor.model;

using Lambda;
import haxe.*;
import sys.io.*;
import cpp.vm.*;

import bezelcursor.cursor.*;
import bezelcursor.model.*;

private enum LoggerMsg {
	LLog(time:Float, event:String, data:String);
	LClose;
}

class PlayRecord implements IStruct {
	/**
	* uuid of length 36
	*/
	public var id:String;
	public var creationTime:Float;
	public var device:Dynamic;
	public var build:Dynamic;
	public var user:Dynamic;
	public var world:String;
	public var taskBlockData:Dynamic;
	public var flipStage:Bool;
	public var inputMethod:String;
	public var cursorManager:Dynamic;
	@skip var _file:FileOutput;

	public var isLogging(default, null) = true;
	@skip var thread:Thread;
	@skip var deque = new Deque<LoggerMsg>();
	
	public function new(file:FileOutput):Void {
		_file = file;

		var str = Json.stringify(toObj());
		str = str.substr(0, str.length - 1); //remove last '}'
		_file.writeString(str + ',\n"_events": [');

		thread = Thread.create(run);
	}
	
	public function addEvent(time:Float, event:String, data:Dynamic):Void {
		if (isLogging){
			deque.add(LLog(time, event, Json.stringify(data)));
		} else {
			trace("Logger is already closed.");
		}
	}
	
	public function close():Void {
		if (isLogging) {
			isLogging = false;
			deque.add(LClose);
		} else {
			trace("Logger is already closed.");
		}
	}

	function run():Void {
		while (true) {
			switch (deque.pop(true)) {
				case LLog(time, event, data):
					_file.writeString('\n{"event":"$event","data":$data,"time":$time},');
				case LClose:
					_file.writeString('\n{"event":"close","data":null,"time":${haxe.Timer.stamp()}}]}');
					_file.close();
					break;
				case null:
					throw "Message should not be null";
			}
		}
	}
}