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

			Json.parse(File.getContent(folder + file));
			trace(file);
		}
		
		var csv = new Array<Array<Dynamic>>();
		
		for (record in records) {
			
			/*
			var numOfNext = new LINQ(record.eventRecords).count(function(e:EventRecord, i) return e.event == "next");
			
			csv.push([record.id, record.user.name, record.world, numOfNext, record.inputMethod]);
			*/
		}
		
		/*
		var users = new LINQ(records).groupBy(function(r) return r.user);
		for (user in users) {
			trace(user + ": " + new LINQ(user).count());
		}
		*/
		
		Sys.exit(0);
	}
}