package bezelcursor;

using Lambda;
using StringTools;
import haxe.*;
import sys.*;
import sys.io.*;
import flash.geom.*;
import bezelcursor.model.*;
using bezelcursor.util.UnitUtil;
import hxLINQ.LINQ;
import thx.csv.*;
using org.casalib.util.NumberUtil;

class Result {
	inline static public var DATA_WIDTH = 720;
	inline static public var DATA_HEIGHT = 1280;
	
	static public function com(a:Array<Array<Int>>, i:Int):Array<Array<Int>> {
		var newA = [];
		if (a.length > 0) {
			for (e in a) {
				for (i in 0...i) {
					if (e.indexOf(i) >= 0) continue;
				
					newA.push(e.copy().concat([i]));
				}
			}
		} else {
			for (i in 0...i) {
				newA.push([i]);
			}
		}
		return newA;
	}
	
	static function genRegions(width:Int, height:Int):Array<Rectangle> {
		var regions = [];
		for (x in 0...width) {
			for (y in 0...height) {
				var region = new Rectangle(
					x.map(0, width, 0, DATA_WIDTH),
					y.map(0, height, 0, DATA_HEIGHT),
					DATA_WIDTH / width,
					DATA_HEIGHT / height
				);
				regions.push(region);
			}
		}
		
		return regions;
	}
	
	static public function main():Void {
		var combinations:Array<Array<Int>> = [];
		for (i in 0...4) combinations = com(combinations, 4);
		
		var comHash = new Hash();
		for (c in combinations) {
			comHash.set(c.join(","), 0);
		}
		
		var folder = "/Users/andy/Google Drive/CityU PhD/BezelCursor/UserStudyPart2_data/";
		
		
		var regions = genRegions(3,4);
		
		function isSucessCursorClick(e, i) {
			return e.event == "cursor-click" && e.data.target != null && e.data.isCurrent;
		}
		
		var record = new PlayRecord();
		
		for (i in 0...12) {
			var region = regions[i];
		
			var csv = new Array<Array<Dynamic>>();
			csv.push([
				"record.id",
				"record.user.name",
				"record.world",
				"targetSize",
				"numOfNext",
				"record.inputMethod",
				"worldCompleteTime",
				"targetMeanTime",
				"successRate",
				"successTargetMeanTime",
			]);
					
			for (file in FileSystem.readDirectory(folder)) {
				if (!file.endsWith(".txt")) continue;

				record.fromString(File.getContent(folder + file).replace("Inf", "0").replace("NaN", "0"));
			
				var userName:String = record.user.name;
				var numOfNext = new LINQ(record.events).count(function(e,i) return e.event == "next");
				var worldCompleteTime = new LINQ(record.events).last(function(e,i) return e.event == "end").time - new LINQ(record.events).first(function(e,i) return e.event == "begin").time;
				var targetMeanTime = worldCompleteTime / numOfNext;
				var target = record.taskBlockData.targetQueue[0][0];
				var targetSizeVal:Float = target.width;
				var targetSize = target.width + "mm x " + target.height + "mm";
				var successClicks, successRate, successTargetMeanTime;
			
				if (region == null) {
					successClicks = new LINQ(record.events).where(isSucessCursorClick);
					successRate = successClicks.count() / numOfNext;
					successTargetMeanTime = successClicks.average(function(e){
						var success_i = record.events.indexOf(e);
						return e.time - new LINQ(record.events).last(function(e,i) return i < success_i && e.event == "next").time;
					});
				} else {
					successClicks = new LINQ(record.events).where(function(e,i){
						return 
							e.event == "cursor-click" && e.data.isCurrent && e.data.target != null &&
							region.contains(e.data.target.x % DATA_WIDTH, e.data.target.y) &&
							Math.abs(e.data.target.width - targetSizeVal.mm2inches() * record.device.screenDPI) <= 1;
					});
					successRate = successClicks.count() / 3;
					successTargetMeanTime = successClicks.average(function(e){
						var success_i = record.events.indexOf(e);
						return e.time - new LINQ(record.events).last(function(e,i) return i < success_i && e.event == "next").time;
					});
				}
			
			
				var row = [
					record.id,
					userName.toLowerCase(),
					record.world,
					targetSize,
					numOfNext,
					record.inputMethod + (record.inputMethod != "ThumbSpace" && record.cursorManager.inputMethod.requireOverlayButton ? " (button)" : ""),
					worldCompleteTime,
					targetMeanTime,
					successRate,
					successTargetMeanTime
				];
			
				csv.push(row);
			
				trace(file);
			}
				
			var fileName = 'UserStudyPart2_data_${i}.csv';
			File.saveContent(folder + "../" + fileName, Csv.encode(csv));
			trace(fileName);
		}
		Sys.exit(0);
	}
}