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
	@skip public var eventRecords:Array<EventRecord>;
	@skip var buf:StringBuf;
	
	public function new():Void {
		
	}
	
	public function addEvent(time:Float, event:String, data:String):Void {
		if (buf == null) {
			eventRecords = [];
			buf = new StringBuf();
			var str = Json.stringify(toObj());
			str = str.substr(0, str.length - 1); //remove last '}'
			buf.add(str + ",\neventRecords: [");
		} else {
			buf.add(",");
		}
		var evt = {
			time: time,
			event: event,
			data: Serializer.run(data)
		};
		buf.add(Json.stringify(evt));
		eventRecords.push(evt);
	}
	
	public function toString():String {
		buf.add("]}");
		return buf.toString();
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
		record.user = beginData.participate;
		record.world = beginData.world;
		
		var cm:CursorManager = beginData.cursorManager;
		record.inputMethod = cm.inputMethod.name;
		
		record.eventRecords = [];
		for (ele in json) {
			record.eventRecords.push({
				time: ele.time,
				event: ele.event,
				data: ele.data
			});
		}
		return record;
	}
}