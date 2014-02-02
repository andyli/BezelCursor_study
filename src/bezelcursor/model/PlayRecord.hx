package bezelcursor.model;

using Lambda;
import haxe.*;
import org.casalib.util.*;

import bezelcursor.cursor.*;
import bezelcursor.model.*;

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
	@skip public var events(get_events, null):Array<EventRecord>;
	function get_events() {
		return _events;
	}
	@skip var _events:Array<EventRecord>;
	@skip var _events_buf:StringBuf;
	
	public function new():Void {
		
	}
	
	function init_events_buf():Void {
		_events_buf = new StringBuf();
		var str = Json.stringify(toObj());
		str = str.substr(0, str.length - 1); //remove last '}'
		_events_buf.add(str + ',\n"_events": [');
		
		if (_events == null) {
			_events = [];
		} else {
			_events_buf.add([for (e in _events) Json.stringify(e)].join(","));
		}
	}
	
	public function addEvent(time:Float, event:String, data:Dynamic):Void {
		if (_events_buf == null) {
			init_events_buf();
		} else {
			_events_buf.add(",");
		}
		var evt = {
			time: time,
			event: event,
			data: data
		};
		_events_buf.add(Json.stringify(evt));
		_events.push(evt);
	}
	
	public function toString():String {
		if (_events_buf == null) {
			init_events_buf();
		}
		_events_buf.add("]}");
		return _events_buf.toString();
	}
	
	public function fromString(str:String):PlayRecord {
		var json = Json.parse(str);
		fromObj(json);
		_events = json._events;
		_events_buf = null;
		return this;
	}
}