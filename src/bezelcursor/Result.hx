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
		
		var folder = "/Users/andy/Google Drive/CityU PhD/BezelCursor/UserStudyPart1_data/";
		
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

			record.fromString(File.getContent(folder + file));			
			
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
				record.user.name,
				record.world,
				targetSize,
				numOfNext,
				record.inputMethod,
				worldCompleteTime,
				targetMeanTime,
				successRate,
				successTargetMeanTime
			]);
			
			trace(file);
		}
		
		var finishedUser = new LINQ(csv)
			.where(function(e,i) return e[4] == 36 && e[2] == "bezelcursor.world.TestTouchWorld")
			.groupBy(function(e) return e[1])
			.where(function(g,i) return g.count() == 8);
		
		var methods = [
			InputMethod.BezelCursor_acceleratedBubbleCursor.name,
			InputMethod.BezelCursor_directMappingBubbleCursor.name,
			InputMethod.BezelCursor_acceleratedDynaSpot.name,
			InputMethod.BezelCursor_directMappingDynaSpot.name
		];
		
		for (g in finishedUser) {
			var c = new LINQ(g).select(function(r) return methods.indexOf(r[5])).distinct(function(_) return _).array().join(",");
			comHash.set(c, comHash.get(c) + 1);
		}
		for (c in comHash.keys()) {
			switch(c.substr(0, 3)){
				case "0,1", "1,0", "2,3", "3,2":
				default: continue;
			}
			Sys.println(c + " " + comHash.get(c));
		}
		
		File.saveContent(folder + "result.csv", Csv.encode(csv));
		
		Sys.exit(0);
	}
}