extends SceneTree
func _initialize() -> void:
	print("Name: ",ProjectSettings.get_setting("application/config/name"))
	print("User data: ",OS.get_user_data_dir())
	assert(OS.get_user_data_dir().replace("\\","/").ends_with("/Godot/app_userdata/Cat Sort Lab"))
	print("Existing progress accessible: ",FileAccess.file_exists("user://progress.json"))
	quit()
