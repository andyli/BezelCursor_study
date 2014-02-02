package bezelcursor.util;

import flash.geom.*;

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
	
	/**
	 * Find the distance between two rectangles. Will return 0 if the rectangles overlap.
	 * Based on HaxePunk.
	 */
	public static function distanceRects(rect1:Rectangle, rect2:Rectangle):Float
	{
		inline function distance(x1:Float, y1:Float, x2:Float = 0, y2:Float = 0):Float {
			return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
		}
		
		if (rect1.x < rect2.x + rect2.width && rect2.x < rect1.x + rect1.width)
		{
			if (rect1.y < rect2.y + rect2.height && rect2.y < rect1.y + rect1.height) return 0;
			if (rect1.y > rect2.y) return rect1.y - (rect2.y + rect2.height);
			return rect2.y - (rect1.y + rect1.height);
		}
		if (rect1.y < rect2.y + rect2.height && rect2.y < rect1.y + rect1.height)
		{
			if (rect1.x > rect2.x) return rect1.x - (rect2.x + rect2.width);
			return rect2.x - (rect1.x + rect1.width);
		}
		if (rect1.x > rect2.x)
		{
			if (rect1.y > rect2.y) return distance(rect1.x, rect1.y, (rect2.x + rect2.width), (rect2.y + rect2.height));
			return distance(rect1.x, rect1.y + rect1.height, rect2.x + rect2.width, rect2.y);
		}
		if (rect1.y > rect2.y) return distance(rect1.x + rect1.width, rect1.y, rect2.x, rect2.y + rect2.height);
		return distance(rect1.x + rect1.width, rect1.y + rect1.height, rect2.x, rect2.y);
	}
	
	public static function toObj(rect:Rectangle) {
		return {
			x: rect.x,
			y: rect.y,
			width: rect.width,
			height: rect.height
		};
	}
}