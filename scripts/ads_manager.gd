extends Node

signal banner_geometry_changed
var banner_height_pixels := 0
var banner_hidden := false

func set_banner_hidden(value: bool) -> void:
	banner_hidden=value
	if is_instance_valid(provider) and provider.banner:
		if value:provider.banner.hide()
		else:provider.banner.show()

signal reward_earned(request_id: int)
signal request_finished(request_id: int, earned: bool)
signal presentation_changed(showing: bool)

enum Result { COMPLETED, CANCELLED, UNAVAILABLE }
var pending_id := -1
var sequence := 0
var provider: Node
var configuration: Dictionary = {}
var last_result: int=Result.CANCELLED
var waiting_age:=0.0
var presentation_active:=false
func _process(delta: float) -> void:
	if pending_id<0 or presentation_active:return
	waiting_age+=delta
	if waiting_age>=15:
		var id:=pending_id
		if is_instance_valid(provider) and provider.active_id==id:provider.finish_video(id,Result.UNAVAILABLE)
		else:finish_reward(id,Result.UNAVAILABLE)
func mark_presented(id: int) -> void:
	if id==pending_id:presentation_active=true

func _ready() -> void:
	configuration = JSON.parse_string(FileAccess.get_file_as_string("res://assets/admob_config.json"))
	if OS.has_feature("android"):
		provider = preload("res://scripts/admob_provider.gd").new()
		provider.manager = self
		add_child(provider)

func get_ad_unit(format_name: String) -> String:
	var section := "google_demo" if bool(configuration.get("test_mode", true)) else "android"
	return str(configuration.get(section, {}).get(format_name + "_unit_id", ""))

# An Android adapter must emit earned ONLY from the SDK's earned-reward event.
# Closing, failing, or merely showing an ad must never grant a reward.
func begin_reward() -> int:
	if pending_id >= 0:
		return -1
	sequence += 1
	pending_id = sequence
	waiting_age=0;presentation_active=false
	return pending_id

func finish_reward(id: int, result: Result) -> void:
	if id < 0 or id != pending_id:
		return
	pending_id = -1
	last_result=result
	var earned := result == Result.COMPLETED
	if earned:
		reward_earned.emit(id)
	request_finished.emit(id, earned)

func request_provider(id: int) -> void:
	if is_instance_valid(provider):
		provider.call("show_rewarded", id)
	else:
		finish_reward(id, Result.UNAVAILABLE)
