extends RefCounted
## Local aggregate counters only. No identifiers, network, SDK, or personal data.
var enabled:=false
var level: int=-1
var elapsed:=0.0
var data: Dictionary={}
var finished:=false
func begin(index: int,allow_write: bool) -> void:
	enabled=allow_write;level=index;elapsed=0;finished=false
	if not enabled:return
	if data.is_empty() and FileAccess.file_exists("user://playtest_metrics.json"):
		var saved=JSON.parse_string(FileAccess.get_file_as_string("user://playtest_metrics.json"))
		if saved is Dictionary:data=saved
	event("attempts")
func event(name: String) -> void:
	if not enabled or level<0:return
	var key:=str(level+1)
	var record: Dictionary=data.get(key,{})
	record[name]=int(record.get(name,0))+1;data[key]=record;save()
func result(won: bool,moves: int) -> void:
	if not enabled or finished:return
	finished=true
	event("wins" if won else "losses")
	var key:=str(level+1)
	data[key]["moves_total"]=int(data[key].get("moves_total",0))+moves
	data[key]["active_seconds_total"]=float(data[key].get("active_seconds_total",0))+elapsed
	save()
func save() -> void:
	var file:=FileAccess.open("user://playtest_metrics.json",FileAccess.WRITE)
	if file:file.store_string(JSON.stringify(data,"\t"))
