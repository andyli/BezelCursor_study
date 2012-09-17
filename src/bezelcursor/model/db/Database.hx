package bezelcursor.model.db;

import sys.db.*;

import bezelcursor.model.*;

class Database {
	public var connection:Connection;
	
	public function new():Void {
		connect();
		Manager.cnx = connection;
	}
	
	static public var current(get_current, null):Database;
	static public function get_current():Database {
		return current != null ? current : new Database();
	}
	
	public function connect():Void {
		connection = Mysql.connect(Env.mysql);
	}
}