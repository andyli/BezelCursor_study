package bezelcursor;

using Lambda;
using StringTools;
import haxe.*;
import sys.*;
import sys.io.*;
import bezelcursor.model.*;
import hxLINQ.LINQ;
import thx.csv.*;

class Result {
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
	
	static public function main():Void {
		var combinations:Array<Array<Int>> = [];
		for (i in 0...4) combinations = com(combinations, 4);
		
		var comHash = new Hash();
		for (c in combinations) {
			comHash.set(c.join(","), 0);
		}
		
		var folder = "/Users/andy/Google Drive/CityU PhD/BezelCursor/UserStudyPart2_data/";
		
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
			"successTargetMeanTime"
		]);
		
		function isSucessCursorClick(e, i) {
			return e.event == "cursor-click" && e.data.target != null && e.data.isCurrent;
		}
		
		var record = new PlayRecord();
		
		for (file in FileSystem.readDirectory(folder)) {
			if (!file.endsWith(".txt")) continue;
			
			trace(file);

			record.fromString(File.getContent(folder + file).replace("Inf", "0").replace("NaN", "0"));			
			
			var userName:String = record.user.name;
			var numOfNext = new LINQ(record.events).count(function(e,i) return e.event == "next");
			var worldCompleteTime = new LINQ(record.events).last(function(e,i) return e.event == "end").time - new LINQ(record.events).first(function(e,i) return e.event == "begin").time;
			var targetMeanTime = worldCompleteTime / numOfNext;
			var successClicks = new LINQ(record.events).where(isSucessCursorClick);
			var successRate = successClicks.count() / numOfNext;
			var successTargetMeanTime = successClicks.average(function(e){
				var success_i = record.events.indexOf(e);
				return e.time - new LINQ(record.events).last(function(e,i) return i < success_i && e.event == "next").time;
			});
			
			var target = record.taskBlockData.targetQueue[0][0];
			var targetSize = target.width + "mm x " + target.height + "mm";
			
			csv.push([
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
			]);
			
			trace(file);
		}
		
		File.saveContent(folder + "result.csv", Csv.encode(csv));
		
		Sys.exit(0);
	}
}