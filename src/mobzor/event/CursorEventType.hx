package mobzor.event;

enum CursorEventType {
	Click;
}

class CursorEventTypeTools {
	static public function toString(eType:CursorEventType):String {
		return switch (eType) {
			case Click: "CursorEventType.Click";
		}
	}
}