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
	public var device:DeviceData;
	public var build:BuildData;
	public var user:UserData;
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
	
	public function addEvent(time:Float, event:String, data:String):Void {
		if (_events_buf == null) {
			_events = [];
			_events_buf = new StringBuf();
			var str = Json.stringify(toObj());
			str = str.substr(0, str.length - 1); //remove last '}'
			_events_buf.add(str + ",\n_events: [");
		} else {
			_events_buf.add(",");
		}
		var evt = {
			time: time,
			event: event,
			data: Serializer.run(data)
		};
		_events_buf.add(Json.stringify(evt));
		_events.push(evt);
	}
	
	public function toString():String {
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
		record.user = new UserData(); 
		record.user.name = beginData.participate;
		record.world = beginData.world;
		record.taskBlockData = cast(beginData.taskBlockData, TaskBlockData).toObj();
		record.build = new BuildData().fromObj({"buildTime":1.349282409e+12,"isMobile":true,"isAir":false,"isLinux":false,"isWindows":false,"isMac":false,"isPhp":false,"isFlash":false,"isCpp":true,"isIos":false,"isAndroid":true,"isDebug":false});
		record.device = new DeviceData().fromObj({"lastLocalSyncTime":1.349237504e+12,"lastRemoteSyncTime":null,"screenDPI":304.7999878,"screenResolutionY":1280,"screenResolutionX":720,"hardwareModel":"GT-I9300","systemVersion":"4.0.4","systemName":"Android","id":"20CEAD1B-FD33-49DB-B494-CED096601A50"});
		
		var cm:CursorManager = beginData.cursorManager;
		record.inputMethod = cm.inputMethod.name;
		
		for (ele in json) {
			record.addEvent(
				ele.time,
				ele.event,
				ele.data
			);
		}
		return record;
	}
}