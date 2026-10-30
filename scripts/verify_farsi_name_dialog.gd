extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	root.size=Vector2i(540,840)
	var g=load("res://main.tscn").instantiate();root.add_child(g);g.persistence_enabled=false;g.audio.set_enabled(false);g.audio.set_music_enabled(false);g.change_language("fa");g.show_menu("settings")
	preload("res://scripts/leaderboard_ui.gd").name_prompt(g,true)
	await process_frame;await process_frame
	var layer=g.get_node("PlayerNameOverlay")
	for child in layer.get_children():
		if child is Label or child is LineEdit:
			print(child.name," ",child.position," ",child.size)
			assert(child.position.x>=70 and child.position.x+child.size.x<=650)
	RenderingServer.force_draw();root.get_texture().get_image().save_png("res://video_work/farsi_name_dialog.png")
	g.free();print("PASS Persian name dialog content stays inside card");quit()
