package mobzor.event;

import nme.events.Event;

using mobzor.event.CursorEventType;

class CursorEvent extends Event {
	public var cursorEventType(default, null):CursorEventType;
	
	public function new(type:CursorEventType):Void {
		super(type.toString());
		
		cursorEventType = type;
	}
}