package;

/*
 * 1€ Filter http://www.lifl.fr/~casiez/1euro/
 * Haxe version by Andy Li (andy@onthewings.net)
 * 
 * Based on OneEuroFilter.cc - Nicolas Roussel (nicolas.roussel@inria.fr)
 */

class OneEuroFilter {
	var freq:Float;
	var mincutoff:Float;
	var beta_:Float;
	var dcutoff:Float;
	var x:LowPassFilter;
	var dx:LowPassFilter;
	var lasttime:Float;
	inline static var UndefinedTime:Float = -1;

	function alpha(cutoff:Float):Float {
		var te:Float = 1.0 / freq;
		var tau:Float = 1.0 / (2 * Math.PI * cutoff);
		return 1.0 / (1.0 + tau / te);
	}

	function setFrequency(f:Float):Void {
		if (f <= 0) {
			throw "freq should be >0";
		}
		freq = f;
	}

	function setMinCutoff(mc:Float):Void {
		if (mc <= 0) {
			throw "mincutoff should be >0";
		}
		mincutoff = mc;
	}

	function setBeta(b:Float):Void {
		beta_ = b;
	}

	function setDerivateCutoff(dc:Float):Void {
		if (dc <= 0) {
			throw "dcutoff should be >0";
		}
		dcutoff = dc;
	}

	public function new(freq:Float, mincutoff:Float = 1, beta_:Float = 0, dcutoff:Float = 1):Void {
		init(freq, mincutoff, beta_, dcutoff);
	}

	public function init(freq:Float, mincutoff:Float, beta_:Float, dcutoff:Float):Void {
		setFrequency(freq);
		setMinCutoff(mincutoff);
		setBeta(beta_);
		setDerivateCutoff(dcutoff);
		x = new LowPassFilter(alpha(mincutoff));
		dx = new LowPassFilter(alpha(dcutoff));
		lasttime = UndefinedTime;
	}

	public function filter(value:Float, timestamp:Float = UndefinedTime):Float {
		// update the sampling frequency based on timestamps
		if (lasttime != UndefinedTime && timestamp != UndefinedTime) {
			freq = 1.0 / (timestamp - lasttime);
		}
		
		lasttime = timestamp;
		// estimate the current variation per second
		var dvalue:Float = x.hasLastRawValue() ? (value - x.lastRawValue()) * freq : 0.0; // FIXME: 0.0 or value?
		var edvalue:Float = dx.filterWithAlpha(dvalue, alpha(dcutoff));
		// use it to update the cutoff frequency
		var cutoff:Float = mincutoff + beta_ * Math.abs(edvalue);
		// filter the given value
		return x.filterWithAlpha(value, alpha(cutoff));
	}
	
	static function main():Void {
		//randSeed();
		var duration:Float = 10.0;	// seconds
		var frequency:Float = 120;	// Hz
		var mincutoff:Float = 1.0;	// FIXME
		var beta:Float = 1.0;		// FIXME
		var dcutoff:Float = 1.0;	// this one should be ok
		
		trace(
				"#SRC OneEuroFilter.hx" + "\n"
				+ "#CFG {'beta': " + beta + ", 'freq': " + frequency + ", 'dcutoff': " + dcutoff + ", 'mincutoff': " + mincutoff + "}" + "\n"
				+ "#LOG timestamp, signal, noisy, filtered");

		var f = new OneEuroFilter(frequency, mincutoff, beta, dcutoff);
		var timestamp:Float = 0.0;
		while (timestamp < duration) {
			var signal:Float = Math.sin(timestamp);
			var noisy:Float = signal + (Math.random() - 0.5) / 5.0;
			var filtered:Float = f.filter(noisy, timestamp);
			trace(
					timestamp + ", "
					+ signal + ", "
					+ noisy + ", "
					+ filtered);
			timestamp += 1.0 / frequency;
		}
	}
}

class LowPassFilter {

	var y:Float;
	var a:Float;
	var s:Float;
	var initialized:Bool;

	function setAlpha(alpha:Float):Void {
		if (alpha <= 0.0 || alpha > 1.0) {
			throw "alpha should be in (0.0., 1.0]";
		}
		a = alpha;
	}

	public function new(alpha:Float, initval:Float = 0):Void {
		init(alpha, initval);
	}

	public function init(alpha:Float, initval:Float):Void {
		y = s = initval;
		setAlpha(alpha);
		initialized = false;
	}

	public function filter(value:Float):Float {
		var result:Float;
		if (initialized) {
			result = a * value + (1.0 - a) * s;
		} else {
			result = value;
			initialized = true;
		}
		y = value;
		s = result;
		return result;
	}

	inline public function filterWithAlpha(value:Float, alpha:Float):Float {
		setAlpha(alpha);
		return filter(value);
	}

	inline public function hasLastRawValue():Bool {
		return initialized;
	}

	inline public function lastRawValue():Float {
		return y;
	}
}