package bezelcursor.util;

class UnitUtil {
	inline static public function mm2inches(v:Float):Float {
		return v * 0.03937;
	}
	
	inline static public function inches2mm(v:Float):Float {
		return v * 25.4;
	}
}