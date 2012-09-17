package bezelcursor.model.db;

import sys.db.*;
import sys.db.Types;

class TaskBlockDataStore extends Object {
	public var id:SId;
	public var generateTime:STimeStamp;
	public var screenResolutionXInch:SFloat;
	public var screenResolutionYInch:SFloat;
	public var screenResolutionX:SFloat;
	public var screenResolutionY:SFloat;
	public var screenDPI:SFloat;
	public var taskBlockDatas:SData<Array<TaskBlockData>>;
	
	static public var manager(get_manager, null):Manager<TaskBlockDataStore>;
	static public function get_manager():Manager<TaskBlockDataStore> {
		if (manager != null) {
			return manager;
		} else {
			if (Database.current == null) throw "db not ready?";
			manager = new Manager<TaskBlockDataStore>(TaskBlockDataStore);
			if (!TableCreate.exists(manager)) {
				TableCreate.create(manager);
			}
			return manager;
		}
	}
}