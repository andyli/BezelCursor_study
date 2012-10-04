package bezelcursor.model;

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
	@skip public var events(get_events, null):Iterable<EventRecord>;
	function get_events() {
		return _events;
	}
	@skip var _events:Array<EventRecord>;
	@skip var _events_buf:StringBuf;
	
	public function new():Void {
		
	}
	
	function init_events_buf():Void {
		_events = [];
		_events_buf = new StringBuf();
		var str = Json.stringify(toObj());
		str = str.substr(0, str.length - 1); //remove last '}'
		_events_buf.add(str + ',\n"_events": [');
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
	
	static public function fromString(str:String):PlayRecord {
		var record = new PlayRecord();
		var json:Array<{
			time:Float,
			event:String,
			data:String
		}> = Json.parse(str);
			
		if (json[0].event != "begin") throw "not begin?";
		
		var beginData = Unserializer.run(json[0].data);
		record.id = beginData.id == null ? StringUtil.uuid() : beginData.id;
		record.creationTime = json[0].time;
		//record.device = json[0].device;
		var u = new UserData(); 
		u.name = beginData.participate;
		record.user = u;
		record.world = beginData.world;
		record.taskBlockData = cast(beginData.taskBlockData, TaskBlockData).toObj();
		record.build = new BuildData().fromObj({"buildTime":1.349282409e+12,"isMobile":true,"isAir":false,"isLinux":false,"isWindows":false,"isMac":false,"isPhp":false,"isFlash":false,"isCpp":true,"isIos":false,"isAndroid":true,"isDebug":false}).toObj();
		record.device = new DeviceData().fromObj({"lastLocalSyncTime":1.349237504e+12,"lastRemoteSyncTime":null,"screenDPI":304.7999878,"screenResolutionY":1280,"screenResolutionX":720,"hardwareModel":"GT-I9300","systemVersion":"4.0.4","systemName":"Android","id":"20CEAD1B-FD33-49DB-B494-CED096601A50"}).toObj();
		
		var cm:CursorManager = beginData.cursorManager;
		record.inputMethod = cm.inputMethod.name;
		
		var _n = 0;
		for (ele in json) {
			trace(ele.event);
			var data = Unserializer.run(ele.data);
			if (ele.event.indexOf("cursor-") > -1) {
				var _data:Dynamic = {};
				for (f in Reflect.fields(data)) {
					var v = Reflect.field(data, f);
					Reflect.setField(_data, f, v == null ? null : Std.is(v,IStruct) ? cast(v,IStruct).toObj() : v);
				}
				record.addEvent(
					ele.time,
					ele.event,
					_data
				);
			} else {
				record.addEvent(
					ele.time,
					ele.event,
					data == null || ele.event == "begin" ? null : ele.event == "next" ? cast _n++ : Std.is(data,IStruct) ? cast(data,IStruct).toObj() : data
				);
			}
		}
		return record;
	}
}