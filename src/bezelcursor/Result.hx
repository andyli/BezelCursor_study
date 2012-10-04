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
	static public function main():Void {		
		var folder = "/Users/andy/Google Drive/CityU PhD/BezelCursor/UserStudyPart1_data/";
		
		var csv = new Array<Array<Dynamic>>();
		csv.push([
			"record.id",
			"record.user.name",
			"record.world",
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
			
			csv.push([
				record.id,
				record.user.name,
				record.world,
				numOfNext,
				record.inputMethod,
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