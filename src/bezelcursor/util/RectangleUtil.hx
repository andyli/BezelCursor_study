package bezelcursor.util;

import nme.geom.Rectangle;
import nme.geom.Matrix3D;
import nme.geom.Vector3D;

class RectangleUtil {
	static public function transform3D(rect:Rectangle, m:Matrix3D):Rectangle {
		var topLeft = m.transformVector(new Vector3D(rect.x, rect.y));
		var bottomRight = m.transformVector(new Vector3D(rect.right, rect.bottom));
		return new Rectangle(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
	}
	
	/**
	* Make sure x,y is the top left.
	*/
	static public function normalize(rect:Rectangle):Rectangle {
		var newrect = rect.clone();
		
		if (rect.top > rect.bottom) {
			newrect.bottom = rect.top;
			newrect.top = rect.bottom;
		}
		if (rect.left > rect.right) {
			newrect.right = rect.left;
			newrect.left = rect.right;
		}
		
		return newrect;
	}
}