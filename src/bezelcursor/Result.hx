package bezelcursor;

using StringTools;
import haxe.*;
import sys.*;
import sys.io.*;
import bezelcursor.model.*;
import hxLINQ.LINQ;
import thx.csv.*;

class Result {
	static public function main():Void {		
		var folder = "/Users/andy/Documents/workspace/bezelcursor/web/playrecord/";
		
		var records:Array<PlayRecord> = [];
		
		for (file in FileSystem.readDirectory(folder)) {
			if (!file.endsWith(".txt")) continue;

			records.push(PlayRecord.fromString(File.getContent(folder + file)));
			trace(file);
		}
		
		var csv = new Array<Array<Dynamic>>();
		csv.push(["record.id", "record.user.name", "record.world", "numOfNext", "record.inputMethod", "worldCompleteTime"]);
		for (record in records) {
			var numOfNext = new LINQ(record.events).count(function(e, i) return e.event == "next");
			var worldCompleteTime = new LINQ(record.events).last(function(e,i) return e.event == "end").time - new LINQ(record.events).first(function(e,i) return e.event == "begin").time;
			csv.push([record.id, record.user.name, record.world, numOfNext, record.inputMethod, worldCompleteTime]);
		}
		
		File.saveContent(folder + "result.csv", Csv.encode(csv));
		
		Sys.exit(0);
	}
}